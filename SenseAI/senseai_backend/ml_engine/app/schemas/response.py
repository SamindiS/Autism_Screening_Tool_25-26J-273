"""
Response schemas for API endpoints
"""

from pydantic import BaseModel, Field
from typing import List, Optional


class ExplanationItem(BaseModel):
    """Simple explanation item for model output"""

    feature: str = Field(..., description="Feature name")
    value: float = Field(..., description="Feature value used for prediction")
    contribution: float = Field(..., description="Signed contribution score (approximate)")
    direction: str = Field(..., description="'increases_risk' or 'decreases_risk'")

class PredictionResponse(BaseModel):
    """Response schema for ASD prediction"""
    
    prediction: int = Field(
        ...,
        description="Prediction: 0 = Control, 1 = ASD Risk",
        ge=0,
        le=1
    )
    
    probability: List[float] = Field(
        ...,
        description="Probability distribution: [control_prob, asd_prob]",
        min_length=2,
        max_length=2
    )
    
    confidence: float = Field(
        ...,
        description="Confidence in prediction (max probability)",
        ge=0.0,
        le=1.0
    )
    
    risk_level: str = Field(
        ...,
        description="Risk level: 'low', 'moderate', or 'high'"
    )
    
    risk_score: float = Field(
        ...,
        description="Risk score (0-100), where higher = higher ASD risk",
        ge=0.0,
        le=100.0
    )
    
    asd_probability: float = Field(
        ...,
        description="Probability of ASD (0-1)",
        ge=0.0,
        le=1.0
    )

    model_age_group: Optional[str] = Field(
        default=None,
        description="Age group model used: '2-3.5', '3.5-5.5', '5.5-6.9', or null if legacy"
    )

    explanations: Optional[List[ExplanationItem]] = Field(
        default=None,
        description="Optional simple explanation of top factors affecting the prediction"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "prediction": 1,
                "probability": [0.21, 0.79],
                "confidence": 0.79,
                "risk_level": "high",
                "risk_score": 78.9,
                "asd_probability": 0.789
            }
        }


