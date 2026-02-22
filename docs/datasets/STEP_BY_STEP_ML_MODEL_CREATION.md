# Step-by-Step ML Model Creation Guide
## Using Jupyter Notebook or Google Colab

Complete guide for creating your ASD screening ML model following scientific best practices.

---

## 📋 Prerequisites

### Option 1: Google Colab (Recommended - No Setup Required)
1. Go to https://colab.research.google.com/
2. Sign in with Google account
3. Create new notebook
4. All libraries pre-installed!

### Option 2: Jupyter Notebook (Local)
```bash
# Install Jupyter
pip install jupyter notebook

# Install required libraries
pip install pandas numpy scikit-learn xgboost lightgbm matplotlib seaborn scipy joblib

# Start Jupyter
jupyter notebook
```

---

## 📝 Step 1: Setup and Import Libraries

### 1.1 Install Required Packages (Google Colab Only)

```python
# Run this first in Google Colab
!pip install xgboost lightgbm scikit-learn pandas numpy matplotlib seaborn scipy joblib -q

print("✅ All packages installed!")
```

### 1.2 Import All Libraries

```python
# Data manipulation
import pandas as pd
import numpy as np

# Machine Learning
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold, GroupKFold
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, roc_curve, confusion_matrix, classification_report,
    precision_recall_curve
)
from sklearn.calibration import CalibratedClassifierCV

# Advanced ML
import xgboost as xgb
import lightgbm as lgb

# Visualization
import matplotlib.pyplot as plt
import seaborn as sns

# Statistical analysis
from scipy import stats
from scipy.stats import mannwhitneyu, pearsonr

# Utilities
import joblib
import pickle
import warnings
warnings.filterwarnings('ignore')

# Set style
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 6)

print("✅ All libraries imported successfully!")
```

---

## 📝 Step 2: Load and Explore Data

### 2.1 Load Data from CSV

**Option A: Upload to Google Colab**
```python
from google.colab import files
uploaded = files.upload()

# Load the CSV (adjust filename)
df = pd.read_csv('training_data.csv')  # Change to your filename
```

**Option B: Load from Local File (Jupyter)**
```python
df = pd.read_csv('training_data.csv')
```

**Option C: Load from URL**
```python
# If you have data hosted online
df = pd.read_csv('https://your-url.com/training_data.csv')
```

### 2.2 Explore Data

```python
print("Data Shape:", df.shape)
print("\nColumn Names:")
print(df.columns.tolist())

print("\n" + "="*50)
print("Missing Values:")
print(df.isnull().sum().sort_values(ascending=False))

print("\n" + "="*50)
print("Target Distribution:")
print(df['group'].value_counts())  # Adjust column name if different

print("\n" + "="*50)
print("Age Distribution:")
print(df['age_months'].describe())

print("\n" + "="*50)
print("First few rows:")
df.head()
```

---

## 📝 Step 3: Data Preprocessing

### 3.1 Handle Missing Values

```python
# Fill numeric columns with median
numeric_cols = df.select_dtypes(include=[np.number]).columns
for col in numeric_cols:
    if df[col].isnull().sum() > 0:
        median_val = df[col].median()
        df[col].fillna(median_val, inplace=True)
        print(f"Filled {col} with median: {median_val:.2f}")

# Fill categorical with mode
categorical_cols = df.select_dtypes(include=['object']).columns
for col in categorical_cols:
    if df[col].isnull().sum() > 0:
        mode_val = df[col].mode()[0] if len(df[col].mode()) > 0 else 'unknown'
        df[col].fillna(mode_val, inplace=True)
        print(f"Filled {col} with mode: {mode_val}")

print("\n✅ Missing values handled!")
print(f"Remaining missing values: {df.isnull().sum().sum()}")
```

### 3.2 Encode Target Variable

```python
# Encode target variable
label_encoder = LabelEncoder()
df['target'] = label_encoder.fit_transform(df['group'])
# ASD = 1, Control = 0

print("Target encoding:")
print(f"ASD = {1 if 'asd' in df['group'].values else 'check'}")
print(f"Control = {0 if 'typically_developing' in df['group'].values else 'check'}")
print(f"\nTarget distribution:")
print(df['target'].value_counts())
```

### 3.3 Encode Categorical Variables

