/**
 * ML Predictions Route - FastAPI Integration
 * 
 * This version uses the FastAPI ML Engine instead of spawning Python script
 * 
 * To use: Replace ml_predictions.js with this file, or update the existing file
 */

const express = require('express');
const axios = require('axios');
const router = express.Router();

// FastAPI ML Engine URL
const ML_ENGINE_URL = process.env.ML_ENGINE_URL || 'http://localhost:8002';

// Check if ML engine is available
let ML_AVAILABLE = false;

// Check ML engine health on startup
async function checkMLEngine() {
  try {
    const response = await axios.get(`${ML_ENGINE_URL}/health`, {
      timeout: 5000
    });
    
    // Check if any models are ready (age-specific or legacy)
    const ageModels = response.data.age_specific_models || {};
    const ageModelsReady = Object.values(ageModels).some(status => status.ready === true);
    const legacyReady = response.data.legacy_model?.loaded === true;
    const statusOK = response.data.status === 'OK';
    
    ML_AVAILABLE = ageModelsReady || legacyReady || statusOK;
    
    if (ML_AVAILABLE) {
      const readyModels = Object.entries(ageModels)
        .filter(([_, status]) => status.ready)
        .map(([age, _]) => age);
      console.log(`✅ FastAPI ML Engine is available and models are loaded`);
      if (readyModels.length > 0) {
        console.log(`   Ready models: ${readyModels.join(', ')}`);
      }
    } else {
      console.log('⚠️  FastAPI ML Engine is running but models not loaded');
      console.log(`   Status: ${response.data.status}`);
      console.log(`   Age-specific models:`, ageModels);
    }
  } catch (err) {
    console.log('⚠️  FastAPI ML Engine not available, using fallback predictions');
    console.log(`   URL: ${ML_ENGINE_URL}`);
    console.log(`   Error: ${err.message}`);
    ML_AVAILABLE = false;
  }
}

// Check on startup
checkMLEngine();

// Recheck every 30 seconds
setInterval(checkMLEngine, 30000);

/**
 * POST /api/ml/predict
 * Predict ASD risk using FastAPI ML Engine
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

    // If ML engine not available, use fallback rule-based prediction
    if (!ML_AVAILABLE) {
      console.log('⚠️  Using fallback rule-based prediction (ML engine not available)');
      return res.json(fallbackPrediction(mlFeatures));
    }

    // Call FastAPI ML Engine
    try {
      const response = await axios.post(
        `${ML_ENGINE_URL}/predict`,
        {
          age_months: mlFeatures.age_months || 36,
          features: mlFeatures,
          age_group: ageGroup || 'unknown',
          session_type: sessionType || 'unknown'
        },
        {
          timeout: 10000, // 10 second timeout
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );

      const result = response.data;
      console.log(
        `✅ ML Prediction: ${result.prediction === 1 ? 'ASD Risk' : 'Control'}, ` +
        `Score: ${result.risk_score.toFixed(1)}`
      );

      return res.json({
        success: true,
        prediction: result.prediction,
        probability: result.probability,
        confidence: result.confidence,
        risk_level: result.risk_level,
        risk_score: result.risk_score,
        asd_probability: result.asd_probability,
        method: 'ml', // Indicates ML was used
      });

    } catch (apiError) {
      console.error('❌ FastAPI ML Engine error:', apiError.message);
      if (apiError.response) {
        console.error('   Response:', apiError.response.data);
      }
      console.log('⚠️  Falling back to rule-based prediction');
      return res.json(fallbackPrediction(mlFeatures));
    }

  } catch (err) {
    console.error('❌ ML prediction error:', err);
    return res.status(500).json({ 
      error: 'Prediction failed', 
      details: err.message,
      fallback: fallbackPrediction(req.body.mlFeatures || {})
    });
  }
});

/**
 * Fallback rule-based prediction when ML engine is not available
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
router.get('/health', async (req, res) => {
  try {
    // Check FastAPI ML Engine
    const response = await axios.get(`${ML_ENGINE_URL}/health`, {
      timeout: 5000
    });
    
    res.json({
      available: response.data.models_loaded === true,
      engine: 'fastapi',
      engine_url: ML_ENGINE_URL,
      engine_status: response.data,
      message: response.data.models_loaded 
        ? 'FastAPI ML Engine loaded and ready' 
        : 'FastAPI ML Engine running but models not loaded',
    });
  } catch (err) {
    res.json({
      available: false,
      engine: 'fastapi',
      engine_url: ML_ENGINE_URL,
      error: err.message,
      message: 'FastAPI ML Engine not available - using fallback predictions',
    });
  }
});

module.exports = router;

