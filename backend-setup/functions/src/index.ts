/**
 * SenseAI Autism Screening Tool - Backend API
 * Main Entry Point for Firebase Cloud Functions
 */

import * as functions from 'firebase-functions';
import express, { Request, Response } from 'express';
import cors from 'cors';
import { errorHandler } from './middleware/errorHandler';
import logger from './utils/logger';

// Initialize Express app
const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  logger.info(`[${req.method}] ${req.path}`, {
    body: req.body,
    query: req.query,
    ip: req.ip,
  });
  next();
});

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    message: 'SenseAI Backend API is running ✅',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// Import routes
import authRoutes from './api/auth';
import childrenRoutes from './api/children';
import assessmentsRoutes from './api/assessments';
import translationsRoutes from './api/translations';
import mlRoutes from './api/ml';
import analyticsRoutes from './api/analytics';

// API v1 routes
const apiV1 = express.Router();
apiV1.use('/auth', authRoutes);
apiV1.use('/children', childrenRoutes);
apiV1.use('/assessments', assessmentsRoutes);
apiV1.use('/translations', translationsRoutes);
apiV1.use('/ml', mlRoutes);
apiV1.use('/analytics', analyticsRoutes);

app.use('/v1', apiV1);

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: {
      message: 'Endpoint not found',
      path: req.path,
      method: req.method,
    },
  });
});

// Error handler (must be last)
app.use(errorHandler);

// Export Cloud Function
export const api = functions
  .region('us-central1')
  .https.onRequest(app);

// Scheduled functions
export const dailyAnalytics = functions
  .region('us-central1')
  .pubsub.schedule('every day 00:00')
  .timeZone('Asia/Colombo')
  .onRun(async (context) => {
    logger.info('Running daily analytics job');
    // Add analytics aggregation logic here
    return null;
  });

export const weeklyBackup = functions
  .region('us-central1')
  .pubsub.schedule('every sunday 00:00')
  .timeZone('Asia/Colombo')
  .onRun(async (context) => {
    logger.info('Running weekly backup job');
    // Add backup logic here
    return null;
  });







