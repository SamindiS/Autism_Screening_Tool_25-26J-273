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

# Model file paths
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

# Age band definitions (for normalization)
AGE_BANDS = {
    "24-36": (24, 36),
    "36-48": (36, 48),
    "48-60": (48, 60),
    "60-72": (60, 72),
}

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
DEFAULT_PORT = 8001
DEFAULT_HOST = "0.0.0.0"

