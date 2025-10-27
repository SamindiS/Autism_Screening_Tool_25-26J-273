from sqlalchemy import Column, String, Integer, DateTime, Text, ForeignKey, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database.connection import Base

class Session(Base):
    __tablename__ = "sessions"

    id = Column(String, primary_key=True, index=True)
    child_id = Column(String, ForeignKey("children.id"), nullable=False)
    component_type = Column(String, nullable=False)  # 'cognitive_flexibility', 'rrb', etc.
    game_type = Column(String, nullable=False)  # 'go_nogo', 'stroop', 'dccs'
    age_group = Column(String, nullable=False)  # '2-3', '4-5', '5-6'
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True))
    duration = Column(Integer)  # in seconds
    status = Column(String, nullable=False)  # 'in_progress', 'completed', 'cancelled'
    data = Column(JSON)  # Game data, trials, metrics
    ml_prediction = Column(JSON)  # ML prediction results
    clinician_notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationship
    child = relationship("Child", back_populates="sessions")

class Child(Base):
    __tablename__ = "children"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    gender = Column(String, nullable=False)
    language = Column(String, nullable=False)
    clinic_id = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    is_active = Column(Boolean, default=True)

    # Relationship
    sessions = relationship("Session", back_populates="child")










