/**
 * Session Recorder - Logs all assessment data in JSON format
 * Captures: Game data, Questionnaire data, Clinical reflections
 */

import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface TrialLog {
  trial_no: number;
  stimulus: string;
  rule?: string;
  response: string;
  correct: boolean;
  rt_ms: number;
  timestamp: string;
}

export interface GameSummary {
  total_trials: number;
  correct: number;
  errors: number;
  mean_rt_ms: number;
  switch_cost_ms?: number;
  inhibition_errors?: number;
  accuracy_percent: number;
  recovery_trials?: number;
}

export interface SessionData {
  session_id: string;
  clinic_id?: string;
  clinician_id?: string;
  child: {
    child_id: string;
    name: string;
    age_years: number;
    gender: string;
    language: string;
    hospitalId?: string;
    hospitalName?: string;
  };
  assessment_type: string;
  timestamp_start: string;
  timestamp_end: string;
  device_id: string;
  questionnaire_data?: any;
  clinical_reflection?: any;
  game_data?: {
    total_trials: number;
    correct_responses: number;
    incorrect_responses: number;
    mean_rt_ms: number;
    switch_cost_ms?: number;
    inhibition_errors?: number;
    accuracy_percent: number;
    recovery_trials?: number;
    trials?: TrialLog[];
  };
  computed_summary?: {
    flexibility_index?: number;
    attention_index?: number;
    emotion_index?: number;
    overall_risk_estimate?: string;
    confidence?: number;
  };
}

/**
 * Records and logs a complete assessment session
 */
