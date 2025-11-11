/**
 * ML Service - Handle ML predictions
 */

import axios from 'axios';
import logger from '../utils/logger';

interface MLFeatures {
  // Game performance metrics
  mean_rt?: number;
  rt_std?: number;
  switch_cost?: number;
  accuracy?: number;
  inhibition_errors?: number;
  
  // Questionnaire features
  routine_change_reaction?: number;
  activity_switch_ability?: number;
  flexibility_index?: number;
  
  // Clinical features
  attention_span?: number;
  impulse_control?: number;
  
  // Derived features
  age_adjusted_rt?: number;
  composite_flexibility?: number;
}

interface MLPredictionResult {
  riskLevel: 'low' | 'moderate' | 'high';
  confidence: number;
  drivers: string[];
  modelVersion: string;
  predictedAt: string;
}

/**
 * Call external ML API for risk prediction
 */
export const predictRisk = async (features: MLFeatures): Promise<MLPredictionResult> => {
  try {
    const ML_API_URL = process.env.ML_API_URL || 'http://localhost:5000/predict';
    
    logger.info(`🤖 Calling ML API: ${ML_API_URL}`);
    logger.debug(`Features: ${JSON.stringify(features, null, 2)}`);

    const response = await axios.post(
      ML_API_URL,
      { features },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.ML_API_KEY || ''}`,
        },
        timeout: 30000, // 30 seconds
      }
    );

    const result = response.data;
    logger.info(`✅ ML prediction: ${result.riskLevel} (${result.confidence})`);

    return {
      riskLevel: result.risk_level || result.riskLevel,
      confidence: result.confidence || 0,
      drivers: result.drivers || result.top_features || [],
      modelVersion: result.model_version || result.modelVersion || 'v1.0.0',
      predictedAt: new Date().toISOString(),
    };

  } catch (error: any) {
    logger.error(`❌ ML prediction error: ${error.message}`);
    
    // Return a fallback prediction
    return {
      riskLevel: 'moderate',
      confidence: 0.5,
      drivers: ['Unable to compute - API error'],
      modelVersion: 'fallback',
      predictedAt: new Date().toISOString(),
    };
  }
};

/**
 * Extract features from session data for ML
 */
export const extractFeatures = (sessionData: any): MLFeatures => {
  const features: MLFeatures = {};

  // Extract game features
  if (sessionData.game_data) {
    features.mean_rt = sessionData.game_data.mean_rt_ms;
    features.switch_cost = sessionData.game_data.switch_cost_ms;
    features.accuracy = sessionData.game_data.accuracy_percent;
    features.inhibition_errors = sessionData.game_data.inhibition_errors;
    
    // Calculate RT standard deviation if trials available
    if (sessionData.game_data.trials && sessionData.game_data.trials.length > 0) {
      const rts = sessionData.game_data.trials
        .filter((t: any) => t.correct)
        .map((t: any) => t.rt_ms);
      
      if (rts.length > 0) {
        const mean = rts.reduce((a: number, b: number) => a + b, 0) / rts.length;
        const variance = rts.reduce((a: number, b: number) => a + Math.pow(b - mean, 2), 0) / rts.length;
        features.rt_std = Math.sqrt(variance);
      }
    }
  }

  // Extract questionnaire features
  if (sessionData.questionnaire_data) {
    features.routine_change_reaction = sessionData.questionnaire_data.routine_change_reaction;
    features.activity_switch_ability = sessionData.questionnaire_data.activity_switch_ability;
  }

  // Extract clinical features
  if (sessionData.clinical_reflection) {
    features.attention_span = sessionData.clinical_reflection.attention_span;
    features.impulse_control = sessionData.clinical_reflection.impulse_control;
  }

  // Extract computed features
  if (sessionData.computed_summary) {
    features.flexibility_index = sessionData.computed_summary.flexibility_index;
    features.composite_flexibility = sessionData.computed_summary.composite_flexibility;
  }

  // Calculate age-adjusted features
  if (sessionData.child && sessionData.child.age_years) {
    const ageNorm = 5.0; // Normalization baseline
    if (features.mean_rt) {
      features.age_adjusted_rt = features.mean_rt / (sessionData.child.age_years / ageNorm);
    }
  }

  return features;
};

/**
 * Calculate a simple heuristic risk score (fallback if ML unavailable)
 */
export const calculateHeuristicRisk = (features: MLFeatures): MLPredictionResult => {
  let riskScore = 0;
  const factors: string[] = [];

  // High RT = risk
  if (features.mean_rt && features.mean_rt > 1500) {
    riskScore += 1;
    factors.push('high_reaction_time');
  }

  // Low accuracy = risk
  if (features.accuracy !== undefined && features.accuracy < 70) {
    riskScore += 1;
    factors.push('low_accuracy');
  }

  // High switch cost = risk
  if (features.switch_cost && features.switch_cost > 300) {
    riskScore += 1;
    factors.push('high_switch_cost');
  }

  // Many inhibition errors = risk
  if (features.inhibition_errors && features.inhibition_errors > 5) {
    riskScore += 1;
    factors.push('inhibition_errors');
  }

  // Low flexibility from questionnaire = risk
  if (features.flexibility_index !== undefined && features.flexibility_index < 2.0) {
    riskScore += 1;
    factors.push('low_flexibility');
  }

  // Determine risk level
  let riskLevel: 'low' | 'moderate' | 'high';
  if (riskScore === 0) {
    riskLevel = 'low';
  } else if (riskScore <= 2) {
    riskLevel = 'moderate';
  } else {
    riskLevel = 'high';
  }

  return {
    riskLevel,
    confidence: 0.6, // Lower confidence for heuristic
    drivers: factors.length > 0 ? factors : ['insufficient_data'],
    modelVersion: 'heuristic_v1',
    predictedAt: new Date().toISOString(),
  };
};






