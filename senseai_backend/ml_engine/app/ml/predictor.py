"""
Main prediction logic
"""

import numpy as np
from app.ml.model_loader import load_models
from app.ml.preprocessing import normalize_features, prepare_features
from app.core.config import RISK_THRESHOLDS
from app.core.logger import logger
from app.schemas.request import PredictionRequest
from app.schemas.response import PredictionResponse

def validate_features(features_dict: dict, feature_names: list) -> None:
    """
    Validate that required features are present
    
    Args:
        features_dict: Dictionary of provided features
        feature_names: List of expected feature names
        
    Raises:
        ValueError: If critical features are missing
    """
    if feature_names is None:
        return  # Cannot validate without feature names
    
    # Check for missing features (warn but don't fail - missing features default to 0)
    missing = set(feature_names) - set(features_dict.keys())
    if missing:
        # Only warn about critical features (non-Z-score features)
        critical_missing = [f for f in missing if not f.endswith('_zscore')]
        if critical_missing:
            logger.warning(f"Missing features (will use 0): {critical_missing[:5]}...")  # Log first 5

def predict_asd(request: PredictionRequest) -> PredictionResponse:
    """
    Predict ASD risk from ML features
    
    Args:
        request: PredictionRequest with age_months and features
        
    Returns:
        PredictionResponse with risk score, level, and probabilities
    """
    logger.info(f"Prediction requested: age={request.age_months}, child_id={request.child_id or 'N/A'}")
    
    # Load models (cached after first load)
    model, scaler, feature_names, age_norms = load_models()
    
    # Extract age_months
    age_months = request.age_months
    if age_months is None:
        age_months = request.features.get('age_months', 36)
    
    # Normalize age_months to int
    try:
        age_months = int(float(age_months))
    except (ValueError, TypeError):
        age_months = 36  # Default
    
    # Validate features
    validate_features(request.features, feature_names)
    
    # Perform age normalization if norms are available
    features_dict = request.features.copy()
    if age_norms is not None:
        features_dict = normalize_features(features_dict, age_months, age_norms)
    else:
        logger.debug("Age normalization skipped (age_norms.json not available)")
    
    # Get expected number of features from scaler
    expected_n_features = scaler.n_features_in_
    
    # Prepare features in correct order
    if feature_names is None:
        raise ValueError(
            "feature_names.json not found. Cannot determine which features the model expects."
        )
    
    features = prepare_features(features_dict, feature_names, expected_n_features)
    logger.debug(f"Prepared {expected_n_features} features for prediction")
    
    # Scale features (using the same scaler from training)
    features_scaled = scaler.transform(features)
    
    # Predict
    prediction = model.predict(features_scaled)[0]
    probabilities = model.predict_proba(features_scaled)[0]
    
    # Calculate risk score and level
    asd_probability = float(probabilities[1])  # Probability of ASD
    control_probability = float(probabilities[0])  # Probability of Control
    risk_score = asd_probability * 100
    confidence = float(max(probabilities))
    
    # Determine risk level using thresholds
    if risk_score >= RISK_THRESHOLDS["HIGH"] * 100:
        risk_level = "high"
    elif risk_score >= RISK_THRESHOLDS["MODERATE"] * 100:
        risk_level = "moderate"
    else:
        risk_level = "low"
    
    logger.info(
        f"Prediction complete: {risk_level.upper()} risk "
        f"(score={risk_score:.1f}%, prob={asd_probability:.3f})"
    )
    
    return PredictionResponse(
        prediction=int(prediction),
        probability=[control_probability, asd_probability],
        confidence=confidence,
        risk_level=risk_level,
        risk_score=round(risk_score, 1),
        asd_probability=round(asd_probability, 3)
    )