```python
# Encode other categorical variables
categorical_features = ['gender', 'session_type', 'age_group']
label_encoders = {}

for col in categorical_features:
    if col in df.columns:
        le = LabelEncoder()
        df[f'{col}_encoded'] = le.fit_transform(df[col].astype(str))
        label_encoders[col] = le
        print(f"Encoded {col}: {df[col].nunique()} unique values")

print("\n✅ Categorical variables encoded!")
```

---

## 📝 Step 4: Age Normalization (CRITICAL!)

### 4.1 Calculate Age-Normalized Z-Scores

```python
def calculate_age_normalized_scores(df, feature_col, age_col='age_months', group_col='group'):
    """
    Calculate age-normalized z-scores using control group norms.
    This is CRITICAL for scientific validity!
    """
    # Get control group data (for establishing norms)
    control_data = df[df[group_col] == 'typically_developing'].copy()
    
    # Calculate norms by age group
    age_groups = control_data[age_col].apply(lambda x: 
        '2-3.5' if 24 <= x < 42 else
        '3.5-5.5' if 42 <= x < 66 else
        '5.5-6' if 66 <= x <= 72 else 'other'
    )
    
    normalized_scores = []
    
    for idx, row in df.iterrows():
        age = row[age_col]
        feature_value = row[feature_col]
        
        # Determine age group
        if 24 <= age < 42:
            age_group = '2-3.5'
        elif 42 <= age < 66:
            age_group = '3.5-5.5'
        elif 66 <= age <= 72:
            age_group = '5.5-6'
        else:
            age_group = 'other'
        
        # Get control group norms for this age group
        age_group_control = control_data[age_groups == age_group]
        
        if len(age_group_control) > 0 and feature_col in age_group_control.columns:
            mean_val = age_group_control[feature_col].mean()
            std_val = age_group_control[feature_col].std()
            
            if std_val > 0:
                z_score = (feature_value - mean_val) / std_val
                normalized_scores.append(z_score)
            else:
                normalized_scores.append(0)  # No variation in control group
        else:
            normalized_scores.append(0)  # No control data for this age group
    
    return normalized_scores

# Apply age normalization to key features
features_to_normalize = [
    'accuracy_overall',
    'nogo_accuracy',
    'go_accuracy',
    'commission_error_rate',
    'post_switch_accuracy',
    'switch_cost_ms',
    'perseverative_error_rate_post_switch',
]

for feature in features_to_normalize:
    if feature in df.columns:
        normalized_col = f'{feature}_z_score'
        df[normalized_col] = calculate_age_normalized_scores(df, feature)
        print(f"✅ Age-normalized {feature} → {normalized_col}")

print("\n✅ Age normalization complete!")
```

---

## 📝 Step 5: Feature Selection

### 5.1 Define Feature Columns

```python
# Adjust based on your actual column names

feature_columns = [
    # Demographics
    'age_months',
    'gender_encoded',  # if encoded
    
    # Age-normalized features (preferred)
    'accuracy_overall_z_score',
    'nogo_accuracy_z_score',
    'go_accuracy_z_score',
    'commission_error_rate_z_score',
    'post_switch_accuracy_z_score',
    'switch_cost_ms_z_score',
    'perseverative_error_rate_post_switch_z_score',
    
    # DCCS Features (if available)
    'post_switch_accuracy',
    'total_perseverative_errors',
    'switch_cost_ms',
    'perseverative_error_rate_post_switch',
    'avg_rt_pre_switch_ms',
    'avg_rt_post_switch_correct_ms',
    
    # Frog Jump Features (if available)
    'nogo_accuracy',
    'commission_error_rate',
    'commission_errors',
    'rt_variability',
    'go_accuracy',
    'omission_errors',
    'avg_rt_go_ms',
    
    # Questionnaire Features (if available)
    'critical_items_failed',
    'critical_items_fail_rate',
    'social_responsiveness_score',
    'joint_attention_score',
    'cognitive_flexibility_score',
    
    # General Features
    'completion_time_sec',
    'total_score',
    
    # Behavioral Observations (if available)
    'attention_level',
    'engagement_level',
    'frustration_tolerance',
    'instruction_following',
    'overall_behavior',
]

# Filter to only columns that exist in your dataframe
available_features = [col for col in feature_columns if col in df.columns]
print(f"Available features: {len(available_features)}")
print(available_features)

# Create feature matrix
X = df[available_features].copy()
y = df['target'].copy()

print(f"\n✅ Feature matrix created: {X.shape}")
print(f"✅ Target vector created: {y.shape}")
print(f"✅ Class distribution: {y.value_counts().to_dict()}")
```

---

## 📝 Step 6: Train-Test Split (CHILD-LEVEL - CRITICAL!)

### 6.1 Split by Child, Not by Session

```python
# CRITICAL: Split by child to prevent data leakage!

# Get unique children
unique_children = df['child_id'].unique()
print(f"Total unique children: {len(unique_children)}")

# Get target for each child (for stratification)
child_targets = df.groupby('child_id')['target'].first()

# Split children (not sessions!)
train_children, test_children = train_test_split(
    unique_children,
    test_size=0.2,  # 20% for testing
    random_state=42,
    stratify=child_targets  # Maintain class balance
)

print(f"Train children: {len(train_children)}")
print(f"Test children: {len(test_children)}")

# Filter data by child split
train_mask = df['child_id'].isin(train_children)
test_mask = df['child_id'].isin(test_children)

X_train = X[train_mask].copy()
X_test = X[test_mask].copy()
y_train = y[train_mask].copy()
y_test = y[test_mask].copy()

print(f"\n✅ Train set: {X_train.shape[0]} sessions from {len(train_children)} children")
print(f"✅ Test set: {X_test.shape[0]} sessions from {len(test_children)} children")

# Verify no child overlap
train_child_set = set(df[train_mask]['child_id'].unique())
test_child_set = set(df[test_mask]['child_id'].unique())
assert len(train_child_set.intersection(test_child_set)) == 0, "ERROR: Child overlap detected!"
print("✅ Verified: No child overlap between train and test sets")
```

### 6.2 Feature Scaling

```python
# Scale features (important for some algorithms)
scaler = StandardScaler()

# Fit on training data only
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Convert back to DataFrame (optional, but helpful)
X_train_scaled = pd.DataFrame(X_train_scaled, columns=X_train.columns, index=X_train.index)
X_test_scaled = pd.DataFrame(X_test_scaled, columns=X_test.columns, index=X_test.index)

print("✅ Features scaled!")
print(f"Train mean: {X_train_scaled.mean().mean():.4f}")
print(f"Train std: {X_train_scaled.std().mean():.4f}")
```

---

## 📝 Step 7: Train Multiple Models (Comparison)

### 7.1 Baseline: Logistic Regression

```python
# Logistic Regression (interpretable, good baseline)
print("="*50)
print("Training Logistic Regression...")
print("="*50)

lr_model = LogisticRegression(random_state=42, max_iter=1000)
lr_model.fit(X_train_scaled, y_train)

# Predictions
lr_y_pred = lr_model.predict(X_test_scaled)
lr_y_proba = lr_model.predict_proba(X_test_scaled)[:, 1]

# Metrics
lr_accuracy = accuracy_score(y_test, lr_y_pred)
lr_precision = precision_score(y_test, lr_y_pred)
lr_recall = recall_score(y_test, lr_y_pred)
lr_f1 = f1_score(y_test, lr_y_pred)
lr_auc = roc_auc_score(y_test, lr_y_proba)

print(f"Accuracy: {lr_accuracy:.4f}")
print(f"Precision: {lr_precision:.4f}")
print(f"Recall (Sensitivity): {lr_recall:.4f}")
print(f"F1-Score: {lr_f1:.4f}")
print(f"AUC-ROC: {lr_auc:.4f}")

# Show learned weights (interpretability!)
print("\nFeature Weights (Top 10):")
feature_importance = pd.DataFrame({
    'feature': X_train.columns,
    'weight': lr_model.coef_[0]
}).sort_values('weight', key=abs, ascending=False)

print(feature_importance.head(10))
```

### 7.2 Random Forest

