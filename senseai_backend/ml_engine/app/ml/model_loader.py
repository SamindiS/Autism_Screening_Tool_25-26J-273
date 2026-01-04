"""
Load trained ML models, scaler, and configuration files
"""

import joblib
import json
from pathlib import Path
from typing import Optional, Dict, Any
from app.core.config import (
    MODEL_DIR, MODEL_PATH, MODEL_PATH_ALT, SCALER_PATH,
    FEATURES_PATH, AGE_NORMS_PATH, MODEL_METADATA_PATH
)
from app.core.logger import logger

# Global variables (loaded once at startup)
_model = None
_scaler = None
_feature_names = None
_age_norms = None

def load_models():
    """Load all model files (called once at startup)"""
    global _model, _scaler, _feature_names, _age_norms
    
    if _model is not None:
        # Already loaded
        return _model, _scaler, _feature_names, _age_norms
    
    logger.info("Loading ML models...")
    try:
        # Load model
        if MODEL_PATH.exists():
            _model = joblib.load(MODEL_PATH)
            model_path_used = str(MODEL_PATH)
            logger.info(f"Model loaded from: {MODEL_PATH.name}")
        elif MODEL_PATH_ALT.exists():
            _model = joblib.load(MODEL_PATH_ALT)
            model_path_used = str(MODEL_PATH_ALT)
            logger.info(f"Model loaded from: {MODEL_PATH_ALT.name}")
        else:
            raise FileNotFoundError(
                f"Model not found. Expected: {MODEL_PATH} or {MODEL_PATH_ALT}"
            )
        
        # Load scaler
        if not SCALER_PATH.exists():
            raise FileNotFoundError(f"Scaler not found: {SCALER_PATH}")
        _scaler = joblib.load(SCALER_PATH)
        logger.info(f"Scaler loaded: {SCALER_PATH.name} (expects {_scaler.n_features_in_} features)")
        
        # Load feature names
        _feature_names = None
        if FEATURES_PATH.exists():
            with open(FEATURES_PATH, 'r') as f:
                feature_data = json.load(f)
                if isinstance(feature_data, list):
                    _feature_names = feature_data
                elif isinstance(feature_data, dict) and 'feature_names' in feature_data:
                    _feature_names = feature_data['feature_names']
                else:
                    _feature_names = feature_data
        
        # Load age norms (optional)
        _age_norms = None
        if AGE_NORMS_PATH.exists():
            with open(AGE_NORMS_PATH, 'r') as f:
                _age_norms = json.load(f)
            logger.info(f"Age norms loaded: {AGE_NORMS_PATH.name}")
        else:
            logger.warning(f"Age norms not found: {AGE_NORMS_PATH.name} (age normalization disabled)")
        
        logger.info("✅ All models loaded successfully")
        return _model, _scaler, _feature_names, _age_norms
        
    except Exception as e:
        logger.error(f"❌ Error loading models: {str(e)}")
        raise FileNotFoundError(f"Error loading models: {str(e)}")

def load_model_metadata() -> Optional[Dict[str, Any]]:
    """Load model metadata if available"""
    if MODEL_METADATA_PATH.exists():
        try:
            with open(MODEL_METADATA_PATH, 'r') as f:
                return json.load(f)
        except Exception as e:
            logger.warning(f"Could not load model metadata: {e}")
    return None

def check_models_loaded() -> Dict[str, Any]:
    """Check if models are loaded and return status"""
    try:
        model, scaler, feature_names, age_norms = load_models()
        metadata = load_model_metadata()
        
        status = {
            "loaded": True,
            "model_path": str(MODEL_PATH) if MODEL_PATH.exists() else str(MODEL_PATH_ALT),
            "scaler_path": str(SCALER_PATH),
            "features_path": str(FEATURES_PATH) if FEATURES_PATH.exists() else None,
            "age_norms_available": age_norms is not None,
            "expected_features": scaler.n_features_in_ if scaler else None,
            "feature_names_count": len(feature_names) if feature_names else None
        }
        
        if metadata:
            status["metadata"] = metadata
        
        return status
    except Exception as e:
        return {
            "loaded": False,
            "error": str(e)
        }

# Load models at module import
try:
    load_models()
except FileNotFoundError:
    # Models not available yet - will fail on first prediction
    pass

