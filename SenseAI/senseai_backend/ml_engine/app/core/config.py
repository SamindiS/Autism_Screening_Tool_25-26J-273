"""
Centralized configuration for ML Engine
Ensures reproducibility and prevents hard-coded paths
"""

from pathlib import Path
from typing import Dict

# Base directory (ml_engine/)
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Model directory
MODEL_DIR = BASE_DIR / "models"

# Age-specific model paths
AGE_2_3_5_MODEL_PATH = MODEL_DIR / "model_age_2_3_5_questionnaire.pkl"
AGE_2_3_5_SCALER_PATH = MODEL_DIR / "scaler_age_2_3_5_questionnaire.pkl"
AGE_2_3_5_FEATURES_PATH = MODEL_DIR / "features_age_2_3_5_questionnaire.json"
AGE_2_3_5_METADATA_PATH = MODEL_DIR / "model_metadata_age_2_3_5.json"

AGE_3_5_5_5_MODEL_PATH = MODEL_DIR / "model_age_3_5_5_5_frog_jump.pkl"
AGE_3_5_5_5_SCALER_PATH = MODEL_DIR / "scaler_age_3_5_5_5_frog_jump.pkl"
AGE_3_5_5_5_FEATURES_PATH = MODEL_DIR / "features_age_3_5_5_5_frog_jump.json"
AGE_3_5_5_5_METADATA_PATH = MODEL_DIR / "model_metadata_age_3_5_5_5.json"

AGE_5_5_6_9_MODEL_PATH = MODEL_DIR / "model_age_5_5_6_9_color_shape.pkl"
AGE_5_5_6_9_SCALER_PATH = MODEL_DIR / "scaler_age_5_5_6_9_color_shape.pkl"
AGE_5_5_6_9_FEATURES_PATH = MODEL_DIR / "features_age_5_5_6_9_color_shape.json"
AGE_5_5_6_9_METADATA_PATH = MODEL_DIR / "model_metadata_age_5_5_6_9_color_shape.json"

# Legacy model paths (for backward compatibility)
MODEL_PATH = MODEL_DIR / "asd_detection_model.pkl"
MODEL_PATH_ALT = MODEL_DIR / "asd_screening_model_calibrated.pkl"
SCALER_PATH = MODEL_DIR / "feature_scaler.pkl"
FEATURES_PATH = MODEL_DIR / "feature_names.json"
AGE_NORMS_PATH = MODEL_DIR / "age_norms.json"
MODEL_METADATA_PATH = MODEL_DIR / "model_metadata.json"

# Risk score thresholds
RISK_THRESHOLDS: Dict[str, float] = {
    "HIGH": 0.7,      # >= 70% = HIGH risk
    "MODERATE": 0.4,  # >= 40% = MODERATE risk
    # < 40% = LOW risk
}

# Age group definitions (for model routing)
AGE_GROUPS = {
    "2-3.5": (24, 42),      # Age 2-3.5 years (24-42 months) - Questionnaire
    "3.5-5.5": (42, 66),    # Age 3.5-5.5 years (42-66 months) - Frog Jump
    "5.5-6.9": (66, 83),    # Age 5.5-6.9 years (66-83 months) - Color-Shape
}

# Age band definitions (for normalization - legacy)
AGE_BANDS = {
    "24-36": (24, 36),
    "36-48": (36, 48),
    "48-60": (48, 60),
    "60-72": (60, 72),
}

def get_age_group(age_months: int) -> str:
    """
    Determine age group from age in months
    
    Args:
        age_months: Age in months
        
    Returns:
        Age group string: '2-3.5', '3.5-5.5', '5.5-6.9', or None
    """
    if 24 <= age_months < 42:
        return "2-3.5"
    elif 42 <= age_months < 66:
        return "3.5-5.5"
    elif 66 <= age_months < 83:
        return "5.5-6.9"
    else:
        return None

# Features that require age normalization (Z-scores)
FEATURES_TO_NORMALIZE = [
    'post_switch_accuracy',
    'perseverative_error_rate_post_switch',
    'switch_cost_ms',
    'avg_rt_pre_switch_ms',
    'avg_rt_post_switch_correct_ms',
    'accuracy_drop_percent',
    'nogo_accuracy',
    'commission_error_rate',
    'rt_variability',
    'avg_rt_go_ms',
]

# API Configuration
API_TITLE = "SenseAI ASD ML Engine"
API_DESCRIPTION = "Machine Learning Inference Service for Autism Spectrum Disorder Screening"
API_VERSION = "1.0.0"

# Service Configuration
DEFAULT_PORT = 8002  # Changed from 8001 due to port conflict
DEFAULT_HOST = "0.0.0.0"


