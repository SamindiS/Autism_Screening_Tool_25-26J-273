# 🎯 Complete ML Training Pipeline - All 3 Models

## 📋 Overview

This directory contains a **complete, professional ML training pipeline** for all three age-specific autism screening models:

1. **Age 2-3.5**: Questionnaire Model (Q-CHAT-10 style)
2. **Age 3.5-5.5**: Frog Jump Model (Go/No-Go)
3. **Age 5.5-6.9**: Color-Shape Model (DCCS)

---

## 📁 File Structure

```
ML_TRAINING/
├── README_TRAINING_PIPELINE.md          # This file
├── config.py                            # Configuration for all models
├── utils/
│   ├── __init__.py
│   ├── feature_engineering.py          # Feature engineering utilities
│   ├── outlier_detection.py            # Outlier detection and handling
│   ├── data_augmentation.py             # Data augmentation methods
│   ├── preprocessing.py                 # Data preprocessing utilities
│   └── evaluation.py                    # Model evaluation utilities
├── preprocessing/
│   ├── prepare_age_2_3_5_data.py       # Prepare Age 2-3.5 datasets
│   ├── prepare_age_3_5_5_5_data.py     # Prepare Age 3.5-5.5 datasets
│   └── prepare_age_5_5_6_9_data.py      # Prepare Age 5.5-6.9 datasets
├── training/
│   ├── train_age_2_3_5_model.py        # Train Age 2-3.5 model
│   ├── train_age_3_5_5_5_model.py      # Train Age 3.5-5.5 model
│   └── train_age_5_5_6_9_model.py      # Train Age 5.5-6.9 model
└── notebooks/
    ├── Age_2_3_5_Questionnaire_Model_Training.ipynb
    ├── Age_3_5_5_5_FrogJump_Model_Training.ipynb
    └── Age_5_5_6_9_ColorShape_Model_Training.ipynb
```

---

## 🚀 Quick Start

### Step 1: Prepare Datasets
```bash
# Age 2-3.5
python preprocessing/prepare_age_2_3_5_data.py

# Age 3.5-5.5
python preprocessing/prepare_age_3_5_5_5_data.py

# Age 5.5-6.9
python preprocessing/prepare_age_5_5_6_9_data.py
```

### Step 2: Train Models
```bash
# Age 2-3.5
python training/train_age_2_3_5_model.py

# Age 3.5-5.5
python training/train_age_3_5_5_5_model.py

# Age 5.5-6.9
python training/train_age_5_5_6_9_model.py
```

---

## 📊 Training Strategy

### **Train/Test Split Strategy**

| Model | Training Data | Test Data | Split Method |
|-------|--------------|-----------|--------------|
| **Age 2-3.5** | External datasets (~2,314 samples) | Hospital data (40 samples) | External vs Hospital |
| **Age 3.5-5.5** | External (592) + Game (29) | Hospital game data | Child-level split |
| **Age 5.5-6.9** | External (19) + Game (19) | Hospital game data | Child-level split |

### **Key Principles**

1. **No Data Leakage**: Child-level splitting (not row-level)
2. **External for Training**: Use external datasets for training
3. **Hospital for Testing**: Use your collected data for testing
4. **Stratified Splits**: Maintain class balance

---

## 🔧 Components

### 1. **Feature Engineering**
- Age normalization (z-scores)
- Composite indices
- Binary risk flags
- Domain-specific scores

### 2. **Outlier Detection**
- IQR-based detection
- Winsorization (capping)
- Statistical validation

### 3. **Data Augmentation**
- Bootstrap resampling
- SMOTE (for imbalanced data)
- Safe noise injection

### 4. **Model Training**
- Logistic Regression (primary)
- Random Forest (comparison)
- Cross-validation
- Hyperparameter tuning

### 5. **Evaluation**
- Accuracy, Precision, Recall, F1
- ROC-AUC, PR-AUC
- Confusion matrices
- Feature importance

---

## 📈 Expected Results

| Model | Training Accuracy | Test Accuracy | Notes |
|-------|------------------|---------------|-------|
| **Age 2-3.5** | 85-90% | 80-85% | Large training set |
| **Age 3.5-5.5** | 80-85% | 75-80% | Hybrid features |
| **Age 5.5-6.9** | 75-80% | 70-75% | Small dataset |

---

## 📝 Detailed Documentation

- **Configuration**: See `config.py`
- **Feature Engineering**: See `utils/feature_engineering.py`
- **Outlier Detection**: See `utils/outlier_detection.py`
- **Augmentation**: See `utils/data_augmentation.py`
- **Preprocessing**: See `preprocessing/` directory
- **Training**: See `training/` directory

---

## ✅ Quality Assurance

All models include:
- ✅ Outlier detection and handling
- ✅ Feature engineering
- ✅ Data augmentation
- ✅ Cross-validation
- ✅ Model evaluation
- ✅ Feature importance analysis
- ✅ Model persistence
- ✅ Metadata saving

---

**Status**: Ready for professional model training! 🎉
