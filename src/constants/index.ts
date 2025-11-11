// Constants for Autism Screening App

export const COLORS = {
  primary: '#6366F1',
  secondary: '#8B5CF6',
  accent: '#F18F01',
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  info: '#3B82F6',
  background: '#F8FAFC',
  surface: '#FFFFFF',
  text: '#1E293B',
  textSecondary: '#64748B',
  border: '#E2E8F0',
  disabled: '#BDBDBD',
  // Game specific colors
  go: '#4CAF50',
  noGo: '#F44336',
  neutral: '#9E9E9E',
  correct: '#4CAF50',
  incorrect: '#F44336',
  // Age group colors
  age2to3: '#FFB74D',
  age4to5: '#81C784',
  age5to6: '#64B5F6',
  // Additional colors
  lightGray: '#F1F5F9',
  darkGray: '#475569',
};

export const FONTS = {
  regular: 'System',
  medium: 'System',
  bold: 'System',
  sizes: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 18,
    xl: 20,
    xxl: 24,
    xxxl: 32,
  },
  weights: {
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
  },
};

export const SPACING = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
};

export const GAME_CONFIGS = {
  goNoGo: {
    maxTrials: 20,
    practiceTrials: 4,
    stimulusDuration: 2000,
    responseTimeout: 3000,
    feedbackDuration: 1000,
    goProbability: 0.7,
  },
  stroop: {
    maxTrials: 24,
    practiceTrials: 6,
    stimulusDuration: 3000,
    responseTimeout: 4000,
    feedbackDuration: 1500,
    switchPoint: 12,
  },
  dccs: {
    maxTrials: 30,
    practiceTrials: 8,
    stimulusDuration: 2500,
    responseTimeout: 3500,
    feedbackDuration: 1200,
    switchPoint: 15,
  },
};

export const AGE_GROUPS = {
  '2-3': {
    label: '2-3 Years',
    color: COLORS.age2to3,
    games: ['ai_bot'], // AI Doctor Bot for ages 2-3
    maxSessionTime: 5, // minutes
  },
  '4-5': {
    label: '3-5 Years',
    color: COLORS.age4to5,
    games: ['frog_jump'], // Frog Jump Game (Go/No-Go) for ages 3-5
    maxSessionTime: 5, // minutes
  },
  '5-6': {
    label: '5-6 Years',
    color: COLORS.age5to6,
    games: ['color_shape'], // Magic Garden (DCCS-style) for ages 5-6
    maxSessionTime: 5, // minutes
  },
};

export const LANGUAGES = {
  en: {
    code: 'en',
    name: 'English',
    flag: '🇺🇸',
  },
  si: {
    code: 'si',
    name: 'සිංහල',
    flag: '🇱🇰',
  },
  ta: {
    code: 'ta',
    name: 'தமிழ்',
    flag: '🇱🇰',
  },
};

export const COMPONENTS = {
  cognitive_flexibility: {
    name: 'Cognitive Flexibility & Rule-Switching',
    icon: 'brain',
    description: 'Assesses executive functioning and rule-switching abilities',
    color: COLORS.primary,
  },
  rrb: {
    name: 'Restricted & Repetitive Behaviors',
    icon: 'repeat',
    description: 'Evaluates repetitive behaviors and restricted interests',
    color: COLORS.secondary,
  },
  visual_attention: {
    name: 'Visual Attention',
    icon: 'eye',
    description: 'Measures visual attention and focus capabilities',
    color: COLORS.accent,
  },
  rtn: {
    name: 'Response to Name',
    icon: 'volume-up',
    description: 'Tests social attention and name response',
    color: COLORS.success,
  },
};

export const ML_THRESHOLDS = {
  low: {
    min: 0,
    max: 0.33,
    label: 'Low Risk',
    color: COLORS.success,
  },
  moderate: {
    min: 0.34,
    max: 0.66,
    label: 'Moderate Risk',
    color: COLORS.warning,
  },
  high: {
    min: 0.67,
    max: 1.0,
    label: 'High Risk',
    color: COLORS.error,
  },
};

