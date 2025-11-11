/**
 * Global Error Handler Middleware
 */

import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';
import { ERROR_MESSAGES } from '../config/constants';

interface CustomError extends Error {
  status?: number;
  details?: any;
}

/**
 * Global error handling middleware
 * Must be the last middleware in the chain
 */
export const errorHandler = (
  err: CustomError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Log the error
  logger.error('Error occurred', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    ip: req.ip,
    userId: req.user?.uid,
  });

  // Determine status code
  const statusCode = err.status || 500;

  // Prepare error response
  const errorResponse: any = {
    error: err.message || ERROR_MESSAGES.INTERNAL_ERROR,
    path: req.path,
    timestamp: new Date().toISOString(),
  };

  // Add details if available (for validation errors)
  if (err.details) {
    errorResponse.details = err.details;
  }

  // Add stack trace in development
  if (process.env.NODE_ENV === 'development') {
    errorResponse.stack = err.stack;
  }

  // Send error response
  res.status(statusCode).json(errorResponse);
};

/**
 * Async error wrapper to catch async errors in route handlers
 */
export const asyncHandler = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

/**
 * Not found error handler
 */
export const notFoundHandler = (req: Request, res: Response) => {
  res.status(404).json({
    error: ERROR_MESSAGES.NOT_FOUND,
    message: `Route ${req.method} ${req.path} not found`,
    timestamp: new Date().toISOString(),
  });
};







