# 🚀 Quick Start Guide - ML Training Pipeline

## 📋 Overview

This is a **complete, professional ML training pipeline** for all 3 age-specific autism screening models.

---

## ⚡ Quick Start (3 Steps)

### Step 1: Prepare Datasets

```bash
cd ML_TRAINING

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

### Step 3: Check Results

```bash
# Models saved in: ML_TRAINING/models/
# Results saved in: ML_TRAINING/output/
```

---

## 📁 File Structure

```
ML_TRAINING/
├── README_TRAINING_PIPELINE.md      # Main overview
├── COMPLETE_TRAINING_GUIDE.md       # Detailed guide
├── QUICK_START.md                   # This file
├── config.py                        # All configurations
├── utils/                           # Utility modules
│   ├── feature_engineering.py
│   ├── outlier_detection.py
│   ├── data_augmentation.py
│   ├── preprocessing.py
│   └── evaluation.py
├── preprocessing/                   # Data preparation
│   ├── prepare_age_2_3_5_data.py
│   ├── prepare_age_3_5_5_5_data.py
│   └── prepare_age_5_5_6_9_data.py
└── training/                        # Model training
    ├── train_age_2_3_5_model.py
    ├── train_age_3_5_5_5_model.py
    └── train_age_5_5_6_9_model.py
```

---

## 🎯 What Each Script Does

### Preprocessing Scripts

**Purpose**: Prepare and combine datasets

1. **Load external datasets** (Toddler Autism, Autism Screening Combined)
2. **Filter by age range**
3. **Extract features** (A1-A10, game metrics, etc.)
4. **Age-normalize** (z-scores)
5. **Save prepared datasets**

### Training Scripts

**Purpose**: Train professional-grade ML models

1. **Load prepared data**
2. **Preprocess** (clean, handle missing values)
3. **Feature engineering** (composite indices, binary flags)
4. **Outlier detection** (IQR-based, Winsorization)
5. **Data augmentation** (bootstrap/SMOTE)
6. **Feature scaling** (StandardScaler)
7. **Train models** (Logistic Regression + Random Forest)
8. **Evaluate** (accuracy, precision, recall, F1, ROC-AUC)
9. **Save models** (model, scaler, features, metadata)

---

## 📊 Expected Results

| Model | Training Samples | Test Accuracy | ROC-AUC |
|-------|----------------|---------------|---------|
| **Age 2-3.5** | ~2,314 | 80-85% | 0.85-0.90 |
| **Age 3.5-5.5** | ~500 (augmented) | 75-80% | 0.80-0.85 |
| **Age 5.5-6.9** | ~300 (augmented) | 70-75% | 0.75-0.80 |

---

## 🔧 Customization

Edit `config.py` to customize:

- **Hyperparameters**: Model parameters, augmentation settings
- **Data paths**: External datasets, hospital data
- **Feature lists**: Which features to use
- **Outlier detection**: Method, thresholds
- **Augmentation**: Method, target samples

---

## 📝 Output Files

After training, you'll have:

### Model Files (in `models/`)
- `model_age_X_X_X_X.pkl` - Trained model
- `scaler_model_age_X_X_X_X.pkl` - Feature scaler
- `features_model_age_X_X_X_X.json` - Feature list
- `model_metadata_model_age_X_X_X_X.json` - Model metadata

### Results Files (in `output/`)
- `training_results_model_age_X_X_X_X.json` - Evaluation metrics

---

## ✅ Quality Checklist

Before deploying:

- [ ] Training accuracy > 75%
- [ ] Test accuracy > 70%
- [ ] ROC-AUC > 0.75
- [ ] No overfitting (train/test gap < 10%)
- [ ] All model files saved
- [ ] Features list saved
- [ ] Metadata saved

---

## 🚨 Common Issues

### "File not found"
- Check dataset paths in `config.py`
- Ensure external datasets are in `Online Datasets/`

### "Low accuracy"
- Increase augmentation target samples
- Check data quality
- Verify feature engineering

### "Overfitting"
- Reduce model complexity
- Increase regularization
- Reduce augmentation

---

## 📚 Documentation

- **Complete Guide**: See `COMPLETE_TRAINING_GUIDE.md`
- **Pipeline Overview**: See `README_TRAINING_PIPELINE.md`
- **Configuration**: See `config.py`

---

## 🎉 Next Steps

1. **Copy models** to `senseai_backend/ml_engine/models/`
2. **Update ML engine config** to use new models
3. **Test predictions** with new child data
4. **Add to dashboard** (performance metrics, charts)

---

**Status**: Ready to train! 🚀
