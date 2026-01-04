# 🧪 How to Test the ML Engine

## ⚠️ PowerShell Quote Issue

PowerShell handles quotes differently than bash. Here are the correct ways to test:

---

## ✅ Method 1: Use Double Quotes with Escaping (PowerShell)

```powershell
python ml_scripts/predict.py "{\"features\": {\"age_months\": 48, \"post_switch_accuracy\": 65}}"
```

---

## ✅ Method 2: Use Single Quotes with Escaped Double Quotes (PowerShell)

```powershell
python ml_scripts/predict.py '{\"features\": {\"age_months\": 48, \"post_switch_accuracy\": 65}}'
```

---

## ✅ Method 3: Create a Test File (Easiest)

**Create `test_input.json`:**
```json
{
  "features": {
    "age_months": 48,
    "post_switch_accuracy": 65,
    "perseverative_error_rate_post_switch": 35,
    "switch_cost_ms": 450,
    "commission_error_rate": 28,
    "rt_variability": 280
  },
  "age_group": "4-5",
  "session_type": "color_shape"
}
```

**Then run:**
```powershell
Get-Content test_input.json | python ml_scripts/predict.py
```

**OR:**
```powershell
python ml_scripts/predict.py (Get-Content test_input.json -Raw)
```

---

## ✅ Method 4: Use Python Directly (Best for Testing)

**Create `test_predict.py`:**
```python
import json
import sys
sys.path.insert(0, 'ml_scripts')
from predict import predict

# Test data
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
    "completion_time_sec": 180
}

result = predict(
    test_features,
    age_months=48,
    age_group="4-5",
    session_type="color_shape"
)

print(json.dumps(result, indent=2))
```

**Run:**
```powershell
python test_predict.py
```

---

## ✅ Method 5: Fix the Script to Handle Input Better

The script can be improved to handle input from stdin. Let me update it:

