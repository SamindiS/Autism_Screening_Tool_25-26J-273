#!/usr/bin/env python3
"""
Check what features your trained model expects
"""

import joblib
import json
from pathlib import Path

MODEL_DIR = Path(__file__).parent / 'models'
MODEL_PATH = MODEL_DIR / 'asd_detection_model.pkl'
MODEL_PATH_ALT = MODEL_DIR / 'asd_screening_model_calibrated.pkl'
SCALER_PATH = MODEL_DIR / 'feature_scaler.pkl'
FEATURES_PATH = MODEL_DIR / 'feature_names.json'

print("🔍 Checking Model Features")
print("=" * 50)

try:
    # Load scaler to check expected features
    if SCALER_PATH.exists():
        scaler = joblib.load(SCALER_PATH)
        expected_features = scaler.n_features_in_
        print(f"\n✅ Model expects: {expected_features} features")
    else:
        print("\n❌ Scaler file not found!")
        exit(1)
    
    # Check feature_names.json
    if FEATURES_PATH.exists():
        with open(FEATURES_PATH, 'r') as f:
            feature_data = json.load(f)
            if isinstance(feature_data, list):
                feature_names = feature_data
            elif isinstance(feature_data, dict) and 'feature_names' in feature_data:
                feature_names = feature_data['feature_names']
            else:
                feature_names = feature_data
        
        print(f"✅ feature_names.json has: {len(feature_names)} features")
        
        if len(feature_names) == expected_features:
            print("\n✅ Perfect match! feature_names.json is correct.")
        else:
            print(f"\n⚠️  MISMATCH!")
            print(f"   Model expects: {expected_features} features")
            print(f"   feature_names.json has: {len(feature_names)} features")
            print(f"\n💡 Solution:")
            print(f"   Update feature_names.json to only include the first {expected_features} features:")
            print(f"\n   {json.dumps(feature_names[:expected_features], indent=2)}")
    else:
        print("\n⚠️  feature_names.json not found!")
        print(f"   Model expects {expected_features} features")
        print("   You need to create feature_names.json with the correct features")
    
    # Check model file
    if MODEL_PATH.exists():
        print(f"\n✅ Model file found: {MODEL_PATH.name}")
    elif MODEL_PATH_ALT.exists():
        print(f"\n✅ Model file found: {MODEL_PATH_ALT.name}")
    else:
        print("\n❌ Model file not found!")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    import traceback
    traceback.print_exc()


