# ML Model Integration Guide

## Overview

After training your ML model with real data, you need to integrate it into your Flutter app to make predictions. This guide covers three approaches, with **Backend API** being the recommended method.

---

## 🎯 Recommended Approach: Backend API Integration

### Why Backend API?
- ✅ No model conversion needed (use Python `.pkl` directly)
- ✅ Easy to update model without app updates
- ✅ Can use full Python ML ecosystem (scikit-learn, XGBoost, etc.)
- ✅ Handles feature scaling automatically
- ✅ Can add model versioning and A/B testing

### Step 1: Train Your Model

1. Collect real data from your app
2. Train model using `ML_TRAINING/Complete_ASD_ML_Training.ipynb`
3. Save model files:
   - `asd_detection_model.pkl` (trained model)
   - `feature_scaler.pkl` (feature scaler)
   - `feature_names.json` (list of feature names in order)

### Step 2: Add Model to Backend

1. Copy model files to backend:
   ```bash
   cp asd_detection_model.pkl senseai_backend/models/
   cp feature_scaler.pkl senseai_backend/models/
   cp feature_names.json senseai_backend/models/
   ```

2. Install Python dependencies in backend:
   ```bash
   cd senseai_backend
   npm install python-shell  # Or use child_process to run Python
   # Or install Python packages: pip install scikit-learn joblib numpy pandas
   ```

### Step 3: Create ML Prediction Endpoint

Create `senseai_backend/routes/ml_predictions.js`:

```javascript
const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const router = express.Router();

// ML Prediction endpoint
router.post('/predict', async (req, res) => {
  try {
    const { mlFeatures, ageGroup, sessionType } = req.body;
    
    // Validate input
    if (!mlFeatures || !ageGroup) {
      return res.status(400).json({ error: 'mlFeatures and ageGroup are required' });
    }

    // Prepare Python script input
    const pythonScript = path.join(__dirname, '../ml_scripts/predict.py');
    const inputData = {
      features: mlFeatures,
      age_group: ageGroup,
      session_type: sessionType,
    };

    // Run Python prediction script
    const python = spawn('python3', [pythonScript, JSON.stringify(inputData)]);
    
    let output = '';
    let error = '';

    python.stdout.on('data', (data) => {
      output += data.toString();
    });

    python.stderr.on('data', (data) => {
      error += data.toString();
    });

    python.on('close', (code) => {
      if (code !== 0) {
        console.error('Python script error:', error);
        return res.status(500).json({ error: 'Prediction failed', details: error });
      }

      try {
        const result = JSON.parse(output);
        res.json({
          success: true,
          prediction: result.prediction, // 0 = Control, 1 = ASD
          probability: result.probability, // [control_prob, asd_prob]
          confidence: result.confidence,
          risk_level: result.risk_level, // 'low', 'moderate', 'high'
          risk_score: result.risk_score, // 0-100
        });
      } catch (e) {
        res.status(500).json({ error: 'Failed to parse prediction result' });
      }
    });

  } catch (err) {
    console.error('ML prediction error:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
```

### Step 4: Create Python Prediction Script

Create `senseai_backend/ml_scripts/predict.py`:

```python
import sys
import json
import joblib
import numpy as np
from pathlib import Path

# Load model and scaler
MODEL_PATH = Path(__file__).parent.parent / 'models' / 'asd_detection_model.pkl'
SCALER_PATH = Path(__file__).parent.parent / 'models' / 'feature_scaler.pkl'
FEATURES_PATH = Path(__file__).parent.parent / 'models' / 'feature_names.json'

model = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)

# Load feature names
with open(FEATURES_PATH, 'r') as f:
    feature_names = json.load(f)

def predict(features_dict, age_group, session_type):
    """
    Predict ASD risk from ML features
    
    Args:
        features_dict: Dictionary of feature values
        age_group: Age group (e.g., '2-3', '3-5', '5-6')
        session_type: Type of session (e.g., 'color_shape', 'frog_jump', 'ai_doctor_bot')
    
    Returns:
        Dictionary with prediction results
    """
    # Extract features in correct order
    feature_vector = []
    for feature_name in feature_names:
        value = features_dict.get(feature_name, 0)
        feature_vector.append(float(value))
    
    # Convert to numpy array and reshape
    features = np.array(feature_vector).reshape(1, -1)
    
    # Scale features
    features_scaled = scaler.transform(features)
    
    # Predict
    prediction = model.predict(features_scaled)[0]
    probabilities = model.predict_proba(features_scaled)[0]
    
    # Calculate risk score and level
    asd_probability = probabilities[1]  # Probability of ASD
    risk_score = asd_probability * 100
    
    if risk_score < 30:
        risk_level = 'low'
    elif risk_score < 70:
        risk_level = 'moderate'
    else:
        risk_level = 'high'
    
    return {
        'prediction': int(prediction),
        'probability': probabilities.tolist(),
        'confidence': float(max(probabilities)),
        'risk_level': risk_level,
        'risk_score': float(risk_score),
        'asd_probability': float(asd_probability),
    }

if __name__ == '__main__':
    # Read input from command line
    input_data = json.loads(sys.argv[1])
    
    result = predict(
        input_data['features'],
        input_data.get('age_group', 'unknown'),
        input_data.get('session_type', 'unknown')
    )
    
    # Output JSON result
    print(json.dumps(result))
```

### Step 5: Add Route to Backend Server

In `senseai_backend/server.js`:

```javascript
// Add ML predictions route
app.use('/api/ml', require('./routes/ml_predictions'));
```

### Step 6: Create Flutter ML Service

