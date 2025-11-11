/**
 * Validation Middleware
 */

import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { AppError } from './errorHandler';
import { HTTP_STATUS } from '../config/constants';

export const validateRequest = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error, value } = schema.validate(req.body, { abortEarly: false });

    if (error) {
      const errors = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return next(
        new AppError(
          JSON.stringify({ message: 'Validation failed', errors }),
          HTTP_STATUS.BAD_REQUEST
        )
      );
    }

    req.body = value;
    next();
  };
};

export const validateQuery = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error, value } = schema.validate(req.query, { abortEarly: false });

    if (error) {
      const errors = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));

      return next(
        new AppError(
          JSON.stringify({ message: 'Query validation failed', errors }),
          HTTP_STATUS.BAD_REQUEST
        )
      );
    }

    req.query = value;
    next();
  };
};







