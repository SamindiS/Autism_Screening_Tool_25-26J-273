"""
Age-specific model loader for different age groups
"""

import joblib
import json
from pathlib import Path
from typing import Optional, Dict, Any, Tuple
from app.core.config import (
    AGE_2_3_5_MODEL_PATH, AGE_2_3_5_SCALER_PATH, AGE_2_3_5_FEATURES_PATH, AGE_2_3_5_METADATA_PATH,
    AGE_3_5_5_5_MODEL_PATH, AGE_3_5_5_5_SCALER_PATH, AGE_3_5_5_5_FEATURES_PATH, AGE_3_5_5_5_METADATA_PATH,
    AGE_5_5_6_9_MODEL_PATH, AGE_5_5_6_9_SCALER_PATH, AGE_5_5_6_9_FEATURES_PATH, AGE_5_5_6_9_METADATA_PATH,
    get_age_group
)
from app.core.logger import logger

# Cache for loaded models (age_group -> (model, scaler, features, metadata))
_model_cache: Dict[str, Tuple[Any, Any, list, Optional[Dict]]] = {}

def load_age_specific_model(age_months: int) -> Tuple[Any, Any, list, Optional[Dict]]:
    """
    Load the appropriate model for the given age
    
    Args:
        age_months: Child's age in months
        
    Returns:
        Tuple of (model, scaler, feature_names, metadata)
        
    Raises:
        FileNotFoundError: If model files are not found
    """
    age_group = get_age_group(age_months)
    
    if age_group is None:
        raise ValueError(
            f"Age {age_months} months is outside supported range (24-83 months). "
            f"Supported age groups: 2-3.5 (24-42), 3.5-5.5 (42-66), 5.5-6.9 (66-83)"
        )
    
    # Check cache first
    if age_group in _model_cache:
        logger.debug(f"Using cached model for age group: {age_group}")
        return _model_cache[age_group]
    
    # Load model based on age group
    logger.info(f"Loading model for age group: {age_group} (age: {age_months} months)")
    
    if age_group == "2-3.5":
        model_path = AGE_2_3_5_MODEL_PATH
        scaler_path = AGE_2_3_5_SCALER_PATH
        features_path = AGE_2_3_5_FEATURES_PATH
        metadata_path = AGE_2_3_5_METADATA_PATH
    elif age_group == "3.5-5.5":
        model_path = AGE_3_5_5_5_MODEL_PATH
        scaler_path = AGE_3_5_5_5_SCALER_PATH
        features_path = AGE_3_5_5_5_FEATURES_PATH
        metadata_path = AGE_3_5_5_5_METADATA_PATH
    elif age_group == "5.5-6.9":
        model_path = AGE_5_5_6_9_MODEL_PATH
        scaler_path = AGE_5_5_6_9_SCALER_PATH
        features_path = AGE_5_5_6_9_FEATURES_PATH
        metadata_path = AGE_5_5_6_9_METADATA_PATH
    else:
        raise ValueError(f"Unknown age group: {age_group}")
    
    # Load model
    if not model_path.exists():
        raise FileNotFoundError(
            f"Model not found for age group {age_group}: {model_path}\n"
            f"Please ensure the model file exists. Expected path: {model_path}"
        )
    model = joblib.load(model_path)
    logger.info(f"Model loaded: {model_path.name}")
    
    # Load scaler
    if not scaler_path.exists():
        # Support alternate naming used by some notebooks: scaler_model_<model_name>.pkl
        alt_scaler_path = scaler_path.parent / f"scaler_model_{model_path.stem}.pkl"
        if alt_scaler_path.exists():
            logger.warning(f"Scaler not found at expected path, using alternate: {alt_scaler_path.name}")
            scaler_path = alt_scaler_path
        else:
            raise FileNotFoundError(
                f"Scaler not found for age group {age_group}: {scaler_path}\n"
                f"Please ensure the scaler file exists. Expected path: {scaler_path}"
            )
    scaler = joblib.load(scaler_path)
    logger.info(f"Scaler loaded: {scaler_path.name} (expects {scaler.n_features_in_} features)")
    
    # Load feature names
    feature_names = None
    if features_path.exists():
        with open(features_path, 'r') as f:
            feature_data = json.load(f)
            if isinstance(feature_data, list):
                feature_names = feature_data
            elif isinstance(feature_data, dict) and 'feature_names' in feature_data:
                feature_names = feature_data['feature_names']
            else:
                feature_names = feature_data
        logger.info(f"Features loaded: {features_path.name} ({len(feature_names)} features)")
    else:
        logger.warning(f"Features file not found: {features_path.name}")

    # Fallback: infer feature names from fitted scaler if available
    if not feature_names and hasattr(scaler, "feature_names_in_"):
        try:
            feature_names = list(getattr(scaler, "feature_names_in_"))
            logger.info(f"Features inferred from scaler.feature_names_in_: {len(feature_names)} features")
        except Exception as e:
            logger.warning(f"Could not infer feature names from scaler: {e}")
    
    # Load metadata (optional)
    metadata = None
    if metadata_path.exists():
        try:
            with open(metadata_path, 'r') as f:
                metadata = json.load(f)
            logger.info(f"Metadata loaded: {metadata_path.name}")
        except Exception as e:
            logger.warning(f"Could not load metadata: {e}")
    
    # Cache the loaded model
    _model_cache[age_group] = (model, scaler, feature_names, metadata)
    
    logger.info(f"[OK] Model loaded successfully for age group: {age_group}")
    return model, scaler, feature_names, metadata

def check_age_specific_models() -> Dict[str, Any]:
    """
    Check which age-specific models are available
    
    Returns:
        Dictionary with status of each age group's models
    """
    status = {}
    
    for age_group in ["2-3.5", "3.5-5.5", "5.5-6.9"]:
        if age_group == "2-3.5":
            model_path = AGE_2_3_5_MODEL_PATH
            scaler_path = AGE_2_3_5_SCALER_PATH
            features_path = AGE_2_3_5_FEATURES_PATH
        elif age_group == "3.5-5.5":
            model_path = AGE_3_5_5_5_MODEL_PATH
            scaler_path = AGE_3_5_5_5_SCALER_PATH
            features_path = AGE_3_5_5_5_FEATURES_PATH
        else:  # 5.5-6.9
            model_path = AGE_5_5_6_9_MODEL_PATH
            scaler_path = AGE_5_5_6_9_SCALER_PATH
            features_path = AGE_5_5_6_9_FEATURES_PATH
        
        status[age_group] = {
            "model_exists": model_path.exists(),
            "scaler_exists": scaler_path.exists(),
            "features_exists": features_path.exists(),
            "model_path": str(model_path),
            # Features file is recommended, but we can infer from scaler.feature_names_in_ at runtime
            "ready": model_path.exists() and scaler_path.exists()
        }
    
    return status
