#!/usr/bin/env python3
"""
Test script for ML prediction engine
Easier to use than command-line with PowerShell quote issues
"""

import json
import sys
from pathlib import Path

# Add ml_scripts to path
sys.path.insert(0, str(Path(__file__).parent / 'ml_scripts'))

from predict import predict

# Test data - only include features that the model expects
# The model will automatically filter to only use features from feature_names.json
# So you can include extra features, but only the ones in feature_names.json will be used
test_features = {
    "age_months": 48,
    "post_switch_accuracy": 65,
    "perseverative_error_rate_post_switch": 35,
    "switch_cost_ms": 450,
    "commission_error_rate": 28,
    "rt_variability": 280,
    "nogo_accuracy": 70,
    "avg_rt_pre_switch_ms": 800,
    "avg_rt_post_switch_correct_ms": 1200,
    "accuracy_drop_percent": 15,
    "go_accuracy": 85,
    "avg_rt_go_ms": 600,
    "critical_items_failed": 2,
    "social_responsiveness_score": 60,
    "joint_attention_score": 55,
    "attention_level": 3,
    "engagement_level": 4,
    "frustration_tolerance": 3,
    "accuracy_overall": 70,
    "completion_time_sec": 180,
    # Note: The model will only use features listed in feature_names.json
    # Extra features here are ignored (which is fine)
}

if __name__ == '__main__':
    print("🧪 Testing ML Prediction Engine")
    print("=" * 50)
    
    try:
        result = predict(
            test_features,
            age_months=48,
            age_group="4-5",
            session_type="color_shape"
        )
        
        print("\n✅ Prediction Successful!")
        print("\n📊 Results:")
        print(json.dumps(result, indent=2))
        
        print("\n📋 Summary:")
        print(f"   Prediction: {'ASD Risk' if result['prediction'] == 1 else 'Control'}")
        print(f"   Risk Level: {result['risk_level'].upper()}")
        print(f"   Risk Score: {result['risk_score']:.1f}%")
        print(f"   ASD Probability: {result['asd_probability']*100:.1f}%")
        print(f"   Confidence: {result['confidence']*100:.1f}%")
        
    except FileNotFoundError as e:
        print(f"\n❌ Error: {e}")
        print("\n💡 Make sure model files are in senseai_backend/models/")
        print("   Required files:")
        print("     - asd_detection_model.pkl (or asd_screening_model_calibrated.pkl)")
        print("     - feature_scaler.pkl")
        print("     - feature_names.json (optional but recommended)")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print(f"   Type: {type(e).__name__}")
        import traceback
        traceback.print_exc()

