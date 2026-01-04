# 📊 How to Save Age Normalization Norms

## 🎯 Why This is Needed

Your training notebook performs **age normalization** (Z-scores) using control group norms. For predictions to work correctly, the Python ML engine needs these same norms.

---

## ✅ Solution: Save Age Norms from Training

### Step 1: Add This Cell to Your Training Notebook

**After Cell 11 (Age Normalization), add this cell:**

```python
# Save age norms for prediction engine
import json

# Calculate and save control group norms by age band
control_df = df[df['target'] == 0].copy()

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

# Filter to features that exist
features_to_normalize = [f for f in features_to_normalize if f in control_df.columns]

age_norms = {
    'overall': {}  # Overall control group stats
}

# Calculate overall stats
for feature in features_to_normalize:
    if feature in control_df.columns:
        mean_val = control_df[feature].mean()
        std_val = control_df[feature].std()
        age_norms['overall'][feature] = {
            'mean': float(mean_val) if not pd.isna(mean_val) else 0.0,
            'std': float(std_val) if not pd.isna(std_val) else 1.0
        }

# Calculate stats by age bands
age_bands = {
    '24-36': (24, 36),
    '36-48': (36, 48),
    '48-60': (48, 60),
    '60-72': (60, 72),
}

for band_name, (low, high) in age_bands.items():
    age_norms[band_name] = {}
    band_data = control_df[
        (control_df['age_months'] >= low) & 
        (control_df['age_months'] < high)
    ]
    
    if len(band_data) > 0:
        for feature in features_to_normalize:
            if feature in band_data.columns:
                mean_val = band_data[feature].mean()
                std_val = band_data[feature].std()
                age_norms[band_name][feature] = {
                    'mean': float(mean_val) if not pd.isna(mean_val) else 0.0,
                    'std': float(std_val) if not pd.isna(std_val) else 1.0
                }

# Save to file
with open('age_norms.json', 'w') as f:
    json.dump(age_norms, f, indent=2)

print("✅ Age norms saved to age_norms.json")
print(f"   Features normalized: {len(features_to_normalize)}")
print(f"   Age bands: {list(age_bands.keys())}")

# Download
files.download('age_norms.json')
```

---

## 📋 Step 2: Copy to Backend

After downloading from Colab:

1. Copy `age_norms.json` to `senseai_backend/models/`
2. The Python engine will automatically use it for age normalization

---

## 🔍 What the File Contains

```json
{
  "overall": {
    "post_switch_accuracy": {
      "mean": 65.5,
      "std": 12.3
    },
    "switch_cost_ms": {
      "mean": 250.0,
      "std": 80.5
    }
  },
  "36-48": {
    "post_switch_accuracy": {
      "mean": 62.0,
      "std": 10.5
    }
  }
}
```

---

## ✅ Verification

After placing `age_norms.json` in `models/`, the Python engine will:
1. Load age norms automatically
2. Calculate Z-scores for features that need normalization
3. Use normalized features for prediction

**Test:**
```bash
python ml_scripts/predict.py '{"features": {"post_switch_accuracy": 50, "age_months": 42}}'
```

---

## ⚠️ Important Notes

1. **Age norms are optional**: If `age_norms.json` doesn't exist, the engine will use raw features (may reduce accuracy)
2. **Must match training**: Age norms must be from the same control group used in training
3. **Update when retraining**: If you retrain with new data, regenerate and replace `age_norms.json`

---

## 🚀 Quick Checklist

- [ ] Add cell to training notebook (after age normalization)
- [ ] Run cell to generate `age_norms.json`
- [ ] Download `age_norms.json` from Colab
- [ ] Copy to `senseai_backend/models/age_norms.json`
- [ ] Test prediction engine

**Your Python engine will now perform age normalization correctly!** ✅

