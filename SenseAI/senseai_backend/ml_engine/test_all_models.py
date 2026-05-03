"""Test all 3 cognitive flexibility models."""
import requests
import json

BASE = "http://localhost:8002/predict"

def test_model(name, payload):
    print("=" * 60)
    print(f"TEST: {name}")
    print("=" * 60)
    try:
        r = requests.post(f"{BASE}/cognitive-flexibility", json=payload)
        if r.ok:
            d = r.json()
            print(f"  Model:   {d.get('model_age_group')}")
            print(f"  Risk:    {d.get('risk_level')}")
            print(f"  ASD Prob:{d.get('asd_probability')}")
            print(f"  Hybrid:  {d.get('hybrid_score')}")
            print(f"  Severity:{d.get('severity')}")
            print(f"  Override:{d.get('clinical_override')}")
            print(f"  PASS ✓")
            return True
        else:
            print(f"  ERROR {r.status_code}: {r.text[:300]}")
            return False
    except Exception as e:
        print(f"  EXCEPTION: {e}")
        return False


# TEST 1: Age 2-3.5 (v3 Questionnaire)
t1 = test_model("Age 2-3.5 (v3 Hybrid - Questionnaire)", {
    "age_months": 30,
    "features": {
        "age_months": 30,
        "q1_name_response": 4, "q2_routine_change": 4, "q3_toy_switching": 3,
        "q4_eye_contact": 4, "q5_pointing": 3, "q6_sensory_reaction": 4,
        "q7_imitation": 4, "q8_peer_play": 3, "q9_joint_attention": 4,
        "q10_communication": 4,
        "attention_level": 4, "engagement_level": 4,
        "frustration_tolerance": 3, "instruction_following": 4,
        "completion_time_sec": 300
    }
})

print()

# TEST 2: Age 3.5-5.5 (v4 Frog Jump)
t2 = test_model("Age 3.5-5.5 (v4 Hybrid - Frog Jump)", {
    "age_months": 50,
    "features": {
        "age_months": 50,
        "go_accuracy": 85.0, "rt_variability": 150.0, "avg_rt_go_ms": 800.0,
        "attention_level": 4, "engagement_level": 4,
        "frustration_tolerance": 3, "instruction_following": 4,
        "overall_behavior": 4
    }
})

print()

# TEST 3: Age 5.5-6.9 (v5 Color-Shape/DCCS)
t3 = test_model("Age 5.5-6.9 (v5 Hybrid - Color-Shape/DCCS)", {
    "age_months": 72,
    "features": {
        "age_months": 72,
        "post_switch_accuracy": 85.0,
        "perseverative_error_rate_post_switch": 5.0,
        "number_of_consecutive_perseverations": 2,
        "switch_cost_ms": 300.0,
        "mixed_block_accuracy": 80.0,
        "longest_streak_correct": 10,
        "total_trials": 16,
        "accuracy_overall": 82.0,
        "total_perseverative_errors": 3,
        "attention_level": 4, "engagement_level": 4,
        "frustration_tolerance": 3, "instruction_following": 4,
        "overall_behavior": 4
    }
})

print()
print("=" * 60)
results = ["PASS" if t else "FAIL" for t in [t1, t2, t3]]
print(f"RESULTS: Age 2-3.5={results[0]}, Age 3.5-5.5={results[1]}, Age 5.5-6.9={results[2]}")
if all([t1, t2, t3]):
    print("ALL 3 MODELS RUNNING CORRECTLY ✓")
else:
    print("SOME MODELS FAILED ✗")
print("=" * 60)
