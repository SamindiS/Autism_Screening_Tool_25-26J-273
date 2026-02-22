# 🧠 Complete ML Training Pipeline v2 - Google Colab

**Purpose:** Train new model using master dataset with sample weighting and proper validation

---

## 📋 **STEP-BY-STEP GOOGLE COLAB NOTEBOOK**

### **Cell 1: Setup & Install Dependencies**

```python
# Install required packages
!pip install pandas numpy scikit-learn joblib matplotlib seaborn -q

# Import libraries
import pandas as pd
import numpy as np
import json
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
import matplotlib.pyplot as plt
import seaborn as sns
from google.colab import files

print("✅ Setup complete!")
```

---

### **Cell 2: Upload Master Dataset**

```python
# Upload the master_training_dataset.csv file
uploaded = files.upload()

# Load dataset
df = pd.read_csv('master_training_dataset.csv')

print(f"📊 Dataset loaded: {len(df)} rows, {len(df.columns)} columns")
print(f"\nData sources: {df['data_source'].value_counts().to_dict()}")
print(f"\nGroups: {df['group'].value_counts().to_dict()}")
print(f"\nFirst few rows:")
df.head()
```

---

### **Cell 3: Data Preprocessing & Cleaning**

```python
# Remove rows with missing group (target variable)
df = df[df['group'].notna()].copy()

# Separate real and synthetic data
real_data = df[df['data_source'] == 'real'].copy()
synthetic_data = df[df['data_source'].isin(['synthetic_asd', 'synthetic_td'])].copy()

print(f"📊 Real data: {len(real_data)} rows")
print(f"📊 Synthetic data: {len(synthetic_data)} rows")
print(f"\nReal data groups: {real_data['group'].value_counts().to_dict()}")
print(f"Synthetic data groups: {synthetic_data['group'].value_counts().to_dict()}")

# Check for missing values in key columns
print(f"\nMissing values in real data:")
print(real_data.isnull().sum()[real_data.isnull().sum() > 0])
```

---

### **Cell 4: Define Feature Set (Aligned with Your Current Model)**

```python
# Feature columns to use (aligned with your existing model)
FEATURE_COLUMNS = [
    # Age
    "age_months",
    
    # Cognitive Flexibility (DCCS)
    "post_switch_accuracy",
    "pre_switch_accuracy",
    "switch_cost_ms",
    "avg_rt_pre_switch_ms",
    "avg_rt_post_switch_correct_ms",
    "accuracy_drop_percent",
    "perseverative_error_rate_post_switch",
    "cognitive_flexibility_score",
    
    # Inhibitory Control (Go/No-Go)
    "go_accuracy",
    "nogo_accuracy",
    "commission_error_rate",
    "omission_error_rate",
    "inhibition_failure_rate",
    
    # Reaction Time Metrics
    "avg_reaction_time_ms",
    "rt_variability",
    "rt_range",
    
    # Behavioral Observations
    "attention_level",
    "engagement_level",
    "frustration_tolerance",
    "instruction_following",
    
    # Social Communication
    "social_communication_score",
    "social_responsiveness_score",
    "joint_attention_score",
    
    # Task Performance
    "completion_time_sec",
    "overall_accuracy",
]

# Check which features exist in dataset
available_features = [f for f in FEATURE_COLUMNS if f in df.columns]
missing_features = [f for f in FEATURE_COLUMNS if f not in df.columns]

print(f"✅ Available features: {len(available_features)}/{len(FEATURE_COLUMNS)}")
print(f"Available: {available_features}")
if missing_features:
    print(f"\n⚠️ Missing features (will be skipped): {missing_features}")

# Use only available features
FEATURE_COLUMNS = available_features
TARGET = "group"
```

---

### **Cell 5: Prepare Features & Handle Missing Values**

```python
# Combine real and synthetic data
all_data = pd.concat([real_data, synthetic_data], ignore_index=True)

# Select features and target
X = all_data[FEATURE_COLUMNS].copy()
y = all_data[TARGET].copy()
data_source = all_data['data_source'].copy()

# Handle missing values: Fill with median for numeric features
for col in FEATURE_COLUMNS:
    if X[col].dtype in ['float64', 'int64']:
        median_val = X[col].median()
        X[col] = X[col].fillna(median_val)
        print(f"Filled {col} missing values with median: {median_val:.2f}")

# Check remaining missing values
print(f"\nRemaining missing values: {X.isnull().sum().sum()}")

# Encode target variable
le = LabelEncoder()
y_encoded = le.fit_transform(y)

print(f"\n✅ Target encoding:")
for i, class_name in enumerate(le.classes_):
    print(f"  {class_name} → {i}")

print(f"\n✅ Feature matrix shape: {X.shape}")
print(f"✅ Target distribution:")
print(pd.Series(y).value_counts())
```

---

### **Cell 6: Create Sample Weights (Real > Synthetic)**

```python
# Create sample weights: Real data = 1.0, Synthetic = 0.3
sample_weights = np.where(data_source == 'real', 1.0, 0.3)

print(f"📊 Sample weights distribution:")
print(f"  Real data (weight=1.0): {np.sum(sample_weights == 1.0)} samples")
print(f"  Synthetic data (weight=0.3): {np.sum(sample_weights == 0.3)} samples")
print(f"\n  Total weighted samples: {np.sum(sample_weights):.1f}")
```

---

### **Cell 7: Train/Validation/Test Split**

```python
# Split REAL data into train/val/test (70/15/15)
real_indices = data_source[data_source == 'real'].index
real_X = X.loc[real_indices]
real_y = y_encoded[real_indices]

# First split: 70% train, 30% temp (for val+test)
X_train_real, X_temp, y_train_real, y_temp = train_test_split(
    real_X, real_y, 
    test_size=0.3, 
    random_state=42, 
    stratify=real_y
)

# Second split: 50% val, 50% test (from temp)
X_val, X_test, y_val, y_test = train_test_split(
    X_temp, y_temp,
    test_size=0.5,
    random_state=42,
    stratify=y_temp
)

# Add ALL synthetic data to training set
synthetic_indices = data_source[data_source != 'real'].index
X_train_synthetic = X.loc[synthetic_indices]
y_train_synthetic = y_encoded[synthetic_indices]
weights_synthetic = sample_weights[synthetic_indices]

# Combine real training data with synthetic
X_train = pd.concat([X_train_real, X_train_synthetic], ignore_index=True)
y_train = np.concatenate([y_train_real, y_train_synthetic])
weights_train = np.concatenate([
    np.ones(len(y_train_real)),  # Real data = 1.0
    weights_synthetic  # Synthetic = 0.3
])

print(f"📊 Final Split:")
print(f"  Training: {len(X_train)} samples ({len(X_train_real)} real + {len(X_train_synthetic)} synthetic)")
print(f"  Validation: {len(X_val)} samples (real only)")
print(f"  Test: {len(X_test)} samples (real only)")
print(f"\n  Training target distribution:")
print(f"    {pd.Series(le.inverse_transform(y_train)).value_counts().to_dict()}")
print(f"\n  Validation target distribution:")
print(f"    {pd.Series(le.inverse_transform(y_val)).value_counts().to_dict()}")
print(f"\n  Test target distribution:")
print(f"    {pd.Series(le.inverse_transform(y_test)).value_counts().to_dict()}")
```

---

### **Cell 8: Feature Scaling**

```python
# Scale features
scaler = StandardScaler()

X_train_scaled = scaler.fit_transform(X_train)
X_val_scaled = scaler.transform(X_val)
X_test_scaled = scaler.transform(X_test)

print(f"✅ Features scaled:")
print(f"  Training: {X_train_scaled.shape}")
print(f"  Validation: {X_val_scaled.shape}")
print(f"  Test: {X_test_scaled.shape}")
print(f"\n  Feature means (should be ~0): {X_train_scaled.mean(axis=0)[:5]}")
print(f"  Feature stds (should be ~1): {X_train_scaled.std(axis=0)[:5]}")
```

