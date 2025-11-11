/**
 * Authentication Middleware
 */

import { Request, Response, NextFunction } from 'express';
import { auth } from '../config/firebase';
import { AppError } from './errorHandler';
import { HTTP_STATUS, USER_ROLES } from '../config/constants';
import logger from '../utils/logger';

export interface AuthRequest extends Request {
  user?: {
    uid: string;
    email?: string;
    role?: string;
    [key: string]: any;
  };
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('No token provided', HTTP_STATUS.UNAUTHORIZED);
    }

    const token = authHeader.split('Bearer ')[1];

    try {
      const decodedToken = await auth.verifyIdToken(token);
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        role: decodedToken.role || USER_ROLES.CLINICIAN,
        ...decodedToken,
      };

      logger.info(`User authenticated: ${req.user.uid}`);
      next();
    } catch (error) {
      logger.error('Token verification failed', error);
      throw new AppError('Invalid or expired token', HTTP_STATUS.UNAUTHORIZED);
    }
  } catch (error) {
    next(error);
  }
};

export const authorize = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new AppError('Not authenticated', HTTP_STATUS.UNAUTHORIZED));
    }

    if (!roles.includes(req.user.role || '')) {
      return next(
        new AppError('Insufficient permissions', HTTP_STATUS.FORBIDDEN)
      );
    }

    next();
  };
};

export const optionalAuth = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split('Bearer ')[1];
      try {
        const decodedToken = await auth.verifyIdToken(token);
        req.user = {
          uid: decodedToken.uid,
          email: decodedToken.email,
          role: decodedToken.role || USER_ROLES.CLINICIAN,
          ...decodedToken,
        };
      } catch (error) {
        // Token invalid, but don't throw error
        logger.warn('Optional auth: Invalid token');
      }
    }

    next();
  } catch (error) {
    next(error);
  }
};







