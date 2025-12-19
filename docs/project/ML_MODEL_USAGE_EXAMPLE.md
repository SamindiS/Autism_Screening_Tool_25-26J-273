# ML Model Usage Example

## Quick Start: Using Trained Model in Your App

### Step 1: After Training Your Model

1. **Train model** using `ML_TRAINING/Complete_ASD_ML_Training.ipynb`
2. **Save model files**:
   - `asd_detection_model.pkl`
   - `feature_scaler.pkl`
   - `feature_names.json` (optional but recommended)

3. **Copy to backend**:
   ```bash
   cp asd_detection_model.pkl senseai_backend/models/
   cp feature_scaler.pkl senseai_backend/models/
   cp feature_names.json senseai_backend/models/
   ```

### Step 2: Install Python Dependencies

```bash
cd senseai_backend
pip install scikit-learn joblib numpy pandas
```

Or if using virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install scikit-learn joblib numpy pandas
```

### Step 3: Test Backend Endpoint

Use Postman to test:

```json
POST http://localhost:3000/api/ml/predict
Content-Type: application/json

{
  "mlFeatures": {
    "age_months": 70,
    "completion_time_sec": 280,
    "accuracy_overall": 55.0,
    "primary_asd_marker_1": 6,
    "primary_asd_marker_2": 50.0,
    "primary_asd_marker_3": 450,
    "attention_level": 2,
    "engagement_level": 2,
    "enhanced_risk_score": 35.0
  },
  "ageGroup": "5-6",
  "sessionType": "color_shape"
}
```

**Expected Response:**
```json
{
  "success": true,
  "prediction": 1,
  "probability": [0.2, 0.8],
  "confidence": 0.8,
  "risk_level": "high",
  "risk_score": 80.0,
  "method": "ml"
}
```

### Step 4: Update Flutter Code

The ML service is already created. Now update your summary classes to use it:

#### Example: Update QuestionnaireSummary

In `lib/features/assessment/models/questionnaire_summary.dart`:

```dart
import '../../../../core/services/ml_service.dart';

class QuestionnaireSummary {
  // ... existing code ...
  
  // Add async method to get ML-enhanced risk
  Future<void> enhanceWithML() async {
    try {
      final mlResult = await MLService.predict(
        mlFeatures: mlFeatures,
        ageGroup: '2-3', // Based on child age
        sessionType: 'ai_doctor_bot',
      );
      
      if (mlResult != null) {
        // Use ML prediction
        _riskScore = mlResult.riskScore;
        _riskLevel = mlResult.riskLevelUpper;
        debugPrint('✅ Using ML prediction: ${mlResult.riskLevel} (${mlResult.riskScore.toStringAsFixed(1)})');
      } else {
        debugPrint('⚠️  ML unavailable, using rule-based');
      }
    } catch (e) {
      debugPrint('❌ ML enhancement failed: $e');
      // Keep existing rule-based values
    }
  }
}
```

### Step 5: Call ML in Assessment Flow

Update `lib/features/assessment/ai_doctor_bot_screen.dart`:

```dart
// After generating summary
final summary = QuestionnaireSummary.fromResponses(...);

// Enhance with ML prediction
await summary.enhanceWithML();

// Now use summary.riskScore and summary.riskLevel (ML-enhanced)
```

---

## Feature Names JSON Template

Create `senseai_backend/models/feature_names.json` with your training features:

```json
[
  "age_months",
  "completion_time_sec",
  "total_score_or_trials",
  "accuracy_overall",
  "primary_asd_marker_1",
  "primary_asd_marker_2",
  "primary_asd_marker_3",
  "attention_level",
  "engagement_level",
  "frustration_tolerance",
  "instruction_following",
  "overall_behavior",
  "enhanced_risk_score"
]
```

**Important:** Feature names must match exactly what you used during training!

---

## How It Works

1. **Flutter app** collects assessment data
2. **Extracts ML features** (already implemented in summary classes)
3. **Sends to backend** via `/api/ml/predict`
4. **Backend runs Python script** with trained model
5. **Returns prediction** (ASD risk score, level, probability)
6. **Flutter uses ML result** for risk assessment

---

## Model Update Process

When you retrain with new data:

1. Train new model → Save `.pkl` files
2. Replace files in `senseai_backend/models/`
3. Restart backend server
4. **No app update needed!** 🎉

---

## Troubleshooting

### "ML models not found"
- Check files exist in `senseai_backend/models/`
- Verify file names match exactly

### "Python script error"
- Check Python is installed: `python3 --version`
- Install dependencies: `pip install scikit-learn joblib numpy pandas`
- Check Python script path is correct

### "Feature mismatch"
- Ensure feature names in JSON match training
- Check feature values are numbers (not null/string)

### "Fallback used"
- ML service falls back to rule-based if ML fails
- Check backend logs for errors
- Verify model files are valid

---

## Next Steps

1. ✅ Train model with real data
2. ✅ Copy model files to backend
3. ✅ Test with Postman
4. ✅ Update Flutter to use ML service
5. ✅ Test with real assessments
6. ✅ Monitor predictions
7. ✅ Retrain and update as needed





