/**
 * Application Constants
 */

export const CONSTANTS = {
  // Roles
  ROLES: {
    ADMIN: 'admin',
    DOCTOR: 'doctor',
    RESEARCHER: 'researcher',
  },

  // Assessment Types
  ASSESSMENT_TYPES: {
    AI_BOT: 'ai_bot',
    FROG_JUMP: 'frog_jump',
    RULE_SWITCH: 'rule_switch',
  },

  // Risk Levels
  RISK_LEVELS: {
    LOW: 'low',
    MODERATE: 'moderate',
    HIGH: 'high',
  },

  // ML Thresholds
  ML_THRESHOLDS: {
    LOW_RISK: 33,
    MODERATE_RISK: 66,
    HIGH_RISK: 100,
  },

  // Age Groups
  AGE_GROUPS: {
    TODDLER: { min: 2, max: 3, assessment: 'ai_bot' },
    PRESCHOOL: { min: 3, max: 5, assessment: 'frog_jump' },
    KINDERGARTEN: { min: 5, max: 6, assessment: 'rule_switch' },
  },

  // Report Settings
  REPORT: {
    MAX_SIZE_MB: 10,
    ALLOWED_FORMATS: ['pdf'],
    RETENTION_DAYS: 365,
  },

  // API Limits
  RATE_LIMITS: {
    REQUESTS_PER_MINUTE: 60,
    REQUESTS_PER_HOUR: 1000,
  },

  // Validation Rules
  VALIDATION: {
    MIN_AGE: 2,
    MAX_AGE: 6,
    MIN_NAME_LENGTH: 2,
    MAX_NAME_LENGTH: 50,
    MIN_PASSWORD_LENGTH: 8,
  },

  // Languages
  LANGUAGES: {
    ENGLISH: 'en',
    SINHALA: 'si',
    TAMIL: 'ta',
  },
};

export const ERROR_MESSAGES = {
  UNAUTHORIZED: 'Unauthorized access',
  FORBIDDEN: 'Forbidden - Insufficient permissions',
  NOT_FOUND: 'Resource not found',
  VALIDATION_ERROR: 'Validation error',
  INTERNAL_ERROR: 'Internal server error',
  DUPLICATE_ENTRY: 'Resource already exists',
  INVALID_TOKEN: 'Invalid or expired token',
  INVALID_CREDENTIALS: 'Invalid email or password',
};

export const SUCCESS_MESSAGES = {
  USER_CREATED: 'User created successfully',
  CHILD_REGISTERED: 'Child registered successfully',
  ASSESSMENT_SAVED: 'Assessment saved successfully',
  REPORT_GENERATED: 'Report generated successfully',
  DATA_UPDATED: 'Data updated successfully',
  DATA_DELETED: 'Data deleted successfully',
};







