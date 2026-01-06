# ✅ Age-Specific Dataset Filtering - Strict Session Type Matching

## 🎯 Problem Solved

**Issue**: When exporting data for a specific age group, the export was including sessions from other assessment types, which would contaminate the dataset for separate ML model training.

**Solution**: Implemented **strict filtering** that ensures each age group export **ONLY** contains its corresponding session type.

---

## 🔒 Strict Filtering Rules

### Age Group → Session Type Mapping

| Age Group | Required Session Type | Assessment Type |
|-----------|----------------------|-----------------|
| **2-3.5** | `ai_doctor_bot` | Parental Questionnaire |
| **3.5-5.5** | `frog_jump` | Go/No-Go Game |
| **5.5-6.9** | `color_shape` | DCCS Game |

### Filtering Logic

When `ageGroup` is specified, the export now:

1. **First Check**: Session type MUST match the required type for that age group
2. **Second Check**: Age validation (age_group field or child's age_in_months)
3. **Result**: Only sessions that pass BOTH checks are included

**Example**:
- If you export `ageGroup=2-3.5`, it will **ONLY** include sessions where:
  - `session_type === 'ai_doctor_bot'` ✅
  - AND age is 24-41 months ✅
  - Sessions with `session_type='frog_jump'` or `'color_shape'` are **EXCLUDED** ❌

---

## 📊 What This Means for Your Datasets

### Dataset 1: Age 2-3.5 (Questionnaire Model)
- **Contains**: ONLY `ai_doctor_bot` sessions
- **Excludes**: All `frog_jump` and `color_shape` sessions
- **Features**: Questionnaire features only (critical_items_failed, social_responsiveness_score, etc.)

### Dataset 2: Age 3.5-5.5 (Frog Jump Model)
- **Contains**: ONLY `frog_jump` sessions
- **Excludes**: All `ai_doctor_bot` and `color_shape` sessions
- **Features**: Go/No-Go features only (go_accuracy, nogo_accuracy, commission_error_rate, etc.)

### Dataset 3: Age 5.5-6.9 (Color-Shape Model)
- **Contains**: ONLY `color_shape` sessions
- **Excludes**: All `ai_doctor_bot` and `frog_jump` sessions
- **Features**: DCCS features only (pre_switch_accuracy, post_switch_accuracy, switch_cost_ms, etc.)

---

## 🔧 Implementation Details

### Backend API (`routes/export.js`)

```javascript
// When ageGroup is specified, enforce session type matching
if (ageGroup) {
  const requiredSessionType = {
    '2-3.5': 'ai_doctor_bot',
    '3.5-5.5': 'frog_jump',
    '5.5-6.9': 'color_shape'
  }[ageGroup];

  filteredSessions = filteredSessions.filter(s => {
    // CRITICAL: Must match the required session type
    if (s.session_type !== requiredSessionType) {
      return false; // Exclude if wrong session type
    }
    // ... additional age validation
  });
}
```

### Export Script (`export_firebase_to_csv.js`)

Same logic applied to the standalone export script.

---

## ✅ Verification

### Test Export for Age 2-3.5

```bash
# Export age 2-3.5
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=2-3.5 --output=age_2_3_5_test.csv

# Verify: Check that ALL rows have session_type='ai_doctor_bot'
# In the CSV, check the session_type column
```

**Expected Result**:
- ✅ All rows: `session_type=ai_doctor_bot`
- ❌ No rows with `session_type=frog_jump`
- ❌ No rows with `session_type=color_shape`

### Test Export for Age 3.5-5.5

```bash
# Export age 3.5-5.5
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=3.5-5.5 --output=age_3_5_5_5_test.csv

# Verify: Check that ALL rows have session_type='frog_jump'
```

**Expected Result**:
- ✅ All rows: `session_type=frog_jump`
- ❌ No rows with `session_type=ai_doctor_bot`
- ❌ No rows with `session_type=color_shape`

### Test Export for Age 5.5-6.9

```bash
# Export age 5.5-6.9
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=5.5-6.9 --output=age_5_5_6_9_test.csv

# Verify: Check that ALL rows have session_type='color_shape'
```

**Expected Result**:
- ✅ All rows: `session_type=color_shape`
- ❌ No rows with `session_type=ai_doctor_bot`
- ❌ No rows with `session_type=frog_jump`

---

## 📋 Quick Verification Script

Create a Python script to verify your exports:

```python
import pandas as pd

# Check Age 2-3.5 export
df_2_3_5 = pd.read_csv('age_2_3_5_test.csv')
print("Age 2-3.5 Export:")
print(f"  Total rows: {len(df_2_3_5)}")
print(f"  Session types: {df_2_3_5['session_type'].value_counts()}")
assert all(df_2_3_5['session_type'] == 'ai_doctor_bot'), "❌ Contains wrong session types!"
print("  ✅ All sessions are ai_doctor_bot")

# Check Age 3.5-5.5 export
df_3_5_5_5 = pd.read_csv('age_3_5_5_5_test.csv')
print("\nAge 3.5-5.5 Export:")
print(f"  Total rows: {len(df_3_5_5_5)}")
print(f"  Session types: {df_3_5_5_5['session_type'].value_counts()}")
assert all(df_3_5_5_5['session_type'] == 'frog_jump'), "❌ Contains wrong session types!"
print("  ✅ All sessions are frog_jump")

# Check Age 5.5-6.9 export
df_5_5_6_9 = pd.read_csv('age_5_5_6_9_test.csv')
print("\nAge 5.5-6.9 Export:")
print(f"  Total rows: {len(df_5_5_6_9)}")
print(f"  Session types: {df_5_5_6_9['session_type'].value_counts()}")
assert all(df_5_5_6_9['session_type'] == 'color_shape'), "❌ Contains wrong session types!"
print("  ✅ All sessions are color_shape")

print("\n✅ All exports are correctly filtered!")
```

---

## 🎯 Training Separate Models

Now you can safely train 3 separate models:

### Model 1: Age 2-3.5 (Questionnaire)
```python
# Load ONLY age 2-3.5 data
df = pd.read_csv('age_2_3_5_training.csv')

# Verify: All should be ai_doctor_bot
assert all(df['session_type'] == 'ai_doctor_bot')

# Use questionnaire features only
features = [
    'critical_items_failed',
    'social_responsiveness_score',
    'joint_attention_score',
    # ... questionnaire features
]
```

### Model 2: Age 3.5-5.5 (Frog Jump)
```python
# Load ONLY age 3.5-5.5 data
df = pd.read_csv('age_3_5_5_5_training.csv')

# Verify: All should be frog_jump
assert all(df['session_type'] == 'frog_jump')

# Use frog jump features only
features = [
    'go_accuracy',
    'nogo_accuracy',
    'commission_error_rate',
    # ... frog jump features
]
```

### Model 3: Age 5.5-6.9 (Color-Shape)
```python
# Load ONLY age 5.5-6.9 data
df = pd.read_csv('age_5_5_6_9_training.csv')

# Verify: All should be color_shape
assert all(df['session_type'] == 'color_shape')

# Use color-shape features only
features = [
    'pre_switch_accuracy',
    'post_switch_accuracy',
    'switch_cost_ms',
    # ... color-shape features
]
```

---

## 🔍 Why This Matters

### Before (Without Strict Filtering):
- Age 2-3.5 export might include some `frog_jump` sessions (if child's age was in range)
- This would contaminate the dataset with wrong features
- Model would be confused by mixed feature types

### After (With Strict Filtering):
- Age 2-3.5 export **ONLY** contains `ai_doctor_bot` sessions
- Each dataset is **pure** and **unique**
- Models can be trained on clean, consistent data
- Better accuracy and interpretability

---

## 📝 Summary

✅ **Strict filtering implemented**:
- Age 2-3.5 → Only `ai_doctor_bot` sessions
- Age 3.5-5.5 → Only `frog_jump` sessions
- Age 5.5-6.9 → Only `color_shape` sessions

✅ **Each dataset is now unique** and ready for separate model training

✅ **No cross-contamination** between age groups

✅ **Works in**:
- Flutter app export
- Backend API (`/api/export/csv`)
- Standalone export script

---

## 🚀 Next Steps

1. **Export your 3 datasets**:
   ```bash
   node scripts/export_firebase_to_csv.js --format=ml --ageGroup=2-3.5 --output=age_2_3_5_training.csv
   node scripts/export_firebase_to_csv.js --format=ml --ageGroup=3.5-5.5 --output=age_3_5_5_5_training.csv
   node scripts/export_firebase_to_csv.js --format=ml --ageGroup=5.5-6.9 --output=age_5_5_6_9_training.csv
   ```

2. **Verify each export** (check session_type column)

3. **Train separate models** using the notebook: `Complete_ASD_ML_Training_Age_Specific.ipynb`

4. **Each model will be trained on clean, unique data** ✅

---

✅ **Your datasets are now properly separated and ready for training!**
