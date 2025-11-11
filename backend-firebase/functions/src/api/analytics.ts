/**
 * Analytics API
 * Provides aggregated statistics and insights
 */

import express from 'express';
import * as admin from 'firebase-admin';
import { asyncHandler } from '../middleware/errorHandler';
import { verifyToken, requireRole } from '../middleware/auth';
import { logger } from '../utils/logger';
import { CONSTANTS } from '../config/constants';

export const router = express.Router();

// All routes require authentication
router.use(verifyToken);

/**
 * GET /analytics/overview
 * Get overall system statistics (admin only)
 */
router.get(
  '/overview',
  requireRole(CONSTANTS.ROLES.ADMIN, CONSTANTS.ROLES.RESEARCHER),
  asyncHandler(async (req, res) => {
    logger.info('Fetching overview analytics');

    const db = admin.firestore();

    // Get total users
    const usersSnapshot = await db.collection('users').get();
    const totalUsers = usersSnapshot.size;

    // Get total children and assessments
    let totalChildren = 0;
    let totalAssessments = 0;
    let assessmentsByType: { [key: string]: number } = {};
    let assessmentsByRiskLevel: { [key: string]: number } = {};

    for (const userDoc of usersSnapshot.docs) {
      const childrenSnapshot = await userDoc.ref.collection('children').get();
      totalChildren += childrenSnapshot.size;

      for (const childDoc of childrenSnapshot.docs) {
        const assessmentsSnapshot = await childDoc.ref.collection('assessments').get();
        totalAssessments += assessmentsSnapshot.size;

        // Count by type and risk level
        assessmentsSnapshot.docs.forEach((assessmentDoc) => {
          const data = assessmentDoc.data();
          const type = data.assessmentType;
          const riskLevel = data.riskLevel;

          assessmentsByType[type] = (assessmentsByType[type] || 0) + 1;
          assessmentsByRiskLevel[riskLevel] = (assessmentsByRiskLevel[riskLevel] || 0) + 1;
        });
      }
    }

    logger.info('Overview analytics fetched', {
      totalUsers,
      totalChildren,
      totalAssessments,
    });

    res.json({
      overview: {
        totalUsers,
        totalChildren,
        totalAssessments,
        assessmentsByType,
        assessmentsByRiskLevel,
        timestamp: new Date().toISOString(),
      },
    });
  })
);

/**
 * GET /analytics/user/:userId
 * Get analytics for a specific user
 */
router.get(
  '/user/:userId',
  asyncHandler(async (req, res) => {
    const { userId } = req.params;

    // Verify ownership (users can only view their own analytics, unless admin)
    if (req.user?.uid !== userId && req.userRole !== CONSTANTS.ROLES.ADMIN) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only view your own analytics',
      });
    }

    logger.info('Fetching user analytics', { userId });

    const db = admin.firestore();

    // Get all children for user
    const childrenSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('children')
      .get();

    const totalChildren = childrenSnapshot.size;
    let totalAssessments = 0;
    let avgAccuracy = 0;
    let avgRiskScore = 0;
    let assessmentsByType: { [key: string]: number } = {};
    let assessmentsByAgeGroup: { [key: string]: number } = {};

    const accuracySum: number[] = [];
    const riskScoreSum: number[] = [];

    for (const childDoc of childrenSnapshot.docs) {
      const childData = childDoc.data();
      const childAge = childData.age;

      const assessmentsSnapshot = await childDoc.ref.collection('assessments').get();
      totalAssessments += assessmentsSnapshot.size;

      assessmentsSnapshot.docs.forEach((assessmentDoc) => {
        const data = assessmentDoc.data();

        // Count by type
        const type = data.assessmentType;
        assessmentsByType[type] = (assessmentsByType[type] || 0) + 1;

        // Count by age group
        const ageGroup = getAgeGroup(childAge);
        assessmentsByAgeGroup[ageGroup] = (assessmentsByAgeGroup[ageGroup] || 0) + 1;

        // Accumulate accuracy and risk score
        if (data.gameResults?.accuracy) {
          accuracySum.push(data.gameResults.accuracy);
        }
        if (data.riskScore) {
          riskScoreSum.push(data.riskScore);
        }
      });
    }

    // Calculate averages
    if (accuracySum.length > 0) {
      avgAccuracy = accuracySum.reduce((a, b) => a + b, 0) / accuracySum.length;
    }
    if (riskScoreSum.length > 0) {
      avgRiskScore = riskScoreSum.reduce((a, b) => a + b, 0) / riskScoreSum.length;
    }

    logger.info('User analytics fetched', { userId, totalChildren, totalAssessments });

    res.json({
      analytics: {
        userId,
        totalChildren,
        totalAssessments,
        avgAccuracy: Math.round(avgAccuracy * 100) / 100,
        avgRiskScore: Math.round(avgRiskScore * 100) / 100,
        assessmentsByType,
        assessmentsByAgeGroup,
        timestamp: new Date().toISOString(),
      },
    });
  })
);

