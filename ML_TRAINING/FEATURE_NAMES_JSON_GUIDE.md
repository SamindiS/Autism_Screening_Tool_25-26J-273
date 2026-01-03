# 📝 feature_names.json - Complete Guide

## 🎯 What This File Does

The `feature_names.json` file tells the backend:
1. **Which features** to use for predictions
2. **In what order** (must match training order)
3. Ensures features align with your trained model

---

## ✅ Format: Simple Array (Recommended)

The file should be a **JSON array** of feature names in the **exact order** used during training:

```json
[
  "age_months",
  "post_switch_accuracy",
  "perseverative_error_rate_post_switch",
  "switch_cost_ms",
  "commission_error_rate",
  "rt_variability"
]
```

---

## 🔧 How to Get Your Exact Features

### Method 1: From Colab Notebook (Best)

After training completes, run this in Colab:

```python
# Get the exact features used during training
import json

# Print your features (from Cell 13)
print("Your training features:")
for i, feat in enumerate(selected_features, 1):
    print(f"{i}. {feat}")

# Save to JSON file
with open('feature_names.json', 'w') as f:
    json.dump(selected_features, f, indent=2)

# Download
from google.colab import files
files.download('feature_names.json')

print(f"\n✅ Saved {len(selected_features)} features to feature_names.json")
```

### Method 2: Manual Creation

If you know your features, create the file manually with features in **training order**.

---

## 📋 Template (Based on Your Notebook)

I've created a template file with common features. **Replace with your actual features** from training:

**File location:** `senseai_backend/models/feature_names.json`

**Current content (template):**
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

**⚠️ Important:** This is a **template**. You must replace it with your **actual features** from training!

---

## 🚀 Quick Steps

### Step 1: Get Features from Training

In Colab, after Cell 13 runs, check the output. It shows:
```
✅ Selected X features for training
```

### Step 2: Extract Feature List

Run this in Colab:
```python
# This gets the exact features used
import json

# Save features
with open('feature_names.json', 'w') as f:
    json.dump(selected_features, f, indent=2)

# Download
files.download('feature_names.json')
```

### Step 3: Copy to Backend

1. Download `feature_names.json` from Colab
2. Copy to `senseai_backend/models/feature_names.json`
3. Done!

---

## ✅ Verification

After creating the file, test it:

```bash
cd senseai_backend
python ml_scripts/predict.py '{"features": {"age_months": 48}, "age_group": "4-5"}'
```

If it works without errors, the file is correct!

---

## ⚠️ Critical Requirements

1. **Feature order MUST match training** - Same order as `selected_features` in Cell 13
2. **Feature names MUST match exactly** - Case-sensitive, no typos
3. **Missing features** - Will be set to 0 automatically (OK)
4. **Extra features** - Will be ignored (OK)

---

## 🐛 Troubleshooting

### Issue: "Feature mismatch" errors

**Solution:** Ensure feature names match exactly (case-sensitive)

### Issue: Predictions are wrong

**Solution:** Check feature order matches training order

### Issue: File not found

**Solution:** Ensure file is in `senseai_backend/models/feature_names.json`

---

## 💡 Pro Tip

**Best practice:** Always generate this file from your training notebook to ensure 100% accuracy!

The file I created is a **template** - replace it with your actual features from training.