```python
# Random Forest (non-linear, robust)
print("\n" + "="*50)
print("Training Random Forest...")
print("="*50)

rf_model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    random_state=42,
    n_jobs=-1
)
rf_model.fit(X_train, y_train)  # No scaling needed for RF

# Predictions
rf_y_pred = rf_model.predict(X_test)
rf_y_proba = rf_model.predict_proba(X_test)[:, 1]

# Metrics
rf_accuracy = accuracy_score(y_test, rf_y_pred)
rf_precision = precision_score(y_test, rf_y_pred)
rf_recall = recall_score(y_test, rf_y_pred)
rf_f1 = f1_score(y_test, rf_y_pred)
rf_auc = roc_auc_score(y_test, rf_y_proba)

print(f"Accuracy: {rf_accuracy:.4f}")
print(f"Precision: {rf_precision:.4f}")
print(f"Recall (Sensitivity): {rf_recall:.4f}")
print(f"F1-Score: {rf_f1:.4f}")
print(f"AUC-ROC: {rf_auc:.4f}")

# Feature importance
print("\nFeature Importance (Top 10):")
feature_importance = pd.DataFrame({
    'feature': X_train.columns,
    'importance': rf_model.feature_importances_
}).sort_values('importance', ascending=False)

print(feature_importance.head(10))
```

### 7.3 XGBoost (Best Performance)

```python
# XGBoost (often best on tabular data)
print("\n" + "="*50)
print("Training XGBoost...")
print("="*50)

xgb_model = xgb.XGBClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    random_state=42,
    eval_metric='logloss'
)
xgb_model.fit(X_train, y_train)  # No scaling needed for XGBoost

# Predictions
xgb_y_pred = xgb_model.predict(X_test)
xgb_y_proba = xgb_model.predict_proba(X_test)[:, 1]

# Metrics
xgb_accuracy = accuracy_score(y_test, xgb_y_pred)
xgb_precision = precision_score(y_test, xgb_y_pred)
xgb_recall = recall_score(y_test, xgb_y_pred)
xgb_f1 = f1_score(y_test, xgb_y_pred)
xgb_auc = roc_auc_score(y_test, xgb_y_proba)

print(f"Accuracy: {xgb_accuracy:.4f}")
print(f"Precision: {xgb_precision:.4f}")
print(f"Recall (Sensitivity): {xgb_recall:.4f}")
print(f"F1-Score: {xgb_f1:.4f}")
print(f"AUC-ROC: {xgb_auc:.4f}")

# Feature importance
print("\nFeature Importance (Top 10):")
feature_importance = pd.DataFrame({
    'feature': X_train.columns,
    'importance': xgb_model.feature_importances_
}).sort_values('importance', ascending=False)

print(feature_importance.head(10))
```

---

## 📝 Step 8: Model Comparison

### 8.1 Compare All Models

```python
# Compare all models
results = pd.DataFrame({
    'Model': ['Logistic Regression', 'Random Forest', 'XGBoost'],
    'Accuracy': [lr_accuracy, rf_accuracy, xgb_accuracy],
    'Precision': [lr_precision, rf_precision, xgb_precision],
    'Recall (Sensitivity)': [lr_recall, rf_recall, xgb_recall],
    'F1-Score': [lr_f1, rf_f1, xgb_f1],
    'AUC-ROC': [lr_auc, rf_auc, xgb_auc]
})

print("="*50)
print("Model Comparison")
print("="*50)
print(results.round(4))

# Find best model
best_model_idx = results['AUC-ROC'].idxmax()
best_model_name = results.loc[best_model_idx, 'Model']
print(f"\n✅ Best Model: {best_model_name} (AUC: {results.loc[best_model_idx, 'AUC-ROC']:.4f})")
```

### 8.2 Visualize Model Performance