---

### **Cell 9: Train Logistic Regression Model**

```python
# Train Logistic Regression with sample weights
model = LogisticRegression(
    max_iter=2000,
    class_weight='balanced',  # Handle class imbalance
    random_state=42,
    solver='lbfgs'  # Good for small-medium datasets
)

print("🔄 Training model...")
model.fit(X_train_scaled, y_train, sample_weight=weights_train)

print("✅ Model trained successfully!")
print(f"\nModel coefficients shape: {model.coef_.shape}")
print(f"Model intercept: {model.intercept_}")
```

---

### **Cell 10: Validation Set Evaluation**

```python
# Predict on validation set
y_val_pred = model.predict(X_val_scaled)
y_val_proba = model.predict_proba(X_val_scaled)[:, 1]

# Classification report
print("📊 VALIDATION SET RESULTS:")
print("=" * 60)
print(classification_report(y_val, y_val_pred, target_names=le.classes_))

# Confusion matrix
cm = confusion_matrix(y_val, y_val_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
            xticklabels=le.classes_, yticklabels=le.classes_)
plt.title('Validation Set Confusion Matrix')
plt.ylabel('True Label')
plt.xlabel('Predicted Label')
plt.show()

# ROC-AUC
if len(le.classes_) == 2:
    auc = roc_auc_score(y_val, y_val_proba)
    print(f"\nROC-AUC Score: {auc:.4f}")
    
    fpr, tpr, _ = roc_curve(y_val, y_val_proba)
    plt.figure(figsize=(8, 6))
    plt.plot(fpr, tpr, label=f'ROC Curve (AUC = {auc:.4f})')
    plt.plot([0, 1], [0, 1], 'k--', label='Random')
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Validation Set ROC Curve')
    plt.legend()
    plt.show()
```

---

### **Cell 11: FINAL TEST SET EVALUATION (Real Data Only)**

```python
# Predict on test set (REAL DATA ONLY - this is what you report!)
y_test_pred = model.predict(X_test_scaled)
y_test_proba = model.predict_proba(X_test_scaled)[:, 1]

print("🎯 FINAL TEST SET RESULTS (REAL DATA ONLY)")
print("=" * 60)
print("This is what you report in your thesis!")
print("=" * 60)
print(classification_report(y_test, y_test_pred, target_names=le.classes_))

# Confusion matrix
cm_test = confusion_matrix(y_test, y_test_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(cm_test, annot=True, fmt='d', cmap='Greens', 
            xticklabels=le.classes_, yticklabels=le.classes_)
plt.title('Test Set Confusion Matrix (Real Data Only)')
plt.ylabel('True Label')
plt.xlabel('Predicted Label')
plt.show()

# ROC-AUC
if len(le.classes_) == 2:
    auc_test = roc_auc_score(y_test, y_test_proba)
    print(f"\n🎯 FINAL TEST ROC-AUC Score: {auc_test:.4f}")
    
    fpr, tpr, _ = roc_curve(y_test, y_test_proba)
    plt.figure(figsize=(8, 6))
    plt.plot(fpr, tpr, label=f'ROC Curve (AUC = {auc_test:.4f})', linewidth=2)
    plt.plot([0, 1], [0, 1], 'k--', label='Random')
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Test Set ROC Curve (Real Data Only)')
    plt.legend()
    plt.grid(True)
    plt.show()

# Feature importance (coefficients)
feature_importance = pd.DataFrame({
    'feature': FEATURE_COLUMNS,
    'coefficient': model.coef_[0],
    'abs_coefficient': np.abs(model.coef_[0])
}).sort_values('abs_coefficient', ascending=False)

print("\n📊 Top 10 Most Important Features:")
print(feature_importance.head(10))
```

