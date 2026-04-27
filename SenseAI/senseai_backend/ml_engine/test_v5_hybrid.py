import sys
from pathlib import Path

# Add app directory to path
sys.path.append(str(Path(__file__).resolve().parent.parent))

from app.ml.predictor import predict_asd_v5_hybrid_5_5
from app.schemas.request import PredictionRequest
import json

def test_v5_hybrid_guardrail():
    print("\n🔍 Testing v5 Hybrid Engine (Age 5.5 - 6.9)")
    print("="*50)

    # 1. TEST CASE: High Marks (Excellent Performance)
    # This previously failed (gave High Risk) - our new guardrail should fix it.
    excellent_request = PredictionRequest(
        age_months=72,
        features={
            "accuracy_overall": 95,
            "post_switch_accuracy": 92,
            "total_perseverative_errors": 0,
            "switch_cost_ms": 150,
            "attention_level": 5,
            "engagement_level": 5,
            "frustration_tolerance": 5,
            "instruction_following": 5,
            "overall_behavior": 5
        },
        child_id="test_healthy_child"
    )

    print("\nCASE 1: Excellent Performance (95% accuracy, 0 errors)")
    result = predict_asd_v5_hybrid_5_5(excellent_request)
    print(f"Prediction: {result.risk_level.upper()}")
    print(f"ASD Probability (ML): {result.asd_probability}")
    print(f"Hybrid Score: {result.hybrid_score}")
    print(f"Clinical Override: {result.clinical_override}")
    print(f"Summary: {result.result_summary}")

    # Assert logic
    assert result.risk_level in ["low", "no_risk"], f"Expected low/no_risk for excellent performance, got {result.risk_level}"
    print("✅ OK: Guardrail correctly demoted risk for high-performing child.")

    # 2. TEST CASE: Poor Marks (Typical ASD Pattern)
    poor_request = PredictionRequest(
        age_months=72,
        features={
            "accuracy_overall": 45,
            "post_switch_accuracy": 30,
            "total_perseverative_errors": 12,
            "switch_cost_ms": 1200,
            "attention_level": 2,
            "engagement_level": 2,
            "frustration_tolerance": 2,
            "instruction_following": 2,
            "overall_behavior": 2
        },
        child_id="test_risk_child"
    )

    print("\nCASE 2: Poor Performance (45% accuracy, 12 errors)")
    result = predict_asd_v5_hybrid_5_5(poor_request)
    print(f"Prediction: {result.risk_level.upper()}")
    print(f"ASD Probability (ML): {result.asd_probability}")
    print(f"Hybrid Score: {result.hybrid_score}")
    print(f"Clinical Override: {result.clinical_override}")
    print(f"Summary: {result.result_summary}")

    # Assert logic
    assert result.risk_level == "high", f"Expected high risk for poor performance, got {result.risk_level}"
    print("✅ OK: Hybrid engine correctly identified high risk.")

    # 3. TEST CASE: Good Play but Poor Behavior (Clinical Safety Net)
    behavior_request = PredictionRequest(
        age_months=72,
        features={
            "accuracy_overall": 90,
            "post_switch_accuracy": 85,
            "total_perseverative_errors": 1,
            "switch_cost_ms": 200,
            "attention_level": 1,
            "engagement_level": 1,
            "frustration_tolerance": 1,
            "instruction_following": 1,
            "overall_behavior": 1
        },
        child_id="test_behavior_child"
    )

    print("\nCASE 3: Good Game Play but Poor Behavioral Scores (avg=1.0)")
    result = predict_asd_v5_hybrid_5_5(behavior_request)
    print(f"Prediction: {result.risk_level.upper()}")
    print(f"Clinical Override: {result.clinical_override}")
    print(f"Summary: {result.result_summary}")

    assert result.risk_level != "no_risk", "Expected non-zero risk due to behavioral override"
    print("✅ OK: Behavioral override detected.")

if __name__ == "__main__":
    try:
        test_v5_hybrid_guardrail()
        print("\n🎉 ALL TESTS PASSED!")
    except Exception as e:
        print(f"\n❌ TEST FAILED: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