```python
# ROC Curves
fig, axes = plt.subplots(1, 2, figsize=(15, 5))

# ROC Curve
fpr_lr, tpr_lr, _ = roc_curve(y_test, lr_y_proba)
fpr_rf, tpr_rf, _ = roc_curve(y_test, rf_y_proba)
fpr_xgb, tpr_xgb, _ = roc_curve(y_test, xgb_y_proba)

axes[0].plot(fpr_lr, tpr_lr, label=f'LR (AUC={lr_auc:.3f})', linewidth=2)
axes[0].plot(fpr_rf, tpr_rf, label=f'RF (AUC={rf_auc:.3f})', linewidth=2)
axes[0].plot(fpr_xgb, tpr_xgb, label=f'XGBoost (AUC={xgb_auc:.3f})', linewidth=2)
axes[0].plot([0, 1], [0, 1], 'k--', label='Random')
axes[0].set_xlabel('False Positive Rate')
axes[0].set_ylabel('True Positive Rate')
axes[0].set_title('ROC Curves')
axes[0].legend()
axes[0].grid(True)

# Precision-Recall Curve
precision_lr, recall_lr, _ = precision_recall_curve(y_test, lr_y_proba)
precision_rf, recall_rf, _ = precision_recall_curve(y_test, rf_y_proba)
precision_xgb, recall_xgb, _ = precision_recall_curve(y_test, xgb_y_proba)

axes[1].plot(recall_lr, precision_lr, label='LR', linewidth=2)
axes[1].plot(recall_rf, precision_rf, label='RF', linewidth=2)
axes[1].plot(recall_xgb, precision_xgb, label='XGBoost', linewidth=2)
axes[1].set_xlabel('Recall (Sensitivity)')
axes[1].set_ylabel('Precision')
axes[1].set_title('Precision-Recall Curves')
axes[1].legend()
axes[1].grid(True)

plt.tight_layout()
plt.show()
```

---

## 📝 Step 9: Probability Calibration

### 9.1 Calibrate Best Model

```python
# Calibrate probabilities (makes risk scores more trustworthy)
print("="*50)
print("Calibrating Probabilities...")
print("="*50)

# Use best model (XGBoost in this example)
base_model = xgb_model

calibrated_model = CalibratedClassifierCV(
    base_model,
    method='isotonic',  # or 'sigmoid' (Platt scaling)
    cv=5
)
calibrated_model.fit(X_train, y_train)

# Calibrated predictions
calibrated_y_proba = calibrated_model.predict_proba(X_test)[:, 1]

# Compare calibration
print("Before calibration:")
print(f"  Mean predicted probability: {xgb_y_proba.mean():.4f}")
print(f"  Actual positive rate: {y_test.mean():.4f}")

print("\nAfter calibration:")
print(f"  Mean predicted probability: {calibrated_y_proba.mean():.4f}")
print(f"  Actual positive rate: {y_test.mean():.4f}")

# Calibrated model is now ready for deployment!
```

---

## 📝 Step 10: Ablation Study (Justify Multi-Domain Approach)

### 10.1 Train Models with Different Feature Sets

```python
# Ablation study: Test if all domains are needed
print("="*50)
print("Ablation Study: Testing Feature Importance")
print("="*50)

feature_sets = {
    'Full Model': available_features,
    'Games Only': [f for f in available_features if any(x in f for x in ['accuracy', 'error', 'rt', 'switch', 'commission', 'perseverative'])],
    'Questionnaire Only': [f for f in available_features if any(x in f for x in ['critical', 'social', 'joint', 'cognitive', 'communication'])],
    'DCCS Only': [f for f in available_features if any(x in f for x in ['switch', 'perseverative', 'post_switch', 'pre_switch'])],
    'GoNoGo Only': [f for f in available_features if any(x in f for x in ['nogo', 'go_accuracy', 'commission', 'omission'])],
}

ablation_results = []

for name, features in feature_sets.items():
    if len(features) == 0:
        continue
    
    # Filter features
    X_train_subset = X_train[features]
    X_test_subset = X_test[features]
    
    # Scale
    scaler_subset = StandardScaler()
    X_train_subset_scaled = scaler_subset.fit_transform(X_train_subset)
    X_test_subset_scaled = scaler_subset.transform(X_test_subset)
    
    # Train model
    model = LogisticRegression(random_state=42, max_iter=1000)
    model.fit(X_train_subset_scaled, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test_subset_scaled)
    y_proba = model.predict_proba(X_test_subset_scaled)[:, 1]
    
    auc = roc_auc_score(y_test, y_proba)
    recall = recall_score(y_test, y_pred)
    
    ablation_results.append({
        'Model': name,
        'Features': len(features),
        'AUC': auc,
        'Recall': recall
    })
    
    print(f"{name}: AUC={auc:.4f}, Recall={recall:.4f}")

# Compare
ablation_df = pd.DataFrame(ablation_results)
print("\n" + "="*50)
print("Ablation Study Results")
print("="*50)
print(ablation_df.sort_values('AUC', ascending=False))

# If "Full Model" performs best → justifies multi-domain approach!
```

