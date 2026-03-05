# 🔗 Model Integration Guide

## How to Connect Your Trained Model to the System

This guide shows you how to integrate your age-specific ML models into the production system.

---

## 📋 Step 1: Locate Your Trained Model Files

After training, your notebook saves model files. Check where they were saved:

### If using the notebook (`Age_2_3_5_Questionnaire_Model_Training.ipynb`):

The notebook saves files to `ML_TRAINING/models/` directory:

```
ML_TRAINING/
  models/
    ├── model_age_2_3_5_questionnaire.pkl      # Trained model
    ├── scaler_age_2_3_5_questionnaire.pkl       # Feature scaler
    ├── features_age_2_3_5_questionnaire.json   # Feature list
    └── model_metadata_age_2_3_5.json          # Model metadata
```

### If files are in a different location:

Check the notebook output or search for `.pkl` files:
```bash
# Windows PowerShell
Get-ChildItem -Recurse -Filter "*.pkl" | Select-Object FullName
```

---

## 📋 Step 2: Copy Model Files to ML Engine

Copy your model files to the ML engine's `models/` directory:

### For Age 2-3.5 (Questionnaire Model):

```powershell
# Navigate to project root
cd D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273

# Copy model files (adjust source path if different)
Copy-Item "ML_TRAINING\models\model_age_2_3_5_questionnaire.pkl" `
          "senseai_backend\ml_engine\models\model_age_2_3_5_questionnaire.pkl"

Copy-Item "ML_TRAINING\models\scaler_age_2_3_5_questionnaire.pkl" `
          "senseai_backend\ml_engine\models\scaler_age_2_3_5_questionnaire.pkl"

Copy-Item "ML_TRAINING\models\features_age_2_3_5_questionnaire.json" `
          "senseai_backend\ml_engine\models\features_age_2_3_5_questionnaire.json"

Copy-Item "ML_TRAINING\models\model_metadata_age_2_3_5.json" `
          "senseai_backend\ml_engine\models\model_metadata_age_2_3_5.json"
```

### Expected File Structure:

```
senseai_backend/
  ml_engine/
    models/
      ├── model_age_2_3_5_questionnaire.pkl      ✅ Your model
      ├── scaler_age_2_3_5_questionnaire.pkl      ✅ Your scaler
      ├── features_age_2_3_5_questionnaire.json   ✅ Your features
      └── model_metadata_age_2_3_5.json          ✅ Your metadata
```

---

## 📋 Step 3: Verify Model Files

Check that all files are in place:

```powershell
# Check if files exist
Test-Path "senseai_backend\ml_engine\models\model_age_2_3_5_questionnaire.pkl"
Test-Path "senseai_backend\ml_engine\models\scaler_age_2_3_5_questionnaire.pkl"
Test-Path "senseai_backend\ml_engine\models\features_age_2_3_5_questionnaire.json"
```

All should return `True`.

---

## 📋 Step 4: Restart ML Engine

The ML engine automatically loads models at startup. Restart it:

### Option 1: Using PowerShell Script

```powershell
# Stop the engine (if running)
# Then restart using:
.\start_python_engine.ps1
```

### Option 2: Manual Restart

```powershell
cd senseai_backend\ml_engine
.\venv\Scripts\activate
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001
```

---

## 📋 Step 5: Test the Integration

### 5.1 Check Health Endpoint

Open browser or use curl:
```
http://localhost:8001/health
```

You should see:
```json
{
  "status": "healthy",
  "age_specific_models": {
    "2-3.5": {
      "model_exists": true,
      "scaler_exists": true,
      "features_exists": true,
      "ready": true
    },
    "3.5-5.5": {
      "ready": false
    },
    "5.5-6.9": {
      "ready": false
    }
  }
}
```

### 5.2 Test Prediction

Use the Swagger UI:
```
http://localhost:8001/docs
```

Or send a test request:

```json
POST http://localhost:8001/
{
  "age_months": 35,
  "child_id": "test_001",
  "features": {
    "age_months": 35,
    "critical_items_failed": 3,
    "social_responsiveness_score": 40,
    "joint_attention_score": 30,
    "total_score": 25,
    "attention_level": 3,
    "engagement_level": 4
  }
}
```