export const API_ENDPOINTS = {
  base: 'http://localhost:8000/api',
  auth: {
    login: '/auth/login',
    register: '/auth/register',
    logout: '/auth/logout',
    refresh: '/auth/refresh',
  },
  children: {
    list: '/children',
    create: '/children',
    get: '/children/:id',
    update: '/children/:id',
    delete: '/children/:id',
  },
  sessions: {
    list: '/sessions',
    create: '/sessions',
    get: '/sessions/:id',
    update: '/sessions/:id',
    delete: '/sessions/:id',
  },
  ml: {
    predict: '/ml/predict',
    train: '/ml/train',
  },
  reports: {
    generate: '/reports/generate',
    download: '/reports/download/:id',
  },
};

export const STORAGE_KEYS = {
  authToken: 'auth_token',
  refreshToken: 'refresh_token',
  user: 'user_data',
  settings: 'app_settings',
  offlineData: 'offline_data',
  language: 'selected_language',
  theme: 'selected_theme',
};

export const ANIMATION_DURATION = {
  fast: 200,
  normal: 300,
  slow: 500,
  verySlow: 1000,
};

export const HAPTIC_PATTERNS = {
  light: 'light',
  medium: 'medium',
  heavy: 'heavy',
  success: 'notificationSuccess',
  warning: 'notificationWarning',
  error: 'notificationError',
};

export const AUDIO_FILES = {
  // English
  en: {
    welcome: 'welcome_en.mp3',
    instructions: 'instructions_en.mp3',
    correct: 'correct_en.mp3',
    incorrect: 'incorrect_en.mp3',
    wellDone: 'well_done_en.mp3',
    gameComplete: 'game_complete_en.mp3',
  },
  // Sinhala
  si: {
    welcome: 'welcome_si.mp3',
    instructions: 'instructions_si.mp3',
    correct: 'correct_si.mp3',
    incorrect: 'incorrect_si.mp3',
    wellDone: 'well_done_si.mp3',
    gameComplete: 'game_complete_si.mp3',
  },
  // Tamil
  ta: {
    welcome: 'welcome_ta.mp3',
    instructions: 'instructions_ta.mp3',
    correct: 'correct_ta.mp3',
    incorrect: 'incorrect_ta.mp3',
    wellDone: 'well_done_ta.mp3',
    gameComplete: 'game_complete_ta.mp3',
  },
};

export const VALIDATION_RULES = {
  childName: {
    minLength: 2,
    maxLength: 50,
    pattern: /^[a-zA-Z\s\u0D80-\u0DFF\u0B80-\u0BFF]+$/,
  },
  email: {
    pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  },
  age: {
    min: 2,
    max: 6,
  },
  sessionDuration: {
    max: 5, // minutes
  },
};

export const ERROR_MESSAGES = {
  network: 'Network connection error. Please check your internet connection.',
  server: 'Server error. Please try again later.',
  validation: 'Please check your input and try again.',
  auth: 'Authentication failed. Please login again.',
  session: 'Session expired. Please login again.',
  storage: 'Failed to save data. Please try again.',
  ml: 'Failed to process prediction. Please try again.',
  report: 'Failed to generate report. Please try again.',
};

export const SUCCESS_MESSAGES = {
  login: 'Successfully logged in',
  logout: 'Successfully logged out',
  childCreated: 'Child profile created successfully',
  childUpdated: 'Child profile updated successfully',
  sessionStarted: 'Assessment session started',
  sessionCompleted: 'Assessment completed successfully',
  reportGenerated: 'Report generated successfully',
  dataSaved: 'Data saved successfully',
};

// Professional Design System
export const SHADOWS = {
  small: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  medium: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 4,
  },
  large: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.2,
    shadowRadius: 16,
    elevation: 8,
  },
};

export const GRADIENTS = {
  primary: ['#6366F1', '#8B5CF6'],
  success: ['#10B981', '#34D399'],
  warning: ['#F59E0B', '#FBBF24'],
  error: ['#EF4444', '#F87171'],
  info: ['#3B82F6', '#60A5FA'],
};

