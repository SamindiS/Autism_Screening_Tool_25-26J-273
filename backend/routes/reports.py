from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Dict, Any, Optional
from datetime import datetime
import uuid
from database.connection import get_db
from routes.auth import verify_token

router = APIRouter()

class ReportGenerate(BaseModel):
    session_id: str
    include_ml_prediction: bool = True
    include_recommendations: bool = True

class ReportResponse(BaseModel):
    id: str
    session_id: str
    generated_at: datetime
    risk_level: str
    summary: Dict[str, Any]
    recommendations: list
    clinician_notes: Optional[str]
    ai_bot_answers: list

@router.post("/generate", response_model=ReportResponse)
async def generate_report(
    report_data: ReportGenerate,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Generate a clinical report for a session"""
    try:
        # Mock report generation - replace with actual logic
        report_id = str(uuid.uuid4())
        
        # Mock session data
        session_data = {
            "id": report_data.session_id,
            "child_id": "child_1",
            "component_type": "cognitive_flexibility",
            "game_type": "stroop",
            "age_group": "4-5",
            "data": {
                "metrics": {
                    "accuracy": 85.5,
                    "meanReactionTime": 1200,
                    "switchCost": 250,
                    "perseverativeErrors": 2,
                    "inhibitionErrors": 1
                }
            }
        }
        
        # Generate summary
        summary = {
            "overall_score": 85.5,
            "cognitive_flexibility": 80.0,
            "attention": 90.0,
            "social_interaction": 85.0,
            "behavioral_indicators": [
                "Good response accuracy",
                "Moderate switch cost",
                "Some perseverative errors"
            ]
        }
        
        # Generate recommendations based on risk level
        risk_level = "low"  # This would come from ML prediction
        recommendations = generate_recommendations(risk_level)
        
        # Mock AI bot answers
        ai_bot_answers = [
            {
                "question_id": "q1",
                "answer": "Child showed good engagement during the task",
                "timestamp": datetime.now()
            },
            {
                "question_id": "q2",
                "answer": "No significant behavioral concerns observed",
                "timestamp": datetime.now()
            }
        ]
        
        report = {
            "id": report_id,
            "session_id": report_data.session_id,
            "generated_at": datetime.now(),
            "risk_level": risk_level,
            "summary": summary,
            "recommendations": recommendations,
            "clinician_notes": None,
            "ai_bot_answers": ai_bot_answers
        }
        
        return report
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Report generation failed: {str(e)}")

def generate_recommendations(risk_level: str) -> list:
    """Generate recommendations based on risk level"""
    if risk_level == "low":
        return [
            "Continue monitoring cognitive development",
            "Encourage activities that promote executive functioning",
            "Regular follow-up assessments recommended"
        ]
    elif risk_level == "moderate":
        return [
            "Consider additional assessment tools",
            "Implement targeted cognitive training exercises",
            "Schedule follow-up assessment in 3-6 months",
            "Consider consultation with developmental specialist"
        ]
    else:
        return [
            "Immediate referral to developmental specialist recommended",
            "Comprehensive developmental assessment needed",
            "Consider early intervention services",
            "Regular monitoring and support essential"
        ]

@router.get("/download/{report_id}")
async def download_report(
    report_id: str,
    format: str = "pdf",
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Download a report in specified format"""
    try:
        # Mock report download - replace with actual file generation
        if format not in ["pdf", "csv", "json"]:
            raise HTTPException(status_code=400, detail="Unsupported format")
        
        # Mock file content
        file_content = f"Report {report_id} in {format.upper()} format"
        
        return {
            "file_content": file_content,
            "filename": f"autism_report_{report_id}.{format}",
            "content_type": f"application/{format}"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Report download failed: {str(e)}")

@router.get("/{report_id}", response_model=ReportResponse)
async def get_report(
    report_id: str,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Get a specific report by ID"""
    # Mock data - replace with actual database query
    if report_id == "report_1":
        return {
            "id": "report_1",
            "session_id": "session_1",
            "generated_at": datetime.now(),
            "risk_level": "low",
            "summary": {
                "overall_score": 85.5,
                "cognitive_flexibility": 80.0,
                "attention": 90.0,
                "social_interaction": 85.0,
                "behavioral_indicators": ["Good response accuracy"]
            },
            "recommendations": ["Continue monitoring"],
            "clinician_notes": None,
            "ai_bot_answers": []
        }
    else:
        raise HTTPException(status_code=404, detail="Report not found")

@router.get("/")
async def list_reports(
    child_id: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """List all reports, optionally filtered by child_id"""
    # Mock data - replace with actual database query
    mock_reports = [
        {
            "id": "report_1",
            "session_id": "session_1",
            "child_id": "child_1",
            "generated_at": datetime.now(),
            "risk_level": "low"
        }
    ]
    
    if child_id:
        mock_reports = [r for r in mock_reports if r["child_id"] == child_id]
    
    return mock_reports