Create `lib/core/services/ml_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class MLService {
  /// Predict ASD risk using trained ML model
  static Future<MLPredictionResult> predict({
    required Map<String, dynamic> mlFeatures,
    required String ageGroup,
    required String sessionType,
  }) async {
    try {
      final url = await ApiService.baseUrl;
      final response = await http.post(
        Uri.parse('$url/api/ml/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mlFeatures': mlFeatures,
          'ageGroup': ageGroup,
          'sessionType': sessionType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MLPredictionResult.fromJson(data);
      } else {
        throw Exception('ML prediction failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ ML prediction error: $e');
      rethrow;
    }
  }
}

class MLPredictionResult {
  final bool isASD; // prediction == 1
  final double asdProbability;
  final double controlProbability;
  final double confidence;
  final String riskLevel; // 'low', 'moderate', 'high'
  final double riskScore; // 0-100

  MLPredictionResult({
    required this.isASD,
    required this.asdProbability,
    required this.controlProbability,
    required this.confidence,
    required this.riskLevel,
    required this.riskScore,
  });

  factory MLPredictionResult.fromJson(Map<String, dynamic> json) {
    final prediction = json['prediction'] as int;
    final probabilities = json['probability'] as List<dynamic>;
    
    return MLPredictionResult(
      isASD: prediction == 1,
      asdProbability: (probabilities[1] as num).toDouble(),
      controlProbability: (probabilities[0] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      riskScore: (json['risk_score'] as num).toDouble(),
    );
  }
}
```

### Step 7: Update Risk Calculation to Use ML

Update `lib/features/assessment/models/questionnaire_summary.dart`:

```dart
// Add ML prediction
Future<void> calculateMLRisk() async {
  try {
    final mlResult = await MLService.predict(
      mlFeatures: mlFeatures,
      ageGroup: '2-3', // or determine from child age
      sessionType: 'ai_doctor_bot',
    );
    
    // Use ML prediction for risk score
    _riskScore = mlResult.riskScore;
    _riskLevel = mlResult.riskLevel;
  } catch (e) {
    // Fallback to rule-based if ML fails
    debugPrint('ML prediction failed, using rule-based: $e');
    // Keep existing rule-based calculation
  }
}
```

---

## 🔄 Alternative Approach 1: TensorFlow Lite (On-Device)

### Pros:
- ✅ Works offline
- ✅ Fast predictions
- ✅ No backend needed

### Cons:
- ❌ Need to convert model
- ❌ Model updates require app update
- ❌ Limited to TensorFlow models

### Steps:

1. **Convert Model to TensorFlow Lite**:
   ```python
   import tensorflow as tf
   from tensorflow import lite
   
   # Convert scikit-learn model to TensorFlow
   # (Requires additional conversion steps)
   converter = lite.TFLiteConverter.from_saved_model('model')
   tflite_model = converter.convert()
   
   with open('model.tflite', 'wb') as f:
       f.write(tflite_model)
   ```

2. **Add to Flutter**:
   - Add `tflite_flutter: ^0.10.4` to `pubspec.yaml`
   - Place `model.tflite` in `assets/models/`
   - Load and run model in Flutter

---

## 🔄 Alternative Approach 2: ONNX Runtime

### Pros:
- ✅ Cross-platform
- ✅ Supports multiple ML frameworks
- ✅ Good performance

### Cons:
- ❌ Need to convert model
- ❌ Larger app size

---

## 📋 Complete Integration Checklist

### Backend Setup:
- [ ] Install Python dependencies (`scikit-learn`, `joblib`, `numpy`, `pandas`)
- [ ] Create `models/` folder in backend
- [ ] Copy trained model files (`asd_detection_model.pkl`, `feature_scaler.pkl`, `feature_names.json`)
- [ ] Create `routes/ml_predictions.js`
- [ ] Create `ml_scripts/predict.py`
- [ ] Add route to `server.js`
- [ ] Test endpoint with Postman

### Flutter Integration:
- [ ] Create `lib/core/services/ml_service.dart`
- [ ] Update `questionnaire_summary.dart` to use ML
- [ ] Update `frog_jump_summary.dart` to use ML
- [ ] Update `color_shape_game` summary to use ML
- [ ] Update `reflection_screen.dart` to use ML predictions
- [ ] Test with real data

### Testing:
- [ ] Test with known ASD cases
- [ ] Test with known control cases
- [ ] Verify predictions match training results
- [ ] Test error handling (offline, backend down)

---

## 🧪 Testing the Integration

### Test with Postman:

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
  "risk_score": 80.0
}
```

---

## 📊 Model Update Workflow

1. **Collect new data** from app
2. **Retrain model** with new data
3. **Validate model** performance
4. **Replace model files** in backend (`models/` folder)
5. **Restart backend** server
6. **No app update needed!** 🎉

---

## 🔍 Monitoring & Logging

Add logging to track predictions:

```javascript
// In ml_predictions.js
console.log(`📊 ML Prediction:`, {
  ageGroup,
  sessionType,
  prediction: result.prediction,
  riskScore: result.risk_score,
  confidence: result.confidence,
});
```

---

## ⚠️ Important Notes

1. **Feature Alignment**: Ensure Flutter app sends features in the same format/order as training
2. **Model Versioning**: Keep track of model versions for A/B testing
3. **Fallback**: Always have rule-based fallback if ML fails
4. **Privacy**: ML features may contain sensitive data - ensure secure transmission
5. **Performance**: Cache predictions if needed for offline use

---

## 🚀 Quick Start

1. Train model → Save `.pkl` files
2. Copy to `senseai_backend/models/`
3. Add Python prediction script
4. Add backend endpoint
5. Update Flutter to call ML service
6. Test and deploy!

---

## Need Help?

- Check backend logs for Python errors
- Verify feature names match training data
- Test with Postman first before Flutter integration
- Ensure Python environment has all dependencies


