# Complete ML Model Integration Guide

## 🎯 Overview

This guide explains how to train a model with real data and integrate it into your Flutter app for automated ASD risk predictions.

---

## 📋 Complete Workflow

### Step 1: Collect Real Data (3-6 months)

1. Use your Flutter app to assess children
2. Data automatically saves to Firebase
3. Export data periodically:
   - From Firebase Console → Export collections
   - Or use backend API to export sessions

### Step 2: Prepare Training Data

1. **Export Sessions with ML Features**
   - Each session already includes `ml_features` field
   - Export to CSV format

2. **Format for Training**
   - One row per child assessment
   - Columns: All ML features + `group` (asd/control)
   - Match format from `SAMPLE_DATASETS/`

### Step 3: Train Model

1. **Open Training Notebook**
   - `ML_TRAINING/Complete_ASD_ML_Training.ipynb`
   - Upload to Google Colab

2. **Upload Your Real Data**
   - Replace sample data with your real data
   - Ensure both ASD and Control groups included

3. **Train Model**
   - Run all cells
   - Model will be trained and evaluated
   - Best model selected automatically

4. **Save Model Files**
   - `asd_detection_model.pkl` - Trained model
   - `feature_scaler.pkl` - Feature scaler
   - Create `feature_names.json` with feature list

### Step 4: Deploy to Backend

1. **Copy Files**
   ```bash
   cp asd_detection_model.pkl senseai_backend/models/
   cp feature_scaler.pkl senseai_backend/models/
   cp feature_names.json senseai_backend/models/
   ```

2. **Install Python Dependencies**
   ```bash
   cd senseai_backend
   pip install scikit-learn joblib numpy pandas
   ```

3. **Test**
   ```bash
   # Test health endpoint
   curl http://localhost:3000/api/ml/health
   
   # Test prediction
   # Use Postman with example from ML_MODEL_USAGE_EXAMPLE.md
   ```

### Step 5: Update Flutter (Optional)

The ML service is ready! You can:
- Use it immediately (calls backend)
- Or enhance summary classes to use ML predictions

---

## 🔄 How It Works

```
Flutter App
    ↓
Collects Assessment Data
    ↓
Extracts ML Features (already implemented)
    ↓
Sends to Backend: POST /api/ml/predict
    ↓
Backend Python Script
    ↓
Loads Trained Model (.pkl)
    ↓
Scales Features
    ↓
Makes Prediction
    ↓
Returns: {prediction, risk_score, risk_level, probability}
    ↓
Flutter Uses Result
```

---

## 📊 Feature Extraction (Already Implemented)

Your app already extracts ML features:

### Questionnaire (Age 2-3.5)
- `questionnaire_summary.dart` → `mlFeatures` getter
- Includes: critical items, domain scores, etc.

### Color-Shape Game (Age 5.5-6.9)
- `game_trial.dart` → `mlFeatures` getter
- Includes: accuracy, perseverative errors, switch cost, etc.

### Frog Jump Game (Age 3.5-5.5)
- `frog_jump_summary.dart` → `mlFeatures` getter
- Includes: No-Go accuracy, commission errors, RT variability, etc.

---

## 🚀 Quick Integration Example

### In Your Assessment Screen:

```dart
// After assessment completes
final summary = QuestionnaireSummary.fromResponses(...);

// Option 1: Use ML prediction
try {
  final mlResult = await MLService.predict(
    mlFeatures: summary.mlFeatures,
    ageGroup: '2-3',
    sessionType: 'ai_doctor_bot',
  );
  
  if (mlResult != null) {
    // Use ML-enhanced risk
    final riskScore = mlResult.riskScore;
    final riskLevel = mlResult.riskLevel;
    print('ML Prediction: $riskLevel ($riskScore)');
  } else {
    // Fallback to rule-based
    final riskScore = summary.riskScore;
    final riskLevel = summary.riskLevel;
  }
} catch (e) {
  // Always fallback to rule-based
  final riskScore = summary.riskScore;
  final riskLevel = summary.riskLevel;
}
```

---

## ✅ Checklist

### Backend Setup:
- [ ] Model files in `senseai_backend/models/`
- [ ] Python dependencies installed
- [ ] Backend route added (`/api/ml/predict`)
- [ ] Python script created (`ml_scripts/predict.py`)
- [ ] Health check works (`GET /api/ml/health`)
- [ ] Test prediction with Postman

### Flutter Integration:
- [ ] ML service created (`lib/core/services/ml_service.dart`)
- [ ] Update assessment screens to use ML (optional)
- [ ] Test with real assessments
- [ ] Verify predictions make sense

### Testing:
- [ ] Test with known ASD cases
- [ ] Test with known Control cases
- [ ] Compare ML vs rule-based
- [ ] Monitor prediction accuracy

---

## 🔄 Model Updates

When you have more data:

1. **Retrain Model** (every 3-6 months)
2. **Validate Performance**
3. **Replace Files** in `senseai_backend/models/`
4. **Restart Backend**
5. **No App Update Needed!** 🎉

---

## 📚 Documentation Files

- **ML_MODEL_INTEGRATION_GUIDE.md** - Detailed integration guide
- **ML_MODEL_USAGE_EXAMPLE.md** - Quick start examples
- **ML_INTEGRATION_STEPS.md** - Step-by-step workflow

---

## 🎓 Key Points

1. **Model Format**: Python `.pkl` files (scikit-learn)
2. **Deployment**: Backend API (recommended)
3. **Features**: Already extracted in Flutter app
4. **Fallback**: Rule-based if ML unavailable
5. **Updates**: Replace model files, restart backend

---

## 💡 Tips

- Start with rule-based, add ML gradually
- Monitor ML predictions vs clinician assessments
- Retrain model as you collect more data
- Keep feature names consistent between training and app
- Test thoroughly before full deployment

---

## 🆘 Need Help?

1. Check backend logs for Python errors
2. Verify model files exist and are valid
3. Test with Postman first
4. Ensure feature names match training
5. Check Python dependencies installed




