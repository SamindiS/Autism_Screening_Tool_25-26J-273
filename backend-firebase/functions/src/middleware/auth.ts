/**
 * Authentication Middleware
 */

import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';
import { logger } from '../utils/logger';
import { ERROR_MESSAGES, CONSTANTS } from '../config/constants';

// Extend Express Request to include user
declare global {
  namespace Express {
    interface Request {
      user?: admin.auth.DecodedIdToken;
      userRole?: string;
    }
  }
}

/**
 * Verify Firebase ID Token from Authorization header
 */
export const verifyToken = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // Extract token from Authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: ERROR_MESSAGES.UNAUTHORIZED,
        message: 'No token provided or invalid format',
      });
    }

    const token = authHeader.split('Bearer ')[1];

    // Verify the token
    const decodedToken = await admin.auth().verifyIdToken(token);
    
    // Attach user info to request
    req.user = decodedToken;
    req.userRole = decodedToken.role || CONSTANTS.ROLES.DOCTOR;

    logger.info('Token verified successfully', {
      uid: decodedToken.uid,
      email: decodedToken.email,
      role: req.userRole,
    });

    next();
  } catch (error: any) {
    logger.error('Token verification failed', { error: error.message });
    
    return res.status(401).json({
      error: ERROR_MESSAGES.INVALID_TOKEN,
      message: error.message,
    });
  }
};

/**
 * Check if user has required role
 */
export const requireRole = (...allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !req.userRole) {
      return res.status(401).json({
        error: ERROR_MESSAGES.UNAUTHORIZED,
        message: 'User not authenticated',
      });
    }

    if (!allowedRoles.includes(req.userRole)) {
      logger.warn('Insufficient permissions', {
        uid: req.user.uid,
        role: req.userRole,
        requiredRoles: allowedRoles,
      });

      return res.status(403).json({
        error: ERROR_MESSAGES.FORBIDDEN,
        message: `Required role(s): ${allowedRoles.join(', ')}`,
      });
    }

    next();
  };
};

/**
 * Verify user owns the resource (for data access control)
 */
export const verifyOwnership = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const { userId } = req.params;
  const requestUserId = req.body.userId;
  
  const targetUserId = userId || requestUserId;
  
  if (!req.user) {
    return res.status(401).json({
      error: ERROR_MESSAGES.UNAUTHORIZED,
      message: 'User not authenticated',
    });
  }

  // Admins can access any resource
  if (req.userRole === CONSTANTS.ROLES.ADMIN) {
    return next();
  }

  // Check if user owns the resource
  if (req.user.uid !== targetUserId) {
    logger.warn('Unauthorized resource access attempt', {
      requestedBy: req.user.uid,
      resourceOwner: targetUserId,
    });

    return res.status(403).json({
      error: ERROR_MESSAGES.FORBIDDEN,
      message: 'You do not have permission to access this resource',
    });
  }

  next();
};

/**
 * Optional authentication - continue if no token, but attach user if present
 */
export const optionalAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split('Bearer ')[1];
      const decodedToken = await admin.auth().verifyIdToken(token);
      req.user = decodedToken;
      req.userRole = decodedToken.role || CONSTANTS.ROLES.DOCTOR;
    }
    
    next();
  } catch (error) {
    // Don't block request, just continue without user
    next();
  }
};







