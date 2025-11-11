/**
 * SenseAI Backend - Cloud Functions Entry Point
 * Professional-grade serverless backend for autism screening
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/errorHandler';

// Import routers
import { router as authRouter } from './api/auth';
import { router as childRouter } from './api/child';
import { router as assessmentRouter } from './api/assessment';
import { router as mlRouter } from './api/ml';
import { router as reportRouter } from './api/report';
import { router as analyticsRouter } from './api/analytics';

// Initialize Firebase Admin
admin.initializeApp();

// Create Express app
const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'SenseAI Backend',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/auth', authRouter);
app.use('/child', childRouter);
app.use('/assessment', assessmentRouter);
app.use('/ml', mlRouter);
app.use('/report', reportRouter);
app.use('/analytics', analyticsRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
  });
});

// Error handler (must be last)
app.use(errorHandler);

// Export Cloud Function
export const api = functions.https.onRequest(app);

// Background Functions for data processing
export const processAssessment = functions.firestore
  .document('users/{userId}/children/{childId}/assessments/{assessmentId}')
  .onCreate(async (snap, context) => {
    const assessment = snap.data();
    logger.info('New assessment created', {
      userId: context.params.userId,
      childId: context.params.childId,
      assessmentId: context.params.assessmentId,
    });

    // Add processing timestamp
    await snap.ref.update({
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'processed',
    });
  });

// Scheduled function for analytics aggregation (runs daily at midnight)
export const dailyAnalytics = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('Asia/Colombo')
  .onRun(async (context) => {
    logger.info('Running daily analytics aggregation');
    
    const db = admin.firestore();
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    
    // Aggregate daily statistics
    const usersSnapshot = await db.collection('users').get();
    let totalAssessments = 0;
    
    for (const userDoc of usersSnapshot.docs) {
      const childrenSnapshot = await userDoc.ref.collection('children').get();
      for (const childDoc of childrenSnapshot.docs) {
        const assessmentsSnapshot = await childDoc.ref
          .collection('assessments')
          .where('createdAt', '>=', yesterday)
          .get();
        totalAssessments += assessmentsSnapshot.size;
      }
    }
    
    // Store daily stats
    await db.collection('analytics').doc('daily').collection('stats').add({
      date: admin.firestore.Timestamp.fromDate(yesterday),
      totalAssessments,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    logger.info(`Daily analytics complete: ${totalAssessments} assessments`);
  });

logger.info('SenseAI Backend initialized successfully');