---

## 📝 Step 11: Save Model for Deployment

### 11.1 Save Best Model

```python
# Save best model and scaler
print("="*50)
print("Saving Model...")
print("="*50)

# Choose best model (XGBoost in this example)
final_model = calibrated_model  # or xgb_model if not calibrating
final_scaler = scaler

# Save model
joblib.dump(final_model, 'asd_detection_model.pkl')
joblib.dump(final_scaler, 'feature_scaler.pkl')

# Save feature names (important for deployment!)
import json
with open('feature_names.json', 'w') as f:
    json.dump(available_features, f)

print("✅ Model saved: asd_detection_model.pkl")
print("✅ Scaler saved: feature_scaler.pkl")
print("✅ Feature names saved: feature_names.json")

# Download from Colab (if using Colab)
try:
    from google.colab import files
    files.download('asd_detection_model.pkl')
    files.download('feature_scaler.pkl')
    files.download('feature_names.json')
    print("✅ Files downloaded!")
except:
    print("(Not in Colab - files saved locally)")
```

---

## 📝 Step 12: Model Evaluation Report

### 12.1 Generate Comprehensive Report

```python
# Generate evaluation report
print("="*50)
print("Final Model Evaluation Report")
print("="*50)

# Confusion Matrix
cm = confusion_matrix(y_test, xgb_y_pred)
print("\nConfusion Matrix:")
print(cm)

# Classification Report
print("\nClassification Report:")
print(classification_report(y_test, xgb_y_pred, target_names=['Control', 'ASD']))

# Confidence Intervals (Bootstrap)
def bootstrap_metric(y_true, y_pred, metric_func, n_iterations=1000):
    """Calculate bootstrap confidence interval"""
    metrics = []
    n = len(y_true)
    for _ in range(n_iterations):
        indices = np.random.choice(n, n, replace=True)
        m = metric_func(y_true[indices], y_pred[indices])
        metrics.append(m)
    return np.percentile(metrics, [2.5, 97.5])

# Calculate CIs
accuracy_ci = bootstrap_metric(y_test, xgb_y_pred, accuracy_score)
recall_ci = bootstrap_metric(y_test, xgb_y_pred, recall_score)
precision_ci = bootstrap_metric(y_test, xgb_y_pred, precision_score)

print("\nMetrics with 95% Confidence Intervals:")
print(f"Accuracy: {xgb_accuracy:.4f} [{accuracy_ci[0]:.4f}, {accuracy_ci[1]:.4f}]")
print(f"Recall (Sensitivity): {xgb_recall:.4f} [{recall_ci[0]:.4f}, {recall_ci[1]:.4f}]")
print(f"Precision: {xgb_precision:.4f} [{precision_ci[0]:.4f}, {precision_ci[1]:.4f}]")
print(f"AUC-ROC: {xgb_auc:.4f}")

print("\n✅ Model evaluation complete!")
```

---

## 📝 Step 13: Feature Importance Analysis

### 13.1 Visualize Feature Importance

```python
# Feature importance visualization
feature_importance = pd.DataFrame({
    'feature': X_train.columns,
    'importance': xgb_model.feature_importances_
}).sort_values('importance', ascending=False)

# Top 15 features
top_features = feature_importance.head(15)

plt.figure(figsize=(10, 8))
plt.barh(range(len(top_features)), top_features['importance'])
plt.yticks(range(len(top_features)), top_features['feature'])
plt.xlabel('Feature Importance')
plt.title('Top 15 Most Important Features for ASD Detection')
plt.gca().invert_yaxis()
plt.tight_layout()
plt.show()

print("\nTop 15 Features:")
print(top_features)
```

---

## 📝 Step 14: Cross-Validation (Child-Level)

### 14.1 Child-Level Cross-Validation

