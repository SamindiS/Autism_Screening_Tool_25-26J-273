import React, { createContext, useContext, useReducer, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Clinician } from '../types';
import { STORAGE_KEYS } from '../constants';

interface AuthState {
  isAuthenticated: boolean;
  user: Clinician | null;
  token: string | null;
  refreshToken: string | null;
  loading: boolean;
  error: string | null;
}

interface RegistrationData {
  username: string;
  email: string;
  password: string;
  fullName: string;
  clinicId?: string;
}

interface AuthContextType extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegistrationData) => Promise<void>;
  logout: () => Promise<void>;
  clearError: () => void;
  refreshToken: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

type AuthAction =
  | { type: 'LOGIN_START' }
  | { type: 'LOGIN_SUCCESS'; payload: { user: Clinician; token: string; refreshToken: string } }
  | { type: 'LOGIN_FAILURE'; payload: string }
  | { type: 'REGISTER_START' }
  | { type: 'REGISTER_SUCCESS'; payload: { user: Clinician; token: string; refreshToken: string } }
  | { type: 'REGISTER_FAILURE'; payload: string }
  | { type: 'LOGOUT' }
  | { type: 'CLEAR_ERROR' }
  | { type: 'SET_LOADING'; payload: boolean };

const authReducer = (state: AuthState, action: AuthAction): AuthState => {
  switch (action.type) {
    case 'LOGIN_START':
    case 'REGISTER_START':
      return {
        ...state,
        loading: true,
        error: null,
      };
    case 'LOGIN_SUCCESS':
    case 'REGISTER_SUCCESS':
      return {
        ...state,
        isAuthenticated: true,
        user: action.payload.user,
        token: action.payload.token,
        refreshToken: action.payload.refreshToken,
        loading: false,
        error: null,
      };
    case 'LOGIN_FAILURE':
    case 'REGISTER_FAILURE':
      return {
        ...state,
        isAuthenticated: false,
        user: null,
        token: null,
        refreshToken: null,
        loading: false,
        error: action.payload,
      };
    case 'LOGOUT':
      return {
        ...state,
        isAuthenticated: false,
        user: null,
        token: null,
        refreshToken: null,
        loading: false,
        error: null,
      };
    case 'CLEAR_ERROR':
      return {
        ...state,
        error: null,
      };
    case 'SET_LOADING':
      return {
        ...state,
        loading: action.payload,
      };
    default:
      return state;
  }
};

const initialState: AuthState = {
  isAuthenticated: false,
  user: null,
  token: null,
  refreshToken: null,
  loading: false,
  error: null,
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  useEffect(() => {
    checkAuthState();
  }, []);

  const checkAuthState = async () => {
    try {
      dispatch({ type: 'SET_LOADING', payload: true });
      
      const token = await AsyncStorage.getItem(STORAGE_KEYS.authToken);
      const refreshToken = await AsyncStorage.getItem(STORAGE_KEYS.refreshToken);
      const userData = await AsyncStorage.getItem(STORAGE_KEYS.user);
      
      if (token && userData) {
        const user = JSON.parse(userData);
        dispatch({
          type: 'LOGIN_SUCCESS',
          payload: { user, token, refreshToken: refreshToken || '' },
        });
      }
    } catch (error) {
      console.error('Auth check failed:', error);
      dispatch({ type: 'LOGOUT' });
    } finally {
      dispatch({ type: 'SET_LOADING', payload: false });
    }
  };

  const login = async (email: string, password: string) => {
    try {
      dispatch({ type: 'LOGIN_START' });
      
      // Mock authentication for demo purposes
      const mockUser: Clinician = {
        id: '1',
        username: 'testdoctor',
        name: 'Test Doctor',
        fullName: 'Test Doctor',
        email: email,
        role: 'clinician',
        clinicId: 'clinic_001',
        isActive: true,
        isVerified: true,
        twoFactorEnabled: false,
        lastLogin: new Date(),
        createdAt: new Date(),
      };
      
      const mockToken = 'mock_token_' + Date.now();
      const mockRefreshToken = 'mock_refresh_token_' + Date.now();
      
      // Store tokens and user data
      await AsyncStorage.setItem(STORAGE_KEYS.authToken, mockToken);
      await AsyncStorage.setItem(STORAGE_KEYS.refreshToken, mockRefreshToken);
      await AsyncStorage.setItem(STORAGE_KEYS.user, JSON.stringify(mockUser));
      
      dispatch({
        type: 'LOGIN_SUCCESS',
        payload: { user: mockUser, token: mockToken, refreshToken: mockRefreshToken },
      });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Login failed';
      dispatch({ type: 'LOGIN_FAILURE', payload: errorMessage });
      throw error;
    }
  };

  const register = async (data: RegistrationData) => {
    try {
      dispatch({ type: 'REGISTER_START' });
      
      // Mock registration for demo purposes
      const mockUser: Clinician = {
        id: Date.now().toString(),
        username: data.username,
        name: data.fullName,
        fullName: data.fullName,
        email: data.email,
        role: 'clinician',
        clinicId: data.clinicId || 'clinic_001',
        isActive: true,
        isVerified: true,
        twoFactorEnabled: false,
        lastLogin: new Date(),
        createdAt: new Date(),
      };
      
      const mockToken = 'mock_token_' + Date.now();
      const mockRefreshToken = 'mock_refresh_token_' + Date.now();
      
      // Store tokens and user data
      await AsyncStorage.setItem(STORAGE_KEYS.authToken, mockToken);
      await AsyncStorage.setItem(STORAGE_KEYS.refreshToken, mockRefreshToken);
      await AsyncStorage.setItem(STORAGE_KEYS.user, JSON.stringify(mockUser));
      
      dispatch({
        type: 'REGISTER_SUCCESS',
        payload: { user: mockUser, token: mockToken, refreshToken: mockRefreshToken },
      });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Registration failed';
      dispatch({ type: 'REGISTER_FAILURE', payload: errorMessage });
      throw error;
    }
  };

  const logout = async () => {
    try {
      // Clear local storage
      await AsyncStorage.multiRemove([
        STORAGE_KEYS.authToken,
        STORAGE_KEYS.refreshToken,
        STORAGE_KEYS.user,
      ]);
      
      dispatch({ type: 'LOGOUT' });
    } catch (error) {
      console.error('Logout failed:', error);
      // Still clear local storage even if there's an error
      await AsyncStorage.multiRemove([
        STORAGE_KEYS.authToken,
        STORAGE_KEYS.refreshToken,
        STORAGE_KEYS.user,
      ]);
      dispatch({ type: 'LOGOUT' });
    }
  };

  const clearError = () => {
    dispatch({ type: 'CLEAR_ERROR' });
  };

  const refreshToken = async () => {
    try {
      const currentRefreshToken = await AsyncStorage.getItem(STORAGE_KEYS.refreshToken);
      if (!currentRefreshToken) {
        throw new Error('No refresh token available');
      }

      // For mock authentication, just keep the existing tokens
      const userData = await AsyncStorage.getItem(STORAGE_KEYS.user);
      if (userData) {
        const user = JSON.parse(userData);
        const token = await AsyncStorage.getItem(STORAGE_KEYS.authToken);
        
        if (token) {
          dispatch({
            type: 'LOGIN_SUCCESS',
            payload: { user, token, refreshToken: currentRefreshToken },
          });
        }
      }
    } catch (error) {
      console.error('Token refresh failed:', error);
      dispatch({ type: 'LOGOUT' });
    }
  };

  const value: AuthContextType = {
    ...state,
    login,
    register,
    logout,
    clearError,
    refreshToken,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

