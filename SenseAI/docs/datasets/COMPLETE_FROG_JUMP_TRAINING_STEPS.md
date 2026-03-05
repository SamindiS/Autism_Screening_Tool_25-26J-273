# 🐸 Complete Frog Jump Model Training Steps

## Quick Reference: All Steps for Age 3.5-5.5 Model

This document outlines all the steps needed to complete the Frog Jump model training notebook. The notebook structure follows the same pattern as the Age 2-3.5 questionnaire model, but adapted for Go/No-Go features.

---

## 📋 Complete Step List

### ✅ Steps 1-11: Same as Age 2-3.5 Model
1. Setup and Install Libraries
2. Load Real Clinical Dataset
3. Data Quality Analysis
4. Data Expansion (Multi-view)
5. Feature Engineering
6. Feature Selection
7. Handle Missing Values and Outliers
8. Encode Target Variable
9. Train/Test Split (Child-Level)
10. Safe Data Augmentation
11. Feature Scaling

### ✅ Step 12: Train Models
- Logistic Regression (Primary)
- Random Forest (Secondary)
- Select best model

### ✅ Step 13: Model Evaluation
- Accuracy, Precision, Recall, F1, ROC-AUC
- Confusion Matrix
- Visualizations

### ✅ Step 14: Clinical Risk Level Decision Logic ⭐ NEW

This is the **critical addition** you requested:

```python
def decide_clinical_risk_level(ml_probability, z_scores_dict, clinical_thresholds):
    """
    Hybrid ML + Clinical Rules for Risk Level Decision
    
    Args:
        ml_probability: ML model's ASD probability (0-1)
        z_scores_dict: Dictionary of z-scores for key features
        clinical_thresholds: Clinical thresholds for risk levels
        
    Returns:
        risk_level: 'low', 'moderate', or 'high'
    """
    # Method 1: Normative Deviation (Z-Score Based)
    # Count features that are ≤ -2 SD (high risk)
    high_risk_features = sum(1 for z in z_scores_dict.values() if z <= -2)
    # Count features between -1 and -2 SD (moderate risk)
    moderate_risk_features = sum(1 for z in z_scores_dict.values() if -2 < z <= -1)
    
    # Method 2: ML Probability
    ml_high_risk = ml_probability >= 0.7
    ml_moderate_risk = 0.4 <= ml_probability < 0.7
    
    # Hybrid Decision
    if (high_risk_features >= 2) or (ml_high_risk and high_risk_features >= 1):
        return 'high'
    elif (moderate_risk_features >= 2) or (ml_moderate_risk and moderate_risk_features >= 1):
        return 'moderate'
    else:
        return 'low'
```

### ✅ Step 15: Feature Importance Analysis
- Top features for ASD detection
- Clinical interpretation

### ✅ Step 16: Cross-Validation (LOCO-CV)
- Leave-One-Child-Out validation
- Robust performance estimates

### ✅ Step 17: Save Model and Scalers
- Save model: `model_age_3_5_5_5_frog_jump.pkl`
- Save scaler: `scaler_age_3_5_5_5_frog_jump.pkl`
- Save features: `features_age_3_5_5_5_frog_jump.json`
- Save metadata: `model_metadata_age_3_5_5_5.json`

### ✅ Step 18: Summary and Recommendations

---

## 🔑 Key Differences from Age 2-3.5 Model

### Features Used:

**Frog Jump Specific:**
- `go_accuracy`, `nogo_accuracy`, `overall_accuracy`
- `commission_errors`, `commission_error_rate` ⭐ (Most important)
- `omission_errors`, `omission_error_rate`
- `avg_rt_go_ms`, `rt_variability` ⭐ (Important)
- `inhibition_failure_rate`
- `anticipatory_responses`, `late_responses`

**Age-Normalized:**
- `nogo_accuracy_zscore`
- `commission_error_rate_zscore`
- `rt_variability_zscore`

**Composite Indices:**
- `inhibition_control_index`
- `response_control_index`
- `behavioral_regulation_index`

**Risk Flags:**
- `high_commission_error_flag`
- `low_nogo_accuracy_flag`
- `high_rt_variability_flag`

---

## 🧠 Clinical Risk Level Logic

### Z-Score Thresholds (Based on Normative Data):

| Z-Score Range | Clinical Interpretation | Risk Level |
|--------------|------------------------|------------|
| ≥ -1 SD | Within normal range | Low |
| -1 to -2 SD | Below average | Moderate |
| ≤ -2 SD | Significantly below | High |

### Decision Rules:

1. **High Risk**: 
   - ≥2 features ≤ -2 SD, OR
   - ML probability ≥ 0.7 AND ≥1 feature ≤ -2 SD

2. **Moderate Risk**:
   - ≥2 features between -1 and -2 SD, OR
   - ML probability 0.4-0.7 AND ≥1 feature between -1 and -2 SD

3. **Low Risk**:
   - All other cases

---

## 📝 For Your Report

You can state:

> "Machine learning was used to identify patterns in inhibitory control performance associated with autism risk. Risk levels were determined using a hybrid approach combining ML probability scores with clinically established normative deviations (Z-scores). Features were normalized by age to account for developmental differences, and risk stratification followed standard developmental screening protocols based on deviation from age-appropriate norms."

---

## 🎯 Next Steps

1. Complete the notebook using the structure from Age 2-3.5 model
2. Adapt feature lists for Frog Jump
3. Implement clinical risk level decision function
4. Train and evaluate
5. Save model files
6. Integrate into ML engine

---

**The notebook structure is ready - just follow the same pattern as Age 2-3.5 but with Frog Jump features!**
