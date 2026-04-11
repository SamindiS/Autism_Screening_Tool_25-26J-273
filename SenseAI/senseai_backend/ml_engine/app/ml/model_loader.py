"""
Load trained ML models, scaler, and configuration files.

This module acts as the fallback or legacy unified model loader. Prior to the 
implementation of the age-banded specific models (handled by `age_specific_loader.py`), 
the SenseAI backend relied on a single unified model. 

Key Responsibilities:
- Loads the base `RandomForestClassifier` (or `LogisticRegression`) model from the `models/` dir.
- Loads the universal `StandardScaler` to ensure request features match the training distribution.
- Parses `feature_names.json` to guarantee features are supplied to the model in the exact 
  order they were trained on.
- Loads `age_norms.json` if available for Z-score normalization of developmental metrics.
"""

import joblib
import json
from pathlib import Path
from typing import Optional, Dict, Any
from app.core.config import (
    MODEL_DIR, MODEL_PATH, MODEL_PATH_ALT, SCALER_PATH,
    FEATURES_PATH, AGE_NORMS_PATH, MODEL_METADATA_PATH,
    # v3 Hybrid Model Paths
    AGE_2_V3_BINARY_MODEL_PATH, AGE_2_V3_SEVERITY_MODEL_PATH,
    AGE_2_V3_SCALER_PATH, AGE_2_V3_LE_GENDER_PATH,
    AGE_2_V3_LE_LANG_PATH, AGE_2_V3_CONFIG_PATH
)
from app.core.logger import logger

# Global variables (loaded once at startup)
_model = None
_scaler = None
_feature_names = None
_age_norms = None

# v3 Hybrid Model Cache
_v3_binary_model = None
_v3_severity_model = None
_v3_scaler = None
_v3_le_gender = None
_v3_le_lang = None
_v3_config = None

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
        
        logger.info("[OK] All models loaded successfully")
        return _model, _scaler, _feature_names, _age_norms
        
    except Exception as e:
        logger.error(f"[ERROR] Error loading models: {str(e)}")
        raise FileNotFoundError(f"Error loading models: {str(e)}")

def load_v3_models():
    """
    Load all v3 hybrid model components for the 2-3.5 age group.
    Uses singleton pattern to cache models in memory.
    """
    global _v3_binary_model, _v3_severity_model, _v3_scaler, _v3_le_gender, _v3_le_lang, _v3_config
    
    if _v3_binary_model is not None:
        return _v3_binary_model, _v3_severity_model, _v3_scaler, _v3_le_gender, _v3_le_lang, _v3_config
        
    logger.info("Loading SenseAI Cognitive Flexibility v3 Model Ensemble...")
    
    try:
        # Load specific pkl files
        if not AGE_2_V3_BINARY_MODEL_PATH.exists():
            raise FileNotFoundError(f"v3 Binary model not found: {AGE_2_V3_BINARY_MODEL_PATH}")
        _v3_binary_model = joblib.load(AGE_2_V3_BINARY_MODEL_PATH)
        
        if not AGE_2_V3_SEVERITY_MODEL_PATH.exists():
            raise FileNotFoundError(f"v3 Severity model not found: {AGE_2_V3_SEVERITY_MODEL_PATH}")
        _v3_severity_model = joblib.load(AGE_2_V3_SEVERITY_MODEL_PATH)
        
        if not AGE_2_V3_SCALER_PATH.exists():
            raise FileNotFoundError(f"v3 Scaler not found: {AGE_2_V3_SCALER_PATH}")
        _v3_scaler = joblib.load(AGE_2_V3_SCALER_PATH)
        
        if not AGE_2_V3_LE_GENDER_PATH.exists():
            raise FileNotFoundError(f"v3 Gender Encoder not found: {AGE_2_V3_LE_GENDER_PATH}")
        _v3_le_gender = joblib.load(AGE_2_V3_LE_GENDER_PATH)
        
        if not AGE_2_V3_LE_LANG_PATH.exists():
            raise FileNotFoundError(f"v3 Language Encoder not found: {AGE_2_V3_LE_LANG_PATH}")
        _v3_le_lang = joblib.load(AGE_2_V3_LE_LANG_PATH)
        
        # Load config if available
        if AGE_2_V3_CONFIG_PATH.exists():
            with open(AGE_2_V3_CONFIG_PATH, 'r') as f:
                _v3_config = json.load(f)
        
        logger.info("[OK] v3 Model Ensemble loaded successfully")
        return _v3_binary_model, _v3_severity_model, _v3_scaler, _v3_le_gender, _v3_le_lang, _v3_config
        
    except Exception as e:
        logger.error(f"[ERROR] Failed to load v3 models: {str(e)}")
        # Don't raise here, allow the app to boot even if v3 fails (it will error on use)
        return None, None, None, None, None, None

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
        # Check legacy models
        model_loaded = _model is not None
        
        # Check v3 models
        v3_loaded = _v3_binary_model is not None
        
        status = {
            "legacy": {
                "loaded": model_loaded,
                "model_path": str(MODEL_PATH) if MODEL_PATH.exists() else str(MODEL_PATH_ALT),
                "scaler_path": str(SCALER_PATH),
            },
            "v3_cogflex": {
                "loaded": v3_loaded,
                "age_group": "2-3.5",
                "ready": v3_loaded and _v3_scaler is not None
            }
        }
        
        return status
    except Exception as e:
        return {
            "loaded": False,
            "error": str(e)
        }

# Load models at module import
try:
    load_models()
    load_v3_models()
except Exception:
    pass

