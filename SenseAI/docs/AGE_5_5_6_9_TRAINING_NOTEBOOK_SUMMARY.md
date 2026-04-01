# ✅ Age 5.5-6.9 Color-Shape (DCCS) Model Training Notebook - Complete

## 📋 Notebook Created

**File:** `ML_TRAINING/Age_5_5_6_9_ColorShape_Model_Training.ipynb`

A comprehensive training notebook for the age 5.5-6.9 Color-Shape (DCCS) model, following the same structure and methods as the previous age groups.

---

## 🎯 Key Features Implemented

### ✅ 1. Three Risk Levels (Low, Moderate, High)
- **Hybrid ML + Clinical Rules** approach
- Uses **DCCS-specific features**:
  - `post_switch_accuracy` (lower = more risk)
  - `switch_cost_ms` (higher = more risk)
  - `perseverative_error_rate_post_switch` (higher = more risk)
  - `cognitive_flexibility_index` (lower = more risk)
- **Decision Logic:**
  - **HIGH RISK**: ≥2 features ≥2 SD from norm OR ML probability ≥0.7 + ≥1 feature ≥2 SD
  - **MODERATE RISK**: ≥2 features 1-2 SD from norm OR ML probability 0.4-0.7 + ≥1 feature 1-2 SD
  - **LOW RISK**: All other cases

### ✅ 2. Comprehensive Outlier Detection
- **IQR Method** (1.5 × IQR rule)
- **Z-Score Method** (|Z| > 3)
- **Visualizations:**
  - Box plots for top 6 features with outliers
  - Outlier summary heatmap
  - Before/After outlier handling comparison

### ✅ 3. Complete Data Processing Pipeline
- **Missing Value Imputation**: Median for numeric, mode for categorical
- **Outlier Handling**: Winsorization (IQR-based capping)
- **Feature Scaling**: RobustScaler (robust to outliers)
- **Child-Level Train/Test Split**: Prevents data leakage

### ✅ 4. Dataset Improvement Methods
- **Multi-View Data Expansion** (4 views for DCCS):
  1. **Cognitive Flexibility View**: Pre/post-switch accuracy, switch cost, accuracy drop
  2. **Perseveration View**: Perseverative errors, rule-switching errors
  3. **Reaction Time View**: Pre/post switch RT, switch cost
  4. **Behavioral Regulation View**: Clinical observations
- **Safe Data Augmentation**:
  - Bootstrap resampling (with replacement)
  - Minimal Gaussian noise (3% of std)
  - Only applied if dataset < 30 samples

### ✅ 5. DCCS-Specific Feature Engineering

#### Age-Normalized Features (Age bins: 66-72, 72-78, 78-83 months)
- `post_switch_accuracy_zscore` (inverted: lower = more risk)
- `pre_switch_accuracy_zscore` (inverted: lower = more risk)
- `switch_cost_zscore` (higher = more risk)
- `perseverative_error_rate_zscore` (higher = more risk)

#### Composite Indices
- `cognitive_flexibility_index`: Post-switch accuracy + inverted switch cost
- `perseveration_control_index`: Inverted perseverative error rate
- `behavioral_regulation_index`: Attention, engagement, instruction following

#### Consistency Indicators
- `pre_post_switch_gap`: Pre-switch accuracy - Post-switch accuracy
- `switch_cost_relative`: Switch cost / Pre-switch RT
- `accuracy_drop_percent`: Calculated if not present

#### Binary Risk Flags
- `high_perseverative_error_flag`
- `low_post_switch_accuracy_flag`
- `high_switch_cost_flag`

---

## 📊 Notebook Structure (15 Steps)

1. **Setup and Install Libraries** - All required packages
2. **Load Real Clinical Dataset** - Filter to age 5.5-6.9 + color_shape
3. **Data Quality Analysis** - Missing values, statistics, visualizations
4. **Data Expansion** - Multi-view approach (4 views)
5. **Comprehensive Outlier Detection** - IQR + Z-score with visualizations
6. **Feature Engineering** - Age-normalized, composite indices, flags
7. **Feature Selection** - DCCS-specific feature list
8. **Handle Missing Values and Outliers** - Median imputation + winsorization
9. **Encode Target and Train/Test Split** - Child-level splitting
10. **Safe Data Augmentation** - Bootstrap + 3% noise
11. **Feature Scaling and Model Training** - Logistic Regression + Random Forest
12. **Clinical Risk Level Decision Logic** - Hybrid ML + DCCS norms
13. **Model Evaluation** - Metrics + 6 visualizations
14. **Save Model** - Model, scaler, features, metadata
15. **Summary and Recommendations** - Final report

---

## 🧠 Clinical Risk Level Decision Logic

