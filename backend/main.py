"""
SenseAI Backend - Clinical Gaze Tracking for Autism Screening
==============================================================

FastAPI backend that:
1. Receives gaze tracking data from the Flutter app
2. Analyzes gaze patterns for autism markers
3. Generates clinical PDF reports with metrics and recommendations
"""

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import sqlite3
import uuid
import json
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.pdfgen import canvas
from reportlab.platypus import Table, TableStyle
from model import model as MODEL_WRAPPER
import os

DB_PATH = "data.db"
REPORTS_DIR = "reports"
os.makedirs(REPORTS_DIR, exist_ok=True)

app = FastAPI(
    title="SenseAI Gaze Analysis API",
    description="Clinical gaze tracking analysis for autism screening in children aged 2-6",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# Pydantic Models
# ============================================================

class ParentInfo(BaseModel):
    name: str
    email: str
    phone: str
    relationship: str


class ChildInfo(BaseModel):
    name: str
    age: int = Field(..., ge=1, le=18, description="Child's age (1-18 years)")
    test_datetime: str
    parent: Optional[ParentInfo] = None


class GazeEvent(BaseModel):
    """Flexible gaze event that accepts various formats from different games"""
    timestamp: float
    # Allow x/y or gaze_x/gaze_y (bubble game uses gaze_x/gaze_y for some events)
    x: Optional[float] = Field(None, description="Normalized X position")
    y: Optional[float] = Field(None, description="Normalized Y position")
    gaze_x: Optional[float] = Field(None, description="Alternative gaze X position")
    gaze_y: Optional[float] = Field(None, description="Alternative gaze Y position")
    target_x: Optional[float] = Field(None, description="Target stimulus X position")
    target_y: Optional[float] = Field(None, description="Target stimulus Y position")
    game: Optional[str] = Field(None, description="Game/task name")
    on_target: bool = False
    # Additional fields from bubble game
    event_type: Optional[str] = Field(None, description="Type of event")
    bubble_id: Optional[str] = Field(None, description="Bubble identifier")
    dwell_time: Optional[float] = Field(None, description="Time spent looking")
    pop_method: Optional[str] = Field(None, description="How bubble was popped")
    was_looking_at_bubble: Optional[bool] = Field(None, description="Was gaze on bubble")
    gaze_progress_at_pop: Optional[float] = Field(None, description="Gaze progress when popped")
    real_gaze: Optional[bool] = Field(None, description="Whether gaze data is real")
    
    class Config:
        extra = 'allow'  # Allow extra fields we haven't defined
    
    def get_x(self) -> float:
        """Get x coordinate from either x or gaze_x"""
        if self.x is not None:
            return max(0, min(1, self.x))
        if self.gaze_x is not None and self.gaze_x >= 0:
            return max(0, min(1, self.gaze_x))
        return 0.5  # Default to center
    
    def get_y(self) -> float:
        """Get y coordinate from either y or gaze_y"""
        if self.y is not None:
            return max(0, min(1, self.y))
        if self.gaze_y is not None and self.gaze_y >= 0:
            return max(0, min(1, self.gaze_y))
        return 0.5  # Default to center


class GazeBatch(BaseModel):
    test_id: str
    events: List[GazeEvent]


class AnalysisResult(BaseModel):
    test_id: str
    score: float
    scores: Dict[str, Any]
    metrics: Dict[str, Any]
    interpretation: Dict[str, Any]
    report_path: str


# ============================================================
# Database Functions
# ============================================================

def init_db():
    """Initialize SQLite database with enhanced schema"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Check if table exists
    c.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='tests'")
    table_exists = c.fetchone() is not None
    
    if table_exists:
        # Check if we need to migrate (add missing columns)
        c.execute("PRAGMA table_info(tests)")
        columns = [col[1] for col in c.fetchall()]
        
        if 'scores_json' not in columns:
            print("Migrating database: adding scores_json column")
            c.execute("ALTER TABLE tests ADD COLUMN scores_json TEXT")
        if 'metrics_json' not in columns:
            print("Migrating database: adding metrics_json column")
            c.execute("ALTER TABLE tests ADD COLUMN metrics_json TEXT")
        if 'interpretation_json' not in columns:
            print("Migrating database: adding interpretation_json column")
            c.execute("ALTER TABLE tests ADD COLUMN interpretation_json TEXT")
        if 'raw_events' not in columns:
            print("Migrating database: adding raw_events column")
            c.execute("ALTER TABLE tests ADD COLUMN raw_events TEXT")
        if 'parent_name' not in columns:
            print("Migrating database: adding parent_name column")
            c.execute("ALTER TABLE tests ADD COLUMN parent_name TEXT")
        if 'parent_email' not in columns:
            print("Migrating database: adding parent_email column")
            c.execute("ALTER TABLE tests ADD COLUMN parent_email TEXT")
        if 'parent_phone' not in columns:
            print("Migrating database: adding parent_phone column")
            c.execute("ALTER TABLE tests ADD COLUMN parent_phone TEXT")
        if 'parent_relationship' not in columns:
            print("Migrating database: adding parent_relationship column")
            c.execute("ALTER TABLE tests ADD COLUMN parent_relationship TEXT")
    else:
        # Create new table with full schema
        c.execute("""
            CREATE TABLE IF NOT EXISTS tests (
                id TEXT PRIMARY KEY,
                name TEXT,
                age INTEGER,
                test_datetime TEXT,
                created_at TEXT,
                score REAL,
                scores_json TEXT,
                metrics_json TEXT,
                interpretation_json TEXT,
                raw_events TEXT,
                parent_name TEXT,
                parent_email TEXT,
                parent_phone TEXT,
                parent_relationship TEXT
            )
        """)
    
    conn.commit()
    conn.close()
    print("Database initialized successfully")


def save_test_record(test_id: str, info: dict, analysis: dict, events_json: str):
    """Save complete test record with analysis results"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # Extract parent info from nested structure or direct fields
    parent = info.get("parent") or {}
    if not isinstance(parent, dict):
        parent = {}
    
    parent_name = info.get("parent_name") or parent.get("name")
    parent_email = info.get("parent_email") or parent.get("email")
    parent_phone = info.get("parent_phone") or parent.get("phone")
    parent_relationship = info.get("parent_relationship") or parent.get("relationship")
    
    c.execute("""
        INSERT OR REPLACE INTO tests 
        (id, name, age, test_datetime, created_at, score, scores_json, metrics_json, interpretation_json, raw_events,
         parent_name, parent_email, parent_phone, parent_relationship) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        test_id,
        info.get("name"),
        info.get("age"),
        info.get("test_datetime"),
        datetime.utcnow().isoformat(),
        analysis.get('score', 0.0),
        json.dumps(analysis.get('scores', {})),
        json.dumps(analysis.get('metrics', {})),
        json.dumps(analysis.get('interpretation', {})),
        events_json,
        parent_name,
        parent_email,
        parent_phone,
        parent_relationship,
    ))
    conn.commit()
    conn.close()


def get_test_record(test_id: str) -> Optional[dict]:
    """Retrieve test record from database - OPTIMIZED (skip raw_events for PDF)"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    # Don't load raw_events for PDF generation - it's huge and not needed
    c.execute("""
        SELECT name, age, test_datetime, created_at, score, 
               scores_json, metrics_json, interpretation_json,
               parent_name, parent_email, parent_phone, parent_relationship
        FROM tests WHERE id = ?
    """, (test_id,))
    row = c.fetchone()
    conn.close()
    
    if not row:
        return None
    
    # Fast JSON parsing with error handling
    try:
        scores = json.loads(row[5]) if row[5] else {}
    except:
        scores = {}
    
    try:
        metrics = json.loads(row[6]) if row[6] else {}
    except:
        metrics = {}
    
    try:
        interpretation = json.loads(row[7]) if row[7] else {}
    except:
        interpretation = {}
    
    return {
        'name': row[0] or 'Unknown',
        'age': row[1] or 0,
        'test_datetime': row[2] or 'Unknown',
        'created_at': row[3] or datetime.utcnow().isoformat(),
        'score': row[4] or 0,
        'scores': scores,
        'metrics': metrics,
        'interpretation': interpretation,
        'raw_events': [],  # Not needed for PDF
        'parent_name': row[8] if len(row) > 8 else None,
        'parent_email': row[9] if len(row) > 9 else None,
        'parent_phone': row[10] if len(row) > 10 else None,
        'parent_relationship': row[11] if len(row) > 11 else None,
    }


# ============================================================
# PDF Report Generation
# ============================================================

def generate_clinical_pdf_report(test_id: str, dest_path: str):
    """
    Generate comprehensive clinical PDF report - OPTIMIZED VERSION
    - Child information
    - Overall and domain-specific scores
    - Clinical metrics
    - Interpretation and recommendations
    """
    try:
        print(f"[PDF] ===== Starting PDF generation for {test_id} =====")
        import time
        start_time = time.time()
        
        # Fast database query - only get what we need
        print(f"[PDF] Loading test record from database...")
        record = get_test_record(test_id)
        if not record:
            raise ValueError(f"Test not found: {test_id}")
        
        load_time = time.time() - start_time
        print(f"[PDF] Record loaded in {load_time:.2f}s")
        
        # Validate essential data exists
        if not record.get('name'):
            record['name'] = 'Unknown'
        if not record.get('score'):
            record['score'] = 0
        if not record.get('scores'):
            record['scores'] = {}
        if not record.get('metrics'):
            record['metrics'] = {}
        if not record.get('interpretation'):
            record['interpretation'] = {}
        
        print(f"[PDF] Record validated: name={record.get('name')}, score={record.get('score')}")
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        
        # Delete old file if exists (to avoid corruption)
        if os.path.exists(dest_path):
            try:
                os.remove(dest_path)
            except:
                pass
        
        print(f"[PDF] Creating canvas for {test_id} -> {dest_path}")
        canvas_start = time.time()
        c = canvas.Canvas(dest_path, pagesize=letter)
        width, height = letter
        margin = 0.75 * inch
        
        # ---- Page 1: Summary ----
        y = height - margin
        
        # Header
        c.setFillColor(colors.HexColor('#2E86AB'))
        c.rect(0, height - 1.5 * inch, width, 1.5 * inch, fill=True, stroke=False)
        
        c.setFillColor(colors.white)
        c.setFont("Helvetica-Bold", 24)
        c.drawString(margin, height - inch, "SenseAI Gaze Assessment Report")
        
        c.setFont("Helvetica", 12)
        c.drawString(margin, height - 1.25 * inch, "Clinical Gaze Pattern Analysis for Autism Screening")
        
        y = height - 2 * inch
        
        # Child Information Box
        c.setFillColor(colors.HexColor('#F5F5F5'))
        c.rect(margin, y - 1.2 * inch, width - 2 * margin, 1.2 * inch, fill=True, stroke=False)
        
        c.setFillColor(colors.black)
        c.setFont("Helvetica-Bold", 14)
        c.drawString(margin + 10, y - 0.3 * inch, "Child Information")
        
        c.setFont("Helvetica", 11)
        c.drawString(margin + 10, y - 0.55 * inch, f"Name: {record['name']}")
        c.drawString(margin + 200, y - 0.55 * inch, f"Age: {record['age']} years")
        c.drawString(margin + 10, y - 0.8 * inch, f"Test Date: {record['test_datetime']}")
        c.drawString(margin + 10, y - 1.05 * inch, f"Report Generated: {record['created_at'][:10]}")
        
        y -= 1.6 * inch
        
        # Parent Information Box (only show if parent info exists)
        parent_name = record.get('parent_name')
        parent_email = record.get('parent_email')
        parent_phone = record.get('parent_phone')
        parent_relationship = record.get('parent_relationship')
        
        # Only show parent section if at least name is provided
        if parent_name:
            c.setFillColor(colors.HexColor('#F5F5F5'))
            c.rect(margin, y - 1.2 * inch, width - 2 * margin, 1.2 * inch, fill=True, stroke=False)
            
            c.setFillColor(colors.black)
            c.setFont("Helvetica-Bold", 14)
            c.drawString(margin + 10, y - 0.3 * inch, "Parent Information")
            
            c.setFont("Helvetica", 11)
            c.drawString(margin + 10, y - 0.55 * inch, f"Name: {parent_name or 'N/A'}")
            c.drawString(margin + 200, y - 0.55 * inch, f"Relationship: {parent_relationship or 'N/A'}")
            c.drawString(margin + 10, y - 0.8 * inch, f"Email: {parent_email or 'N/A'}")
            c.drawString(margin + 10, y - 1.05 * inch, f"Phone: {parent_phone or 'N/A'}")
            
            y -= 1.6 * inch
        
        # Overall Score (large display)
        score = record.get('score', 0)
        # Ensure score is a valid number
        if score is None:
            score = 0.0
        score = float(score)
        
        scores = record.get('scores', {})
        risk_category = scores.get('risk_category', 'Unknown')
        
        # Score color based on risk - includes all ranges including below 50%
        if score >= 80:
            score_color = colors.HexColor('#28A745')  # Green
        elif score >= 60:
            score_color = colors.HexColor('#FFC107')  # Yellow
        elif score >= 40:
            score_color = colors.HexColor('#FD7E14')  # Orange
        elif score >= 20:
            score_color = colors.HexColor('#DC3545')  # Red
        else:
            score_color = colors.HexColor('#8B0000')  # Dark red for very low scores (< 20%)
        
        c.setFillColor(score_color)
        c.circle(margin + 0.75 * inch, y - 0.5 * inch, 0.6 * inch, fill=True, stroke=False)
        
        c.setFillColor(colors.white)
        c.setFont("Helvetica-Bold", 28)
        # Always show score with 1 decimal place for accuracy, including low scores
        score_display = f"{score:.1f}"
        c.drawCentredString(margin + 0.75 * inch, y - 0.6 * inch, score_display)
        
        c.setFillColor(colors.black)
        c.setFont("Helvetica-Bold", 16)
        c.drawString(margin + 1.8 * inch, y - 0.3 * inch, "Overall Gaze Score")
        
        c.setFont("Helvetica", 12)
        c.setFillColor(score_color)
        # Display risk category, or show score range if category is missing
        if risk_category == 'Unknown' or not risk_category:
            if score >= 80:
                risk_category = "Low Risk"
            elif score >= 60:
                risk_category = "Moderate Risk"
            elif score >= 40:
                risk_category = "Elevated Risk"
            elif score >= 20:
                risk_category = "High Risk"
            else:
                risk_category = "Very High Risk"
        c.drawString(margin + 1.8 * inch, y - 0.55 * inch, risk_category)
        
        # Add score percentage label for clarity
        c.setFont("Helvetica", 10)
        c.setFillColor(colors.grey)
        c.drawString(margin + 1.8 * inch, y - 0.75 * inch, f"Score: {score:.2f}%")
        
        y -= 1.4 * inch
        
        # Domain Scores Table
        c.setFillColor(colors.black)
        c.setFont("Helvetica-Bold", 14)
        c.drawString(margin, y, "Domain Scores")
        y -= 0.3 * inch
        
        domain_scores = [
            ("Attention to Target", scores.get('attention_score', 0)),
            ("Fixation Patterns", scores.get('fixation_score', 0)),
            ("Visual Exploration", scores.get('exploration_score', 0)),
            ("Smooth Pursuit/Tracking", scores.get('tracking_score', 0)),
            ("Attention Flexibility", scores.get('flexibility_score', 0)),
        ]
        
        for domain, dscore in domain_scores:
            # Ensure score is valid (handle None or missing values)
            if dscore is None:
                dscore = 0.0
            dscore = float(dscore)
            
            # Progress bar background
            c.setFillColor(colors.HexColor('#E9ECEF'))
            c.rect(margin, y - 0.15 * inch, 4 * inch, 0.25 * inch, fill=True, stroke=False)
            
            # Progress bar fill - ensure minimum width for visibility (even for 0%)
            bar_width = max(0.05 * inch, (dscore / 100) * 4 * inch)  # Minimum 0.05 inch width
            
            # Color coding for all score ranges
            if dscore >= 70:
                bar_color = colors.HexColor('#28A745')  # Green
            elif dscore >= 50:
                bar_color = colors.HexColor('#FFC107')  # Yellow
            elif dscore >= 30:
                bar_color = colors.HexColor('#FD7E14')  # Orange
            elif dscore >= 10:
                bar_color = colors.HexColor('#DC3545')  # Red
            else:
                bar_color = colors.HexColor('#8B0000')  # Dark red for very low scores
            
            c.setFillColor(bar_color)
            c.rect(margin, y - 0.15 * inch, bar_width, 0.25 * inch, fill=True, stroke=False)
            
            # Score text - always visible, formatted clearly
            c.setFillColor(colors.black)
            c.setFont("Helvetica-Bold", 10)
            # Format score with 1 decimal place, always show percentage
            score_text = f"{dscore:.1f}%"
            c.drawString(margin + 4.2 * inch, y - 0.1 * inch, score_text)
            
            # Domain name
            c.setFont("Helvetica", 10)
            c.drawString(margin, y + 0.15 * inch, domain)
            
            y -= 0.5 * inch
        
        y -= 0.3 * inch
        
        # Data Quality Warning (if applicable)
        scores_data = record.get('scores', {})
        if scores_data.get('data_quality_warning'):
            c.setFillColor(colors.HexColor('#FFC107'))
            c.rect(margin, y - 0.4 * inch, width - 2 * margin, 0.4 * inch, fill=True, stroke=False)
            c.setFillColor(colors.black)
            c.setFont("Helvetica-Bold", 11)
            c.drawString(margin + 0.1 * inch, y - 0.15 * inch, "⚠ Data Quality Notice:")
            c.setFont("Helvetica", 10)
            quality_issues = scores_data.get('data_quality_issues', [])
            issue_text = "Some data quality issues were detected. Results should be interpreted with caution."
            if quality_issues:
                issue_text += f" Issues: {', '.join(quality_issues)}."
            c.drawString(margin + 0.1 * inch, y - 0.3 * inch, issue_text)
            y -= 0.5 * inch
        
        # Interpretation Summary
        interpretation = record.get('interpretation', {})
        summary = interpretation.get('summary', 'No interpretation available.')
        
        c.setFont("Helvetica-Bold", 14)
        c.drawString(margin, y, "Clinical Summary")
        y -= 0.25 * inch
        
        c.setFont("Helvetica", 10)
        # Simplified word wrap for summary (limit to prevent hanging)
        words = summary.split()[:200]  # Limit words to prevent issues
        line = ""
        max_width = width - 2 * margin
        line_count = 0
        max_lines = 15  # Limit lines to prevent overflow
        for word in words:
            if line_count >= max_lines:
                break
            test_line = line + word + " "
            if c.stringWidth(test_line, "Helvetica", 10) < max_width:
                line = test_line
            else:
                if line.strip():
                    c.drawString(margin, y, line.strip())
                    y -= 0.2 * inch
                    line_count += 1
                line = word + " "
        if line and line_count < max_lines:
            c.drawString(margin, y, line.strip())
            y -= 0.2 * inch
        
        # ---- Page 2: Detailed Analysis ----
        c.showPage()
        y = height - margin
        
        c.setFont("Helvetica-Bold", 16)
        c.drawString(margin, y, "Detailed Analysis")
        y -= 0.5 * inch
        
        # Metrics
        metrics = record.get('metrics', {})
        
        c.setFont("Helvetica-Bold", 12)
        c.drawString(margin, y, "Gaze Metrics")
        y -= 0.3 * inch
        
        # Format metrics with proper handling of low/zero values
        def format_metric(value, format_type='float'):
            if value is None:
                return 'N/A'
            if format_type == 'float':
                return f"{float(value):.2f}"
            elif format_type == 'int':
                return f"{int(value)}"
            elif format_type == 'percent':
                return f"{float(value):.2f}%"
            else:
                return str(value)
        
        metric_items = [
            ("Total Test Duration", format_metric(metrics.get('total_duration', 0), 'float') + " seconds"),
            ("Total Gaze Events", format_metric(metrics.get('total_events', 0), 'int')),
            ("Valid Events", format_metric(metrics.get('valid_events', 0), 'int')),
            ("Fixations Detected", format_metric(metrics.get('fixation_count', 0), 'int')),
            ("Mean Fixation Duration", format_metric(metrics.get('mean_fixation_duration', 0) * 1000, 'float') + " ms"),
            ("Saccades Detected", format_metric(metrics.get('saccade_count', 0), 'int')),
            ("Time on Target", format_metric(metrics.get('time_on_target', 0), 'percent')),
            ("Gaze Dispersion", format_metric(metrics.get('gaze_dispersion', 0), 'float')),
            ("Preferred Region", str(metrics.get('preferred_region', 'N/A'))),
        ]
        
        c.setFont("Helvetica", 10)
        for label, value in metric_items:
            c.drawString(margin, y, f"{label}:")
            c.drawString(margin + 2.5 * inch, y, value)
            y -= 0.22 * inch
        
        y -= 0.3 * inch
        
        # Findings
        findings = interpretation.get('findings', [])
        if findings:
            c.setFont("Helvetica-Bold", 12)
            c.drawString(margin, y, "Clinical Findings")
            y -= 0.25 * inch
            
            c.setFont("Helvetica", 10)
            findings_count = 0
            max_findings = 10  # Limit findings
            for finding in findings[:max_findings]:
                if y < margin + 1 * inch:  # Prevent overflow
                    break
                findings_count += 1
                # Bullet point
                c.drawString(margin, y, "•")
                # Simplified word wrap (limit words)
                words = finding.split()[:50]
                line = ""
                first_line = True
                line_count = 0
                max_lines_per_finding = 3
                for word in words:
                    if line_count >= max_lines_per_finding:
                        break
                    test_line = line + word + " "
                    if c.stringWidth(test_line, "Helvetica", 10) < (width - 2 * margin - 0.3 * inch):
                        line = test_line
                    else:
                        if line.strip():
                            c.drawString(margin + 0.2 * inch, y, line.strip())
                            y -= 0.2 * inch
                            line_count += 1
                            first_line = False
                        line = word + " "
                if line and line_count < max_lines_per_finding:
                    c.drawString(margin + 0.2 * inch, y, line.strip())
                y -= 0.3 * inch
        
        y -= 0.2 * inch
        
        # Recommendations
        recommendations = interpretation.get('recommendations', [])
        if recommendations:
            c.setFont("Helvetica-Bold", 12)
            c.drawString(margin, y, "Recommendations")
            y -= 0.25 * inch
            
            c.setFont("Helvetica", 10)
            max_recommendations = 8  # Limit recommendations
            for i, rec in enumerate(recommendations[:max_recommendations], 1):
                if y < margin + 1 * inch:  # Prevent overflow
                    break
                c.drawString(margin, y, f"{i}.")
                # Simplified word wrap (limit words)
                words = rec.split()[:50]
                line = ""
                first_line = True
                line_count = 0
                max_lines_per_rec = 3
                for word in words:
                    if line_count >= max_lines_per_rec:
                        break
                    test_line = line + word + " "
                    if c.stringWidth(test_line, "Helvetica", 10) < (width - 2 * margin - 0.3 * inch):
                        line = test_line
                    else:
                        if line.strip():
                            c.drawString(margin + 0.25 * inch, y, line.strip())
                            y -= 0.2 * inch
                            line_count += 1
                            first_line = False
                        line = word + " "
                if line and line_count < max_lines_per_rec:
                    c.drawString(margin + 0.25 * inch, y, line.strip())
                y -= 0.35 * inch
        
        # Disclaimer
        y = margin + 0.5 * inch
        c.setFont("Helvetica-Oblique", 8)
        c.setFillColor(colors.gray)
        disclaimer = ("DISCLAIMER: This screening tool is not diagnostic. Results should be interpreted by "
                      "qualified healthcare professionals. A low score does not confirm autism spectrum disorder, "
                      "and a high score does not rule it out. Please consult with a developmental specialist for "
                      "comprehensive evaluation.")
        
        # Simplified word wrap disclaimer (limit to prevent hanging)
        words = disclaimer.split()[:100]
        line = ""
        y = 0.8 * inch
        line_count = 0
        max_disclaimer_lines = 8
        for word in words:
            if line_count >= max_disclaimer_lines:
                break
            test_line = line + word + " "
            if c.stringWidth(test_line, "Helvetica-Oblique", 8) < (width - 2 * margin):
                line = test_line
            else:
                if line.strip():
                    c.drawString(margin, y, line.strip())
                    y -= 0.15 * inch
                    line_count += 1
                line = word + " "
        if line and line_count < max_disclaimer_lines:
            c.drawString(margin, y, line.strip())
        
        # Save the PDF
        print(f"[PDF] Saving canvas to {dest_path}...")
        save_start = time.time()
        try:
            c.save()
        except Exception as save_error:
            print(f"[PDF] ERROR during canvas.save(): {save_error}")
            import traceback
            traceback.print_exc()
            raise
        save_time = time.time() - save_start
        print(f"[PDF] Canvas saved in {save_time:.2f}s")
        
        # Verify file was created and is not empty
        if not os.path.exists(dest_path):
            raise Exception(f"PDF file was not created at {dest_path}")
        
        file_size = os.path.getsize(dest_path)
        print(f"[PDF] File exists, size: {file_size} bytes")
        if file_size == 0:
            raise Exception(f"PDF file is empty (0 bytes) at {dest_path}")
        
        total_time = time.time() - start_time
        print(f"[PDF] ===== PDF file created successfully in {total_time:.2f}s: {dest_path} ({file_size} bytes) =====")
    except Exception as e:
        print(f"[PDF] ERROR in generate_clinical_pdf_report: {e}")
        import traceback
        traceback.print_exc()
        # Clean up partial file
        if os.path.exists(dest_path):
            try:
                os.remove(dest_path)
            except:
                pass
        raise


# ============================================================
# API Endpoints
# ============================================================

@app.on_event("startup")
def startup():
    init_db()


@app.get("/")
def root():
    return {
        "name": "SenseAI Gaze Analysis API",
        "version": "2.0.0",
        "description": "Clinical gaze pattern analysis for autism screening"
    }


@app.post("/submit_info")
def submit_info(info: ChildInfo):
    """Create a new test session for a child"""
    test_id = str(uuid.uuid4())
    # Create placeholder record with parent info
    info_dict = info.dict()
    save_test_record(test_id, info_dict, {'score': 0}, json.dumps([]))
    return {"test_id": test_id, "message": f"Test session created for {info.name}"}


def _generate_pdf_background(test_id: str):
    """Background task to generate PDF report - SIMPLIFIED (no threading)"""
    dest = os.path.join(REPORTS_DIR, f"{test_id}.pdf")
    
    try:
        print(f"[BACKGROUND] Starting PDF generation for test_id: {test_id}")
        
        # Check if test record exists
        record = get_test_record(test_id)
        if not record:
            raise ValueError(f"Test record not found for test_id: {test_id}")
        
        print(f"[BACKGROUND] Test record found, generating PDF...")
        # Generate PDF directly (no threading - simpler and faster)
        generate_clinical_pdf_report(test_id, dest)
        
        # Verify file was created
        if not os.path.exists(dest):
            raise Exception(f"PDF file was not created at {dest}")
        
        file_size = os.path.getsize(dest)
        if file_size <= 100:
            raise Exception(f"PDF file is too small ({file_size} bytes)")
        
        print(f"[BACKGROUND] PDF generation successful: {dest} ({file_size} bytes)")
    except Exception as e:
        print(f"[BACKGROUND] ERROR generating PDF: {e}")
        import traceback
        traceback.print_exc()
        
        # Create error PDF so user knows what happened
        try:
            from reportlab.pdfgen import canvas
            from reportlab.lib.pagesizes import letter
            from reportlab.lib import colors
            
            c = canvas.Canvas(dest, pagesize=letter)
            c.setFillColor(colors.red)
            c.setFont("Helvetica-Bold", 16)
            c.drawString(100, 700, "Error Generating Report")
            c.setFillColor(colors.black)
            c.setFont("Helvetica", 12)
            c.drawString(100, 680, f"Test ID: {test_id}")
            c.drawString(100, 660, f"Error: {str(e)[:200]}")
            c.drawString(100, 640, "Please try again or contact support.")
            c.save()
            print(f"[BACKGROUND] Created error report at {dest}")
        except Exception as create_error:
            print(f"[BACKGROUND] Could not create error report: {create_error}")
                
        except Exception as e:
            print(f"ERROR generating PDF report (attempt {attempt + 1}): {e}")
            import traceback
            traceback.print_exc()
            
            if attempt < max_retries - 1:
                print(f"Retrying PDF generation in 2 seconds...")
                import time
                time.sleep(2)
            else:
                print(f"Failed to generate PDF after {max_retries} attempts")
                # Create a minimal error PDF or log the failure
                try:
                    # Try to create a simple error report
                    from reportlab.pdfgen import canvas
                    from reportlab.lib.pagesizes import letter
                    c = canvas.Canvas(dest, pagesize=letter)
                    c.drawString(100, 700, f"Error generating report for test: {test_id}")
                    c.drawString(100, 680, f"Error: {str(e)}")
                    c.save()
                    print(f"Created error report at {dest}")
                except:
                    print(f"Could not create error report")


@app.post("/upload_gaze", response_model=None)
def upload_gaze(batch: GazeBatch, background_tasks: BackgroundTasks):
    """
    Upload gaze events and receive clinical analysis.
    
    The gaze events are analyzed for:
    - Fixation patterns
    - Saccade characteristics  
    - Attention metrics
    - Smooth pursuit ability
    
    Returns overall score, domain scores, and clinical interpretation.
    PDF generation happens in the background for faster response.
    """
    # Verify test exists
    record = get_test_record(batch.test_id)
    if not record:
        raise HTTPException(status_code=404, detail="Test ID not found")
    
    # Convert events to dict and normalize x/y coordinates
    # Limit events to recent ones if too many (optimization)
    events = []
    for e in batch.events:
        event_dict = e.dict()
        # Ensure x and y are always present using helper methods
        event_dict['x'] = e.get_x()
        event_dict['y'] = e.get_y()
        events.append(event_dict)
    
    # Limit to last 2000 events if too many (for performance)
    if len(events) > 2000:
        events = events[-2000:]
        print(f"Limited events to 2000 for faster analysis (had {len(batch.events)})")
    
    # Run clinical analysis
    analysis = MODEL_WRAPPER.infer(events)
    
    # Save results with parent info
    info = {
        'name': record['name'],
        'age': record['age'],
        'test_datetime': record['test_datetime'],
        'parent': {
            'name': record.get('parent_name'),
            'email': record.get('parent_email'),
            'phone': record.get('parent_phone'),
            'relationship': record.get('parent_relationship'),
        }
    }
    save_test_record(batch.test_id, info, analysis, json.dumps(events))
    
    # Generate PDF report in background (non-blocking)
    dest = os.path.join(REPORTS_DIR, f"{batch.test_id}.pdf")
    background_tasks.add_task(_generate_pdf_background, batch.test_id)
    
    return {
        "test_id": batch.test_id,
        "score": analysis.get('score', 0),
        "scores": analysis.get('scores', {}),
        "metrics": analysis.get('metrics', {}),
        "interpretation": analysis.get('interpretation', {}),
        "report_path": dest,
        "message": "Analysis complete. PDF report is being generated in the background."
    }


@app.get("/test/{test_id}")
def get_test(test_id: str):
    """Get full test results"""
    record = get_test_record(test_id)
    if not record:
        raise HTTPException(status_code=404, detail="Test not found")
    
    # Don't return raw events (too large)
    record_copy = dict(record)
    record_copy['raw_events'] = f"{len(record.get('raw_events', []))} events"
    
    return record_copy


@app.get("/report/{test_id}")
def get_report(test_id: str):
    """Get report file path"""
    path = os.path.join(REPORTS_DIR, f"{test_id}.pdf")
    if not os.path.exists(path):
        raise HTTPException(status_code=404, detail="Report not found")
    return {"report_path": path}


@app.get("/report/{test_id}/status")
def get_report_status(test_id: str):
    """Check if PDF report is ready"""
    path = os.path.join(REPORTS_DIR, f"{test_id}.pdf")
    exists = os.path.exists(path)
    
    # Check if file is valid (not empty and not being written)
    is_valid = False
    if exists:
        try:
            file_size = os.path.getsize(path)
            is_valid = file_size > 100  # At least 100 bytes (minimal valid PDF)
        except:
            is_valid = False
    
    return {
        "ready": is_valid,
        "test_id": test_id,
        "exists": exists,
        "message": "Report is ready" if is_valid else ("Report is being generated" if exists else "Report not found")
    }


@app.get("/report/{test_id}/download")
def download_report(test_id: str, background_tasks: BackgroundTasks, force_regenerate: bool = False):
    """Download PDF report - generates on-demand if missing - OPTIMIZED WITH TIMEOUT"""
    import signal
    import threading
    
    path = os.path.join(REPORTS_DIR, f"{test_id}.pdf")
    
    # Check if valid report exists
    if os.path.exists(path) and not force_regenerate:
        try:
            file_size = os.path.getsize(path)
            if file_size > 100:
                print(f"[DOWNLOAD] Returning existing PDF: {path} ({file_size} bytes)")
                return FileResponse(
                    path, 
                    media_type="application/pdf", 
                    filename=f"SenseAI_Report_{test_id[:8]}.pdf"
                )
        except Exception as e:
            print(f"[DOWNLOAD] Error checking existing file: {e}")
    
    # Generate PDF now - with timeout protection
    print(f"[DOWNLOAD] Generating PDF for test_id: {test_id}")
    record = get_test_record(test_id)
    if not record:
        print(f"[DOWNLOAD] ERROR: Test record not found for test_id: {test_id}")
        raise HTTPException(status_code=404, detail="Test record not found")
    
    try:
        print(f"[DOWNLOAD] Calling generate_clinical_pdf_report for test_id: {test_id}")
        
        # Generate PDF with timeout (30 seconds max)
        generation_complete = threading.Event()
        generation_error = [None]
        
        def generate():
            try:
                generate_clinical_pdf_report(test_id, path)
                generation_complete.set()
            except Exception as e:
                generation_error[0] = e
                generation_complete.set()
        
        gen_thread = threading.Thread(target=generate, daemon=True)
        gen_thread.start()
        gen_thread.join(timeout=30.0)  # 30 second timeout
        
        if not generation_complete.is_set():
            raise TimeoutError("PDF generation timed out after 30 seconds")
        
        if generation_error[0]:
            raise generation_error[0]
        
        # Verify file was created
        if not os.path.exists(path):
            raise Exception("PDF file was not created after generation")
        
        file_size = os.path.getsize(path)
        if file_size <= 100:
            raise Exception(f"PDF file is too small ({file_size} bytes)")
        
        print(f"[DOWNLOAD] PDF generated successfully: {path} ({file_size} bytes)")
        return FileResponse(
            path, 
            media_type="application/pdf", 
            filename=f"SenseAI_Report_{test_id[:8]}.pdf"
        )
    except TimeoutError as e:
        print(f"[DOWNLOAD] TIMEOUT in PDF generation: {e}")
        raise HTTPException(status_code=504, detail="PDF generation timed out. Please try again.")
    except Exception as e:
        print(f"[DOWNLOAD] ERROR in PDF generation: {e}")
        import traceback
        traceback.print_exc()
        
        # Fallback: trigger background generation
        print(f"[DOWNLOAD] Triggering background generation as fallback")
        background_tasks.add_task(_generate_pdf_background, test_id)
        raise HTTPException(
            status_code=202,
            detail="Report generation started in background. Please check status and retry in a few seconds."
        )


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "model_loaded": MODEL_WRAPPER is not None}
