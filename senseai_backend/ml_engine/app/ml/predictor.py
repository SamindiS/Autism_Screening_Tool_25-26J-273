"""
Main prediction logic
"""

import numpy as np
from app.ml.model_loader import load_models
from app.ml.preprocessing import normalize_features, prepare_features
from app.schemas.request import PredictionRequest
from app.schemas.response import PredictionResponse

def predict_asd(request: PredictionRequest) -> PredictionResponse:
    """
    Predict ASD risk from ML features
    
    Args:
        request: PredictionRequest with age_months and features
        
    Returns:
        PredictionResponse with risk score, level, and probabilities
    """
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
    
    # Perform age normalization if norms are available
    features_dict = request.features.copy()
    if age_norms is not None:
        features_dict = normalize_features(features_dict, age_months, age_norms)
    
    # Get expected number of features from scaler
    expected_n_features = scaler.n_features_in_
    
    # Prepare features in correct order
    if feature_names is None:
        raise ValueError(
            "feature_names.json not found. Cannot determine which features the model expects."
        )
    
    features = prepare_features(features_dict, feature_names, expected_n_features)
    
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
    
    # Determine risk level
    if risk_score < 30:
        risk_level = "low"
    elif risk_score < 70:
        risk_level = "moderate"
    else:
        risk_level = "high"
    
    return PredictionResponse(
        prediction=int(prediction),
        probability=[control_probability, asd_probability],
        confidence=confidence,
        risk_level=risk_level,
        risk_score=round(risk_score, 1),
        asd_probability=round(asd_probability, 3)
    )

