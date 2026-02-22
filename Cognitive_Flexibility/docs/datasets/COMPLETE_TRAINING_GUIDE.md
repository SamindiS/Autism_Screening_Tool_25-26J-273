# 📚 Complete ML Training Guide - All 3 Models

## 🎯 Overview

This guide provides **step-by-step instructions** for training all three age-specific autism screening models with **professional-grade quality**, including:

- ✅ Dataset preparation and preprocessing
- ✅ Feature engineering and normalization
- ✅ Outlier detection and handling
- ✅ Data augmentation
- ✅ Model training (Logistic Regression + Random Forest)
- ✅ Evaluation and validation
- ✅ Model persistence and deployment

---

## 📋 Prerequisites

### Required Python Packages

```bash
pip install pandas numpy scikit-learn matplotlib seaborn scipy joblib
pip install imbalanced-learn  # For SMOTE augmentation (optional)
```

### Directory Structure

Ensure you have:
- `Online Datasets/` - External datasets
- `SAMPLE_DATASETS/` - Your hospital-collected data
- `ML_TRAINING/` - Training scripts and utilities

---

## 🚀 Step-by-Step Training Process

### **Phase 1: Data Preparation**

#### Step 1.1: Prepare Age 2-3.5 Dataset

```bash
cd ML_TRAINING
python preprocessing/prepare_age_2_3_5_data.py
```

**What it does:**
- Loads external datasets (Toddler Autism July 2018, Autism Screening Combined)
- Filters to age 24-42 months
- Extracts features (A1-A10, Q-CHAT-10, domain scores)
- Age-normalizes features (z-scores)
- Saves to `SAMPLE_DATASETS/prepared/train_age_2_3_5_questionnaire.csv`
- Prepares test data from hospital datasets

**Expected Output:**
- Training data: ~2,314 samples
- Test data: ~40 samples (from hospital)

---

#### Step 1.2: Prepare Age 3.5-5.5 Dataset

```bash
python preprocessing/prepare_age_3_5_5_5_data.py
```

**What it does:**
- Loads external questionnaire data (auxiliary features)
- Filters to age 42-66 months
- Extracts questionnaire scores
- Saves auxiliary data for hybrid model

**Expected Output:**
- Auxiliary questionnaire data: 592 samples
- Game data: Load from your hospital data (adapt script)

---

#### Step 1.3: Prepare Age 5.5-6.9 Dataset

```bash
python preprocessing/prepare_age_5_5_6_9_data.py
```

**What it does:**
- Loads external questionnaire data (auxiliary features)
- Filters to age 66-83 months
- Extracts questionnaire scores
- Saves auxiliary data for hybrid model

**Expected Output:**
- Auxiliary questionnaire data: 19 samples
- Game data: Load from your hospital data (adapt script)

---

### **Phase 2: Model Training**

#### Step 2.1: Train Age 2-3.5 Questionnaire Model

```bash
python training/train_age_2_3_5_model.py
```

**Training Process:**
1. **Load Data**: Training and test datasets
2. **Preprocess**: Clean, handle missing values
3. **Feature Engineering**: Age normalization, composite indices, binary flags
4. **Outlier Detection**: IQR-based detection, Winsorization
5. **Data Augmentation**: Bootstrap resampling (target: 2,000 samples)
6. **Feature Scaling**: StandardScaler
7. **Model Training**:
   - Logistic Regression (primary)
   - Random Forest (comparison)
8. **Evaluation**: Accuracy, Precision, Recall, F1, ROC-AUC, PR-AUC
9. **Model Persistence**: Save model, scaler, features, metadata

**Expected Results:**
- Training Accuracy: 85-90%
- Test Accuracy: 80-85%
- ROC-AUC: 0.85-0.90

**Output Files:**
- `models/model_age_2_3_5_questionnaire.pkl`
- `models/scaler_model_age_2_3_5_questionnaire.pkl`
- `models/features_model_age_2_3_5_questionnaire.json`
- `models/model_metadata_model_age_2_3_5_questionnaire.json`

---

#### Step 2.2: Train Age 3.5-5.5 Frog Jump Model

```bash
python training/train_age_3_5_5_5_model.py
```

**Training Process:**
1. **Load Data**: Game data (primary) + Questionnaire data (auxiliary)
2. **Feature Engineering**: 
   - Game features: Go/No-Go accuracy, commission errors, RT metrics
   - Auxiliary features: Questionnaire scores
   - Composite indices: Inhibition Control, Response Control
3. **Outlier Detection**: IQR-based, Winsorization
4. **Data Augmentation**: Bootstrap (target: 500 samples)
5. **Model Training**: Logistic Regression + Random Forest
6. **Evaluation**: Comprehensive metrics
7. **Model Persistence**: Save all artifacts

