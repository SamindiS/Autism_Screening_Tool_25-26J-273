"""
Main prediction logic with age-specific model routing
"""

import numpy as np
from app.ml.age_specific_loader import load_age_specific_model
from app.ml.model_loader import load_models  # Legacy support
from app.ml.preprocessing import normalize_features, prepare_features
from app.core.config import RISK_THRESHOLDS, get_age_group
from app.core.logger import logger
from app.schemas.request import PredictionRequest
from app.schemas.response import PredictionResponse


def _build_explanations(
    model: any,
    feature_names: list,
    features_scaled: np.ndarray,
    features_dict: dict,
    top_k: int = 6,
) -> list | None:
    """
    Build a simple explanation list for linear models (e.g. LogisticRegression).
    Uses signed contribution ~= coef_i * x_i (on scaled features).
    """
    try:
        if not hasattr(model, "coef_"):
            return None
        coefs = getattr(model, "coef_")
        if coefs is None or len(coefs) == 0:
            return None

        coef_vec = np.array(coefs[0], dtype=float)
        x = np.array(features_scaled[0], dtype=float)
        n = min(len(coef_vec), len(x), len(feature_names))
        if n <= 0:
            return None

        contrib = coef_vec[:n] * x[:n]
        # Rank by absolute contribution
        idx_sorted = np.argsort(np.abs(contrib))[::-1][:top_k]

        explanations = []
        for i in idx_sorted:
            fname = str(feature_names[i])
            val = features_dict.get(fname, 0)
            try:
                val_f = float(val) if val is not None else 0.0
            except Exception:
                val_f = 0.0
            c = float(contrib[i])
            explanations.append(
                {
                    "feature": fname,
                    "value": val_f,
                    "contribution": round(c, 4),
                    "direction": "increases_risk" if c >= 0 else "decreases_risk",
                }
            )

        return explanations
    except Exception as e:
        logger.warning(f"Could not build explanations: {e}")
        return None

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
    Predict ASD risk from ML features using age-specific models
    
    Args:
        request: PredictionRequest with age_months and features
        
    Returns:
        PredictionResponse with risk score, level, and probabilities
    """
    logger.info(f"Prediction requested: age={request.age_months}, child_id={request.child_id or 'N/A'}")
    
    # Extract age_months
    age_months = request.age_months
    if age_months is None:
        age_months = request.features.get('age_months', 36)
    
    # Normalize age_months to int
    try:
        age_months = int(float(age_months))
    except (ValueError, TypeError):
        age_months = 36  # Default
    
    # Determine age group
    age_group = get_age_group(age_months)
    
    # Try to load age-specific model first
    try:
        model, scaler, feature_names, metadata = load_age_specific_model(age_months)
        logger.info(f"Using age-specific model for age group: {age_group}")
    except (FileNotFoundError, ValueError) as e:
        # Fallback to legacy model if age-specific model not found
        logger.warning(f"Age-specific model not found for {age_group}, trying legacy model: {e}")
        try:
            model, scaler, feature_names, age_norms = load_models()
            logger.info("Using legacy unified model")
        except FileNotFoundError:
            raise FileNotFoundError(
                f"No model available for age {age_months} months (age group: {age_group}). "
                f"Please ensure model files are in models/ directory. "
                f"Error: {str(e)}"
            )
    
    # Validate features
    validate_features(request.features, feature_names)
    
    # Prepare features (skip age normalization for age-specific models as they're already age-normalized)
    features_dict = request.features.copy()
    
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
        f"Prediction complete ({age_group or 'legacy'}): {risk_level.upper()} risk "
        f"(score={risk_score:.1f}%, prob={asd_probability:.3f})"
    )

    explanations = _build_explanations(
        model=model,
        feature_names=feature_names,
        features_scaled=features_scaled,
        features_dict=features_dict,
        top_k=6,
    )
    
    return PredictionResponse(
        prediction=int(prediction),
        probability=[control_probability, asd_probability],
        confidence=confidence,
        risk_level=risk_level,
        risk_score=round(risk_score, 1),
        asd_probability=round(asd_probability, 3),
        model_age_group=age_group,
        explanations=explanations,
    )

