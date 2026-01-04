"""
Health check endpoint
"""

from fastapi import APIRouter
from app.core.logger import logger
from app.ml.model_loader import check_models_loaded

router = APIRouter()

@router.get("/")
def health_check():
    """Check if ML service is healthy and models are loaded"""
    models_status = check_models_loaded()
    
    response = {
        "status": "OK",
        "service": "SenseAI ML Engine",
        "models_loaded": models_status["loaded"],
        "model_path": models_status.get("model_path"),
        "scaler_path": models_status.get("scaler_path"),
        "features_path": models_status.get("features_path"),
        "age_norms_available": models_status.get("age_norms_available", False),
        "expected_features": models_status.get("expected_features"),
        "feature_names_count": models_status.get("feature_names_count")
    }
    
    # Include metadata if available
    if "metadata" in models_status:
        response["model_metadata"] = models_status["metadata"]
    
    if not models_status["loaded"]:
        logger.warning(f"Health check: Models not loaded - {models_status.get('error')}")
        response["status"] = "DEGRADED"
    
    return response

