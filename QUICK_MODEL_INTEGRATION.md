# ⚡ Quick Model Integration Guide

## 🚀 3-Step Integration

### Step 1: Copy Model Files

Run the PowerShell script:
```powershell
.\copy_model_to_engine.ps1
```

**OR** manually copy files:
```powershell
# From ML_TRAINING/models/ to senseai_backend/ml_engine/models/
Copy-Item "ML_TRAINING\models\model_age_2_3_5_questionnaire.pkl" `
          "senseai_backend\ml_engine\models\model_age_2_3_5_questionnaire.pkl"

Copy-Item "ML_TRAINING\models\scaler_age_2_3_5_questionnaire.pkl" `
          "senseai_backend\ml_engine\models\scaler_age_2_3_5_questionnaire.pkl"

Copy-Item "ML_TRAINING\models\features_age_2_3_5_questionnaire.json" `
          "senseai_backend\ml_engine\models\features_age_2_3_5_questionnaire.json"

Copy-Item "ML_TRAINING\models\model_metadata_age_2_3_5.json" `
          "senseai_backend\ml_engine\models\model_metadata_age_2_3_5.json"
```

### Step 2: Restart ML Engine

```powershell
.\start_python_engine.ps1
```

### Step 3: Test

1. **Check Health**: http://localhost:8001/health
2. **Test Prediction**: http://localhost:8001/docs

---

## ✅ That's It!

Your model is now connected. The system automatically:
- Detects age group from `age_months`
- Loads the correct model (2-3.5, 3.5-5.5, or 5.5-6.9)
- Makes predictions using your trained model

---

## 📍 File Locations

**Source** (after training):
```
ML_TRAINING/models/
  ├── model_age_2_3_5_questionnaire.pkl
  ├── scaler_age_2_3_5_questionnaire.pkl
  ├── features_age_2_3_5_questionnaire.json
  └── model_metadata_age_2_3_5.json
```

**Destination** (for production):
```
senseai_backend/ml_engine/models/
  ├── model_age_2_3_5_questionnaire.pkl      ✅
  ├── scaler_age_2_3_5_questionnaire.pkl      ✅
  ├── features_age_2_3_5_questionnaire.json   ✅
  └── model_metadata_age_2_3_5.json          ✅
```

---

## 🔍 Troubleshooting

**"Model not found"** → Check file names match exactly (case-sensitive)

**"Wrong number of features"** → Ensure you're sending the correct features from your training

**"Model not loading"** → Restart ML engine after copying files

---

For detailed guide, see: `MODEL_INTEGRATION_GUIDE.md`
