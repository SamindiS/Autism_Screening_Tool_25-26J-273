/**
 * Validation Utilities using Joi
 */

import Joi from 'joi';
import { VALIDATION_RULES, AGE_GROUPS, LANGUAGES, ASSESSMENT_TYPES } from '../config/constants';

// Child Registration Schema
export const childRegistrationSchema = Joi.object({
  name: Joi.string()
    .min(VALIDATION_RULES.NAME_MIN_LENGTH)
    .max(VALIDATION_RULES.NAME_MAX_LENGTH)
    .required(),
  dateOfBirth: Joi.string().isoDate().required(),
  age: Joi.number()
    .min(VALIDATION_RULES.AGE_MIN)
    .max(VALIDATION_RULES.AGE_MAX)
    .required(),
  gender: Joi.string().valid('male', 'female').required(),
  language: Joi.string()
    .valid(LANGUAGES.EN, LANGUAGES.SI, LANGUAGES.TA)
    .default(LANGUAGES.EN),
  guardianName: Joi.string().min(2).max(100).optional(),
  contactNumber: Joi.string().pattern(/^\+?[0-9]{10,15}$/).optional(),
  notes: Joi.string().max(500).optional(),
});

// User Registration Schema
export const userRegistrationSchema = Joi.object({
  email: Joi.string()
    .pattern(VALIDATION_RULES.EMAIL_REGEX)
    .required(),
  password: Joi.string()
    .min(VALIDATION_RULES.PASSWORD_MIN_LENGTH)
    .required(),
  fullName: Joi.string()
    .min(VALIDATION_RULES.NAME_MIN_LENGTH)
    .max(VALIDATION_RULES.NAME_MAX_LENGTH)
    .required(),
  role: Joi.string()
    .valid('doctor', 'clinician', 'researcher')
    .default('clinician'),
  clinicId: Joi.string().optional(),
});

// Assessment Data Schema
export const assessmentDataSchema = Joi.object({
  childId: Joi.string().required(),
  assessmentType: Joi.string()
    .valid(ASSESSMENT_TYPES.AI_BOT, ASSESSMENT_TYPES.FROG_JUMP, ASSESSMENT_TYPES.RULE_SWITCH)
    .required(),
  ageGroup: Joi.string()
    .valid(AGE_GROUPS.TODDLER, AGE_GROUPS.PRESCHOOL, AGE_GROUPS.KINDERGARTEN)
    .required(),
  duration: Joi.number().min(0).required(),
  gameFeatures: Joi.object().optional(),
  questionnaireFeatures: Joi.object().optional(),
  derivedFeatures: Joi.object().optional(),
  riskScore: Joi.number().min(0).max(100).optional(),
  riskLevel: Joi.string().valid('low', 'moderate', 'high').optional(),
  clinicianNotes: Joi.string().max(1000).optional(),
  recommendations: Joi.array().items(Joi.string()).optional(),
});

// Update Child Schema
export const updateChildSchema = Joi.object({
  name: Joi.string()
    .min(VALIDATION_RULES.NAME_MIN_LENGTH)
    .max(VALIDATION_RULES.NAME_MAX_LENGTH)
    .optional(),
  guardianName: Joi.string().min(2).max(100).optional(),
  contactNumber: Joi.string().pattern(/^\+?[0-9]{10,15}$/).optional(),
  notes: Joi.string().max(500).optional(),
  language: Joi.string()
    .valid(LANGUAGES.EN, LANGUAGES.SI, LANGUAGES.TA)
    .optional(),
});

// Query Parameters Schema
export const queryParamsSchema = Joi.object({
  limit: Joi.number().min(1).max(100).default(10),
  offset: Joi.number().min(0).default(0),
  sortBy: Joi.string().valid('createdAt', 'updatedAt', 'name', 'age').default('createdAt'),
  order: Joi.string().valid('asc', 'desc').default('desc'),
  language: Joi.string().valid(LANGUAGES.EN, LANGUAGES.SI, LANGUAGES.TA).optional(),
  ageGroup: Joi.string()
    .valid(AGE_GROUPS.TODDLER, AGE_GROUPS.PRESCHOOL, AGE_GROUPS.KINDERGARTEN)
    .optional(),
  riskLevel: Joi.string().valid('low', 'moderate', 'high').optional(),
});

// Translation Request Schema
export const translationRequestSchema = Joi.object({
  language: Joi.string()
    .valid(LANGUAGES.EN, LANGUAGES.SI, LANGUAGES.TA)
    .required(),
  keys: Joi.array().items(Joi.string()).optional(),
});

// Validation Helper
export const validate = (schema: Joi.ObjectSchema, data: any) => {
  const { error, value } = schema.validate(data, { abortEarly: false });
  if (error) {
    const errors = error.details.map((detail) => ({
      field: detail.path.join('.'),
      message: detail.message,
    }));
    return { isValid: false, errors, value: null };
  }
  return { isValid: true, errors: null, value };
};







