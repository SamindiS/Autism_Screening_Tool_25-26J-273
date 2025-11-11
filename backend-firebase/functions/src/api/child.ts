/**
 * Child Management API Routes
 */

import express from 'express';
import * as admin from 'firebase-admin';
import { asyncHandler } from '../middleware/errorHandler';
import { verifyToken, verifyOwnership } from '../middleware/auth';
import { validate, childSchema, updateChildSchema } from '../utils/validation';
import { logger } from '../utils/logger';
import { SUCCESS_MESSAGES, ERROR_MESSAGES } from '../config/constants';

export const router = express.Router();

// All routes require authentication
router.use(verifyToken);

/**
 * POST /child
 * Register a new child
 */
router.post(
  '/',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    // Validate request body
    const validatedData = validate(childSchema)(req.body);

    const { userId, ...childData } = validatedData;

    logger.info('Registering new child', { userId, childName: childData.name });

    // Create child document
    const childRef = admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc();

    await childRef.set({
      id: childRef.id,
      ...childData,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      assessmentCount: 0,
      lastAssessment: null,
    });

    logger.info('Child registered successfully', {
      userId,
      childId: childRef.id,
      childName: childData.name,
    });

    res.status(201).json({
      message: SUCCESS_MESSAGES.CHILD_REGISTERED,
      child: {
        id: childRef.id,
        ...childData,
      },
    });
  })
);

/**
 * GET /child/:userId
 * Get all children for a user
 */
router.get(
  '/:userId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId } = req.params;

    logger.info('Fetching children for user', { userId });

    // Get all children
    const childrenSnapshot = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .orderBy('createdAt', 'desc')
      .get();

    const children = childrenSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    logger.info('Children fetched successfully', {
      userId,
      count: children.length,
    });

    res.json({
      count: children.length,
      children,
    });
  })
);

/**
 * GET /child/:userId/:childId
 * Get a specific child
 */
router.get(
  '/:userId/:childId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId } = req.params;

    logger.info('Fetching child details', { userId, childId });

    // Get child document
    const childDoc = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .get();

    if (!childDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Child not found',
      });
    }

    // Get assessment count
    const assessmentsSnapshot = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .get();

    const childData = childDoc.data();

    logger.info('Child details fetched successfully', { userId, childId });

    res.json({
      child: {
        id: childDoc.id,
        ...childData,
        assessmentCount: assessmentsSnapshot.size,
      },
    });
  })
);

/**
 * PUT /child/:userId/:childId
 * Update child information
 */
router.put(
  '/:userId/:childId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId } = req.params;

    // Validate request body
    const validatedData = validate(updateChildSchema)(req.body);

    logger.info('Updating child', { userId, childId });

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

    // Update child document
    await childRef.update({
      ...validatedData,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info('Child updated successfully', { userId, childId });

    res.json({
      message: SUCCESS_MESSAGES.DATA_UPDATED,
      child: {
        id: childId,
        ...validatedData,
      },
    });
  })
);

/**
 * DELETE /child/:userId/:childId
 * Delete a child and all their assessments
 */
router.delete(
  '/:userId/:childId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId } = req.params;

    logger.info('Deleting child', { userId, childId });

    const childRef = admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId);

    // Check if child exists
    const childDoc = await childRef.get();

    if (!childDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Child not found',
      });
    }

    // Delete all assessments first
    const assessmentsSnapshot = await childRef.collection('assessments').get();

    const batch = admin.firestore().batch();

    assessmentsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete child document
    batch.delete(childRef);

    await batch.commit();

    logger.info('Child deleted successfully', {
      userId,
      childId,
      deletedAssessments: assessmentsSnapshot.size,
    });

    res.json({
      message: SUCCESS_MESSAGES.DATA_DELETED,
      deletedAssessments: assessmentsSnapshot.size,
    });
  })
);

/**
 * GET /child/:userId/:childId/summary
 * Get child assessment summary
 */
router.get(
  '/:userId/:childId/summary',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId } = req.params;

    logger.info('Fetching child assessment summary', { userId, childId });

    // Get child
    const childDoc = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .get();

    if (!childDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Child not found',
      });
    }

    // Get all assessments
    const assessmentsSnapshot = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .orderBy('createdAt', 'desc')
      .get();

    const assessments = assessmentsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Calculate summary statistics
    const totalAssessments = assessments.length;
    const avgAccuracy =
      totalAssessments > 0
        ? assessments.reduce((sum, a: any) => sum + (a.gameResults?.accuracy || 0), 0) /
          totalAssessments
        : 0;

    const latestAssessment = assessments[0] || null;

    logger.info('Child summary fetched successfully', { userId, childId });

    res.json({
      child: {
        id: childDoc.id,
        ...childDoc.data(),
      },
      summary: {
        totalAssessments,
        avgAccuracy: Math.round(avgAccuracy * 100) / 100,
        latestAssessment,
        assessmentHistory: assessments,
      },
    });
  })
);

export default router;







