from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid
from database.connection import get_db
from routes.auth import verify_token

router = APIRouter()

class ChildCreate(BaseModel):
    name: str
    age: int
    gender: str
    language: str

class ChildUpdate(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    language: Optional[str] = None

class ChildResponse(BaseModel):
    id: str
    name: str
    age: int
    gender: str
    language: str
    clinic_id: str
    created_at: datetime
    updated_at: Optional[datetime]
    is_active: bool

@router.get("/", response_model=List[ChildResponse])
async def get_children(
    skip: int = 0,
    limit: int = 100,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Get list of children"""
    # Mock data - replace with actual database query
    mock_children = [
        {
            "id": "child_1",
            "name": "Emma Johnson",
            "age": 4,
            "gender": "female",
            "language": "en",
            "clinic_id": "clinic_1",
            "created_at": datetime.now(),
            "updated_at": None,
            "is_active": True
        },
        {
            "id": "child_2",
            "name": "Liam Smith",
            "age": 3,
            "gender": "male",
            "language": "en",
            "clinic_id": "clinic_1",
            "created_at": datetime.now(),
            "updated_at": None,
            "is_active": True
        }
    ]
    return mock_children

@router.post("/", response_model=ChildResponse)
async def create_child(
    child: ChildCreate,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Create a new child"""
    # Mock creation - replace with actual database insert
    new_child = {
        "id": str(uuid.uuid4()),
        "name": child.name,
        "age": child.age,
        "gender": child.gender,
        "language": child.language,
        "clinic_id": "clinic_1",  # Get from user context
        "created_at": datetime.now(),
        "updated_at": None,
        "is_active": True
    }
    return new_child

@router.get("/{child_id}", response_model=ChildResponse)
async def get_child(
    child_id: str,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Get a specific child by ID"""
    # Mock data - replace with actual database query
    if child_id == "child_1":
        return {
            "id": "child_1",
            "name": "Emma Johnson",
            "age": 4,
            "gender": "female",
            "language": "en",
            "clinic_id": "clinic_1",
            "created_at": datetime.now(),
            "updated_at": None,
            "is_active": True
        }
    else:
        raise HTTPException(status_code=404, detail="Child not found")

@router.put("/{child_id}", response_model=ChildResponse)
async def update_child(
    child_id: str,
    child_update: ChildUpdate,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Update a child's information"""
    # Mock update - replace with actual database update
    existing_child = {
        "id": child_id,
        "name": "Emma Johnson",
        "age": 4,
        "gender": "female",
        "language": "en",
        "clinic_id": "clinic_1",
        "created_at": datetime.now(),
        "updated_at": None,
        "is_active": True
    }
    
    # Apply updates
    if child_update.name is not None:
        existing_child["name"] = child_update.name
    if child_update.age is not None:
        existing_child["age"] = child_update.age
    if child_update.gender is not None:
        existing_child["gender"] = child_update.gender
    if child_update.language is not None:
        existing_child["language"] = child_update.language
    
    existing_child["updated_at"] = datetime.now()
    
    return existing_child

@router.delete("/{child_id}")
async def delete_child(
    child_id: str,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Delete a child (soft delete)"""
    # Mock deletion - replace with actual database update
    return {"message": f"Child {child_id} deleted successfully"}