Expected response:
```json
{
  "prediction": 1,
  "probability": [0.2, 0.8],
  "confidence": 0.8,
  "risk_level": "high",
  "risk_score": 80.0,
  "asd_probability": 0.8
}
```

---

## 🔄 How It Works

### Age-Based Model Routing

The system automatically selects the correct model based on age:

| Age (months) | Age Group | Model Used | Assessment Type |
|-------------|-----------|------------|-----------------|
| 24-41 | 2-3.5 | `model_age_2_3_5_questionnaire.pkl` | Questionnaire |
| 42-65 | 3.5-5.5 | `model_age_3_5_5_5_frog_jump.pkl` | Frog Jump |
| 66-82 | 5.5-6.9 | `model_age_5_5_6_9_color_shape.pkl` | Color-Shape |

### Request Flow

1. **Request arrives** with `age_months` and `features`
2. **System determines age group** (e.g., 35 months → "2-3.5")
3. **Loads appropriate model** (cached after first load)
4. **Preprocesses features** (scaling, ordering)
5. **Makes prediction** using the age-specific model
6. **Returns risk score** and probabilities

---

## 🚨 Troubleshooting

### Error: "Model not found for age group 2-3.5"

**Solution**: Check file paths and names:
- File must be exactly: `model_age_2_3_5_questionnaire.pkl`
- Location: `senseai_backend/ml_engine/models/`
- Check spelling and case sensitivity

### Error: "Scaler expects X features but got Y"

**Solution**: 
- Ensure you're sending the correct features
- Check `features_age_2_3_5_questionnaire.json` for expected feature list
- Features must match exactly (order doesn't matter, but names do)

### Error: "Age X months is outside supported range"

**Solution**:
- Age must be between 24-83 months
- For ages outside this range, the system will return an error
- Consider training additional models for other age ranges

### Model Not Loading

**Check**:
1. Files exist in `senseai_backend/ml_engine/models/`
2. File names match exactly (case-sensitive)
3. ML engine was restarted after copying files
4. Check logs: `senseai_backend/ml_engine/logs/ml_engine.log`

---

## 📝 Next Steps

### For Other Age Groups:

When you train models for other age groups:

1. **Age 3.5-5.5 (Frog Jump)**:
   - Save as: `model_age_3_5_5_5_frog_jump.pkl`
   - Copy to: `senseai_backend/ml_engine/models/`

2. **Age 5.5-6.9 (Color-Shape)**:
   - Save as: `model_age_5_5_6_9_color_shape.pkl`
   - Copy to: `senseai_backend/ml_engine/models/`

### Update Backend API:

The backend API (`senseai_backend/routes/`) automatically calls the ML engine. No changes needed!

### Update Flutter App:

The Flutter app already sends the correct features. No changes needed!

---

## ✅ Verification Checklist

- [ ] Model files copied to `senseai_backend/ml_engine/models/`
- [ ] File names match exactly (case-sensitive)
- [ ] ML engine restarted
- [ ] Health endpoint shows model as "ready"
- [ ] Test prediction works
- [ ] Response includes correct risk score

---

## 🎯 Quick Command Reference

```powershell
# Copy model files
Copy-Item "ML_TRAINING\models\*.pkl" "senseai_backend\ml_engine\models\"
Copy-Item "ML_TRAINING\models\*.json" "senseai_backend\ml_engine\models\"

# Check files
Get-ChildItem "senseai_backend\ml_engine\models\model_age_2_3_5*"

# Restart engine
cd senseai_backend\ml_engine
.\venv\Scripts\activate
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001
```

---

## 📞 Support

If you encounter issues:
1. Check the logs: `senseai_backend/ml_engine/logs/ml_engine.log`
2. Verify file paths and names
3. Ensure ML engine is running on port 8001
4. Test health endpoint first: `http://localhost:8001/health`

---

**Your model is now integrated! 🎉**

The system will automatically use your age-specific model for predictions.
