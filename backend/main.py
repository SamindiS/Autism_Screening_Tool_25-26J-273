"""
SenseAI Backend - Clinical Gaze Tracking for Autism Screening
==============================================================

FastAPI backend that:
1. Receives gaze tracking data from the Flutter app
2. Analyzes gaze patterns for autism markers
3. Generates clinical PDF reports with metrics and recommendations
"""

from fastapi import FastAPI, HTTPException
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

from routes.social_object import router as social_object_router
app.include_router(social_object_router)


# ============================================================
# Pydantic Models
# ============================================================

class ChildInfo(BaseModel):
    name: str
    age: int = Field(..., ge=1, le=18, description="Child's age (1-18 years)")
    test_datetime: str


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
                raw_events TEXT
            )
        """)
    
    conn.commit()
    conn.close()
    print("Database initialized successfully")


def save_test_record(test_id: str, info: dict, analysis: dict, events_json: str):
    """Save complete test record with analysis results"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("""
        INSERT OR REPLACE INTO tests 
        (id, name, age, test_datetime, created_at, score, scores_json, metrics_json, interpretation_json, raw_events) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
    ))
    conn.commit()
    conn.close()


def get_test_record(test_id: str) -> Optional[dict]:
    """Retrieve test record from database"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("""
        SELECT name, age, test_datetime, created_at, score, 
               scores_json, metrics_json, interpretation_json, raw_events
        FROM tests WHERE id = ?
    """, (test_id,))
    row = c.fetchone()
    conn.close()
    
    if not row:
        return None
    
    return {
        'name': row[0],
        'age': row[1],
        'test_datetime': row[2],
        'created_at': row[3],
        'score': row[4],
        'scores': json.loads(row[5]) if row[5] else {},
        'metrics': json.loads(row[6]) if row[6] else {},
        'interpretation': json.loads(row[7]) if row[7] else {},
        'raw_events': json.loads(row[8]) if row[8] else [],
    }


# ============================================================
# PDF Report Generation
# ============================================================

def generate_clinical_pdf_report(test_id: str, dest_path: str):
    """
    Generate comprehensive clinical PDF report with:
    - Child information
    - Overall and domain-specific scores
    - Clinical metrics
    - Interpretation and recommendations
    """
    record = get_test_record(test_id)
    if not record:
        raise ValueError("Test not found")
    
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
    
    # Overall Score (large display)
    score = record.get('score', 0)
    scores = record.get('scores', {})
    risk_category = scores.get('risk_category', 'Unknown')
    
    # Score color based on risk
    if score >= 80:
        score_color = colors.HexColor('#28A745')  # Green
    elif score >= 60:
        score_color = colors.HexColor('#FFC107')  # Yellow
    elif score >= 40:
        score_color = colors.HexColor('#FD7E14')  # Orange
    else:
        score_color = colors.HexColor('#DC3545')  # Red
    
    c.setFillColor(score_color)
    c.circle(margin + 0.75 * inch, y - 0.5 * inch, 0.6 * inch, fill=True, stroke=False)
    
    c.setFillColor(colors.white)
    c.setFont("Helvetica-Bold", 28)
    c.drawCentredString(margin + 0.75 * inch, y - 0.6 * inch, f"{score:.0f}")
    
    c.setFillColor(colors.black)
    c.setFont("Helvetica-Bold", 16)
    c.drawString(margin + 1.8 * inch, y - 0.3 * inch, "Overall Gaze Score")
    
    c.setFont("Helvetica", 12)
    c.setFillColor(score_color)
    c.drawString(margin + 1.8 * inch, y - 0.55 * inch, risk_category)
    
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
        # Progress bar background
        c.setFillColor(colors.HexColor('#E9ECEF'))
        c.rect(margin, y - 0.15 * inch, 4 * inch, 0.25 * inch, fill=True, stroke=False)
        
        # Progress bar fill
        if dscore >= 70:
            bar_color = colors.HexColor('#28A745')
        elif dscore >= 50:
            bar_color = colors.HexColor('#FFC107')
        else:
            bar_color = colors.HexColor('#DC3545')
        
        c.setFillColor(bar_color)
        c.rect(margin, y - 0.15 * inch, (dscore / 100) * 4 * inch, 0.25 * inch, fill=True, stroke=False)
        
        c.setFillColor(colors.black)
        c.setFont("Helvetica", 10)
        c.drawString(margin + 4.2 * inch, y - 0.1 * inch, f"{dscore:.1f}%")
        c.drawString(margin, y + 0.15 * inch, domain)
        
        y -= 0.5 * inch
    
    y -= 0.3 * inch
    
    # Interpretation Summary
    interpretation = record.get('interpretation', {})
    summary = interpretation.get('summary', 'No interpretation available.')
    
    c.setFont("Helvetica-Bold", 14)
    c.drawString(margin, y, "Clinical Summary")
    y -= 0.25 * inch
    
    c.setFont("Helvetica", 10)
    # Word wrap for summary
    words = summary.split()
    line = ""
    max_width = width - 2 * margin
    for word in words:
        test_line = line + word + " "
        if c.stringWidth(test_line, "Helvetica", 10) < max_width:
            line = test_line
        else:
            c.drawString(margin, y, line.strip())
            y -= 0.2 * inch
            line = word + " "
    if line:
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
    
    metric_items = [
        ("Total Test Duration", f"{metrics.get('total_duration', 0):.1f} seconds"),
        ("Total Gaze Events", f"{metrics.get('total_events', 0)}"),
        ("Valid Events", f"{metrics.get('valid_events', 0)}"),
        ("Fixations Detected", f"{metrics.get('fixation_count', 0)}"),
        ("Mean Fixation Duration", f"{metrics.get('mean_fixation_duration', 0)*1000:.0f} ms"),
        ("Saccades Detected", f"{metrics.get('saccade_count', 0)}"),
        ("Time on Target", f"{metrics.get('time_on_target', 0):.1f}%"),
        ("Gaze Dispersion", f"{metrics.get('gaze_dispersion', 0):.3f}"),
        ("Preferred Region", f"{metrics.get('preferred_region', 'N/A')}"),
    ]
    
    c.setFont("Helvetica", 10)
    for label, value in metric_items:
        c.drawString(margin, y, f"{label}:")
        c.drawString(margin + 2.5 * inch, y, value)
        y -= 0.22 * inch
    
    y -= 0.3 * inch
    
    # Social Attention Task Results (if available)
    social_metrics = record.get('social_object_metrics')
    if social_metrics:
        from reports.pdf_report import build_social_object_section
        y = build_social_object_section(c, social_metrics, y, margin, width)
        y -= 0.3 * inch
    
    # Findings
    findings = interpretation.get('findings', [])
    if findings:
        c.setFont("Helvetica-Bold", 12)
        c.drawString(margin, y, "Clinical Findings")
        y -= 0.25 * inch
        
        c.setFont("Helvetica", 10)
        for finding in findings:
            # Bullet point
            c.drawString(margin, y, "•")
            # Word wrap
            words = finding.split()
            line = ""
            first_line = True
            for word in words:
                test_line = line + word + " "
                if c.stringWidth(test_line, "Helvetica", 10) < (width - 2 * margin - 0.3 * inch):
                    line = test_line
                else:
                    if first_line:
                        c.drawString(margin + 0.2 * inch, y, line.strip())
                        first_line = False
                    else:
                        c.drawString(margin + 0.2 * inch, y, line.strip())
                    y -= 0.2 * inch
                    line = word + " "
            if line:
                if first_line:
                    c.drawString(margin + 0.2 * inch, y, line.strip())
                else:
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
        for i, rec in enumerate(recommendations, 1):
            c.drawString(margin, y, f"{i}.")
            # Word wrap
            words = rec.split()
            line = ""
            first_line = True
            for word in words:
                test_line = line + word + " "
                if c.stringWidth(test_line, "Helvetica", 10) < (width - 2 * margin - 0.3 * inch):
                    line = test_line
                else:
                    if first_line:
                        c.drawString(margin + 0.25 * inch, y, line.strip())
                        first_line = False
                    else:
                        c.drawString(margin + 0.25 * inch, y, line.strip())
                    y -= 0.2 * inch
                    line = word + " "
            if line:
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
    
    # Word wrap disclaimer
    words = disclaimer.split()
    line = ""
    y = 0.8 * inch
    for word in words:
        test_line = line + word + " "
        if c.stringWidth(test_line, "Helvetica-Oblique", 8) < (width - 2 * margin):
            line = test_line
        else:
            c.drawString(margin, y, line.strip())
            y -= 0.15 * inch
            line = word + " "
    if line:
        c.drawString(margin, y, line.strip())
    
    c.save()


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
    # Create placeholder record
    save_test_record(test_id, info.dict(), {'score': 0}, json.dumps([]))
    return {"test_id": test_id, "message": f"Test session created for {info.name}"}


@app.post("/upload_gaze", response_model=None)
def upload_gaze(batch: GazeBatch):
    """
    Upload gaze events and receive clinical analysis.
    
    The gaze events are analyzed for:
    - Fixation patterns
    - Saccade characteristics  
    - Attention metrics
    - Smooth pursuit ability
    
    Returns overall score, domain scores, and clinical interpretation.
    """
    # Verify test exists
    record = get_test_record(batch.test_id)
    if not record:
        raise HTTPException(status_code=404, detail="Test ID not found")
    
    # Convert events to dict and normalize x/y coordinates
    events = []
    for e in batch.events:
        event_dict = e.dict()
        # Ensure x and y are always present using helper methods
        event_dict['x'] = e.get_x()
        event_dict['y'] = e.get_y()
        events.append(event_dict)
    
    # Run clinical analysis
    analysis = MODEL_WRAPPER.infer(events)
    
    # Save results
    info = {'name': record['name'], 'age': record['age'], 'test_datetime': record['test_datetime']}
    save_test_record(batch.test_id, info, analysis, json.dumps(events))
    
    # Generate PDF report
    dest = os.path.join(REPORTS_DIR, f"{batch.test_id}.pdf")
    generate_clinical_pdf_report(batch.test_id, dest)
    
    return {
        "test_id": batch.test_id,
        "score": analysis.get('score', 0),
        "scores": analysis.get('scores', {}),
        "metrics": analysis.get('metrics', {}),
        "interpretation": analysis.get('interpretation', {}),
        "report_path": dest
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


@app.get("/report/{test_id}/download")
def download_report(test_id: str):
    """Download PDF report"""
    path = os.path.join(REPORTS_DIR, f"{test_id}.pdf")
    if not os.path.exists(path):
        raise HTTPException(status_code=404, detail="Report not found")
    return FileResponse(
        path, 
        media_type="application/pdf", 
        filename=f"SenseAI_Report_{test_id[:8]}.pdf"
    )


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "model_loaded": MODEL_WRAPPER is not None}
