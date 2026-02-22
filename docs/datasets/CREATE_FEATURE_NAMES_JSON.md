# 📝 How to Create feature_names.json

## 🎯 What This File Does

The `feature_names.json` file tells the backend **which features to use** and **in what order** when making predictions. This ensures features match exactly how the model was trained.

---

## ✅ Format Options

The backend supports **two formats**:

### Option 1: Simple Array (Recommended)

```json
[
  "age_months",
  "post_switch_accuracy",
  "perseverative_error_rate_post_switch",
  "switch_cost_ms",
  "commission_error_rate",
  "rt_variability",
  "nogo_accuracy",
  "critical_items_failed",
  "social_responsiveness_score"
]
```

### Option 2: Detailed Object (With Metadata)

```json
{
  "feature_names": [
    "age_months",
    "post_switch_accuracy",
    "perseverative_error_rate_post_switch",
    "switch_cost_ms",
    "commission_error_rate",
    "rt_variability",
    "nogo_accuracy",
    "critical_items_failed",
    "social_responsiveness_score"
  ],
  "feature_count": 9,
  "model_type": "Logistic Regression (Calibrated)",
  "training_date": "2025-01-02",
  "dataset_size": 83
}
```

**Note:** The backend code needs a small update to handle Option 2 (see below).

---

## 🔧 How to Get Your Feature Names

### Method 1: From the Notebook (Best)

After training, run this in Colab:

```python
# Get the exact features used during training
import json

# This should match 'selected_features' from Cell 13
feature_names = selected_features  # From your training

# Save as simple array (Option 1 - Recommended)
with open('feature_names.json', 'w') as f:
    json.dump(feature_names, f, indent=2)

files.download('feature_names.json')
```

### Method 2: Manual Creation

If you know your features, create the file manually:

1. Open `senseai_backend/models/feature_names.json`
2. Add your features in the **exact order** they were used during training
3. Use the format from Option 1 above

---

## 📋 Your Feature List (From Training)

Based on your notebook, your features should include:

```json
[
  "age_months",
  "post_switch_accuracy",
  "post_switch_accuracy_zscore",
  "total_perseverative_errors",
  "perseverative_error_rate_post_switch",
  "perseverative_error_rate_post_switch_zscore",
  "switch_cost_ms",
  "switch_cost_ms_zscore",
  "avg_rt_pre_switch_ms",
  "avg_rt_pre_switch_ms_zscore",
  "avg_rt_post_switch_correct_ms",
  "avg_rt_post_switch_correct_ms_zscore",
  "accuracy_drop_percent",
  "accuracy_drop_percent_zscore",
  "nogo_accuracy",
  "nogo_accuracy_zscore",
  "commission_error_rate",
  "commission_error_rate_zscore",
  "rt_variability",
  "rt_variability_zscore",
  "go_accuracy",
  "avg_rt_go_ms",
  "avg_rt_go_ms_zscore",
  "critical_items_failed",
  "critical_items_fail_rate",
  "social_responsiveness_score",
  "joint_attention_score",
  "attention_level",
  "engagement_level",
  "frustration_tolerance",
  "accuracy_overall",
  "completion_time_sec"
]
```

**⚠️ Important:** This is a **template**. You need to use the **exact features** from your training (from `selected_features` variable in Cell 13).

---

## 🚀 Quick Solution

### Step 1: Get Features from Notebook

In Colab, after training, run:

```python
# Print your exact features
print("Your training features:")
print(json.dumps(selected_features, indent=2))

# Save to file
with open('feature_names.json', 'w') as f:
    json.dump(selected_features, f, indent=2)

files.download('feature_names.json')
```

### Step 2: Copy to Backend

1. Download `feature_names.json` from Colab
2. Copy to `senseai_backend/models/feature_names.json`
3. Done!

---

## 🔍 How to Verify

After creating the file, test it:

```bash
cd senseai_backend
python ml_scripts/predict.py '{"features": {"age_months": 48}, "age_group": "4-5"}'
```

If it works, the file is correct!

---

## ⚠️ Important Notes

1. **Feature order matters!** Features must be in the **same order** as training
2. **Feature names must match exactly** (case-sensitive)
3. **Missing features** will be set to 0 automatically
4. **Extra features** in the dict will be ignored (if using feature_names)

---

## 📝 Example: Complete File

Here's a complete example based on typical training:

```json
[
  "age_months",
  "post_switch_accuracy",
  "perseverative_error_rate_post_switch",
  "switch_cost_ms",
  "commission_error_rate",
  "rt_variability",
  "nogo_accuracy",
  "critical_items_failed",
  "social_responsiveness_score"
]
```

Save this to `senseai_backend/models/feature_names.json`

---

## 🐛 If Backend Doesn't Use feature_names.json

The backend code might need a small update. Check `ml_scripts/predict.py` line 54-62.

If it expects a dict with `feature_names` key, use Option 2 format above.

If it expects a simple array, use Option 1 format.


