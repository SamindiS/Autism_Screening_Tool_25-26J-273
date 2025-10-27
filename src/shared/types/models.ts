/**
 * Core Data Models
 * TypeScript interfaces for all data structures
 */

import type { GameType, AgeGroup, Language, Gender, RiskLevel, SessionStatus, TrialPhase, ComponentType, UserRole } from '../../core/constants';

// ==================== USER & AUTH ====================

export interface User {
  id: string;
  username: string;
  email: string;
  fullName: string;
  role: UserRole;
  clinicId?: string;
  isActive: boolean;
  isVerified: boolean;
  twoFactorEnabled: boolean;
  lastLogin?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  username: string;
  email: string;
  password: string;
  fullName: string;
  clinicId?: string;
}

// ==================== CHILD ====================

export interface Child {
  id: string;
  name: string;
  age: number;
  ageGroup: AgeGroup;
  gender: Gender;
  dateOfBirth: Date;
  language: Language;
  clinicId: string;
  createdBy: string; // User ID
  
  // Optional medical information
  medicalHistory?: string;
  notes?: string;
  parentalConsent: boolean;
  consentDate?: Date;
  
  // Assessment history
  totalSessions: number;
  lastSessionDate?: Date;
  currentRiskLevel?: RiskLevel;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

export interface ChildFormData {
  name: string;
  age: number;
  gender: Gender;
  dateOfBirth: Date;
  language: Language;
  medicalHistory?: string;
  notes?: string;
  parentalConsent: boolean;
}

// ==================== SESSION ====================

export interface Session {
  id: string;
  childId: string;
  clinicianId: string;
  
  // Session details
  componentType: ComponentType;
  gameType: GameType;
  ageGroup: AgeGroup;
  language: Language;
  
  // Timing
  startTime: Date;
  endTime?: Date;
  duration: number; // seconds
  
  // Status
  status: SessionStatus;
  
  // Data
  trials: Trial[];
  metrics?: GameMetrics;
  mlFeatures?: MLFeatures;
  mlPrediction?: MLPrediction;
  
  // Clinician input
  clinicianNotes?: string;
  observations?: string;
  
  // Device info
  deviceInfo?: DeviceInfo;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

export interface SessionCreateData {
  childId: string;
  gameType: GameType;
  language: Language;
}

// ==================== TRIAL ====================

export interface Trial {
  id: string;
  sessionId: string;
  trialNumber: number;
  
  // Trial details
  phase: TrialPhase;
  stimulus: string;
  rule: string;
  correctResponse: string;
  
  // Response
  userResponse?: string;
  reactionTime?: number; // milliseconds
  correct: boolean;
  
  // Error classification
  errorType?: ErrorType;
  
  // Timing (precise)
  stimulusOnset: number; // Performance.now()
  responseTime?: number; // Performance.now()
  
  // Metadata
  timestamp: Date;
}

export type ErrorType = 'perseverative' | 'inhibition' | 'no_response' | 'timeout';

// ==================== METRICS ====================

export interface GameMetrics {
  // Basic metrics
  totalTrials: number;
  completedTrials: number;
  correctTrials: number;
  incorrectTrials: number;
  noResponseTrials: number;
  
  // Accuracy
  accuracy: number; // percentage
  accuracyPreSwitch?: number;
  accuracyPostSwitch?: number;
  
  // Reaction time
  meanReactionTime: number; // milliseconds
  medianReactionTime: number;
  reactionTimeSD: number;
  reactionTimePreSwitch?: number;
  reactionTimePostSwitch?: number;
  
  // Switching metrics
  switchCost?: number; // milliseconds (post - pre)
  switchCostAccuracy?: number; // accuracy difference
  
  // Error analysis
  totalErrors: number;
  perseverativeErrors: number;
  inhibitionErrors: number;
  errorRate: number; // percentage
  
  // Recovery
  recoveryTrials: number; // trials to recover after error
  adaptabilityScore: number; // 0-100
  
  // Consistency
  consistencyScore: number; // 0-100
  variabilityCoefficient: number;
}

// ==================== ML FEATURES ====================

export interface MLFeatures {
  // Demographics
  age: number;
  gender: number; // 0=male, 1=female
  
  // Performance features
  accuracy: number;
  mean_rt: number;
  median_rt: number;
  rt_sd: number;
  rt_cv: number; // coefficient of variation
  
  // Switching features
  switch_cost: number;
  switch_cost_accuracy: number;
  
  // Error features
  error_rate: number;
  perseverative_error_rate: number;
  inhibition_error_rate: number;
  
  // Recovery features
  recovery_speed: number;
  adaptability_score: number;
  
  // Consistency features
  consistency_score: number;
  variability: number;
  
  // Sequential features
  learning_slope: number; // improvement over trials
  fatigue_slope: number; // performance drop over time
}

// ==================== ML PREDICTION ====================

export interface MLPrediction {
  riskLevel: RiskLevel;
  confidence: number; // 0-1
  probability: {
    low: number;
    moderate: number;
    high: number;
  };
  features: MLFeatures;
  modelVersion: string;
  timestamp: Date;
}

// ==================== REPORT ====================

export interface Report {
  id: string;
  sessionId: string;
  childId: string;
  clinicianId: string;
  
  // Report content
  riskLevel: RiskLevel;
  confidence: number;
  summary: ReportSummary;
  recommendations: string[];
  
  // Data
  metrics: GameMetrics;
  mlPrediction: MLPrediction;
  clinicianNotes?: string;
  botAnswers?: BotAnswer[];
  
  // Export
  pdfUrl?: string;
  csvUrl?: string;
  
  // Metadata
  generatedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface ReportSummary {
  overallScore: number; // 0-100
  cognitiveFlexibility: number; // 0-100
  inhibitoryControl: number; // 0-100
  setShifting: number; // 0-100
  processingSpeed: number; // 0-100
  consistency: number; // 0-100
  
  strengths: string[];
  weaknesses: string[];
  keyFindings: string[];
}

// ==================== AI BOT ====================

export interface BotQuestion {
  id: string;
  question: string;
  type: 'multiple_choice' | 'scale' | 'text' | 'yes_no';
  options?: string[];
  scaleRange?: { min: number; max: number; labels?: string[] };
  required: boolean;
  order: number;
}

export interface BotAnswer {
  questionId: string;
  answer: string | number;
  timestamp: Date;
}

// ==================== DEVICE INFO ====================

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  platform: 'ios' | 'android';
  osVersion: string;
  appVersion: string;
  screenWidth: number;
  screenHeight: number;
  isTablet: boolean;
}

// ==================== CLINIC ====================

export interface Clinic {
  id: string;
  name: string;
  address: string;
  phone: string;
  email: string;
  licenseNumber: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// ==================== STATISTICS ====================

export interface DashboardStats {
  totalChildren: number;
  totalSessions: number;
  sessionsToday: number;
  sessionsThisWeek: number;
  sessionsThisMonth: number;
  
  riskDistribution: {
    low: number;
    moderate: number;
    high: number;
  };
  
  averageAccuracy: number;
  averageReactionTime: number;
  
  recentSessions: Session[];
  upcomingFollowUps: Child[];
}



