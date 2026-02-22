#!/usr/bin/env python3
"""
Test script for ML Engine
Tests prediction endpoint locally
"""

import requests
import json
from pathlib import Path

ML_ENGINE_URL = "http://localhost:8001"

def test_health():
    """Test health endpoint"""
    print("🔍 Testing health endpoint...")
    response = requests.get(f"{ML_ENGINE_URL}/health")
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))
    print()

def test_predict():
    """Test prediction endpoint"""
    print("🧪 Testing prediction endpoint...")
    
    # Load sample input
    sample_file = Path(__file__).parent.parent / "data" / "sample_input.json"
    if sample_file.exists():
        with open(sample_file, 'r') as f:
            data = json.load(f)
    else:
        # Use default test data
        data = {
            "age_months": 48,
            "features": {
                "age_months": 48,
                "post_switch_accuracy": 65,
                "switch_cost_ms": 450,
                "perseverative_error_rate_post_switch": 35
            }
        }
    
    response = requests.post(
        f"{ML_ENGINE_URL}/predict",
        json=data
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print("✅ Prediction Successful!")
        print(json.dumps(result, indent=2))
        print()
        print("📊 Summary:")
        print(f"   Prediction: {'ASD Risk' if result['prediction'] == 1 else 'Control'}")
        print(f"   Risk Level: {result['risk_level'].upper()}")
        print(f"   Risk Score: {result['risk_score']:.1f}%")
        print(f"   ASD Probability: {result['asd_probability']*100:.1f}%")
    else:
        print("❌ Error:")
        print(response.text)

if __name__ == "__main__":
    try:
        test_health()
        test_predict()
    except requests.exceptions.ConnectionError:
        print("❌ Error: Cannot connect to ML Engine")
        print(f"   Make sure the service is running at {ML_ENGINE_URL}")
        print("   Start it with: uvicorn app.main:app --reload --port 8001")
    except Exception as e:
        print(f"❌ Error: {e}")


