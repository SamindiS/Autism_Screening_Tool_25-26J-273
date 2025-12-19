#!/usr/bin/env python3
"""
ML Prediction Script for SenseAI Backend
Predicts ASD risk from ML features using trained model
"""

import sys
import json
import joblib
import numpy as np
from pathlib import Path

# Get script directory
SCRIPT_DIR = Path(__file__).parent
MODEL_DIR = SCRIPT_DIR.parent / 'models'

# Model file paths
MODEL_PATH = MODEL_DIR / 'asd_detection_model.pkl'
SCALER_PATH = MODEL_DIR / 'feature_scaler.pkl'
FEATURES_PATH = MODEL_DIR / 'feature_names.json'

def load_models():
    """Load trained model, scaler, and feature names"""
    try:
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        
        # Load feature names if available
        feature_names = None
        if FEATURES_PATH.exists():
            with open(FEATURES_PATH, 'r') as f:
                feature_names = json.load(f)
        
        return model, scaler, feature_names
    except Exception as e:
        print(f"Error loading models: {e}", file=sys.stderr)
        sys.exit(1)

def predict(features_dict, age_group, session_type):
    """
    Predict ASD risk from ML features
    
    Args:
        features_dict: Dictionary of feature values
        age_group: Age group (e.g., '2-3', '3-5', '5-6')
        session_type: Type of session (e.g., 'color_shape', 'frog_jump', 'ai_doctor_bot')
    
    Returns:
        Dictionary with prediction results
    """
    model, scaler, feature_names = load_models()
    
    # If feature names file exists, use it to order features
    if feature_names:
        # Extract features in correct order
        feature_vector = []
        for feature_name in feature_names:
            value = features_dict.get(feature_name, 0)
            # Handle None values
            if value is None:
                value = 0
            feature_vector.append(float(value))
    else:
        # If no feature names file, use all features from dict
        # Sort keys for consistency
        sorted_keys = sorted(features_dict.keys())
        feature_vector = []
        for key in sorted_keys:
            value = features_dict[key]
            if value is None:
                value = 0
            feature_vector.append(float(value))
    
    # Convert to numpy array and reshape
    features = np.array(feature_vector).reshape(1, -1)
    
    # Scale features
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
        # Read input from command line
        if len(sys.argv) < 2:
            print(json.dumps({
                'error': 'No input data provided'
            }), file=sys.stderr)
            sys.exit(1)
        
        input_data = json.loads(sys.argv[1])
        
        result = predict(
            input_data['features'],
            input_data.get('age_group', 'unknown'),
            input_data.get('session_type', 'unknown')
        )
        
        # Output JSON result
        print(json.dumps(result))
        
    except Exception as e:
        print(json.dumps({
            'error': str(e)
        }), file=sys.stderr)
        sys.exit(1)




