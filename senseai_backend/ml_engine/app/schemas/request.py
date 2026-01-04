"""
Request schemas for API endpoints
"""

from pydantic import BaseModel, Field
from typing import Dict, Any, Optional

class PredictionRequest(BaseModel):
    """Request schema for ASD prediction"""
    
    child_id: Optional[str] = Field(
        None,
        description="Child ID for longitudinal tracking and ethics traceability"
    )
    
    age_months: Optional[int] = Field(
        None,
        description="Child's age in months (for age normalization)",
        ge=12,
        le=120
    )
    
    features: Dict[str, Any] = Field(
        ...,
        description="Dictionary of ML features (raw values from assessments)"
    )
    
    age_group: Optional[str] = Field(
        None,
        description="Age group (e.g., '2-3', '3-5', '5-6')"
    )
    
    session_type: Optional[str] = Field(
        None,
        description="Type of session (e.g., 'color_shape', 'frog_jump', 'ai_doctor_bot')"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "age_months": 48,
                "features": {
                    "age_months": 48,
                    "post_switch_accuracy": 65,
                    "perseverative_error_rate_post_switch": 35,
                    "switch_cost_ms": 450,
                    "commission_error_rate": 28,
                    "rt_variability": 280
                },
                "age_group": "4-5",
                "session_type": "color_shape"
            }
        }