export const recordSession = async (data: {
  clinicId?: string;
  clinicianId?: string;
  child: any;
  assessmentType: string;
  gameSummary?: GameSummary;
  trialLogs?: TrialLog[];
  questionnaireData?: any;
  reflectionData?: any;
  riskEstimate?: any;
  startTime?: string;
  endTime?: string;
}): Promise<SessionData> => {
  const sessionId = `SESSION_${Date.now()}`;
  
  const session: SessionData = {
    session_id: sessionId,
    clinic_id: data.clinicId,
    clinician_id: data.clinicianId,
    child: {
      child_id: data.child.id,
      name: data.child.name,
      age_years: data.child.age,
      gender: data.child.gender,
      language: data.child.language,
      hospitalId: data.child.hospitalId,
      hospitalName: data.child.hospitalName,
    },
    assessment_type: data.assessmentType,
    timestamp_start: data.startTime || new Date().toISOString(),
    timestamp_end: data.endTime || new Date().toISOString(),
    device_id: `${Platform.OS}-${Platform.Version}`,
    questionnaire_data: data.questionnaireData,
    clinical_reflection: data.reflectionData,
  };

  // Add game data if available
  if (data.gameSummary) {
    session.game_data = {
      total_trials: data.gameSummary.total_trials,
      correct_responses: data.gameSummary.correct,
      incorrect_responses: data.gameSummary.errors,
      mean_rt_ms: data.gameSummary.mean_rt_ms,
      switch_cost_ms: data.gameSummary.switch_cost_ms,
      inhibition_errors: data.gameSummary.inhibition_errors,
      accuracy_percent: data.gameSummary.accuracy_percent,
      recovery_trials: data.gameSummary.recovery_trials,
      trials: data.trialLogs,
    };
  }

  // Add computed summary if available
  if (data.riskEstimate) {
    session.computed_summary = {
      flexibility_index: data.riskEstimate.flexibility_index,
      attention_index: data.riskEstimate.attention_index,
      emotion_index: data.riskEstimate.emotion_index,
      overall_risk_estimate: data.riskEstimate.risk_label || data.riskEstimate.riskLevel,
      confidence: data.riskEstimate.confidence,
    };
  }

  // 🔥 LOG TO CONSOLE - DATABASE READY JSON
  console.log('\n');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║                                                            ║');
  console.log('║           🎮 ASSESSMENT SESSION COMPLETE                  ║');
  console.log('║                                                            ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('\n📊 DATABASE-READY JSON (Copy this):');
  console.log('\n' + JSON.stringify(session, null, 2));
  console.log('\n✅ Assessment Type:', data.assessmentType);
  console.log('👶 Child:', data.child.name, '(Age:', data.child.age + ')');
  console.log('🏥 Hospital ID:', data.child.hospitalId || 'Not specified');
  if (data.gameSummary) {
    console.log('🎯 Accuracy:', data.gameSummary.accuracy_percent + '%');
    console.log('⏱️  Mean RT:', data.gameSummary.mean_rt_ms + 'ms');
  }
  console.log('\n════════════════════════════════════════════════════════════\n');

  // Store in AsyncStorage for later retrieval
  try {
    const existingSessions = await AsyncStorage.getItem('ASSESSMENT_SESSIONS');
    const sessions = existingSessions ? JSON.parse(existingSessions) : [];
    sessions.push(session);
    await AsyncStorage.setItem('ASSESSMENT_SESSIONS', JSON.stringify(sessions, null, 2));
  } catch (error) {
    console.error('Failed to store session:', error);
  }

  return session;
};

/**
 * Records game completion data
 */
export const recordGameCompletion = async (data: {
  child: any;
  gameType: string;
  gameResults: any;
  clinicianId?: string;
}): Promise<void> => {
  const gameData = {
    event: 'GAME_COMPLETED',
    timestamp: new Date().toISOString(),
    child: {
      id: data.child.id,
      name: data.child.name,
      age: data.child.age,
      hospitalId: data.child.hospitalId,
      hospitalName: data.child.hospitalName,
    },
    game: {
      type: data.gameType,
      results: data.gameResults,
    },
    clinician_id: data.clinicianId,
    success: true,
  };

  console.log('\n');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║                                                            ║');
  console.log('║           🎮 GAME COMPLETED                               ║');
  console.log('║                                                            ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('\n📊 DATABASE-READY JSON (Copy this):');
  console.log('\n' + JSON.stringify(gameData, null, 2));
  console.log('\n✅ Game Type:', data.gameType);
  console.log('👶 Child:', data.child.name);
  console.log('🏥 Hospital ID:', data.child.hospitalId || 'Not specified');
  console.log('\n════════════════════════════════════════════════════════════\n');
};

/**
 * Records questionnaire completion (AI Doctor Bot)
 */
export const recordQuestionnaireCompletion = async (data: {
  child: any;
  responses: any;
  summary: any;
  clinicianId?: string;
}): Promise<void> => {
  const questionnaireData = {
    event: 'QUESTIONNAIRE_COMPLETED',
    timestamp: new Date().toISOString(),
    child: {
      id: data.child.id,
      name: data.child.name,
      age: data.child.age,
      hospitalId: data.child.hospitalId,
      hospitalName: data.child.hospitalName,
    },
    questionnaire: {
      type: 'AI_DOCTOR_BOT',
      responses: data.responses,
      summary: data.summary,
    },
    clinician_id: data.clinicianId,
    success: true,
  };

  console.log('\n');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║                                                            ║');
  console.log('║           🤖 QUESTIONNAIRE COMPLETED                      ║');
  console.log('║                                                            ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('\n📊 DATABASE-READY JSON (Copy this):');
  console.log('\n' + JSON.stringify(questionnaireData, null, 2));
  console.log('\n✅ Questionnaire Type: AI Doctor Bot');
  console.log('👶 Child:', data.child.name);
  console.log('🏥 Hospital ID:', data.child.hospitalId || 'Not specified');
  console.log('📊 Risk Score:', data.summary.riskScore);
  console.log('📊 Risk Level:', data.summary.riskLevel);
  console.log('\n════════════════════════════════════════════════════════════\n');

  // Store in AsyncStorage
  try {
    const existingQuestionnaires = await AsyncStorage.getItem('QUESTIONNAIRE_RESPONSES');
    const questionnaires = existingQuestionnaires ? JSON.parse(existingQuestionnaires) : [];
    questionnaires.push(questionnaireData);
    await AsyncStorage.setItem('QUESTIONNAIRE_RESPONSES', JSON.stringify(questionnaires, null, 2));
  } catch (error) {
    console.error('Failed to store questionnaire:', error);
  }
};

/**
 * Records clinical reflection data
 */
export const recordClinicalReflection = async (data: {
  child: any;
  gameType: string;
  reflectionData: any;
  clinicianId?: string;
}): Promise<void> => {
  const reflectionRecord = {
    event: 'CLINICAL_REFLECTION_COMPLETED',
    timestamp: new Date().toISOString(),
    child: {
      id: data.child.id,
      name: data.child.name,
      age: data.child.age,
      hospitalId: data.child.hospitalId,
      hospitalName: data.child.hospitalName,
    },
    game_type: data.gameType,
    reflection: data.reflectionData,
    clinician_id: data.clinicianId,
    success: true,
  };

  console.log('\n');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║                                                            ║');
  console.log('║           🩺 CLINICAL REFLECTION COMPLETED                ║');
  console.log('║                                                            ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('\n📊 DATABASE-READY JSON (Copy this):');
  console.log('\n' + JSON.stringify(reflectionRecord, null, 2));
  console.log('\n✅ Game Type:', data.gameType);
  console.log('👶 Child:', data.child.name);
  console.log('🏥 Hospital ID:', data.child.hospitalId || 'Not specified');
  console.log('📝 Questions Answered:', Object.keys(data.reflectionData).length);
  console.log('\n════════════════════════════════════════════════════════════\n');

  // Store in AsyncStorage
  try {
    const existingReflections = await AsyncStorage.getItem('CLINICAL_REFLECTIONS');
    const reflections = existingReflections ? JSON.parse(existingReflections) : [];
    reflections.push(reflectionRecord);
    await AsyncStorage.setItem('CLINICAL_REFLECTIONS', JSON.stringify(reflections, null, 2));
  } catch (error) {
    console.error('Failed to store reflection:', error);
  }
};

/**
 * Get all stored sessions for export
 */
export const getAllSessions = async (): Promise<any> => {
  try {
    const sessions = await AsyncStorage.getItem('ASSESSMENT_SESSIONS');
    const questionnaires = await AsyncStorage.getItem('QUESTIONNAIRE_RESPONSES');
    const reflections = await AsyncStorage.getItem('CLINICAL_REFLECTIONS');

    return {
      sessions: sessions ? JSON.parse(sessions) : [],
      questionnaires: questionnaires ? JSON.parse(questionnaires) : [],
      reflections: reflections ? JSON.parse(reflections) : [],
    };
  } catch (error) {
    console.error('Failed to get sessions:', error);
    return {
      sessions: [],
      questionnaires: [],
      reflections: [],
    };
  }
};

/**
 * Export all session data as JSON string
 */
export const exportAllSessions = async (): Promise<string> => {
  const data = await getAllSessions();
  return JSON.stringify(data, null, 2);
};







