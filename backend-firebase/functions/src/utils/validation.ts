/**
 * Validation Schemas using Joi
 */

import Joi from 'joi';
import { CONSTANTS } from '../config/constants';

// User Registration Schema
export const registerUserSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string()
    .min(CONSTANTS.VALIDATION.MIN_PASSWORD_LENGTH)
    .required(),
  name: Joi.string()
    .min(CONSTANTS.VALIDATION.MIN_NAME_LENGTH)
    .max(CONSTANTS.VALIDATION.MAX_NAME_LENGTH)
    .required(),
  role: Joi.string()
    .valid(...Object.values(CONSTANTS.ROLES))
    .default(CONSTANTS.ROLES.DOCTOR),
  clinic: Joi.string().optional(),
  phone: Joi.string().optional(),
});

// User Login Schema
export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

// Child Registration Schema
export const childSchema = Joi.object({
  userId: Joi.string().required(),
  name: Joi.string()
    .min(CONSTANTS.VALIDATION.MIN_NAME_LENGTH)
    .max(CONSTANTS.VALIDATION.MAX_NAME_LENGTH)
    .required(),
  age: Joi.number()
    .integer()
    .min(CONSTANTS.VALIDATION.MIN_AGE)
    .max(CONSTANTS.VALIDATION.MAX_AGE)
    .required(),
  gender: Joi.string().valid('M', 'F').required(),
  dateOfBirth: Joi.date().required(),
  language: Joi.string()
    .valid(...Object.values(CONSTANTS.LANGUAGES))
    .default(CONSTANTS.LANGUAGES.ENGLISH),
  parentName: Joi.string().optional(),
  parentContact: Joi.string().optional(),
  medicalHistory: Joi.string().optional(),
  notes: Joi.string().optional(),
});

// Assessment Schema
export const assessmentSchema = Joi.object({
  userId: Joi.string().required(),
  childId: Joi.string().required(),
  assessmentType: Joi.string()
    .valid(...Object.values(CONSTANTS.ASSESSMENT_TYPES))
    .required(),
  gameResults: Joi.object({
    totalTrials: Joi.number().integer().min(0).required(),
    correctTrials: Joi.number().integer().min(0).required(),
    accuracy: Joi.number().min(0).max(100).required(),
    avgReactionTime: Joi.number().min(0).required(),
    switchCost: Joi.number().optional(),
    trials: Joi.array().items(Joi.object()).optional(),
  }).optional(),
  questionnaireData: Joi.object().optional(),
  reflectionData: Joi.object().optional(),
  duration: Joi.number().min(0).required(),
  clinicianNotes: Joi.string().allow('').optional(),
  language: Joi.string()
    .valid(...Object.values(CONSTANTS.LANGUAGES))
    .optional(),
});

// ML Prediction Request Schema
export const mlPredictionSchema = Joi.object({
  features: Joi.object({
    mean_rt: Joi.number().required(),
    accuracy: Joi.number().required(),
    switch_cost: Joi.number().optional(),
    inhibition_errors: Joi.number().optional(),
    age: Joi.number().required(),
    // Add more features as needed
  }).required(),
  childId: Joi.string().optional(),
  assessmentId: Joi.string().optional(),
});

// Report Generation Schema
export const reportSchema = Joi.object({
  userId: Joi.string().required(),
  childId: Joi.string().required(),
  assessmentId: Joi.string().required(),
  language: Joi.string()
    .valid(...Object.values(CONSTANTS.LANGUAGES))
    .default(CONSTANTS.LANGUAGES.ENGLISH),
  includeGraphs: Joi.boolean().default(true),
  includeRecommendations: Joi.boolean().default(true),
});

// Update Child Schema
export const updateChildSchema = Joi.object({
  name: Joi.string()
    .min(CONSTANTS.VALIDATION.MIN_NAME_LENGTH)
    .max(CONSTANTS.VALIDATION.MAX_NAME_LENGTH)
    .optional(),
  age: Joi.number()
    .integer()
    .min(CONSTANTS.VALIDATION.MIN_AGE)
    .max(CONSTANTS.VALIDATION.MAX_AGE)
    .optional(),
  parentName: Joi.string().optional(),
  parentContact: Joi.string().optional(),
  medicalHistory: Joi.string().optional(),
  notes: Joi.string().optional(),
}).min(1); // At least one field must be present

// Validate function helper
export const validate = (schema: Joi.ObjectSchema) => {
  return (data: any) => {
    const { error, value } = schema.validate(data, {
      abortEarly: false,
      stripUnknown: true,
    });
    
    if (error) {
      const details = error.details.map((detail) => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));
      throw {
        status: 400,
        message: 'Validation error',
        details,
      };
    }
    
    return value;
  };
};







