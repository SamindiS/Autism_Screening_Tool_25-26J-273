/**
 * Constants barrel export
 */

export * from './ages';
export * from './games';

// App-wide constants
export const APP_NAME = 'SenseAI';
export const APP_VERSION = '1.0.0';

// Maximum session duration (in minutes)
export const MAX_SESSION_DURATION = 5;

// Languages supported
export const LANGUAGES = {
  ENGLISH: 'en',
  SINHALA: 'si',
  TAMIL: 'ta',
} as const;

export type Language = typeof LANGUAGES[keyof typeof LANGUAGES];

export const LANGUAGE_OPTIONS = [
  { code: LANGUAGES.ENGLISH, name: 'English', nativeName: 'English', flag: '🇬🇧' },
  { code: LANGUAGES.SINHALA, name: 'Sinhala', nativeName: 'සිංහල', flag: '🇱🇰' },
  { code: LANGUAGES.TAMIL, name: 'Tamil', nativeName: 'தமிழ்', flag: '🇱🇰' },
] as const;

// Gender options
export const GENDER = {
  MALE: 'male',
  FEMALE: 'female',
  OTHER: 'other',
} as const;

export type Gender = typeof GENDER[keyof typeof GENDER];

// Risk levels
export const RISK_LEVELS = {
  LOW: 'low',
  MODERATE: 'moderate',
  HIGH: 'high',
} as const;

export type RiskLevel = typeof RISK_LEVELS[keyof typeof RISK_LEVELS];

// Session status
export const SESSION_STATUS = {
  NOT_STARTED: 'not_started',
  IN_PROGRESS: 'in_progress',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
} as const;

export type SessionStatus = typeof SESSION_STATUS[keyof typeof SESSION_STATUS];

// Trial phases
export const TRIAL_PHASES = {
  PRACTICE: 'practice',
  PRE_SWITCH: 'pre_switch',
  POST_SWITCH: 'post_switch',
} as const;

export type TrialPhase = typeof TRIAL_PHASES[keyof typeof TRIAL_PHASES];

// Component types
export const COMPONENT_TYPES = {
  COGNITIVE_FLEXIBILITY: 'cognitive_flexibility',
  VISUAL_ATTENTION: 'visual_attention',
  RRB: 'rrb',
  RTN: 'rtn',
} as const;

export type ComponentType = typeof COMPONENT_TYPES[keyof typeof COMPONENT_TYPES];

// User roles
export const USER_ROLES = {
  ADMIN: 'admin',
  DOCTOR: 'doctor',
  CLINICIAN: 'clinician',
} as const;

export type UserRole = typeof USER_ROLES[keyof typeof USER_ROLES];



