#!/usr/bin/env python3
"""
ML Prediction Script for SenseAI Backend
Predicts ASD risk from ML features using trained model

This script:
1. Loads trained model, scaler, and feature names
2. Optionally performs age normalization (if control norms available)
3. Orders features correctly
4. Scales features
5. Makes predictions
"""

import sys
import json
import joblib
import numpy as np
from pathlib import Path

# Get script directory
SCRIPT_DIR = Path(__file__).parent
MODEL_DIR = SCRIPT_DIR.parent / 'models'

# Model file paths (supports both naming conventions)
MODEL_PATH = MODEL_DIR / 'asd_detection_model.pkl'
MODEL_PATH_ALT = MODEL_DIR / 'asd_screening_model_calibrated.pkl'  # Alternative name
SCALER_PATH = MODEL_DIR / 'feature_scaler.pkl'
FEATURES_PATH = MODEL_DIR / 'feature_names.json'
AGE_NORMS_PATH = MODEL_DIR / 'age_norms.json'  # Optional: control group norms for age normalization

def load_models():
    """Load trained model, scaler, feature names, and age norms"""
    try:
        # Try primary model name first, then alternative
        if MODEL_PATH.exists():
            model = joblib.load(MODEL_PATH)
        elif MODEL_PATH_ALT.exists():
            model = joblib.load(MODEL_PATH_ALT)
        else:
            raise FileNotFoundError(f"Model not found. Expected: {MODEL_PATH} or {MODEL_PATH_ALT}")
        
        scaler = joblib.load(SCALER_PATH)
        
        # Load feature names if available
        feature_names = None
        if FEATURES_PATH.exists():
            with open(FEATURES_PATH, 'r') as f:
                feature_data = json.load(f)
                # Handle both formats: array or object with 'feature_names' key
                if isinstance(feature_data, list):
                    feature_names = feature_data
                elif isinstance(feature_data, dict) and 'feature_names' in feature_data:
                    feature_names = feature_data['feature_names']
                else:
                    feature_names = feature_data
        
        # Load age norms if available (for age normalization)
        age_norms = None
        if AGE_NORMS_PATH.exists():
            with open(AGE_NORMS_PATH, 'r') as f:
                age_norms = json.load(f)
        
        return model, scaler, feature_names, age_norms
    except Exception as e:
        print(f"Error loading models: {e}", file=sys.stderr)
        sys.exit(1)

def calculate_zscore(value, age_months, feature_name, age_norms):
    """
    Calculate Z-score for a feature using age-normalized control group norms
    
    Args:
        value: Raw feature value
        age_months: Child's age in months
        feature_name: Name of the feature
        age_norms: Dictionary with control group norms by age band
    
    Returns:
        Z-score (normalized value)
    """
    if age_norms is None:
        return value  # No normalization available, return raw value
    
    # Find appropriate age band (±6 months)
    age_band = None
    for band in age_norms.keys():
        # Age bands are like "30-42", "42-54", etc.
        try:
            if '-' in band:
                low, high = map(int, band.split('-'))
                if low <= age_months <= high:
                    age_band = band
                    break
        except:
            continue
    
    # If no exact match, use closest or overall mean
    if age_band is None:
        # Use overall control mean/std
        if 'overall' in age_norms and feature_name in age_norms['overall']:
            stats = age_norms['overall'][feature_name]
            mean_val = stats.get('mean', 0)
            std_val = stats.get('std', 1)
            if std_val > 0:
                return (value - mean_val) / std_val
        return value
    
    # Get stats for this age band and feature
    if age_band in age_norms and feature_name in age_norms[age_band]:
        stats = age_norms[age_band][feature_name]
        mean_val = stats.get('mean', 0)
        std_val = stats.get('std', 1)
        if std_val > 0:
            return (value - mean_val) / std_val
    
    # Fallback to overall stats
    if 'overall' in age_norms and feature_name in age_norms['overall']:
        stats = age_norms['overall'][feature_name]
        mean_val = stats.get('mean', 0)
        std_val = stats.get('std', 1)
        if std_val > 0:
            return (value - mean_val) / std_val
    
    return value  # No normalization available