```python
# Child-level cross-validation (prevents data leakage)
print("="*50)
print("Child-Level Cross-Validation")
print("="*50)

# Get child groups for GroupKFold
child_groups = df['child_id'].values
y_cv = df['target'].values
X_cv = X.values

# Use GroupKFold to ensure no child appears in both train and test
group_kfold = GroupKFold(n_splits=5)

cv_scores = cross_val_score(
    xgb_model,
    X_cv,
    y_cv,
    cv=group_kfold.split(X_cv, y_cv, child_groups),
    scoring='roc_auc',
    n_jobs=-1
)

print(f"Cross-Validation AUC Scores: {cv_scores}")
print(f"Mean AUC: {cv_scores.mean():.4f} (+/- {cv_scores.std() * 2:.4f})")
print(f"95% CI: [{cv_scores.mean() - 1.96 * cv_scores.std():.4f}, {cv_scores.mean() + 1.96 * cv_scores.std():.4f}]")
```

---

## 📝 Step 15: Model Deployment Preparation

### 15.1 Create Prediction Function

```python
def predict_asd_risk(features_dict, model_path='asd_detection_model.pkl', scaler_path='feature_scaler.pkl'):
    """
    Predict ASD risk for a new child's session data.
    
    Args:
        features_dict: Dictionary with feature names and values
        model_path: Path to saved model
        scaler_path: Path to saved scaler
    
    Returns:
        Dictionary with prediction, probability, and risk level
    """
    # Load model and scaler
    model = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    
    # Load feature names
    with open('feature_names.json', 'r') as f:
        feature_names = json.load(f)
    
    # Create feature vector
    feature_vector = np.array([features_dict.get(f, 0) for f in feature_names])
    feature_vector = feature_vector.reshape(1, -1)
    
    # Scale features
    feature_vector_scaled = scaler.transform(feature_vector)
    
    # Predict
    prediction = model.predict(feature_vector_scaled)[0]
    probability = model.predict_proba(feature_vector_scaled)[0][1]
    
    # Determine risk level
    if probability >= 0.7:
        risk_level = 'HIGH'
    elif probability >= 0.4:
        risk_level = 'MODERATE'
    else:
        risk_level = 'LOW'
    
    return {
        'prediction': 'ASD' if prediction == 1 else 'Control',
        'probability': float(probability),
        'risk_level': risk_level,
        'confidence': 'High' if probability > 0.8 or probability < 0.2 else 'Moderate'
    }

# Example usage
example_features = {
    'age_months': 48,
    'nogo_accuracy': 65.0,
    'commission_error_rate': 35.0,
    'rt_variability': 280.0,
    # ... add all required features
}

# prediction = predict_asd_risk(example_features)
# print(prediction)
```

---

## 📋 Complete Workflow Summary

```
1. Setup & Import Libraries
2. Load Data from CSV
3. Data Preprocessing (handle missing values, encode)
4. Age Normalization (CRITICAL - z-scores)
5. Feature Selection
6. Child-Level Train-Test Split (prevents leakage)
7. Train Multiple Models (LR, RF, XGBoost)
8. Compare Models
9. Probability Calibration
10. Ablation Study (justify multi-domain)
11. Save Model for Deployment
12. Generate Evaluation Report
13. Feature Importance Analysis
14. Cross-Validation
15. Deployment Preparation
```

---

## ✅ Key Best Practices Implemented

- ✅ **Child-level splitting** (prevents data leakage)
- ✅ **Age normalization** (z-scores from control group)
- ✅ **Multiple models** (compare performance)
- ✅ **Probability calibration** (trustworthy risk scores)
- ✅ **Ablation study** (justifies multi-domain approach)
- ✅ **Cross-validation** (child-level, prevents leakage)
- ✅ **Comprehensive evaluation** (AUC, sensitivity, specificity, CIs)
- ✅ **Feature importance** (interpretability)

---

## 🎯 Expected Results

**Realistic Targets** (for screening with real child data):
- **Accuracy**: 80-88%
- **Sensitivity (Recall)**: > 80% (prefer higher)
- **Specificity**: > 70% (acceptable for screening)
- **AUC-ROC**: > 0.75

**Remember**: This is a **screening tool**, not a diagnostic tool. Moderate false positives are acceptable if sensitivity is high.

---

## 📦 Files Generated

After running this notebook, you'll have:
- `asd_detection_model.pkl` - Trained model
- `feature_scaler.pkl` - Feature scaler
- `feature_names.json` - Feature names (for deployment)

These files can be used in your backend for real-time predictions!

---

**Your ML model is now ready for deployment!** 🚀
