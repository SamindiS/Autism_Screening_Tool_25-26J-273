// Core Types for Autism Screening App

export interface Child {
  id: string;
  name: string;
  age: number;
  gender: 'male' | 'female';
  language: 'en' | 'si' | 'ta';
  testCompleted?: boolean;
  riskLevel?: 'low' | 'moderate' | 'high';
  assessmentScore?: number;
  lastSession?: string;
  createdAt: Date;
  updatedAt: Date;
  // Additional properties
  notes?: string;
  tags?: string[];
}

export interface Session {
  id: string;
  childId: string;
  componentType: 'cognitive_flexibility' | 'rrb' | 'visual_attention' | 'rtn';
  gameType: 'go_nogo' | 'stroop' | 'dccs';
  ageGroup: '2-3' | '4-5' | '5-6';
  startTime: Date;
  endTime: Date;
  duration: number; // in seconds
  status: 'in_progress' | 'completed' | 'cancelled';
  data: GameData;
  mlPrediction?: MLPrediction;
  clinicianNotes?: string;
}

export interface GameData {
  trials: Trial[];
  metrics: GameMetrics;
  features: MLFeatures;
}

export interface Trial {
  id: string;
  trialNumber: number;
  stimulus: string;
  rule: string;
  response?: string;
  reactionTime?: number; // in milliseconds
  correct: boolean;
  timestamp: Date;
  phase: 'practice' | 'pre_switch' | 'post_switch';
}

export interface GameMetrics {
  accuracy: number; // percentage
  meanReactionTime: number; // milliseconds
  switchCost: number; // milliseconds
  perseverativeErrors: number;
  inhibitionErrors: number;
  recoveryTrials: number;
  totalTrials: number;
  correctTrials: number;
}

export interface MLFeatures {
  mean_rt: number;
  accuracy: number;
  switch_cost: number;
  perseverative_error_rate: number;
  inhibition_error_rate: number;
  recovery_speed: number;
  age: number;
  gender: number; // 0 for male, 1 for female
}

export interface MLPrediction {
  riskLevel: 'low' | 'moderate' | 'high';
  confidence: number; // 0-1
  features: MLFeatures;
  timestamp: Date;
}

export interface Clinician {
  id: string;
  username: string;
  name: string;
  fullName: string;
  email: string;
  role: 'doctor' | 'admin' | 'clinician';
  clinicId: string;
  isActive: boolean;
  isVerified: boolean;
  twoFactorEnabled: boolean;
  lastLogin?: Date;
  createdAt: Date;
}

export interface RegistrationData {
  username: string;
  email: string;
  password: string;
  fullName: string;
  clinicId?: string;
}

export interface Clinic {
  id: string;
  name: string;
  address: string;
  phone: string;
  email: string;
  licenseNumber: string;
  isActive: boolean;
  createdAt: Date;
}

export interface AIBotResponse {
  questionId: string;
  question: string;
  type: 'multiple_choice' | 'scale' | 'text';
  options?: string[];
  scaleRange?: { min: number; max: number };
  required: boolean;
}

export interface AIBotAnswer {
  questionId: string;
  answer: string | number;
  timestamp: Date;
}

export interface Report {
  id: string;
  sessionId: string;
  childId: string;
  generatedAt: Date;
  riskLevel: 'low' | 'moderate' | 'high';
  summary: ReportSummary;
  recommendations: string[];
  clinicianNotes: string;
  aiBotAnswers: AIBotAnswer[];
}

export interface ReportSummary {
  overallScore: number;
  cognitiveFlexibility: number;
  attention: number;
  socialInteraction: number;
  behavioralIndicators: string[];
}

export interface Language {
  code: 'en' | 'si' | 'ta';
  name: string;
  flag: string;
}

export interface NavigationProps {
  navigation: any;
  route: any;
}

export interface GameConfig {
  maxTrials: number;
  practiceTrials: number;
  switchPoint: number;
  stimulusDuration: number;
  responseTimeout: number;
  feedbackDuration: number;
}

export interface AudioConfig {
  enabled: boolean;
  volume: number;
  language: 'en' | 'si' | 'ta';
}

export interface HapticConfig {
  enabled: boolean;
  intensity: 'light' | 'medium' | 'heavy';
}

export interface AppConfig {
  audio: AudioConfig;
  haptic: HapticConfig;
  theme: 'light' | 'dark';
  language: 'en' | 'si' | 'ta';
  maxSessionDuration: number; // in minutes
  autoSave: boolean;
}

