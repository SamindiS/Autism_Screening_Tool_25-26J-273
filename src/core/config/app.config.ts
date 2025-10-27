/**
 * Application Configuration
 * Central configuration for the entire app
 */

import { Platform } from 'react-native';

export const appConfig = {
  // App information
  name: 'SenseAI',
  version: '1.0.0',
  buildNumber: '1',
  
  // Environment
  env: __DEV__ ? 'development' : 'production',
  isDevelopment: __DEV__,
  isProduction: !__DEV__,
  
  // Platform
  platform: Platform.OS,
  isIOS: Platform.OS === 'ios',
  isAndroid: Platform.OS === 'android',
  
  // Features
  features: {
    enableOfflineMode: true,
    enableDebugMode: __DEV__,
    enableAnalytics: !__DEV__,
    enableCrashReporting: !__DEV__,
    enableTwoFactor: false, // Will enable later
    enableMLPrediction: true,
    enableDataExport: true,
  },
  
  // Session settings
  session: {
    maxDuration: 5 * 60, // 5 minutes in seconds
    autoSave: true,
    autoSaveInterval: 30, // seconds
  },
  
  // Data collection settings
  dataCollection: {
    enablePreciseTiming: true,
    timingPrecision: 'millisecond', // or 'microsecond'
    collectDeviceInfo: true,
    anonymizeData: true,
  },
  
  // Security
  security: {
    tokenRefreshThreshold: 300, // 5 minutes before expiry
    maxLoginAttempts: 5,
    lockoutDuration: 900, // 15 minutes in seconds
  },
  
  // Storage
  storage: {
    enableEncryption: true,
    maxStorageSize: 100 * 1024 * 1024, // 100MB
    clearOnLogout: false,
  },
  
  // Network
  network: {
    timeout: 30000, // 30 seconds
    retryAttempts: 3,
    retryDelay: 1000, // 1 second
  },
  
  // UI/UX
  ui: {
    animationDuration: 300,
    hapticFeedback: true,
    soundEffects: true,
    defaultLanguage: 'en',
  },
} as const;

export default appConfig;



