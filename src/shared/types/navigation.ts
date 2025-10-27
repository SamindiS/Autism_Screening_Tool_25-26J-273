/**
 * Navigation Types
 * Type-safe navigation parameters and props
 */

import type { StackScreenProps } from '@react-navigation/stack';
import type { CompositeScreenProps } from '@react-navigation/native';
import type { Child, Session } from './models';

// ==================== ROOT NAVIGATOR ====================

export type RootStackParamList = {
  Splash: undefined;
  Auth: undefined;
  Main: undefined;
};

export type RootStackScreenProps<T extends keyof RootStackParamList> = 
  StackScreenProps<RootStackParamList, T>;

// ==================== AUTH NAVIGATOR ====================

export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  TwoFactor: {
    userId: string;
    email: string;
  };
  ForgotPassword: undefined;
  ResetPassword: {
    token: string;
  };
};

export type AuthStackScreenProps<T extends keyof AuthStackParamList> = 
  CompositeScreenProps<
    StackScreenProps<AuthStackParamList, T>,
    RootStackScreenProps<keyof RootStackParamList>
  >;

// ==================== MAIN NAVIGATOR ====================

export type MainStackParamList = {
  Dashboard: undefined;
  
  // Children
  ChildrenList: undefined;
  ChildDetail: {
    childId: string;
  };
  ChildRegistration: {
    mode?: 'create' | 'edit';
    childId?: string;
  };
  
  // Assessment
  AgeSelection: {
    childId: string;
  };
  GameInstructions: {
    childId: string;
    gameType: string;
  };
  Game: {
    sessionId: string;
  };
  GameResults: {
    sessionId: string;
  };
  
  // Reports
  ReportsList: undefined;
  ReportDetail: {
    reportId: string;
  };
  ReportExport: {
    reportId: string;
  };
  
  // AI Bot
  BotQuestions: {
    sessionId: string;
  };
  
  // Settings
  Settings: undefined;
  Profile: undefined;
  Language: undefined;
  About: undefined;
};

export type MainStackScreenProps<T extends keyof MainStackParamList> = 
  CompositeScreenProps<
    StackScreenProps<MainStackParamList, T>,
    RootStackScreenProps<keyof RootStackParamList>
  >;

// ==================== ASSESSMENT NAVIGATOR ====================

export type AssessmentStackParamList = {
  SelectChild: undefined;
  AgeSelection: {
    child: Child;
  };
  Instructions: {
    child: Child;
    gameType: string;
  };
  Game: {
    sessionId: string;
    child: Child;
  };
  Results: {
    session: Session;
  };
  BotQuestions: {
    session: Session;
  };
  Report: {
    sessionId: string;
  };
};

export type AssessmentStackScreenProps<T extends keyof AssessmentStackParamList> = 
  StackScreenProps<AssessmentStackParamList, T>;

// ==================== SCREEN PROPS HELPERS ====================

// Helper type for screens with navigation
export interface ScreenProps<T extends keyof MainStackParamList> {
  navigation: MainStackScreenProps<T>['navigation'];
  route: MainStackScreenProps<T>['route'];
}

// Helper type for Auth screens
export interface AuthScreenProps<T extends keyof AuthStackParamList> {
  navigation: AuthStackScreenProps<T>['navigation'];
  route: AuthStackScreenProps<T>['route'];
}

// ==================== NAVIGATION HELPER TYPES ====================

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}



