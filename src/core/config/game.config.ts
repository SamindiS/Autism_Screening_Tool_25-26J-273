/**
 * Game Configuration
 * Parameters for each game/assessment
 */

import { GAME_TYPES } from '../constants';
import type { GameType } from '../constants';

export interface GameConfig {
  practiceTrials: number;
  mainTrials: number;
  switchPoint?: number; // For rule-switching games
  stimulusDuration: number; // milliseconds
  responseTimeout: number; // milliseconds
  feedbackDuration: number; // milliseconds
  interTrialInterval: number; // milliseconds
  maxErrors?: number; // Optional limit on consecutive errors
  successCriteria?: number; // Number of correct trials to proceed
}

// Game configurations
export const gameConfigs: Record<GameType, GameConfig> = {
  // Go/No-Go Game (Ages 2-3)
  [GAME_TYPES.GO_NO_GO]: {
    practiceTrials: 4,
    mainTrials: 20,
    stimulusDuration: 2000, // 2 seconds
    responseTimeout: 3000, // 3 seconds
    feedbackDuration: 500, // 0.5 seconds
    interTrialInterval: 1000, // 1 second
    maxErrors: 3, // Stop after 3 consecutive errors
    successCriteria: 3, // Need 3 correct in practice
  },
  
  // Day-Night Stroop (Ages 4-5)
  [GAME_TYPES.STROOP]: {
    practiceTrials: 6,
    mainTrials: 24,
    switchPoint: 12, // Switch rule at trial 12
    stimulusDuration: 2000, // 2 seconds
    responseTimeout: 4000, // 4 seconds
    feedbackDuration: 500, // 0.5 seconds
    interTrialInterval: 1000, // 1 second
    maxErrors: 3,
    successCriteria: 4,
  },
  
  // DCCS (Ages 5-6)
  [GAME_TYPES.DCCS]: {
    practiceTrials: 6,
    mainTrials: 30,
    switchPoint: 15, // Switch dimension at trial 15
    stimulusDuration: 2500, // 2.5 seconds
    responseTimeout: 5000, // 5 seconds
    feedbackDuration: 500, // 0.5 seconds
    interTrialInterval: 1000, // 1 second
    maxErrors: 3,
    successCriteria: 5,
  },
};

// Stimulus configurations
export const stimulusConfig = {
  [GAME_TYPES.GO_NO_GO]: {
    go: {
      type: 'frog',
      image: '🐸',
      color: '#66BB6A',
      frequency: 0.7, // 70% of trials
    },
    noGo: {
      type: 'rock',
      image: '🪨',
      color: '#8D6E63',
      frequency: 0.3, // 30% of trials
    },
  },
  
  [GAME_TYPES.STROOP]: {
    day: {
      image: '☀️',
      response: 'night', // Say opposite
      color: '#FFD54F',
    },
    night: {
      image: '🌙',
      response: 'day', // Say opposite
      color: '#7986CB',
    },
  },
  
  [GAME_TYPES.DCCS]: {
    shapes: ['circle', 'square'],
    colors: ['red', 'blue'],
    dimensions: ['color', 'shape'],
  },
};

// Scoring parameters
export const scoringConfig = {
  correctResponse: 10,
  incorrectResponse: 0,
  noResponse: -5,
  switchCostThreshold: 200, // milliseconds
  perseverativeErrorThreshold: 3,
  
  // Risk level thresholds (based on research literature)
  riskThresholds: {
    accuracy: {
      low: 0.8, // >80% accuracy
      moderate: 0.6, // 60-80% accuracy
      high: 0.6, // <60% accuracy
    },
    switchCost: {
      low: 250, // <250ms switch cost
      moderate: 500, // 250-500ms
      high: 500, // >500ms
    },
    errorRate: {
      low: 0.2, // <20% errors
      moderate: 0.4, // 20-40%
      high: 0.4, // >40%
    },
  },
};

export default gameConfigs;



