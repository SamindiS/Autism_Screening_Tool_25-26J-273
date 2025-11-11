/**
 * ML Routes - Handle ML predictions
 */

import express, { Request, Response } from 'express';
import { db } from '../config/firebase';
import { predictRisk, extractFeatures, calculateHeuristicRisk } from '../services/mlService';
import logger from '../utils/logger';

const router = express.Router();

/**
 * POST /api/ml/predict
 * Trigger ML prediction for a session
 */
router.post('/predict', async (req: Request, res: Response) => {
  try {
    const { sessionId, clinicId, childId, useHeuristic } = req.body;

    if (!sessionId || !clinicId || !childId) {
      return res.status(400).json({
        success: false,
        message: 'sessionId, clinicId, and childId are required',
      });
    }

    logger.info(`🤖 Triggering ML prediction for session: ${sessionId}`);

    // Get session data from Firestore
    const docRef = db
      .collection('clinics')
      .doc(clinicId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .doc(sessionId);

    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Session not found',
      });
    }

    const sessionData = doc.data();

    // Extract features
    const features = extractFeatures(sessionData);
    logger.debug(`Extracted features: ${JSON.stringify(features, null, 2)}`);

    // Get ML prediction
    let prediction;
    if (useHeuristic) {
      logger.info('Using heuristic risk calculation');
      prediction = calculateHeuristicRisk(features);
    } else {
      prediction = await predictRisk(features);
    }

    // Update Firestore with ML prediction
    await docRef.update({
      ml: prediction,
      ml_status: 'completed',
      updated_at: new Date().toISOString(),
    });

    logger.info(`✅ ML prediction saved: ${prediction.riskLevel}`);

    res.json({
      success: true,
      message: 'ML prediction completed',
      data: {
        sessionId,
        prediction,
        features,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error in ML prediction: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error processing ML prediction',
      error: error.message,
    });
  }
});

/**
 * POST /api/ml/batch-predict
 * Trigger ML predictions for multiple sessions
 */
router.post('/batch-predict', async (req: Request, res: Response) => {
  try {
    const { sessionIds, clinicId, childId } = req.body;

    if (!sessionIds || !Array.isArray(sessionIds) || sessionIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'sessionIds array is required',
      });
    }

    logger.info(`🤖 Triggering batch ML prediction for ${sessionIds.length} sessions`);

    const results = [];
    const errors = [];

    for (const sessionId of sessionIds) {
      try {
        // Get session data
        const docRef = db
          .collection('clinics')
          .doc(clinicId)
          .collection('children')
          .doc(childId)
          .collection('assessments')
          .doc(sessionId);

        const doc = await docRef.get();

        if (!doc.exists) {
          errors.push({ sessionId, error: 'Session not found' });
          continue;
        }

        const sessionData = doc.data();
        const features = extractFeatures(sessionData);
        const prediction = await predictRisk(features);

        // Update Firestore
        await docRef.update({
          ml: prediction,
          ml_status: 'completed',
          updated_at: new Date().toISOString(),
        });

        results.push({ sessionId, prediction });

      } catch (error: any) {
        errors.push({ sessionId, error: error.message });
      }
    }

    logger.info(`✅ Batch prediction completed: ${results.length} success, ${errors.length} errors`);

    res.json({
      success: true,
      message: 'Batch ML prediction completed',
      data: {
        results,
        errors,
        totalProcessed: results.length,
        totalErrors: errors.length,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error in batch ML prediction: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error processing batch ML prediction',
      error: error.message,
    });
  }
});

/**
 * GET /api/ml/stats
 * Get ML prediction statistics
 */
router.get('/stats', async (req: Request, res: Response) => {
  try {
    const { clinicId } = req.query;

    if (!clinicId) {
      return res.status(400).json({
        success: false,
        message: 'clinicId is required',
      });
    }

    // Get all assessments for the clinic
    const childrenSnapshot = await db
      .collection('clinics')
      .doc(clinicId as string)
      .collection('children')
      .get();

    let totalAssessments = 0;
    let riskDistribution = { low: 0, moderate: 0, high: 0 };
    let avgConfidence = 0;
    let confidenceSum = 0;
    let confidenceCount = 0;

    for (const childDoc of childrenSnapshot.docs) {
      const assessmentsSnapshot = await childDoc.ref
        .collection('assessments')
        .where('ml_status', '==', 'completed')
        .get();

      totalAssessments += assessmentsSnapshot.size;

      assessmentsSnapshot.forEach((assessmentDoc) => {
        const ml = assessmentDoc.data().ml;
        if (ml && ml.riskLevel) {
          riskDistribution[ml.riskLevel]++;
          
          if (ml.confidence) {
            confidenceSum += ml.confidence;
            confidenceCount++;
          }
        }
      });
    }

    if (confidenceCount > 0) {
      avgConfidence = confidenceSum / confidenceCount;
    }

    res.json({
      success: true,
      data: {
        totalAssessments,
        riskDistribution,
        avgConfidence: Math.round(avgConfidence * 100) / 100,
        totalChildren: childrenSnapshot.size,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error fetching ML stats: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching ML statistics',
      error: error.message,
    });
  }
});

export default router;






