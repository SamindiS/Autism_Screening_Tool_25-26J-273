/**
 * Application Constants
 */

export const API_VERSION = 'v1';

export const COLLECTIONS = {
  USERS: 'users',
  CHILDREN: 'children',
  ASSESSMENTS: 'assessments',
  SESSIONS: 'sessions',
  REPORTS: 'reports',
  ANALYTICS: 'analytics',
};

export const ASSESSMENT_TYPES = {
  AI_BOT: 'ai_bot',
  FROG_JUMP: 'frog_jump',
  RULE_SWITCH: 'rule_switch',
};

export const AGE_GROUPS = {
  TODDLER: '2-3',
  PRESCHOOL: '3-5',
  KINDERGARTEN: '5-6',
};

export const RISK_LEVELS = {
  LOW: 'low',
  MODERATE: 'moderate',
  HIGH: 'high',
};

export const LANGUAGES = {
  EN: 'en',
  SI: 'si',
  TA: 'ta',
};

export const USER_ROLES = {
  ADMIN: 'admin',
  DOCTOR: 'doctor',
  CLINICIAN: 'clinician',
  RESEARCHER: 'researcher',
};

export const VALIDATION_RULES = {
  AGE_MIN: 2,
  AGE_MAX: 6,
  NAME_MIN_LENGTH: 2,
  NAME_MAX_LENGTH: 100,
  EMAIL_REGEX: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PASSWORD_MIN_LENGTH: 8,
};

export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL_ERROR: 500,
};

export const ERROR_MESSAGES = {
  INVALID_INPUT: 'Invalid input data',
  UNAUTHORIZED: 'Unauthorized access',
  NOT_FOUND: 'Resource not found',
  ALREADY_EXISTS: 'Resource already exists',
  INTERNAL_ERROR: 'Internal server error',
  INVALID_AGE: 'Age must be between 2 and 6 years',
  INVALID_EMAIL: 'Invalid email format',
  WEAK_PASSWORD: 'Password must be at least 8 characters',
};

export const SUCCESS_MESSAGES = {
  CREATED: 'Resource created successfully',
  UPDATED: 'Resource updated successfully',
  DELETED: 'Resource deleted successfully',
  RETRIEVED: 'Resource retrieved successfully',
};