---

### **Cell 12: Save Model Artifacts**

```python
# Save model, scaler, and feature names
joblib.dump(model, 'asd_detection_model_v2.pkl')
joblib.dump(scaler, 'feature_scaler_v2.pkl')

with open('feature_names_v2.json', 'w') as f:
    json.dump(FEATURE_COLUMNS, f, indent=2)

# Save label encoder info
label_mapping = {int(i): class_name for i, class_name in enumerate(le.classes_)}
with open('label_encoder_v2.json', 'w') as f:
    json.dump(label_mapping, f, indent=2)

print("✅ Model artifacts saved:")
print("  - asd_detection_model_v2.pkl")
print("  - feature_scaler_v2.pkl")
print("  - feature_names_v2.json")
print("  - label_encoder_v2.json")

# Download files
files.download('asd_detection_model_v2.pkl')
files.download('feature_scaler_v2.pkl')
files.download('feature_names_v2.json')
files.download('label_encoder_v2.json')

print("\n✅ All files downloaded!")
```

---

### **Cell 13: Model Summary & Statistics**

```python
# Create summary report
summary = {
    "model_version": "v2",
    "training_samples": {
        "real": len(X_train_real),
        "synthetic": len(X_train_synthetic),
        "total": len(X_train)
    },
    "validation_samples": len(X_val),
    "test_samples": len(X_test),
    "features_used": len(FEATURE_COLUMNS),
    "feature_list": FEATURE_COLUMNS,
    "sample_weights": {
        "real_data": 1.0,
        "synthetic_data": 0.3
    },
    "test_performance": {
        "accuracy": (y_test == y_test_pred).mean(),
        "roc_auc": float(auc_test) if len(le.classes_) == 2 else None
    }
}

# Print summary
print("📋 MODEL TRAINING SUMMARY")
print("=" * 60)
print(json.dumps(summary, indent=2))

# Save summary
with open('model_training_summary_v2.json', 'w') as f:
    json.dump(summary, f, indent=2)

files.download('model_training_summary_v2.json')
```

---

## 🎯 **KEY DIFFERENCES FROM OLD MODEL**

| Aspect | Old Model | New Model v2 |
|--------|-----------|--------------|
| **Dataset** | Small real data only | Master dataset (real + synthetic) |
| **Sample Weighting** | ❌ No | ✅ Yes (real=1.0, synthetic=0.3) |
| **Data Split** | Train/Test only | Train/Val/Test (proper) |
| **Test Set** | Mixed | ✅ Real data only |
| **Validation** | ❌ No | ✅ Yes (for hyperparameter tuning) |
| **Reproducibility** | Partial | ✅ Full (random_state fixed) |

---

## 📝 **WHAT TO SAY IN YOUR THESIS**

> "An initial prototype model (v1) was developed using a limited dataset of 53 children. Based on supervisor feedback and to improve generalizability, a revised model (v2) was trained using an expanded dataset comprising real clinical data and statistically constrained synthetic augmentation. The training protocol employed sample-weighted learning, where real data samples were weighted 3.3× higher than synthetic samples to prioritize clinical validity. The model was evaluated using a strict train-validation-test split, with final performance reported only on real clinical data to ensure unbiased assessment."

---

## ✅ **NEXT STEPS AFTER TRAINING**

1. **Download all artifacts** from Colab
2. **Replace old model files** in `senseai_backend/models/`:
   - `asd_detection_model.pkl` → `asd_detection_model_v2.pkl`
   - `feature_scaler.pkl` → `feature_scaler_v2.pkl`
   - `feature_names.json` → `feature_names_v2.json`
3. **Update ML engine** to use new model files
4. **Test predictions** with new model
5. **Archive old model** (keep for reference)

---

**Last Updated:** 2025-01-XX  
**Status:** Ready for Colab execution

