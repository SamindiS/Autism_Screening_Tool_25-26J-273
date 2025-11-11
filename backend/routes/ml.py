from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Dict, Any
import joblib
import numpy as np
from database.connection import get_db
from routes.auth import verify_token

router = APIRouter()

class MLFeatures(BaseModel):
    mean_rt: float
    accuracy: float
    switch_cost: float
    perseverative_error_rate: float
    inhibition_error_rate: float
    recovery_speed: float
    age: int
    gender: int

class MLPrediction(BaseModel):
    risk_level: str
    confidence: float
    features: MLFeatures
    timestamp: str

class PredictionRequest(BaseModel):
    features: MLFeatures

class PredictionResponse(BaseModel):
    risk_level: str
    confidence: float
    interpretation: str
    recommendations: list

# Mock ML model - replace with actual trained model
class MockMLModel:
    def __init__(self):
        self.is_trained = False
    
    def predict(self, features: MLFeatures) -> Dict[str, Any]:
        # Simple rule-based prediction for demonstration
        risk_score = 0.0
        
        # Higher reaction time increases risk
        if features.mean_rt > 2000:
            risk_score += 0.3
        elif features.mean_rt > 1500:
            risk_score += 0.2
        elif features.mean_rt > 1000:
            risk_score += 0.1
        
        # Lower accuracy increases risk
        if features.accuracy < 60:
            risk_score += 0.4
        elif features.accuracy < 80:
            risk_score += 0.2
        elif features.accuracy < 90:
            risk_score += 0.1
        
        # Higher switch cost increases risk
        if features.switch_cost > 500:
            risk_score += 0.2
        elif features.switch_cost > 300:
            risk_score += 0.1
        
        # Higher error rates increase risk
        risk_score += (features.perseverative_error_rate / 100) * 0.2
        risk_score += (features.inhibition_error_rate / 100) * 0.2
        
        # Determine risk level
        if risk_score <= 0.33:
            risk_level = "low"
            confidence = 0.7 + (0.33 - risk_score) * 0.3
        elif risk_score <= 0.66:
            risk_level = "moderate"
            confidence = 0.7 + (0.66 - risk_score) * 0.3
        else:
            risk_level = "high"
            confidence = 0.7 + (1.0 - risk_score) * 0.3
        
        confidence = min(max(confidence, 0.5), 0.95)
        
        return {
            "risk_level": risk_level,
            "confidence": confidence,
            "risk_score": risk_score
        }

# Initialize mock model
ml_model = MockMLModel()

@router.post("/predict", response_model=PredictionResponse)
async def predict_risk(
    request: PredictionRequest,
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Predict ASD risk level based on assessment features"""
    try:
        features = request.features
        
        # Get prediction from ML model
        prediction = ml_model.predict(features)
        
        # Generate interpretation and recommendations
        interpretation = generate_interpretation(prediction)
        recommendations = generate_recommendations(prediction["risk_level"])
        
        return PredictionResponse(
            risk_level=prediction["risk_level"],
            confidence=prediction["confidence"],
            interpretation=interpretation,
            recommendations=recommendations
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

def generate_interpretation(prediction: Dict[str, Any]) -> str:
    """Generate human-readable interpretation of the prediction"""
    risk_level = prediction["risk_level"]
    confidence = prediction["confidence"]
    risk_score = prediction["risk_score"]
    
    if risk_level == "low":
        return f"The assessment indicates a low risk of ASD (confidence: {confidence:.1%}). The child shows typical cognitive flexibility patterns for their age group."
    elif risk_level == "moderate":
        return f"The assessment indicates a moderate risk of ASD (confidence: {confidence:.1%}). Some difficulties with cognitive flexibility were observed. Further assessment may be beneficial."
    else:
        return f"The assessment indicates a high risk of ASD (confidence: {confidence:.1%}). Significant difficulties with cognitive flexibility were observed. Professional evaluation is recommended."

def generate_recommendations(risk_level: str) -> list:
    """Generate recommendations based on risk level"""
    if risk_level == "low":
        return [
            "Continue monitoring cognitive development",
            "Encourage activities that promote executive functioning",
            "Regular follow-up assessments recommended",
            "Maintain current developmental support"
        ]
    elif risk_level == "moderate":
        return [
            "Consider additional assessment tools",
            "Implement targeted cognitive training exercises",
            "Schedule follow-up assessment in 3-6 months",
            "Consider consultation with developmental specialist",
            "Monitor for other developmental concerns"
        ]
    else:
        return [
            "Immediate referral to developmental specialist recommended",
            "Comprehensive developmental assessment needed",
            "Consider early intervention services",
            "Regular monitoring and support essential",
            "Family support and resources should be provided"
        ]

@router.post("/train")
async def train_model(
    training_data: Dict[str, Any],
    current_user_id: str = Depends(verify_token),
    db: Session = Depends(get_db)
):
    """Train the ML model with new data"""
    try:
        # TODO: Implement actual model training
        # This would involve:
        # 1. Loading training data from database
        # 2. Preprocessing features
        # 3. Training the model
        # 4. Saving the trained model
        
        return {"message": "Model training initiated", "status": "success"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Training failed: {str(e)}")

@router.get("/model/status")
async def get_model_status(current_user_id: str = Depends(verify_token)):
    """Get current model status and performance metrics"""
    return {
        "is_trained": ml_model.is_trained,
        "model_type": "mock_classifier",
        "last_trained": "2024-01-01T00:00:00Z",
        "accuracy": 0.85,  # Mock accuracy
        "version": "1.0.0"
    }










