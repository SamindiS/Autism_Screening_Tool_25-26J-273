/**
 * API Types
 * Request/Response types for API calls
 */

import type { 
  User, 
  Child, 
  Session, 
  Report, 
  MLPrediction,
  AuthTokens,
  LoginCredentials,
  RegisterData,
  BotQuestion,
  BotAnswer,
  DashboardStats,
} from './models';

// ==================== GENERIC API RESPONSE ====================

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: ApiError;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

// ==================== AUTH API ====================

export interface LoginRequest {
  credentials: LoginCredentials;
}

export interface LoginResponse {
  user: User;
  tokens: AuthTokens;
}

export interface RegisterRequest {
  data: RegisterData;
}

export interface RegisterResponse {
  user: User;
  tokens: AuthTokens;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface RefreshTokenResponse {
  tokens: AuthTokens;
}

export interface TwoFactorRequest {
  userId: string;
  code: string;
}

export interface TwoFactorResponse {
  success: boolean;
  tokens?: AuthTokens;
}

// ==================== CHILDREN API ====================

export interface ChildListRequest {
  page?: number;
  pageSize?: number;
  search?: string;
  sortBy?: 'name' | 'age' | 'lastSession' | 'createdAt';
  sortOrder?: 'asc' | 'desc';
}

export interface ChildListResponse {
  children: PaginatedResponse<Child>;
}

export interface ChildCreateRequest {
  data: Partial<Child>;
}

export interface ChildCreateResponse {
  child: Child;
}

export interface ChildUpdateRequest {
  childId: string;
  data: Partial<Child>;
}

export interface ChildUpdateResponse {
  child: Child;
}

export interface ChildDetailRequest {
  childId: string;
}

export interface ChildDetailResponse {
  child: Child;
  sessions: Session[];
  reports: Report[];
}

// ==================== SESSION API ====================

export interface SessionCreateRequest {
  childId: string;
  gameType: string;
  language: string;
}

export interface SessionCreateResponse {
  session: Session;
}

export interface SessionUpdateRequest {
  sessionId: string;
  data: Partial<Session>;
}

export interface SessionUpdateResponse {
  session: Session;
}

export interface SessionCompleteRequest {
  sessionId: string;
  trials: any[];
  clinicianNotes?: string;
}

export interface SessionCompleteResponse {
  session: Session;
  metrics: any;
  prediction?: MLPrediction;
}

// ==================== ML API ====================

export interface MLPredictRequest {
  sessionId: string;
  features: any;
}

export interface MLPredictResponse {
  prediction: MLPrediction;
}

export interface MLFeaturesRequest {
  trials: any[];
  age: number;
  gender: string;
}

export interface MLFeaturesResponse {
  features: any;
}

// ==================== REPORTS API ====================

export interface ReportGenerateRequest {
  sessionId: string;
  botAnswers?: BotAnswer[];
  clinicianNotes?: string;
}

export interface ReportGenerateResponse {
  report: Report;
}

export interface ReportListRequest {
  page?: number;
  pageSize?: number;
  childId?: string;
  startDate?: Date;
  endDate?: Date;
}

export interface ReportListResponse {
  reports: PaginatedResponse<Report>;
}

export interface ReportExportRequest {
  reportId: string;
  format: 'pdf' | 'csv' | 'json';
}

export interface ReportExportResponse {
  url: string;
  filename: string;
}

// ==================== BOT API ====================

export interface BotQuestionsRequest {
  sessionId: string;
  language: string;
}

export interface BotQuestionsResponse {
  questions: BotQuestion[];
}

export interface BotSubmitRequest {
  sessionId: string;
  answers: BotAnswer[];
}

export interface BotSubmitResponse {
  success: boolean;
}

// ==================== DASHBOARD API ====================

export interface DashboardStatsRequest {
  startDate?: Date;
  endDate?: Date;
}

export interface DashboardStatsResponse {
  stats: DashboardStats;
}

// ==================== DATA SYNC API ====================

export interface DataSyncRequest {
  lastSyncTimestamp?: Date;
  data: {
    sessions?: Session[];
    children?: Child[];
  };
}

export interface DataSyncResponse {
  synced: {
    sessions: number;
    children: number;
  };
  conflicts?: any[];
}



