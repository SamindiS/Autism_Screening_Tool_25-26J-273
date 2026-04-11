/**
 * ML Predictions Route - FastAPI Integration
 * 
 * This version uses the FastAPI ML Engine instead of spawning Python script
 */

const express = require('express');
const axios = require('axios');
const router = express.Router();

// FastAPI ML Engine URL
// NOTE: config.py uses port 8002 to avoid conflicts.
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
    const v3Ready = response.data.v3_cogflex?.loaded === true;
    const statusOK = response.data.status === 'OK';
    
    ML_AVAILABLE = ageModelsReady || legacyReady || statusOK || v3Ready;
    
    if (ML_AVAILABLE) {
      console.log(`✅ FastAPI ML Engine is available and models are loaded at ${ML_ENGINE_URL}`);
    } else {
      console.log('⚠️  FastAPI ML Engine is running but models not loaded');
    }
  } catch (err) {
    console.log('⚠️  FastAPI ML Engine not available, using fallback predictions');
    console.log(`   URL: ${ML_ENGINE_URL}`);
    ML_AVAILABLE = false;
  }
}

// Check on startup
checkMLEngine();

// Recheck every 60 seconds
setInterval(checkMLEngine, 60000);

/**
 * POST /api/ml/predict
 * Predict ASD risk using FastAPI ML Engine
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
        model_age_group: result.model_age_group,
        
        // v3 specific fields
        result_summary: result.result_summary,
        severity: result.severity,
        hybrid_score: result.hybrid_score,
        explanations: result.explanations,
        
        method: 'ml',
      });

    } catch (apiError) {
      console.error('❌ FastAPI ML Engine error:', apiError.message);
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
 * Fallback rule-based prediction
 */
function fallbackPrediction(mlFeatures) {
  const asdProbability = 0.5;
  const prediction = asdProbability > 0.5 ? 1 : 0;
  
  return {
    success: true,
    prediction: prediction,
    probability: [1 - asdProbability, asdProbability],
    confidence: 0.5,
    risk_level: 'moderate',
    risk_score: 50.0,
    asd_probability: asdProbability,
    method: 'fallback',
  };
}

/**
 * GET /api/ml/health
 */
router.get('/health', async (req, res) => {
  try {
    const response = await axios.get(`${ML_ENGINE_URL}/health`, { timeout: 5000 });
    res.json({
      available: true,
      engine: 'fastapi',
      engine_status: response.data,
    });
  } catch (err) {
    res.json({
      available: false,
      engine: 'fastapi',
      error: err.message,
    });
  }
});

module.exports = router;
