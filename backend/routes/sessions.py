from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid
from database.connection import get_db
from routes.auth import verify_token

router = APIRouter()

class SessionCreate(BaseModel):
    child_id: str
    component_type: str
    game_type: str
    age_group: str
    data: Dict[str, Any]

class SessionUpdate(BaseModel):
    end_time: Optional[datetime] = None
    duration: Optional[int] = None
    status: Optional[str] = None
    data: Optional[Dict[str, Any]] = None
    ml_prediction: Optional[Dict[str, Any]] = None
    clinician_notes: Optional[str] = None

class SessionResponse(BaseModel):
    id: str
    child_id: str
    component_type: str
    game_type: str
    age_group: str
    start_time: datetime
    end_time: Optional[datetime]
    duration: Optional[int]
    status: str
    data: Optional[Dict[str, Any]]
    ml_prediction: Optional[Dict[str, Any]]
    clinician_notes: Optional[str]
    created_at: datetime
    updated_at: Optional[datetime]

@router.get("/", response_model=List[SessionResponse])
async def get_sessions(
    child_id: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Get list of sessions, optionally filtered by child_id"""
    # Mock data - replace with actual database query
    mock_sessions = [
        {
            "id": "session_1",
            "child_id": "child_1",
            "component_type": "cognitive_flexibility",
            "game_type": "stroop",
            "age_group": "4-5",
            "start_time": datetime.now(),
            "end_time": datetime.now(),
            "duration": 180,
            "status": "completed",
            "data": {
                "trials": [],
                "metrics": {
                    "accuracy": 85.5,
                    "meanReactionTime": 1200,
                    "switchCost": 250
                }
            },
            "ml_prediction": {
                "risk_level": "low",
                "confidence": 0.8
            },
            "clinician_notes": None,
            "created_at": datetime.now(),
            "updated_at": None
        }
    ]
    
    if child_id:
        mock_sessions = [s for s in mock_sessions if s["child_id"] == child_id]
    
    return mock_sessions

@router.post("/", response_model=SessionResponse)
async def create_session(
    session: SessionCreate,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Create a new session"""
    # Mock creation - replace with actual database insert
    new_session = {
        "id": str(uuid.uuid4()),
        "child_id": session.child_id,
        "component_type": session.component_type,
        "game_type": session.game_type,
        "age_group": session.age_group,
        "start_time": datetime.now(),
        "end_time": None,
        "duration": None,
        "status": "in_progress",
        "data": session.data,
        "ml_prediction": None,
        "clinician_notes": None,
        "created_at": datetime.now(),
        "updated_at": None
    }
    return new_session

@router.get("/{session_id}", response_model=SessionResponse)
async def get_session(
    session_id: str,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Get a specific session by ID"""
    # Mock data - replace with actual database query
    if session_id == "session_1":
        return {
            "id": "session_1",
            "child_id": "child_1",
            "component_type": "cognitive_flexibility",
            "game_type": "stroop",
            "age_group": "4-5",
            "start_time": datetime.now(),
            "end_time": datetime.now(),
            "duration": 180,
            "status": "completed",
            "data": {
                "trials": [],
                "metrics": {
                    "accuracy": 85.5,
                    "meanReactionTime": 1200,
                    "switchCost": 250
                }
            },
            "ml_prediction": {
                "risk_level": "low",
                "confidence": 0.8
            },
            "clinician_notes": None,
            "created_at": datetime.now(),
            "updated_at": None
        }
    else:
        raise HTTPException(status_code=404, detail="Session not found")

@router.put("/{session_id}", response_model=SessionResponse)
async def update_session(
    session_id: str,
    session_update: SessionUpdate,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Update a session"""
    # Mock update - replace with actual database update
    existing_session = {
        "id": session_id,
        "child_id": "child_1",
        "component_type": "cognitive_flexibility",
        "game_type": "stroop",
        "age_group": "4-5",
        "start_time": datetime.now(),
        "end_time": None,
        "duration": None,
        "status": "in_progress",
        "data": {},
        "ml_prediction": None,
        "clinician_notes": None,
        "created_at": datetime.now(),
        "updated_at": None
    }
    
    # Apply updates
    if session_update.end_time is not None:
        existing_session["end_time"] = session_update.end_time
    if session_update.duration is not None:
        existing_session["duration"] = session_update.duration
    if session_update.status is not None:
        existing_session["status"] = session_update.status
    if session_update.data is not None:
        existing_session["data"] = session_update.data
    if session_update.ml_prediction is not None:
        existing_session["ml_prediction"] = session_update.ml_prediction
    if session_update.clinician_notes is not None:
        existing_session["clinician_notes"] = session_update.clinician_notes
    
    existing_session["updated_at"] = datetime.now()
    
    return existing_session

@router.delete("/{session_id}")
async def delete_session(
    session_id: str,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Delete a session"""
    # Mock deletion - replace with actual database delete
    return {"message": f"Session {session_id} deleted successfully"}










