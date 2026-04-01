"""
Prediction endpoint for ASD risk assessment
"""

from fastapi import APIRouter, HTTPException
from app.core.logger import logger
from app.schemas.request import PredictionRequest
from app.schemas.response import PredictionResponse
from app.ml.predictor import predict_asd

router = APIRouter()

@router.post("/", response_model=PredictionResponse)
def predict_endpoint(request: PredictionRequest):
    """
    Predict ASD risk from ML features
    
    - **age_months**: Child's age in months
    - **features**: Dictionary of ML features (raw values)
    - **age_group**: Optional age group (e.g., '2-3', '3-5', '5-6')
    - **session_type**: Optional session type (e.g., 'color_shape', 'frog_jump')
    
    Returns prediction with risk score, level, and probabilities.
    """
    try:
        result = predict_asd(request)
        return result
    except ValueError as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except FileNotFoundError as e:
        logger.error(f"Model not found: {e}")
        raise HTTPException(
            status_code=503,
            detail=f"ML models not available: {str(e)}. Please ensure model files are in models/ directory."
        )
    except Exception as e:
        logger.error(f"Prediction failed: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

