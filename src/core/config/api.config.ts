/**
 * API Configuration
 * Backend API endpoints and settings
 */

// Base URLs for different environments
const API_URLS = {
  development: 'http://localhost:8000/api/v1',
  staging: 'https://staging-api.senseai.lk/api/v1',
  production: 'https://api.senseai.lk/api/v1',
};

// Get current API URL based on environment
export const getApiUrl = (): string => {
  if (__DEV__) {
    return API_URLS.development;
  }
  // Can check for staging env variable here
  return API_URLS.production;
};

// API endpoints
export const apiEndpoints = {
  // Auth endpoints
  auth: {
    login: '/auth/login',
    register: '/auth/register',
    logout: '/auth/logout',
    refresh: '/auth/refresh',
    verify: '/auth/verify',
    twoFactor: '/auth/2fa',
  },
  
  // User endpoints
  user: {
    profile: '/user/profile',
    update: '/user/update',
    changePassword: '/user/change-password',
  },
  
  // Children endpoints
  children: {
    list: '/children',
    create: '/children/create',
    detail: (id: string) => `/children/${id}`,
    update: (id: string) => `/children/${id}/update`,
    delete: (id: string) => `/children/${id}/delete`,
    sessions: (id: string) => `/children/${id}/sessions`,
  },
  
  // Session endpoints
  sessions: {
    create: '/sessions/create',
    detail: (id: string) => `/sessions/${id}`,
    update: (id: string) => `/sessions/${id}/update`,
    complete: (id: string) => `/sessions/${id}/complete`,
    cancel: (id: string) => `/sessions/${id}/cancel`,
    list: '/sessions',
  },
  
  // ML endpoints
  ml: {
    predict: '/ml/predict',
    features: '/ml/extract-features',
    train: '/ml/train',
    evaluate: '/ml/evaluate',
  },
  
  // Report endpoints
  reports: {
    generate: '/reports/generate',
    detail: (id: string) => `/reports/${id}`,
    list: '/reports',
    export: (id: string) => `/reports/${id}/export`,
    pdf: (id: string) => `/reports/${id}/pdf`,
  },
  
  // Data endpoints
  data: {
    upload: '/data/upload',
    sync: '/data/sync',
    export: '/data/export',
  },
  
  // AI Bot endpoints
  bot: {
    questions: '/bot/questions',
    submit: '/bot/submit-answers',
  },
} as const;

// API configuration
export const apiConfig = {
  baseURL: getApiUrl(),
  timeout: 30000, // 30 seconds
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  withCredentials: true,
};

export default apiConfig;



