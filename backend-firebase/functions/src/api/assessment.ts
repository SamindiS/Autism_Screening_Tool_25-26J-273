/**
 * Assessment API Routes
 * Handles game results, questionnaires, and behavioral reflections
 */

import express from 'express';
import * as admin from 'firebase-admin';
import { asyncHandler } from '../middleware/errorHandler';
import { verifyToken, verifyOwnership } from '../middleware/auth';
import { validate, assessmentSchema } from '../utils/validation';
import { logger } from '../utils/logger';
import { SUCCESS_MESSAGES, ERROR_MESSAGES, CONSTANTS } from '../config/constants';

export const router = express.Router();

// All routes require authentication
router.use(verifyToken);

/**
 * POST /assessment
 * Save a new assessment
 */
router.post(
  '/',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    // Validate request body
    const validatedData = validate(assessmentSchema)(req.body);

    const {
      userId,
      childId,
      assessmentType,
      gameResults,
      questionnaireData,
      reflectionData,
      duration,
      clinicianNotes,
      language,
    } = validatedData;

    logger.info('Saving new assessment', {
      userId,
      childId,
      assessmentType,
    });

    // Check if child exists
    const childRef = admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId);

    const childDoc = await childRef.get();

    if (!childDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Child not found',
      });
    }

    const childData = childDoc.data();

    // Calculate risk score
    const riskScore = calculateRiskScore(gameResults, questionnaireData, reflectionData);
    const riskLevel = determineRiskLevel(riskScore);

    // Create assessment document
    const assessmentRef = childRef.collection('assessments').doc();

    await assessmentRef.set({
      id: assessmentRef.id,
      userId,
      childId,
      childName: childData?.name,
      childAge: childData?.age,
      assessmentType,
      gameResults: gameResults || null,
      questionnaireData: questionnaireData || null,
      reflectionData: reflectionData || null,
      duration,
      clinicianNotes: clinicianNotes || '',
      language: language || CONSTANTS.LANGUAGES.ENGLISH,
      riskScore,
      riskLevel,
      status: 'completed',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      processedAt: null,
    });

    // Update child's last assessment timestamp and count
    await childRef.update({
      lastAssessment: admin.firestore.FieldValue.serverTimestamp(),
      assessmentCount: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info('Assessment saved successfully', {
      userId,
      childId,
      assessmentId: assessmentRef.id,
      riskScore,
      riskLevel,
    });

    res.status(201).json({
      message: SUCCESS_MESSAGES.ASSESSMENT_SAVED,
      assessment: {
        id: assessmentRef.id,
        assessmentType,
        riskScore,
        riskLevel,
        createdAt: new Date().toISOString(),
      },
    });
  })
);

/**
 * GET /assessment/:userId/:childId
 * Get all assessments for a child
 */
router.get(
  '/:userId/:childId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId } = req.params;
    const { limit = 10, orderBy = 'createdAt', order = 'desc' } = req.query;

    logger.info('Fetching assessments', { userId, childId });

    // Get assessments
    let query = admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .orderBy(orderBy as string, order as any)
      .limit(Number(limit));

    const assessmentsSnapshot = await query.get();

    const assessments = assessmentsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    logger.info('Assessments fetched successfully', {
      userId,
      childId,
      count: assessments.length,
    });

    res.json({
      count: assessments.length,
      assessments,
    });
  })
);

/**
 * GET /assessment/:userId/:childId/:assessmentId
 * Get a specific assessment
 */
router.get(
  '/:userId/:childId/:assessmentId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId, assessmentId } = req.params;

    logger.info('Fetching assessment details', {
      userId,
      childId,
      assessmentId,
    });

    // Get assessment
    const assessmentDoc = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .doc(assessmentId)
      .get();

    if (!assessmentDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Assessment not found',
      });
    }

    const assessmentData = assessmentDoc.data();

    logger.info('Assessment fetched successfully', {
      userId,
      childId,
      assessmentId,
    });

    res.json({
      assessment: {
        id: assessmentDoc.id,
        ...assessmentData,
      },
    });
  })
);