def normalize_features(features_dict, age_months, age_norms):
    """
    Normalize features by calculating Z-scores for features that need it
    
    Features ending in '_zscore' need to be calculated from raw features
    """
    normalized = features_dict.copy()
    
    if age_norms is None:
        # No age norms available, return features as-is
        return normalized
    
    # Features that need age normalization (create Z-scores)
    features_to_normalize = [
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
    
    # Calculate Z-scores for features that need normalization
    for feature in features_to_normalize:
        if feature in features_dict:
            raw_value = features_dict[feature]
            if raw_value is not None:
                zscore = calculate_zscore(raw_value, age_months, feature, age_norms)
                normalized[f'{feature}_zscore'] = zscore
    
    return normalized

def predict(features_dict, age_months=None, age_group=None, session_type=None):
    """
    Predict ASD risk from ML features
    
    Args:
        features_dict: Dictionary of feature values (raw features from frontend)
        age_months: Child's age in months (for age normalization)
        age_group: Age group (e.g., '2-3', '3-5', '5-6') - optional
        session_type: Type of session (e.g., 'color_shape', 'frog_jump') - optional
    
    Returns:
        Dictionary with prediction results
    """
    model, scaler, feature_names, age_norms = load_models()
    
    # Extract age_months from features if not provided
    if age_months is None:
        age_months = features_dict.get('age_months', 36)  # Default to 36 months
    
    # Normalize age_months to int
    try:
        age_months = int(float(age_months))
    except:
        age_months = 36
    
    # Perform age normalization if norms are available
    if age_norms is not None:
        features_dict = normalize_features(features_dict, age_months, age_norms)
    
    # CRITICAL: The scaler knows how many features the model expects
    # We need to match that exactly, regardless of feature_names.json length
    expected_n_features = scaler.n_features_in_
    
    # If feature names file exists, use it to order features
    # But only use the first N features that match what the model expects
    if feature_names:
        # Check if feature_names matches model expectations
        if len(feature_names) != expected_n_features:
            print(f"Warning: feature_names.json has {len(feature_names)} features, "
                  f"but model expects {expected_n_features}. Using first {expected_n_features} features.",
                  file=sys.stderr)
            # Use only the first N features that match model expectations
            feature_names = feature_names[:expected_n_features]
        
        # Extract features in correct order (ONLY the features the model expects)
        feature_vector = []
        missing_features = []
        for feature_name in feature_names:
            if feature_name in features_dict:
                value = features_dict[feature_name]
            else:
                # Feature not provided, use default 0
                value = 0
                missing_features.append(feature_name)
            
            # Handle None values
            if value is None:
                value = 0
            
            try:
                feature_vector.append(float(value))
            except (ValueError, TypeError):
                feature_vector.append(0.0)
        
        # Warn about missing features (for debugging)
        if missing_features:
            print(f"Warning: Missing features (using 0): {missing_features}", file=sys.stderr)
        
        # Verify we have the right number of features
        if len(feature_vector) != expected_n_features:
            raise ValueError(
                f"Feature count mismatch: Expected {expected_n_features} features, "
                f"but got {len(feature_vector)}. "
                f"Please check feature_names.json matches your trained model."
            )
    else:
        # If no feature names file, we can't know which features to use
        # This is an error - we need feature_names.json
        raise ValueError(
            f"feature_names.json not found. Model expects {expected_n_features} features. "
            "Please ensure feature_names.json exists in models/ directory with the correct features."
        )
    
    # Convert to numpy array and reshape
    features = np.array(feature_vector).reshape(1, -1)
    
    # Scale features (using the same scaler from training)
    features_scaled = scaler.transform(features)
    
    # Predict
    prediction = model.predict(features_scaled)[0]
    probabilities = model.predict_proba(features_scaled)[0]
    
    # Calculate risk score and level
    asd_probability = probabilities[1]  # Probability of ASD
    risk_score = asd_probability * 100
    
    if risk_score < 30:
        risk_level = 'low'
    elif risk_score < 70:
        risk_level = 'moderate'
    else:
        risk_level = 'high'
    
    return {
        'prediction': int(prediction),
        'probability': probabilities.tolist(),
        'confidence': float(max(probabilities)),
        'risk_level': risk_level,
        'risk_score': float(risk_score),
        'asd_probability': float(asd_probability),
    }

if __name__ == '__main__':
    try:
        # Read input from command line or stdin
        input_str = None
        
        if len(sys.argv) >= 2:
            # Try command line argument first
            input_str = sys.argv[1]
        else:
            # Try reading from stdin
            import sys
            if not sys.stdin.isatty():
                input_str = sys.stdin.read()
        
        if not input_str:
            print(json.dumps({
                'error': 'No input data provided. Usage: python predict.py \'{"features": {...}}\''
            }), file=sys.stderr)
            sys.exit(1)
        
        # Parse JSON input
        try:
            input_data = json.loads(input_str)
        except json.JSONDecodeError as e:
            print(json.dumps({
                'error': f'Invalid JSON: {str(e)}',
                'hint': 'Make sure to properly escape quotes in PowerShell: use \\" or create a JSON file'
            }), file=sys.stderr)
            sys.exit(1)
        
        # Extract age_months if provided
        age_months = input_data.get('age_months')
        if age_months is None:
            # Try to get from features
            age_months = input_data.get('features', {}).get('age_months')
        
        result = predict(
            input_data.get('features', {}),
            age_months=age_months,
            age_group=input_data.get('age_group', 'unknown'),
            session_type=input_data.get('session_type', 'unknown')
        )
        
        # Output JSON result
        print(json.dumps(result))
        
    except Exception as e:
        print(json.dumps({
            'error': str(e),
            'type': type(e).__name__
        }), file=sys.stderr)
        sys.exit(1)
