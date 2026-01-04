# 📱 ML Prediction Usage Examples

## Complete examples of how to use ML predictions in your Flutter app

---

## 🎯 Overview

Your app already has ML integration! Here's how to use it in different scenarios.

---

## Example 1: After DCCS Game (Color-Shape)

### Location: `color_shape_game_screen.dart`

```dart
import 'package:my_autism_app/core/services/ml_service.dart';

// After game completes and trials are collected
Future<void> _onGameComplete() async {
  // 1. Create game summary (already extracts ML features)
  final gameSummary = DccsGameSummary.fromTrials(_trials);
  
  // 2. Get child age for age group
  final childAge = _child.ageInMonths;
  final ageGroup = _getAgeGroup(childAge); // '5-6' for DCCS
  
  // 3. Call ML prediction
  try {
    final mlResult = await MLService.predict(
      mlFeatures: gameSummary.mlFeatures,  // Already implemented!
      ageGroup: ageGroup,
      sessionType: 'color_shape',
    );
    
    // 4. Use ML result if available
    if (mlResult != null && mlResult.method == 'ml') {
      // ML prediction successful
      final riskScore = mlResult.riskScore;
      final riskLevel = mlResult.riskLevel;
      final asdProbability = mlResult.asdProbability;
      
      print('✅ ML Prediction:');
      print('   Risk Level: $riskLevel');
      print('   Risk Score: ${riskScore.toStringAsFixed(1)}%');
      print('   ASD Probability: ${(asdProbability * 100).toStringAsFixed(1)}%');
      
      // 5. Save to session with ML-enhanced risk
      await _saveSession(
        riskScore: riskScore,
        riskLevel: riskLevel,
        mlPrediction: mlResult,
        gameResults: gameSummary.toJson(),
      );
      
      // 6. Show result to user
      _showResult(riskLevel, riskScore, isML: true);
      
    } else {
      // Fallback to rule-based (already calculated in gameSummary)
      final riskScore = gameSummary.riskScore;
      final riskLevel = gameSummary.riskLevel;
      
      print('⚠️  Using rule-based prediction (ML unavailable)');
      await _saveSession(
        riskScore: riskScore,
        riskLevel: riskLevel,
        gameResults: gameSummary.toJson(),
      );
      _showResult(riskLevel, riskScore, isML: false);
    }
    
  } catch (e) {
    // Always fallback to rule-based
    print('❌ ML prediction error: $e');
    final riskScore = gameSummary.riskScore;
    final riskLevel = gameSummary.riskLevel;
    await _saveSession(
      riskScore: riskScore,
      riskLevel: riskLevel,
      gameResults: gameSummary.toJson(),
    );
    _showResult(riskLevel, riskScore, isML: false);
  }
}

String _getAgeGroup(int ageMonths) {
  if (ageMonths < 42) return '2-3';
  else if (ageMonths < 66) return '3-5';
  else return '5-6';
}
```

---

## Example 2: After Frog Jump Game

### Location: `frog_jump_game_screen.dart`

```dart
import 'package:my_autism_app/core/services/ml_service.dart';

Future<void> _onGameComplete() async {
  // 1. Create summary
  final frogSummary = FrogJumpSummary.fromTrials(_trials);
  
  // 2. Get ML prediction
  final mlResult = await MLService.predict(
    mlFeatures: frogSummary.mlFeatures,
    ageGroup: '3-5',  // Frog Jump age range
    sessionType: 'frog_jump',
  );
  
  // 3. Use result
  if (mlResult != null) {
    await _updateRiskAssessment(mlResult);
  } else {
    // Use rule-based from summary
    await _updateRiskAssessment(
      riskScore: frogSummary.riskScore,
      riskLevel: frogSummary.riskLevel,
    );
  }
}
```

---

## Example 3: After Questionnaire (AI Doctor Bot)

### Location: `ai_doctor_bot_screen.dart`

```dart
import 'package:my_autism_app/core/services/ml_service.dart';

Future<void> _onQuestionnaireComplete() async {
  // 1. Create summary
  final questionnaireSummary = QuestionnaireSummary.fromResponses(_responses);
  
  // 2. Get ML prediction
  final mlResult = await MLService.predict(
    mlFeatures: questionnaireSummary.mlFeatures,
    ageGroup: '2-3',  // Questionnaire age range
    sessionType: 'ai_doctor_bot',
  );
  
  // 3. Combine with rule-based (ML enhances, doesn't replace)
  double finalRiskScore;
  String finalRiskLevel;
  
  if (mlResult != null && mlResult.method == 'ml') {
    // Use ML prediction (more accurate)
    finalRiskScore = mlResult.riskScore;
    finalRiskLevel = mlResult.riskLevel;
  } else {
    // Fallback to rule-based
    finalRiskScore = questionnaireSummary.riskScore;
    finalRiskLevel = questionnaireSummary.riskLevel;
  }
  
  // 4. Save session
  await _saveSession(
    riskScore: finalRiskScore,
    riskLevel: finalRiskLevel,
    mlPrediction: mlResult,
  );
}
```

---

## Example 4: Displaying ML Results in UI

### Create a Results Widget

