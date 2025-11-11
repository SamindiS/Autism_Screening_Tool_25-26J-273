// Core Types for Autism Screening App

export interface Child {
  id: string;
  name: string;
  age: number; // Calculated age in years
  dateOfBirth: string; // ISO date string (YYYY-MM-DD)
  gender: 'male' | 'female';
  language: 'en' | 'si' | 'ta';
  hospitalId: string; // Hospital ID - identifies which hospital this child belongs to
  hospitalName?: string; // Hospital Name
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
  clinicId: string; // Hospital ID
  hospitalName?: string; // Hospital Name
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
  clinicId?: string; // Hospital ID
  hospitalName?: string; // Hospital Name
  role?: 'doctor' | 'admin';
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

// ============ ML-READY DATA STRUCTURES ============

export interface EnhancedAssessment {
  // Basic Info
  assessmentId: string;
  childId: string;
  childAge: number;
  childGender: 'male' | 'female';
  assessmentType: 'frog_jump' | 'rule_switch' | 'ai_bot';
  timestamp: string;
  duration: number; // seconds
  
  // Game Features (objective metrics)
  gameFeatures: GameFeatures;
  
  // Questionnaire Features (subjective observations)
  questionnaireFeatures?: QuestionnaireFeatures;
  
  // Derived ML Indices
  derivedFeatures?: DerivedFeatures;
  
  // Risk Assessment
  riskScore: number;
  riskLevel: 'low' | 'moderate' | 'high';
  confidence?: number;
  
  // Clinical Context
  clinicianId?: string;
  clinicianNotes?: string;
  recommendations: string[];
}

// Game-captured objective metrics
export interface GameFeatures {
  // Reaction Time Metrics
  mean_rt: number; // Average reaction time (ms)
  rt_sd: number; // Standard deviation
  min_rt: number;
  max_rt: number;
  
  // Accuracy Metrics
  accuracy: number; // Overall percentage
  go_accuracy?: number; // For Frog Jump
  nogo_accuracy?: number; // For Frog Jump
  pre_switch_accuracy?: number; // For Rule Switch
  post_switch_accuracy?: number; // For Rule Switch
  
  // Error Metrics
  inhibition_errors: number; // False alarms
  perseveration_errors: number; // Using old rule after switch
  missed_targets: number;
  total_errors: number;
  
  // Flexibility Metrics (Rule Switch only)
  switch_cost?: number; // RT increase after rule change
  recovery_trials?: number; // Trials to return to baseline
  
  // Session Metrics
  total_trials: number;
  correct_trials: number;
  completion_rate: number; // Percentage of trials completed
  late_responses: number; // Responses after timeout
}

// Clinician-observed behavioral metrics
export interface QuestionnaireFeatures {
  // Attention & Focus
  attention_span?: number; // 0-4 scale
  engagement?: number; // 0-4 scale
  understanding?: number; // 0-4 scale
  
  // Inhibition & Control (Frog Jump specific)
  impulse_control?: number; // 0-4 scale
  
  // Cognitive Flexibility (Rule Switch specific)
  rule_switch_adaptation?: number; // 0-4 scale
  perseveration?: number; // 0-4 scale (inverted for ML)
  prompts_needed?: number; // 0-4 scale (inverted for ML)
  mental_flexibility?: number; // 0-4 scale
  
  // Emotional Regulation
  frustration_tolerance?: number; // 0-4 scale
  frustration_with_change?: number; // 0-4 scale
  calm_recovery_rate?: number; // 0-4 scale
  
  // Behavioral Context
  routine_change_reaction?: number; // From parent questionnaire
  activity_switch_ability?: number;
  error_recovery_score?: number;
  transition_support_usage?: number;
}

// Computed ML-ready features
export interface DerivedFeatures {
  // Composite Indices (0-1 scale)
  flexibility_index: number; // Mean of flexibility-related scores
  attention_index: number; // Scaled attention span
  emotion_index: number; // Mean of emotional regulation scores
  inhibition_index: number; // Mean of impulse control scores
  
  // Performance Ratios
  accuracy_consistency: number; // 1 - (errors / total_trials)
  speed_accuracy_tradeoff: number; // accuracy / (mean_rt / 1000)
  
  // Age-Adjusted Scores
  age_adjusted_accuracy: number;
  age_adjusted_rt: number;
  
  // Risk Indicators
  high_switch_cost: boolean; // switch_cost > 500ms
  low_post_switch_accuracy: boolean; // < 70%
  high_perseveration: boolean; // perseveration_errors > 3
}

// AI Doctor Bot specific (ages 2-3)
export interface AIBotQuestionnaireData {
  responses: { [questionId: string]: number }; // Question ID -> Likert value (1-5)
  totalScore: number;
  percentageScore: number;
  riskScore: number;
  categoryScores: {
    [category: string]: number; // Category name -> percentage
  };
  recommendations: string[];
  timestamp: string;
}

// Clinician Reflection specific (ages 3-6)
export interface ClinicianReflectionData {
  responses: { [questionId: string]: number }; // Question ID -> value (0-4)
  totalScore: number;
  percentageScore: number;
  maxScore: number;
  categoryScores: {
    [category: string]: number; // Category name -> percentage
  };
  timestamp: string;
  assessedBy: string;
  childAge: number;
  gameType: string;
}

