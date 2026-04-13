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
const ML_ENGINE_URL = process.env.ML_ENGINE_URL || 'http://localhost:8001';

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
      console.log('📋 FULL ML RESPONSE:', JSON.stringify(result, null, 2));
      
      const riskScore = Number(
        result.risk_score ??
        (result.hybrid_score !== undefined ? result.hybrid_score * 100 : 50)
      );
      console.log(
        `✅ ML Prediction: ${result.prediction === 1 ? 'ASD Risk' : 'Control'}, ` +
        `Risk Level: ${result.risk_level}, Severity: ${result.severity || 'N/A'}, ` +
        `Override: ${result.clinical_override || false}, ` +
        `Score: ${Number.isFinite(riskScore) ? riskScore.toFixed(1) : 'N/A'}`
      );

      return res.json({
        success: true,
        prediction: result.prediction,
        probability: result.probability,
        confidence: result.confidence,
        risk_level: result.risk_level,
        risk_score: riskScore,
        asd_probability: result.asd_probability,
        model_age_group: result.model_age_group,
        
        // v3 specific fields
        result_summary: result.result_summary,
        severity: result.severity,
        clinical_override: result.clinical_override,
        avg_score: result.avg_score,
        hybrid_score: result.hybrid_score,
        explanations: result.explanations,
        
        method: 'ml',
      });

    } catch (apiError) {
      console.error('❌ FastAPI ML Engine error:', apiError.message);
      if (apiError.response) {
        console.error('❌ FastAPI response data:', JSON.stringify(apiError.response.data));
      }
      console.error('⚠️ FALLBACK TRIGGERED - ML FAILED');
      
      return res.status(500).json({
        error: 'ML Engine failed',
        fallback: fallbackPrediction(mlFeatures)
      });
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
  const accuracy = Number(mlFeatures.accuracy_overall ?? mlFeatures.overall_accuracy ?? 0);
  const perseverativeErrors = Number(
    mlFeatures.primary_asd_marker_1 ?? mlFeatures.perseverative_errors ?? 0
  );
  const switchCost = Number(mlFeatures.primary_asd_marker_3 ?? mlFeatures.switch_cost_ms ?? 0);
  const riskSignal = Number(mlFeatures.enhanced_risk_score ?? 50);
  const totalQScore = Number(mlFeatures.total_q_score ?? 25);

  let asdProbability = 0.5;
  // Questionnaire path (age 2-3.5): lower scores increase risk.
  if (Number.isFinite(totalQScore) && totalQScore > 0) {
    if (totalQScore <= 20) asdProbability += 0.30;
    else if (totalQScore <= 30) asdProbability += 0.15;
    else if (totalQScore >= 45) asdProbability -= 0.20;
    else if (totalQScore >= 38) asdProbability -= 0.10;
  }
  // Game feature path (older ages): use simple heuristic markers.
  if (Number.isFinite(accuracy) && accuracy > 0) {
    if (accuracy < 60) asdProbability += 0.20;
    else if (accuracy > 85) asdProbability -= 0.10;
  }
  if (Number.isFinite(perseverativeErrors) && perseverativeErrors > 3) asdProbability += 0.15;
  if (Number.isFinite(switchCost) && switchCost > 300) asdProbability += 0.15;
  if (Number.isFinite(riskSignal) && riskSignal < 40) asdProbability += 0.10;

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