**Expected Results:**
- Training Accuracy: 80-85%
- Test Accuracy: 75-80%
- ROC-AUC: 0.80-0.85

---

#### Step 2.3: Train Age 5.5-6.9 Color-Shape Model

```bash
python training/train_age_5_5_6_9_model.py
```

**Training Process:**
1. **Load Data**: DCCS game data (primary) + Questionnaire data (auxiliary)
2. **Feature Engineering**:
   - Game features: Switch cost, perseverative errors, accuracy drop
   - Auxiliary features: Questionnaire scores
   - Composite indices: Cognitive Flexibility, Perseveration
3. **Outlier Detection**: IQR-based, Winsorization
4. **Data Augmentation**: Bootstrap (target: 300 samples, aggressive)
5. **Model Training**: Logistic Regression + Random Forest
6. **Evaluation**: Comprehensive metrics
7. **Model Persistence**: Save all artifacts

**Expected Results:**
- Training Accuracy: 75-80%
- Test Accuracy: 70-75%
- ROC-AUC: 0.75-0.80

---

## 🔧 Configuration

### Edit `config.py` to customize:

1. **Model Hyperparameters**:
   - Logistic Regression: `max_iter`, `C`, `solver`
   - Random Forest: `n_estimators`, `max_depth`, `min_samples_leaf`

2. **Augmentation Settings**:
   - Method: `"bootstrap"` or `"smote"`
   - Target samples per class
   - Noise level

3. **Outlier Detection**:
   - Method: `"iqr"` or `"zscore"`
   - IQR factor
   - Winsorization limits

4. **Data Paths**:
   - External dataset paths
   - Hospital data paths
   - Output directories

---

## 📊 Evaluation Metrics

Each model training generates:

### **Metrics:**
- **Accuracy**: Overall correctness
- **Precision**: True positives / (True positives + False positives)
- **Recall**: True positives / (True positives + False negatives)
- **F1 Score**: Harmonic mean of precision and recall
- **ROC-AUC**: Area under ROC curve
- **PR-AUC**: Area under Precision-Recall curve

### **Plots:**
- Confusion Matrix
- ROC Curve
- Feature Importance

### **Reports:**
- Classification Report
- Feature Importance Rankings
- Outlier Summary

---

## 🎯 Quality Assurance Checklist

Before deploying models, verify:

- ✅ **Data Quality**:
  - No missing values in critical features
  - Outliers handled appropriately
  - Class balance maintained

- ✅ **Feature Engineering**:
  - Age normalization applied
  - Composite indices calculated
  - Binary flags created

- ✅ **Model Performance**:
  - Training accuracy > 75%
  - Test accuracy > 70%
  - ROC-AUC > 0.75
  - No overfitting (train/test gap < 10%)

- ✅ **Model Persistence**:
  - Model file saved (.pkl)
  - Scaler saved (.pkl)
  - Features list saved (.json)
  - Metadata saved (.json)

---

## 🚨 Troubleshooting

### **Issue: Low Accuracy**

**Solutions:**
1. Increase augmentation target samples
2. Try different hyperparameters
3. Check for data quality issues
4. Verify feature engineering

### **Issue: Overfitting**

**Solutions:**
1. Reduce model complexity (lower max_depth for RF)
2. Increase regularization (higher C for LR)
3. Reduce augmentation
4. Add more training data

### **Issue: Class Imbalance**

**Solutions:**
1. Use `class_weight="balanced"` (already enabled)
2. Use SMOTE instead of bootstrap
3. Adjust augmentation target samples per class

### **Issue: Missing Features**

**Solutions:**
1. Check data preprocessing
2. Verify feature extraction logic
3. Handle missing values appropriately

---

## 📈 Next Steps After Training

1. **Model Integration**:
   - Copy models to `senseai_backend/ml_engine/models/`
   - Update `config.py` in ML engine
   - Test predictions

2. **Dashboard Integration**:
   - Add model performance metrics to admin dashboard
   - Create visualization charts
   - Display feature importance

3. **Monitoring**:
   - Track prediction accuracy over time
   - Monitor for model drift
   - Collect feedback for retraining

---

## 📝 Notes

- **Train/Test Split**: External datasets for training, hospital data for testing
- **Child-Level Splitting**: Prevents data leakage (if child IDs available)
- **Stratified Splits**: Maintains class balance
- **Feature Scaling**: Always fit scaler on training data only
- **Model Selection**: Logistic Regression is primary (interpretable, stable)

---

## ✅ Success Criteria

A successfully trained model should:

1. ✅ Achieve >75% accuracy on test set
2. ✅ Have ROC-AUC >0.75
3. ✅ Show no significant overfitting
4. ✅ Be saved with all artifacts
5. ✅ Have comprehensive evaluation report

---

**Status**: Ready for professional model training! 🎉