/**
 * PUT /assessment/:userId/:childId/:assessmentId
 * Update assessment (e.g., add clinician notes)
 */
router.put(
  '/:userId/:childId/:assessmentId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId, assessmentId } = req.params;
    const { clinicianNotes, reflectionData } = req.body;

    logger.info('Updating assessment', { userId, childId, assessmentId });

    const assessmentRef = admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .doc(assessmentId);

    const assessmentDoc = await assessmentRef.get();

    if (!assessmentDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Assessment not found',
      });
    }

    // Update assessment
    await assessmentRef.update({
      ...(clinicianNotes !== undefined && { clinicianNotes }),
      ...(reflectionData && { reflectionData }),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info('Assessment updated successfully', {
      userId,
      childId,
      assessmentId,
    });

    res.json({
      message: SUCCESS_MESSAGES.DATA_UPDATED,
      assessmentId,
    });
  })
);

/**
 * DELETE /assessment/:userId/:childId/:assessmentId
 * Delete an assessment
 */
router.delete(
  '/:userId/:childId/:assessmentId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId, assessmentId } = req.params;

    logger.info('Deleting assessment', { userId, childId, assessmentId });

    const assessmentRef = admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .doc(assessmentId);

    const assessmentDoc = await assessmentRef.get();

    if (!assessmentDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Assessment not found',
      });
    }

    await assessmentRef.delete();

    // Update child's assessment count
    const childRef = admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId);

    await childRef.update({
      assessmentCount: admin.firestore.FieldValue.increment(-1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info('Assessment deleted successfully', {
      userId,
      childId,
      assessmentId,
    });

    res.json({
      message: SUCCESS_MESSAGES.DATA_DELETED,
    });
  })
);

/**
 * Calculate risk score based on game and behavioral data
 */
function calculateRiskScore(
  gameResults: any,
  questionnaireData: any,
  reflectionData: any
): number {
  let score = 50; // Default baseline

  // Game performance (40% weight)
  if (gameResults) {
    const accuracy = gameResults.accuracy || 0;
    const avgRT = gameResults.avgReactionTime || 0;
    const switchCost = gameResults.switchCost || 0;

    // Lower accuracy = higher risk
    score += (100 - accuracy) * 0.2;

    // Higher reaction time = higher risk
    if (avgRT > 2000) score += 10;
    else if (avgRT > 1500) score += 5;

    // Higher switch cost = higher risk
    if (switchCost > 500) score += 10;
    else if (switchCost > 300) score += 5;
  }

  // Questionnaire data (30% weight)
  if (questionnaireData) {
    const avgScore =
      Object.values(questionnaireData).reduce(
        (sum: number, val: any) => sum + Number(val),
        0
      ) / Object.keys(questionnaireData).length;

    // Lower behavioral scores = higher risk
    score += (4 - avgScore) * 7.5;
  }

  // Reflection data (30% weight)
  if (reflectionData) {
    const avgReflection =
      Object.values(reflectionData).reduce(
        (sum: number, val: any) => sum + Number(val),
        0
      ) / Object.keys(reflectionData).length;

    // Lower reflection scores = higher risk
    score += (4 - avgReflection) * 7.5;
  }

  // Clamp score between 0-100
  return Math.max(0, Math.min(100, Math.round(score)));
}

/**
 * Determine risk level based on score
 */
function determineRiskLevel(score: number): string {
  if (score < CONSTANTS.ML_THRESHOLDS.LOW_RISK) {
    return CONSTANTS.RISK_LEVELS.LOW;
  } else if (score < CONSTANTS.ML_THRESHOLDS.MODERATE_RISK) {
    return CONSTANTS.RISK_LEVELS.MODERATE;
  } else {
    return CONSTANTS.RISK_LEVELS.HIGH;
  }
}

export default router;







