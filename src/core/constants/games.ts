/**
 * Game Type Constants
 * Game configurations and mappings
 */

export const GAME_TYPES = {
  GO_NO_GO: 'go_nogo',
  STROOP: 'stroop',
  DCCS: 'dccs',
} as const;

export type GameType = typeof GAME_TYPES[keyof typeof GAME_TYPES];

// Game metadata
export const GAME_INFO = {
  [GAME_TYPES.GO_NO_GO]: {
    id: GAME_TYPES.GO_NO_GO,
    name: 'Go/No-Go Task',
    description: 'Simple response inhibition task',
    ageGroup: '2-3',
    duration: 90, // seconds
    icon: '🐸',
    cognitiveSkills: ['Response Inhibition', 'Attention'],
  },
  [GAME_TYPES.STROOP]: {
    id: GAME_TYPES.STROOP,
    name: 'Day-Night Stroop',
    description: 'Inhibition and rule reversal task',
    ageGroup: '4-5',
    duration: 150, // seconds
    icon: '🌙',
    cognitiveSkills: ['Inhibitory Control', 'Rule Switching'],
  },
  [GAME_TYPES.DCCS]: {
    id: GAME_TYPES.DCCS,
    name: 'Dimensional Change Card Sort',
    description: 'Cognitive flexibility and rule switching',
    ageGroup: '5-6',
    duration: 240, // seconds
    icon: '🔷',
    cognitiveSkills: ['Cognitive Flexibility', 'Set Shifting', 'Rule Switching'],
  },
} as const;

// Map age groups to games
export const AGE_TO_GAME_MAP = {
  '2-3': GAME_TYPES.GO_NO_GO,
  '4-5': GAME_TYPES.STROOP,
  '5-6': GAME_TYPES.DCCS,
} as const;

// Get game type from age
export const getGameTypeForAge = (age: number): GameType => {
  if (age >= 2 && age <= 3) return GAME_TYPES.GO_NO_GO;
  if (age >= 4 && age <= 5) return GAME_TYPES.STROOP;
  if (age >= 5 && age <= 6) return GAME_TYPES.DCCS;
  
  // Default to Go/No-Go
  return GAME_TYPES.GO_NO_GO;
};