```dart
import 'package:my_autism_app/core/services/ml_service.dart';

class MLPredictionCard extends StatelessWidget {
  final MLPredictionResult? mlResult;
  final double ruleBasedScore;
  final String ruleBasedLevel;
  
  const MLPredictionCard({
    required this.mlResult,
    required this.ruleBasedScore,
    required this.ruleBasedLevel,
  });
  
  @override
  Widget build(BuildContext context) {
    final isML = mlResult != null && mlResult!.method == 'ml';
    final riskScore = isML ? mlResult!.riskScore : ruleBasedScore;
    final riskLevel = isML ? mlResult!.riskLevel : ruleBasedLevel;
    
    return Card(
      child: Column(
        children: [
          // Method indicator
          if (isML)
            Chip(
              label: Text('ML-Enhanced Prediction'),
              backgroundColor: Colors.blue.shade100,
            )
          else
            Chip(
              label: Text('Rule-Based Prediction'),
              backgroundColor: Colors.orange.shade100,
            ),
          
          // Risk level
          Text(
            'Risk Level: ${riskLevel.toUpperCase()}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getRiskColor(riskLevel),
            ),
          ),
          
          // Risk score
          Text(
            'Risk Score: ${riskScore.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 18),
          ),
          
          // ML-specific info
          if (isML && mlResult != null) ...[
            SizedBox(height: 8),
            Text(
              'ASD Probability: ${(mlResult!.asdProbability * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              'Confidence: ${(mlResult!.confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high': return Colors.red;
      case 'moderate': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }
}
```

---

## Example 5: Checking ML Availability

```dart
// Before making prediction, check if ML is available
Future<void> checkMLAvailability() async {
  final isAvailable = await MLService.isAvailable();
  
  if (isAvailable) {
    print('✅ ML service is available');
    // Proceed with ML prediction
  } else {
    print('⚠️  ML service not available, using rule-based');
    // Use rule-based predictions
  }
}
```

---

## Example 6: Combining Multiple Sessions

If a child completes multiple assessments, you can combine predictions:

```dart
// After all sessions complete
Future<void> generateFinalAssessment() async {
  final sessions = await getChildSessions(childId);
  
  // Get ML predictions for each session
  final predictions = <MLPredictionResult>[];
  
  for (final session in sessions) {
    if (session.mlFeatures != null) {
      final result = await MLService.predict(
        mlFeatures: session.mlFeatures!,
        ageGroup: session.ageGroup,
        sessionType: session.sessionType,
      );
      
      if (result != null) {
        predictions.add(result);
      }
    }
  }
  
  // Combine predictions (average or weighted)
  if (predictions.isNotEmpty) {
    final avgRiskScore = predictions
        .map((p) => p.riskScore)
        .reduce((a, b) => a + b) / predictions.length;
    
    final finalRiskLevel = _calculateRiskLevel(avgRiskScore);
    
    // Save combined assessment
    await saveFinalAssessment(
      childId: childId,
      riskScore: avgRiskScore,
      riskLevel: finalRiskLevel,
      sessionCount: predictions.length,
      method: 'ml_combined',
    );
  }
}
```

---

## 🎯 Best Practices

### 1. Always Have Fallback

```dart
try {
  final mlResult = await MLService.predict(...);
  if (mlResult != null) {
    // Use ML
  } else {
    // Use rule-based
  }
} catch (e) {
  // Always fallback
  useRuleBased();
}
```

### 2. Show Method to User

```dart
// Indicate whether ML or rule-based was used
if (mlResult?.method == 'ml') {
  showInfo('ML-Enhanced Prediction');
} else {
  showInfo('Rule-Based Prediction');
}
```

### 3. Log Predictions

```dart
// Log for debugging/analysis
debugPrint('ML Prediction: ${mlResult?.riskLevel} (${mlResult?.riskScore})');
debugPrint('Method: ${mlResult?.method}');
```

### 4. Handle Errors Gracefully

```dart
// Never crash if ML fails
try {
  final result = await MLService.predict(...);
} catch (e) {
  // Silently fallback - user shouldn't see errors
  useRuleBased();
}
```

---

## ✅ Integration Checklist

- [ ] ML model files in `senseai_backend/models/`
- [ ] Backend ML endpoint working (`/api/ml/health`)
- [ ] Frontend calls `MLService.predict()` after assessments
- [ ] Fallback to rule-based when ML unavailable
- [ ] Results displayed to user
- [ ] Results saved to session

---

## 🚀 Quick Integration Template

```dart
// Template for any assessment screen
Future<void> _completeAssessment() async {
  // 1. Create summary (extracts ML features)
  final summary = YourSummary.fromData(data);
  
  // 2. Try ML prediction
  MLPredictionResult? mlResult;
  try {
    mlResult = await MLService.predict(
      mlFeatures: summary.mlFeatures,
      ageGroup: _getAgeGroup(childAge),
      sessionType: 'your_session_type',
    );
  } catch (e) {
    // Silently fallback
  }
  
  // 3. Use best available result
  final riskScore = mlResult?.riskScore ?? summary.riskScore;
  final riskLevel = mlResult?.riskLevel ?? summary.riskLevel;
  
  // 4. Save and display
  await saveSession(riskScore: riskScore, riskLevel: riskLevel);
  showResults(riskLevel, riskScore, isML: mlResult != null);
}
```

---

**Your ML integration is ready to use!** 🎉

