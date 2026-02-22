# Step-by-Step: ML Model Integration

## Complete Workflow

### Phase 1: Train Your Model

1. **Collect Real Data**
   - Use your Flutter app to assess children
   - Data automatically saved to Firebase
   - Export data from Firebase or backend

2. **Prepare Training Data**
   - Export sessions with ML features
   - Format as CSV matching your training notebook
   - Include both ASD and Control groups

3. **Train Model**
   - Open `ML_TRAINING/Complete_ASD_ML_Training.ipynb` in Google Colab
   - Upload your real data CSV
   - Run all cells
   - Model will be saved as `.pkl` files

4. **Download Model Files**
   - `asd_detection_model.pkl` - Your trained model
   - `feature_scaler.pkl` - Feature scaler
   - Create `feature_names.json` with feature list

### Phase 2: Deploy Model to Backend

1. **Create Models Directory**
   ```bash
   mkdir senseai_backend/models
   ```

2. **Copy Model Files**
   ```bash
   cp asd_detection_model.pkl senseai_backend/models/
   cp feature_scaler.pkl senseai_backend/models/
   cp feature_names.json senseai_backend/models/
   ```

3. **Install Python Dependencies**
   ```bash
   cd senseai_backend
   pip install scikit-learn joblib numpy pandas
   ```

4. **Test Python Script**
   ```bash
   python ml_scripts/predict.py '{"features": {"age_months": 70, "accuracy_overall": 55.0}, "age_group": "5-6", "session_type": "color_shape"}'
   ```

5. **Start Backend**
   ```bash
   npm start
   ```

6. **Test ML Endpoint**
   - Use Postman: `POST http://localhost:3000/api/ml/predict`
   - Check health: `GET http://localhost:3000/api/ml/health`

### Phase 3: Update Flutter App

The ML service is already created. Now integrate it:

#### Option A: Use ML for All Predictions (Recommended)

Update `lib/features/assessment/models/questionnaire_summary.dart`:

```dart
import '../../../../core/services/ml_service.dart';

class QuestionnaireSummary {
  // ... existing code ...
  
  // Add method to enhance with ML
  static Future<QuestionnaireSummary> fromResponsesWithML({
    required Map<int, int> responses,
    required List<Map<String, dynamic>> questions,
    required int completionTimeSec,
  }) async {
    // Create summary with rule-based calculation first
    final summary = QuestionnaireSummary.fromResponses(
      responses: responses,
      questions: questions,
      completionTimeSec: completionTimeSec,
    );
    
    // Enhance with ML prediction
    try {
      final mlResult = await MLService.predict(
        mlFeatures: summary.mlFeatures,
        ageGroup: '2-3',
        sessionType: 'ai_doctor_bot',
      );
      
      if (mlResult != null && mlResult.method == 'ml') {
        // Create new summary with ML-enhanced values
        return QuestionnaireSummary(
          totalQuestions: summary.totalQuestions,
          completionTimeSec: summary.completionTimeSec,
          totalScore: summary.totalScore,
          maxPossibleScore: summary.maxPossibleScore,
          percentageScore: summary.percentageScore,
          categoryScores: summary.categoryScores,
          responses: summary.responses,
          criticalItemsFailed: summary.criticalItemsFailed,
          criticalItemsCount: summary.criticalItemsCount,
          criticalItemsFailRate: summary.criticalItemsFailRate,
          riskScore: mlResult.riskScore, // ML-enhanced
          riskLevel: mlResult.riskLevelUpper, // ML-enhanced
          failedItemsTotal: summary.failedItemsTotal,
          failedItemsRate: summary.failedItemsRate,
          socialResponsivenessScore: summary.socialResponsivenessScore,
          cognitiveFlexibilityScore: summary.cognitiveFlexibilityScore,
          jointAttentionScore: summary.jointAttentionScore,
          socialCommunicationScore: summary.socialCommunicationScore,
          sensoryProcessingScore: summary.sensoryProcessingScore,
          communicationScore: summary.communicationScore,
        );
      }
    } catch (e) {
      debugPrint('ML enhancement failed: $e');
    }
    
    // Return original if ML fails
    return summary;
  }
}
```

#### Option B: Hybrid Approach (ML + Rule-Based)

Use ML when available, fallback to rule-based:

```dart
// In your assessment screen
final summary = QuestionnaireSummary.fromResponses(...);

// Try ML enhancement
try {
  final mlResult = await MLService.predict(...);
  if (mlResult != null) {
    // Use ML result
    final enhancedRiskScore = mlResult.riskScore;
    final enhancedRiskLevel = mlResult.riskLevel;
  } else {
    // Use rule-based
    final ruleBasedScore = summary.riskScore;
    final ruleBasedLevel = summary.riskLevel;
  }
} catch (e) {
  // Always fallback to rule-based
}
```

### Phase 4: Test Integration

1. **Test with Known Cases**
   - Test with high-risk child → Should predict ASD
   - Test with low-risk child → Should predict Control

2. **Verify Predictions**
   - Check backend logs for ML predictions
   - Compare ML vs rule-based results
   - Ensure predictions make clinical sense

3. **Monitor Performance**
   - Track prediction accuracy
   - Compare with clinician assessments
   - Adjust model as needed

---

## Feature Mapping

Ensure your Flutter app's ML features match training:

### Questionnaire (Age 2-3.5)
- `critical_items_failed`
- `q5_pointing` (most important)
- `social_responsiveness_score`
- `joint_attention_score`
- etc.

### Color-Shape Game (Age 5.5-6.9)
- `post_switch_accuracy`
- `total_perseverative_errors`
- `switch_cost_ms`
- etc.

### Frog Jump Game (Age 3.5-5.5)
- `nogo_accuracy`
- `commission_error_rate`
- `rt_variability`
- etc.

---

## Model Update Workflow

1. Collect new data (3-6 months)
2. Retrain model with new + old data
3. Validate model performance
4. Replace model files in backend
5. Restart backend
6. No app update needed!

---

## Troubleshooting

### Model Not Loading
- Check file paths
- Verify Python dependencies
- Check file permissions

### Predictions Wrong
- Verify feature names match
- Check feature scaling
- Ensure feature order matches training

### Slow Predictions
- Consider caching
- Optimize Python script
- Use faster model (XGBoost → Random Forest)

---

## Next Steps After Integration

1. ✅ Monitor prediction accuracy
2. ✅ Compare ML vs rule-based
3. ✅ Collect feedback from clinicians
4. ✅ Retrain with more data
5. ✅ Improve model iteratively








