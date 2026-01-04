"""
Load trained ML models, scaler, and configuration files
"""

import joblib
import json
from pathlib import Path
from typing import Optional, Dict, Any

# Get paths relative to this file
ML_ENGINE_DIR = Path(__file__).parent.parent.parent
MODEL_DIR = ML_ENGINE_DIR / "models"

# Model file paths (supports both naming conventions)
MODEL_PATH = MODEL_DIR / "asd_detection_model.pkl"
MODEL_PATH_ALT = MODEL_DIR / "asd_screening_model_calibrated.pkl"
SCALER_PATH = MODEL_DIR / "feature_scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_names.json"
AGE_NORMS_PATH = MODEL_DIR / "age_norms.json"

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
    
    try:
        # Load model
        if MODEL_PATH.exists():
            _model = joblib.load(MODEL_PATH)
            model_path_used = str(MODEL_PATH)
        elif MODEL_PATH_ALT.exists():
            _model = joblib.load(MODEL_PATH_ALT)
            model_path_used = str(MODEL_PATH_ALT)
        else:
            raise FileNotFoundError(
                f"Model not found. Expected: {MODEL_PATH} or {MODEL_PATH_ALT}"
            )
        
        # Load scaler
        if not SCALER_PATH.exists():
            raise FileNotFoundError(f"Scaler not found: {SCALER_PATH}")
        _scaler = joblib.load(SCALER_PATH)
        
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
        
        return _model, _scaler, _feature_names, _age_norms
        
    except Exception as e:
        raise FileNotFoundError(f"Error loading models: {str(e)}")

def check_models_loaded() -> Dict[str, Any]:
    """Check if models are loaded and return status"""
    try:
        model, scaler, feature_names, age_norms = load_models()
        return {
            "loaded": True,
            "model_path": str(MODEL_PATH) if MODEL_PATH.exists() else str(MODEL_PATH_ALT),
            "scaler_path": str(SCALER_PATH),
            "features_path": str(FEATURES_PATH) if FEATURES_PATH.exists() else None,
            "age_norms_available": age_norms is not None,
            "expected_features": scaler.n_features_in_ if scaler else None,
            "feature_names_count": len(feature_names) if feature_names else None
        }
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