/**
 * GET /analytics/child/:userId/:childId
 * Get analytics for a specific child
 */
router.get(
  '/child/:userId/:childId',
  asyncHandler(async (req, res) => {
    const { userId, childId } = req.params;

    // Verify ownership
    if (req.user?.uid !== userId && req.userRole !== CONSTANTS.ROLES.ADMIN) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only view your own children',
      });
    }

    logger.info('Fetching child analytics', { userId, childId });

    const db = admin.firestore();

    // Get child data
    const childDoc = await db
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .get();

    if (!childDoc.exists) {
      return res.status(404).json({
        error: 'Not found',
        message: 'Child not found',
      });
    }

    // Get all assessments
    const assessmentsSnapshot = await childDoc.ref
      .collection('assessments')
      .orderBy('createdAt', 'asc')
      .get();

    const assessments = assessmentsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Calculate trends
    const accuracyTrend = assessments.map((a: any) => ({
      date: a.createdAt?.toDate().toISOString(),
      value: a.gameResults?.accuracy || 0,
    }));

    const riskScoreTrend = assessments.map((a: any) => ({
      date: a.createdAt?.toDate().toISOString(),
      value: a.riskScore || 0,
    }));

    const reactionTimeTrend = assessments.map((a: any) => ({
      date: a.createdAt?.toDate().toISOString(),
      value: a.gameResults?.avgReactionTime || 0,
    }));

    // Latest assessment
    const latestAssessment = assessments[assessments.length - 1] || null;

    logger.info('Child analytics fetched', { userId, childId, totalAssessments: assessments.length });

    res.json({
      analytics: {
        childId,
        totalAssessments: assessments.length,
        latestAssessment,
        trends: {
          accuracy: accuracyTrend,
          riskScore: riskScoreTrend,
          reactionTime: reactionTimeTrend,
        },
        timestamp: new Date().toISOString(),
      },
    });
  })
);

/**
 * GET /analytics/trends
 * Get system-wide trends (admin only)
 */
router.get(
  '/trends',
  requireRole(CONSTANTS.ROLES.ADMIN, CONSTANTS.ROLES.RESEARCHER),
  asyncHandler(async (req, res) => {
    const { period = '30' } = req.query; // days

    logger.info('Fetching system trends', { period });

    const db = admin.firestore();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - Number(period));

    // Get daily analytics
    const analyticsSnapshot = await db
      .collection('analytics')
      .doc('daily')
      .collection('stats')
      .where('date', '>=', admin.firestore.Timestamp.fromDate(startDate))
      .orderBy('date', 'asc')
      .get();

    const dailyStats = analyticsSnapshot.docs.map((doc) => ({
      date: doc.data().date.toDate().toISOString(),
      totalAssessments: doc.data().totalAssessments || 0,
    }));

    res.json({
      trends: {
        period: `${period} days`,
        dailyStats,
        timestamp: new Date().toISOString(),
      },
    });
  })
);

/**
 * GET /analytics/export/:userId
 * Export all data for a user (CSV format)
 */
router.get(
  '/export/:userId',
  asyncHandler(async (req, res) => {
    const { userId } = req.params;

    // Verify ownership
    if (req.user?.uid !== userId && req.userRole !== CONSTANTS.ROLES.ADMIN) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only export your own data',
      });
    }

    logger.info('Exporting user data', { userId });

    const db = admin.firestore();

    // Get all children and assessments
    const childrenSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('children')
      .get();

    const rows: string[] = [];
    rows.push(
      'ChildID,ChildName,ChildAge,AssessmentID,AssessmentType,Date,Accuracy,AvgRT,SwitchCost,RiskScore,RiskLevel'
    );

    for (const childDoc of childrenSnapshot.docs) {
      const childData = childDoc.data();
      const assessmentsSnapshot = await childDoc.ref.collection('assessments').get();

      assessmentsSnapshot.docs.forEach((assessmentDoc) => {
        const data = assessmentDoc.data();
        rows.push(
          `${childDoc.id},"${childData.name}",${childData.age},${assessmentDoc.id},${
            data.assessmentType
          },${data.createdAt?.toDate().toISOString()},${data.gameResults?.accuracy || 0},${
            data.gameResults?.avgReactionTime || 0
          },${data.gameResults?.switchCost || 0},${data.riskScore || 0},${data.riskLevel || ''}`
        );
      });
    }

    const csv = rows.join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="senseai-export-${userId}.csv"`);
    res.send(csv);

    logger.info('User data exported', { userId, rows: rows.length - 1 });
  })
);

/**
 * Helper function to determine age group
 */
function getAgeGroup(age: number): string {
  if (age <= 3) return '2-3';
  if (age <= 5) return '3-5';
  return '5-6';
}

export default router;







