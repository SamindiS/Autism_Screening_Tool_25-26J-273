const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const router = express.Router();

// Check if ML models exist
const MODEL_DIR = path.join(__dirname, '../models');
const MODEL_PATH = path.join(MODEL_DIR, 'asd_detection_model.pkl');
const SCALER_PATH = path.join(MODEL_DIR, 'feature_scaler.pkl');
const FEATURES_PATH = path.join(MODEL_DIR, 'feature_names.json');

const ML_AVAILABLE = fs.existsSync(MODEL_PATH) && fs.existsSync(SCALER_PATH);

if (!ML_AVAILABLE) {
  console.log('⚠️  ML models not found. ML predictions will use fallback.');
  console.log('   Place trained models in: senseai_backend/models/');
  console.log('   Required files:');
  console.log('     - asd_detection_model.pkl');
  console.log('     - feature_scaler.pkl');
  console.log('     - feature_names.json');
}

/**
 * POST /api/ml/predict
 * Predict ASD risk using trained ML model
 * 
 * Body:
 * {
 *   "mlFeatures": { ... },  // Feature dictionary
 *   "ageGroup": "5-6",      // Age group
 *   "sessionType": "color_shape"  // Session type
 * }
 */
router.post('/predict', async (req, res) => {
  try {
    const { mlFeatures, ageGroup, sessionType } = req.body;
    
    // Validate input
    if (!mlFeatures) {
      return res.status(400).json({ error: 'mlFeatures is required' });
    }

    // If ML model not available, use fallback rule-based prediction
    if (!ML_AVAILABLE) {
      console.log('⚠️  Using fallback rule-based prediction (ML model not available)');
      return res.json(fallbackPrediction(mlFeatures));
    }

    // Prepare Python script input
    const pythonScript = path.join(__dirname, '../ml_scripts/predict.py');
    const inputData = {
      features: mlFeatures,
      age_group: ageGroup || 'unknown',
      session_type: sessionType || 'unknown',
    };

    // Run Python prediction script
    const python = spawn('python3', [pythonScript, JSON.stringify(inputData)]);
    // Fallback to 'python' if 'python3' not found
    if (!python.pid) {
      const python2 = spawn('python', [pythonScript, JSON.stringify(inputData)]);
      return handlePythonProcess(python2, res, mlFeatures);
    }

    return handlePythonProcess(python, res, mlFeatures);

  } catch (err) {
    console.error('❌ ML prediction error:', err);
    return res.status(500).json({ 
      error: 'Prediction failed', 
      details: err.message,
      fallback: fallbackPrediction(req.body.mlFeatures || {})
    });
  }
});

function handlePythonProcess(python, res, mlFeatures) {
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
      console.error('❌ Python script error:', error);
      console.log('⚠️  Falling back to rule-based prediction');
      return res.json(fallbackPrediction(mlFeatures));
    }

    try {
      const result = JSON.parse(output.trim());
      console.log(`✅ ML Prediction: ${result.prediction === 1 ? 'ASD Risk' : 'Control'}, Score: ${result.risk_score.toFixed(1)}`);
      res.json({
        success: true,
        prediction: result.prediction,
        probability: result.probability,
        confidence: result.confidence,
        risk_level: result.risk_level,
        risk_score: result.risk_score,
        asd_probability: result.asd_probability,
        method: 'ml', // Indicates ML was used
      });
    } catch (e) {
      console.error('❌ Failed to parse Python output:', e);
      console.log('⚠️  Falling back to rule-based prediction');
      res.json(fallbackPrediction(mlFeatures));
    }
  });

  python.on('error', (err) => {
    console.error('❌ Python process error:', err);
    console.log('⚠️  Falling back to rule-based prediction');
    res.json(fallbackPrediction(mlFeatures));
  });
}

/**
 * Fallback rule-based prediction when ML model is not available
 */
function fallbackPrediction(mlFeatures) {
  // Extract key features
  const accuracy = mlFeatures.accuracy_overall || mlFeatures.overall_accuracy || 0;
  const perseverativeErrors = mlFeatures.primary_asd_marker_1 || mlFeatures.perseverative_errors || 0;
  const switchCost = mlFeatures.primary_asd_marker_3 || mlFeatures.switch_cost_ms || 0;
  const riskScore = mlFeatures.enhanced_risk_score || 50;

  // Simple rule-based logic
  let asdProbability = 0.5;
  
  if (accuracy < 60) asdProbability += 0.2;
  if (perseverativeErrors > 3) asdProbability += 0.15;
  if (switchCost > 300) asdProbability += 0.15;
  if (riskScore < 40) asdProbability += 0.1;

  asdProbability = Math.min(0.95, Math.max(0.05, asdProbability));
  const prediction = asdProbability > 0.5 ? 1 : 0;
  
  let riskLevel = 'moderate';
  if (asdProbability > 0.7) riskLevel = 'high';
  else if (asdProbability < 0.3) riskLevel = 'low';

  return {
    success: true,
    prediction: prediction,
    probability: [1 - asdProbability, asdProbability],
    confidence: Math.max(asdProbability, 1 - asdProbability),
    risk_level: riskLevel,
    risk_score: asdProbability * 100,
    asd_probability: asdProbability,
    method: 'fallback', // Indicates fallback was used
  };
}

/**
 * GET /api/ml/health
 * Check if ML service is available
 */
router.get('/health', (req, res) => {
  res.json({
    available: ML_AVAILABLE,
    model_path: MODEL_PATH,
    scaler_path: SCALER_PATH,
    message: ML_AVAILABLE 
      ? 'ML models loaded and ready' 
      : 'ML models not found - using fallback predictions',
  });
});

module.exports = router;

