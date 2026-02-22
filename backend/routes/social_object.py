"""
Social vs Object Preference – API routes.
Endpoints: /social_object/start, /social_object/upload_gaze, /social_object/finish,
           /social_object/report/{session_id}/download
"""

import uuid
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import os

from analysis.social_object_metrics import compute_metrics
from reports.pdf_report import generate_social_object_pdf

router = APIRouter(prefix="/social_object", tags=["social_object"])

MAX_EVENTS_PER_SESSION = 50_000
sessions: Dict[str, List[Dict[str, Any]]] = {}

REPORTS_DIR = "reports"
os.makedirs(REPORTS_DIR, exist_ok=True)


class StartBody(BaseModel):
    child_id: Optional[str] = None
    session_id: Optional[str] = None


class UploadGazeBody(BaseModel):
    session_id: str
    events: List[Dict[str, Any]] = Field(
        ...,
        description="List of { timestamp_ms, x, y, aoi }",
    )


class FinishBody(BaseModel):
    session_id: str


@router.post("/start")
def start(body: StartBody):
    """Start a new session. Returns session_id."""
    session_id = body.session_id or str(uuid.uuid4())
    sessions[session_id] = []
    return {"session_id": session_id}


@router.post("/upload_gaze")
def upload_gaze(body: UploadGazeBody):
    """Append gaze events for the session. Drops oldest if over limit."""
    if body.session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    evts = sessions[body.session_id]
    for e in body.events:
        evts.append({
            "timestamp_ms": e.get("timestamp_ms"),
            "x": e.get("x"),
            "y": e.get("y"),
            "aoi": e.get("aoi", "none"),
        })
        if len(evts) > MAX_EVENTS_PER_SESSION:
            evts.pop(0)
    return {"ok": True, "received": len(body.events)}


@router.post("/finish")
def finish(body: FinishBody):
    """Compute metrics and return JSON."""
    if body.session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    events = sessions[body.session_id]
    for i, e in enumerate(events):
        e["session_id"] = body.session_id
    metrics = compute_metrics(events)
    return metrics


@router.get("/report/{session_id}/download")
def download_report(session_id: str):
    """Generate and download PDF report for the social object session."""
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    events = sessions[session_id]
    for e in events:
        e["session_id"] = session_id
    metrics = compute_metrics(events)
    path = os.path.join(REPORTS_DIR, f"social_object_{session_id}.pdf")
    generate_social_object_pdf(session_id, metrics, path)
    return FileResponse(
        path,
        media_type="application/pdf",
        filename=f"Social_Object_Report_{session_id[:8]}.pdf",
    )