### DCCS-Specific Features Used:
- `post_switch_accuracy`: Lower accuracy after rule switch = cognitive inflexibility
- `switch_cost_ms`: Higher cost = difficulty switching rules
- `perseverative_error_rate_post_switch`: Higher rate = strong perseveration
- `cognitive_flexibility_index`: Composite measure

### Risk Level Thresholds:
- **High Risk**: ≥2 features ≥2 SD from norm (severe cognitive inflexibility/perseveration)
- **Moderate Risk**: ≥2 features 1-2 SD from norm (moderate cognitive inflexibility)
- **Low Risk**: Features within normal range

### Hybrid Decision:
- Combines ML probability with clinical DCCS norms
- Prevents false positives by requiring clinical confirmation
- Uses NIH Toolbox DCCS norms (proxy: dataset statistics)

---

## 📝 Expected Output Files

After training, the notebook will save:
- `models/model_age_5_5_6_9_color_shape.pkl` - Trained model
- `models/scaler_age_5_5_6_9_color_shape.pkl` - Feature scaler
- `models/features_age_5_5_6_9_color_shape.json` - Feature list
- `models/model_metadata_age_5_5_6_9.json` - Model metadata

---

## 🚀 How to Use

1. **Open in Google Colab or Jupyter:**
   ```
   ML_TRAINING/Age_5_5_6_9_ColorShape_Model_Training.ipynb
   ```

2. **Run all cells sequentially**

3. **Upload dataset** (if in Colab) or ensure file is at:
   ```
   senseai_backend/age_5_5_6_9_training.csv
   ```

4. **Download trained model** from Colab (if used) or find in:
   ```
   ML_TRAINING/models/
   ```

5. **Copy to ML engine:**
   ```powershell
   Copy-Item "ML_TRAINING/models/model_age_5_5_6_9_color_shape.pkl" -Destination "senseai_backend/ml_engine/models/"
   Copy-Item "ML_TRAINING/models/scaler_age_5_5_6_9_color_shape.pkl" -Destination "senseai_backend/ml_engine/models/"
   Copy-Item "ML_TRAINING/models/features_age_5_5_6_9_color_shape.json" -Destination "senseai_backend/ml_engine/models/"
   Copy-Item "ML_TRAINING/models/model_metadata_age_5_5_6_9.json" -Destination "senseai_backend/ml_engine/models/"
   ```

---

## ✅ Checklist

- ✅ Three risk levels (low, moderate, high)
- ✅ Comprehensive outlier detection with visualizations
- ✅ Complete data processing pipeline
- ✅ Dataset improvement (multi-view expansion + safe augmentation)
- ✅ DCCS-specific feature engineering
- ✅ Age-normalized features (66-72, 72-78, 78-83 months)
- ✅ Composite indices (cognitive flexibility, perseveration control)
- ✅ Binary risk flags
- ✅ Clinical risk level decision logic (DCCS norms)
- ✅ Model training (Logistic Regression + Random Forest)
- ✅ Comprehensive evaluation with visualizations
- ✅ Model saving with metadata

---

## 📊 Key Differences from Previous Notebooks

| Aspect | Age 2-3.5 | Age 3.5-5.5 | Age 5.5-6.9 |
|--------|-----------|-------------|-------------|
| **Assessment** | Questionnaire | Frog Jump (Go/No-Go) | Color-Shape (DCCS) |
| **Age Bins** | 24-30, 30-36, 36-42 | 42-48, 48-54, 54-60, 60-66 | 66-72, 72-78, 78-83 |
| **Key Features** | Social responsiveness, joint attention | Commission errors, No-Go accuracy | Post-switch accuracy, switch cost, perseveration |
| **Multi-View** | Social, cognitive, behavioral | Inhibition, response, behavioral | Cognitive flexibility, perseveration, RT, behavioral |
| **Risk Logic** | Questionnaire norms | Go/No-Go norms | DCCS norms |

---

## 🎯 Next Steps

1. ✅ **Notebook is ready** - Run it in Google Colab or Jupyter
2. ⚠️ **Train the model** - Execute all cells
3. ⚠️ **Download model files** - Use the download script or manual download
4. ⚠️ **Integrate into ML engine** - Copy files to `senseai_backend/ml_engine/models/`
5. ⚠️ **Test predictions** - Verify model works with real data

---

**Notebook Status:** ✅ **COMPLETE** - Ready for training!

All methods from previous notebooks are included:
- ✅ Outlier detection with visualizations
- ✅ Feature engineering (age-normalized, composite indices)
- ✅ Safe augmentation (bootstrap + noise)
- ✅ Clinical risk level decision logic
- ✅ Three risk levels (low, moderate, high)
