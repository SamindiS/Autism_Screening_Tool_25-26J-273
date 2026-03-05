"""
Configuration file for ML Training Pipeline
All model configurations, paths, and hyperparameters
"""

import os
from pathlib import Path

# Base paths
BASE_DIR = Path(__file__).parent
PROJECT_ROOT = BASE_DIR.parent
DATA_DIR = PROJECT_ROOT / "SAMPLE_DATASETS"
PREPARED_DATA_DIR = DATA_DIR / "prepared"
MODELS_DIR = BASE_DIR / "models"
ONLINE_DATASETS_DIR = PROJECT_ROOT / "Online Datasets"

# Output directories
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(exist_ok=True)
OUTPUT_DIR.mkdir(exist_ok=True)

# Model output paths
MODELS_DIR.mkdir(exist_ok=True)

# ============================================================================
# AGE 2-3.5: QUESTIONNAIRE MODEL CONFIGURATION
# ============================================================================

AGE_2_3_5_CONFIG = {
    "age_range": (24, 42),  # months
    "session_type": "ai_doctor_bot",
    "model_name": "model_age_2_3_5_questionnaire",
    
    # Data paths
    "external_datasets": [
        {
            "path": ONLINE_DATASETS_DIR / "Toddler Autism dataset July 2018.csv",
            "age_col": "Age_Mons",
            "qchat_col": "Qchat-10-Score",
            "class_col": "Class/ASD Traits"
        },
        {
            "path": ONLINE_DATASETS_DIR / "Autism screening data for toddlers" / "Autism_Screening_Data_Combined.csv",
            "age_col": "Age",
            "qchat_col": None,
            "class_col": "Class"
        }
    ],
    "hospital_datasets": [
        DATA_DIR / "age_2_3_questionnaire_asd.csv.csv",
        DATA_DIR / "age_2_3_questionnaire_control.csv",
        PROJECT_ROOT / "senseai_backend" / "export_1767641156571.csv"
    ],
    
    # Feature engineering
    "features": [
        "age_months",
        "critical_items_failed",
        "completion_time_sec",
        "social_responsiveness_zscore",
        "joint_attention_zscore",
        "total_score_zscore",
        "low_attention_flag",
        "high_critical_items_flag",
        "low_social_flag"
    ],
    
    # Age bins for normalization
    "age_bins": [24, 30, 36, 42],
    
    # Model hyperparameters
    "logistic_regression": {
        "max_iter": 2000,
        "class_weight": "balanced",
        "solver": "liblinear",
        "random_state": 42,
        "C": 1.0
    },
    "random_forest": {
        "n_estimators": 100,
        "max_depth": 5,
        "min_samples_leaf": 5,
        "class_weight": "balanced",
        "random_state": 42
    },
    
    # Training parameters
    "test_size": 0.2,
    "random_state": 42,
    "cv_folds": 5,
    
    # Augmentation
    "augmentation": {
        "enabled": True,
        "method": "bootstrap",  # or "smote"
        "target_samples": 2000,  # Target training samples after augmentation
        "bootstrap_samples": 3  # Bootstrap multiplier
    },
    
    # Outlier detection
    "outlier_detection": {
        "enabled": True,
        "method": "iqr",  # or "zscore"
        "iqr_factor": 1.5,
        "winsorize": True,
        "winsorize_limits": (0.01, 0.99)
    }
}

# ============================================================================
# AGE 3.5-5.5: FROG JUMP MODEL CONFIGURATION
# ============================================================================

