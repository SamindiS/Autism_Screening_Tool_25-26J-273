"""
Health check endpoint
"""

from fastapi import APIRouter
from app.ml.model_loader import check_models_loaded

router = APIRouter()

@router.get("/")
def health_check():
    """Check if ML service is healthy and models are loaded"""
    models_status = check_models_loaded()
    
    return {
        "status": "OK",
        "service": "SenseAI ML Engine",
        "models_loaded": models_status["loaded"],
        "model_path": models_status.get("model_path"),
        "scaler_path": models_status.get("scaler_path"),
        "features_path": models_status.get("features_path"),
        "age_norms_available": models_status.get("age_norms_available", False)
    }

