import React, { createContext, useContext, useReducer, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppConfig, Language } from '../types';
import { STORAGE_KEYS, LANGUAGES } from '../constants';

interface AppState {
  config: AppConfig;
  currentLanguage: Language;
  isOnline: boolean;
  theme: 'light' | 'dark';
}

interface AppContextType extends AppState {
  updateConfig: (config: Partial<AppConfig>) => void;
  setLanguage: (language: Language) => void;
  setTheme: (theme: 'light' | 'dark') => void;
  setOnlineStatus: (isOnline: boolean) => void;
  resetConfig: () => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

type AppAction =
  | { type: 'UPDATE_CONFIG'; payload: Partial<AppConfig> }
  | { type: 'SET_LANGUAGE'; payload: Language }
  | { type: 'SET_THEME'; payload: 'light' | 'dark' }
  | { type: 'SET_ONLINE_STATUS'; payload: boolean }
  | { type: 'RESET_CONFIG' };

const appReducer = (state: AppState, action: AppAction): AppState => {
  switch (action.type) {
    case 'UPDATE_CONFIG':
      return {
        ...state,
        config: { ...state.config, ...action.payload },
      };
    case 'SET_LANGUAGE':
      return {
        ...state,
        currentLanguage: action.payload,
        config: { ...state.config, language: action.payload.code },
      };
    case 'SET_THEME':
      return {
        ...state,
        theme: action.payload,
        config: { ...state.config, theme: action.payload },
      };
    case 'SET_ONLINE_STATUS':
      return {
        ...state,
        isOnline: action.payload,
      };
    case 'RESET_CONFIG':
      return {
        ...state,
        config: getDefaultConfig(),
        currentLanguage: LANGUAGES.en,
        theme: 'light',
      };
    default:
      return state;
  }
};

const getDefaultConfig = (): AppConfig => ({
  audio: {
    enabled: true,
    volume: 0.8,
    language: 'en',
  },
  haptic: {
    enabled: true,
    intensity: 'medium',
  },
  theme: 'light',
  language: 'en',
  maxSessionDuration: 5,
  autoSave: true,
});

const initialState: AppState = {
  config: getDefaultConfig(),
  currentLanguage: LANGUAGES.en,
  isOnline: true,
  theme: 'light',
};

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);

  useEffect(() => {
    loadAppConfig();
  }, []);

  const loadAppConfig = async () => {
    try {
      const savedConfig = await AsyncStorage.getItem(STORAGE_KEYS.settings);
      const savedLanguage = await AsyncStorage.getItem(STORAGE_KEYS.language);
      const savedTheme = await AsyncStorage.getItem(STORAGE_KEYS.theme);

      if (savedConfig) {
        const config = JSON.parse(savedConfig);
        dispatch({ type: 'UPDATE_CONFIG', payload: config });
      }

      if (savedLanguage) {
        const language = LANGUAGES[savedLanguage as keyof typeof LANGUAGES];
        if (language) {
          dispatch({ type: 'SET_LANGUAGE', payload: language });
        }
      }

      if (savedTheme) {
        dispatch({ type: 'SET_THEME', payload: savedTheme as 'light' | 'dark' });
      }
    } catch (error) {
      console.error('Failed to load app config:', error);
    }
  };

  const updateConfig = async (config: Partial<AppConfig>) => {
    try {
      dispatch({ type: 'UPDATE_CONFIG', payload: config });
      await AsyncStorage.setItem(STORAGE_KEYS.settings, JSON.stringify(config));
    } catch (error) {
      console.error('Failed to update config:', error);
    }
  };

  const setLanguage = async (language: Language) => {
    try {
      dispatch({ type: 'SET_LANGUAGE', payload: language });
      await AsyncStorage.setItem(STORAGE_KEYS.language, language.code);
    } catch (error) {
      console.error('Failed to set language:', error);
    }
  };

  const setTheme = async (theme: 'light' | 'dark') => {
    try {
      dispatch({ type: 'SET_THEME', payload: theme });
      await AsyncStorage.setItem(STORAGE_KEYS.theme, theme);
    } catch (error) {
      console.error('Failed to set theme:', error);
    }
  };

  const setOnlineStatus = (isOnline: boolean) => {
    dispatch({ type: 'SET_ONLINE_STATUS', payload: isOnline });
  };

  const resetConfig = async () => {
    try {
      dispatch({ type: 'RESET_CONFIG' });
      await AsyncStorage.multiRemove([
        STORAGE_KEYS.settings,
        STORAGE_KEYS.language,
        STORAGE_KEYS.theme,
      ]);
    } catch (error) {
      console.error('Failed to reset config:', error);
    }
  };

  const value: AppContextType = {
    ...state,
    updateConfig,
    setLanguage,
    setTheme,
    setOnlineStatus,
    resetConfig,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
};

export const useApp = (): AppContextType => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};

