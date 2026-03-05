"""
Health check endpoint
"""

from fastapi import APIRouter
from app.core.logger import logger
from app.ml.model_loader import check_models_loaded
from app.ml.age_specific_loader import check_age_specific_models

router = APIRouter()

@router.get("/")
def health_check():
    """Check if ML service is healthy and models are loaded"""
    # Check age-specific models
    age_specific_status = check_age_specific_models()
    
    # Check legacy model (for backward compatibility)
    legacy_status = check_models_loaded()
    
    # Determine overall status
    age_models_ready = any(status.get("ready", False) for status in age_specific_status.values())
    legacy_ready = legacy_status.get("loaded", False)
    
    overall_status = "OK" if (age_models_ready or legacy_ready) else "DEGRADED"
    
    response = {
        "status": overall_status,
        "service": "SenseAI ML Engine",
        "age_specific_models": age_specific_status,
        "legacy_model": legacy_status
    }
    
    if not (age_models_ready or legacy_ready):
        logger.warning("Health check: No models loaded")
        response["status"] = "DEGRADED"
    
    return response

