/**
 * Machine Learning Integration API
 * Handles ML predictions and model management
 */

import express from 'express';
import axios from 'axios';
import { asyncHandler } from '../middleware/errorHandler';
import { verifyToken } from '../middleware/auth';
import { validate, mlPredictionSchema } from '../utils/validation';
import { logger } from '../utils/logger';
import { CONSTANTS } from '../config/constants';

export const router = express.Router();

// All routes require authentication
router.use(verifyToken);

// ML API endpoint (configure in environment variables)
const ML_API_URL = process.env.ML_API_URL || 'https://ml.senseai.com';

/**
 * POST /ml/predict
 * Get risk prediction from ML model
 */
router.post(
  '/predict',
  asyncHandler(async (req, res) => {
    // Validate request
    const validatedData = validate(mlPredictionSchema)(req.body);

    const { features, childId, assessmentId } = validatedData;

    logger.info('Requesting ML prediction', { childId, assessmentId });

    try {
      // Call external ML API
      const response = await axios.post(
        `${ML_API_URL}/predict`,
        {
          features,
        },
        {
          timeout: 10000, // 10 second timeout
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': process.env.ML_API_KEY || '',
          },
        }
      );

      const prediction = response.data;

      logger.info('ML prediction received', {
        childId,
        assessmentId,
        prediction: prediction.prediction,
        confidence: prediction.confidence,
      });

      res.json({
        prediction: {
          riskLevel: prediction.prediction,
          riskScore: prediction.risk_score,
          confidence: prediction.confidence,
          features_importance: prediction.features_importance,
          timestamp: new Date().toISOString(),
        },
      });
    } catch (error: any) {
      logger.error('ML prediction failed', {
        error: error.message,
        childId,
        assessmentId,
      });

      // Fallback to rule-based prediction
      const fallbackPrediction = fallbackRiskPrediction(features);

      logger.warn('Using fallback prediction', {
        childId,
        assessmentId,
        fallbackPrediction,
      });

      res.json({
        prediction: {
          ...fallbackPrediction,
          fallback: true,
          timestamp: new Date().toISOString(),
        },
      });
    }
  })
);

/**
 * POST /ml/batch-predict
 * Batch predictions for multiple assessments
 */
router.post(
  '/batch-predict',
  asyncHandler(async (req, res) => {
    const { assessments } = req.body;

    if (!Array.isArray(assessments) || assessments.length === 0) {
      return res.status(400).json({
        error: 'Invalid input',
        message: 'assessments must be a non-empty array',
      });
    }

    logger.info('Batch prediction request', { count: assessments.length });

    try {
      const response = await axios.post(
        `${ML_API_URL}/batch-predict`,
        {
          assessments,
        },
        {
          timeout: 30000, // 30 second timeout for batch
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': process.env.ML_API_KEY || '',
          },
        }
      );

      logger.info('Batch prediction successful', { count: assessments.length });

      res.json({
        predictions: response.data.predictions,
        count: response.data.predictions.length,
      });
    } catch (error: any) {
      logger.error('Batch prediction failed', { error: error.message });

      // Fallback to rule-based predictions
      const predictions = assessments.map((assessment: any) =>
        fallbackRiskPrediction(assessment.features)
      );

      res.json({
        predictions,
        count: predictions.length,
        fallback: true,
      });
    }
  })
);

/**
 * GET /ml/model-info
 * Get current ML model information
 */
router.get(
  '/model-info',
  asyncHandler(async (req, res) => {
    try {
      const response = await axios.get(`${ML_API_URL}/model/info`, {
        timeout: 5000,
        headers: {
          'X-API-Key': process.env.ML_API_KEY || '',
        },
      });

      res.json(response.data);
    } catch (error: any) {
      logger.error('Failed to fetch model info', { error: error.message });

      res.status(503).json({
        error: 'ML service unavailable',
        message: 'Could not fetch model information',
      });
    }
  })
);

/**
 * Fallback rule-based risk prediction
 * Used when ML service is unavailable
 */
function fallbackRiskPrediction(features: any) {
  let score = 50;

  // Reaction time analysis
  if (features.mean_rt > 2000) score += 15;
  else if (features.mean_rt > 1500) score += 10;
  else if (features.mean_rt > 1000) score += 5;
  else if (features.mean_rt < 500) score -= 5;

  // Accuracy analysis
  const accuracy = features.accuracy || 0;
  if (accuracy < 50) score += 20;
  else if (accuracy < 70) score += 10;
  else if (accuracy > 90) score -= 10;

  // Switch cost analysis (if available)
  if (features.switch_cost) {
    if (features.switch_cost > 500) score += 15;
    else if (features.switch_cost > 300) score += 10;
  }

  // Inhibition errors (if available)
  if (features.inhibition_errors) {
    score += features.inhibition_errors * 3;
  }

  // Age adjustment
  if (features.age <= 3 && score > 60) score += 5;
  if (features.age >= 5 && score < 40) score -= 5;

  // Clamp score
  score = Math.max(0, Math.min(100, Math.round(score)));

  // Determine risk level
  let riskLevel: string;
  if (score < CONSTANTS.ML_THRESHOLDS.LOW_RISK) {
    riskLevel = CONSTANTS.RISK_LEVELS.LOW;
  } else if (score < CONSTANTS.ML_THRESHOLDS.MODERATE_RISK) {
    riskLevel = CONSTANTS.RISK_LEVELS.MODERATE;
  } else {
    riskLevel = CONSTANTS.RISK_LEVELS.HIGH;
  }

  return {
    riskLevel,
    riskScore: score,
    confidence: 0.65, // Lower confidence for rule-based
    method: 'rule-based-fallback',
  };
}

export default router;







