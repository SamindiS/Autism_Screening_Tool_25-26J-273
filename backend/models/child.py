from sqlalchemy import Column, String, Integer, DateTime, Boolean
from sqlalchemy.sql import func
from database.connection import Base

class Child(Base):
    __tablename__ = "children"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    gender = Column(String, nullable=False)  # 'male' or 'female'
    language = Column(String, nullable=False)  # 'en', 'si', 'ta'
    clinic_id = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    is_active = Column(Boolean, default=True)