AGE_3_5_5_5_CONFIG = {
    "age_range": (42, 66),  # months
    "session_type": "frog_jump",
    "model_name": "model_age_3_5_5_5_frog_jump",
    
    # Data paths
    "external_datasets": [
        {
            "path": ONLINE_DATASETS_DIR / "Autism screening data for toddlers" / "Autism_Screening_Data_Combined.csv",
            "age_col": "Age",
            "class_col": "Class",
            "type": "questionnaire"  # Auxiliary features only
        }
    ],
    "hospital_datasets": [
        # Add your hospital game data paths here
        DATA_DIR / "age_3_5_5_5_frog_jump_data.csv"  # Update with actual path
    ],
    
    # Feature engineering
    "game_features": [
        "age_months",
        "go_accuracy",
        "nogo_accuracy",
        "overall_accuracy",
        "commission_errors",
        "commission_error_rate",
        "omission_errors",
        "omission_error_rate",
        "avg_rt_go_ms",
        "rt_variability",
        "inhibition_failure_rate",
        "anticipatory_responses",
        "late_responses"
    ],
    "auxiliary_features": [
        "questionnaire_score",  # From external dataset
        "critical_items_failed",
        "social_responsiveness_score"
    ],
    "clinical_features": [
        "attention_level",
        "engagement_level",
        "frustration_tolerance",
        "instruction_following",
        "overall_behavior"
    ],
    
    # Age bins for normalization
    "age_bins": [42, 48, 54, 60, 66],
    
    # Model hyperparameters
    "logistic_regression": {
        "max_iter": 2000,
        "class_weight": "balanced",
        "solver": "liblinear",
        "random_state": 42,
        "C": 1.0
    },
    "random_forest": {
        "n_estimators": 100,
        "max_depth": 5,
        "min_samples_leaf": 5,
        "class_weight": "balanced",
        "random_state": 42
    },
    
    # Training parameters
    "test_size": 0.2,
    "random_state": 42,
    "cv_folds": 5,
    
    # Augmentation
    "augmentation": {
        "enabled": True,
        "method": "bootstrap",
        "target_samples": 500,
        "bootstrap_samples": 5
    },
    
    # Outlier detection
    "outlier_detection": {
        "enabled": True,
        "method": "iqr",
        "iqr_factor": 1.5,
        "winsorize": True,
        "winsorize_limits": (0.01, 0.99)
    }
}

# ============================================================================
# AGE 5.5-6.9: COLOR-SHAPE MODEL CONFIGURATION
# ============================================================================

AGE_5_5_6_9_CONFIG = {
    "age_range": (66, 83),  # months
    "session_type": "color_shape",
    "model_name": "model_age_5_5_6_9_color_shape",
    
    # Data paths
    "external_datasets": [
        {
            "path": ONLINE_DATASETS_DIR / "Autism screening data for toddlers" / "Autism_Screening_Data_Combined.csv",
            "age_col": "Age",
            "class_col": "Class",
            "type": "questionnaire"  # Auxiliary features only
        }
    ],
    "hospital_datasets": [
        # Add your hospital game data paths here
        DATA_DIR / "age_5_5_6_9_color_shape_data.csv"  # Update with actual path
    ],
    
    # Feature engineering
    "game_features": [
        "age_months",
        "pre_switch_accuracy",
        "post_switch_accuracy",
        "mixed_block_accuracy",
        "switch_cost_ms",
        "accuracy_drop_percent",
        "total_perseverative_errors",
        "perseverative_error_rate_post_switch",
        "number_of_consecutive_perseverations",
        "avg_rt_pre_switch_ms",
        "avg_rt_post_switch_correct_ms",
        "rt_variability"
    ],
    "auxiliary_features": [
        "questionnaire_score",
        "critical_items_failed",
        "social_responsiveness_score"
    ],
    "clinical_features": [
        "attention_level",
        "engagement_level",
        "frustration_tolerance",
        "instruction_following",
        "overall_behavior"
    ],
    
    # Age bins for normalization
    "age_bins": [66, 72, 78, 83],
    
    # Model hyperparameters
    "logistic_regression": {
        "max_iter": 2000,
        "class_weight": "balanced",
        "solver": "liblinear",
        "random_state": 42,
        "C": 1.0
    },
    "random_forest": {
        "n_estimators": 100,
        "max_depth": 5,
        "min_samples_leaf": 5,
        "class_weight": "balanced",
        "random_state": 42
    },
    
    # Training parameters
    "test_size": 0.2,
    "random_state": 42,
    "cv_folds": 5,
    
    # Augmentation
    "augmentation": {
        "enabled": True,
        "method": "bootstrap",
        "target_samples": 300,
        "bootstrap_samples": 10
    },
    
    # Outlier detection
    "outlier_detection": {
        "enabled": True,
        "method": "iqr",
        "iqr_factor": 1.5,
        "winsorize": True,
        "winsorize_limits": (0.01, 0.99)
    }
}

# ============================================================================
# SHARED CONFIGURATION
# ============================================================================

# Clinical risk thresholds
RISK_THRESHOLDS = {
    "high": 0.7,      # >= 70% probability = HIGH risk
    "moderate": 0.4,  # 40-70% = MODERATE risk
    "low": 0.0        # < 40% = LOW risk
}

# Evaluation metrics
EVALUATION_METRICS = [
    "accuracy",
    "precision",
    "recall",
    "f1_score",
    "roc_auc",
    "pr_auc"
]

# Model persistence
MODEL_EXTENSIONS = {
    "model": ".pkl",
    "scaler": ".pkl",
    "features": ".json",
    "metadata": ".json"
}
