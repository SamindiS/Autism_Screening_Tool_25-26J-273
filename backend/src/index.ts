/**
 * SenseAI Backend API Server
 * Main entry point for the Express server
 */

import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import logger from './utils/logger';

// Import Firebase configuration (initializes Firebase)
import './config/firebase';

// Import routes
import sessionsRouter from './routes/sessions';
import childrenRouter from './routes/children';
import mlRouter from './routes/ml';

// Load environment variables
dotenv.config();

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// ============================================================================
// Middleware
// ============================================================================

// CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:19006'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
};

app.use(cors(corsOptions));

// Body parser middleware
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info(
      `${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`
    );
  });
  
  next();
});

// ============================================================================
// Routes
// ============================================================================

// Health check route
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    message: 'SenseAI Backend API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// API routes
app.use('/api/sessions', sessionsRouter);
app.use('/api/children', childrenRouter);
app.use('/api/ml', mlRouter);

// Root route
app.get('/', (req: Request, res: Response) => {
  res.json({
    name: 'SenseAI Backend API',
    version: '1.0.0',
    description: 'Backend API for Autism Screening Tool',
    endpoints: {
      health: '/health',
      sessions: '/api/sessions',
      children: '/api/children',
      ml: '/api/ml',
    },
    docs: 'https://github.com/your-repo/docs',
  });
});

// ============================================================================
// Error Handling Middleware
// ============================================================================

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.originalUrl,
  });
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  logger.error(`Unhandled error: ${err.message}`, { stack: err.stack });
  
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// ============================================================================
// Start Server
// ============================================================================

app.listen(PORT, () => {
  logger.info(`
  ╔═══════════════════════════════════════════════════════════╗
  ║                                                           ║
  ║    🚀 SenseAI Backend API Server                         ║
  ║                                                           ║
  ║    📍 Server running on http://localhost:${PORT}           ║
  ║    🌍 Environment: ${process.env.NODE_ENV || 'development'}                      ║
  ║    🔥 Firebase initialized                                ║
  ║    📚 Documentation: /docs                                ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝
  `);
  
  logger.info('Available endpoints:');
  logger.info('  - GET  /health');
  logger.info('  - POST /api/sessions');
  logger.info('  - GET  /api/sessions/:sessionId');
  logger.info('  - GET  /api/sessions/:sessionId/trials');
  logger.info('  - GET  /api/sessions/child/:childId');
  logger.info('  - POST /api/children');
  logger.info('  - GET  /api/children');
  logger.info('  - GET  /api/children/:childId');
  logger.info('  - PUT  /api/children/:childId');
  logger.info('  - DELETE /api/children/:childId');
  logger.info('  - POST /api/ml/predict');
  logger.info('  - POST /api/ml/batch-predict');
  logger.info('  - GET  /api/ml/stats');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received: closing HTTP server');
  process.exit(0);
});

export default app;






