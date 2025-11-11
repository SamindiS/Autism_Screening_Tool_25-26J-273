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
  hospitalName?: string;
  role?: 'doctor' | 'admin';
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
      
      // Get registered users from AsyncStorage
      const registeredUsersData = await AsyncStorage.getItem('REGISTERED_USERS');
      const registeredUsers = registeredUsersData ? JSON.parse(registeredUsersData) : [];
      
      // Find user with matching email
      const foundUser = registeredUsers.find((u: any) => 
        u.email.toLowerCase() === email.toLowerCase()
      );
      
      if (!foundUser) {
        throw new Error('User not found. Please register first.');
      }
      
      // Validate password (in real app, this would be hashed)
      if (foundUser.password !== password) {
        throw new Error('Invalid password');
      }
      
      // Create user object from registered data
      const user: Clinician = {
        id: foundUser.id,
        username: foundUser.username,
        name: foundUser.fullName,
        fullName: foundUser.fullName,
        email: foundUser.email,
        role: foundUser.role,
        clinicId: foundUser.clinicId,
        hospitalName: foundUser.hospitalName,
        isActive: true,
        isVerified: true,
        twoFactorEnabled: false,
        lastLogin: new Date(),
        createdAt: new Date(foundUser.createdAt),
      };
      
      const token = 'token_' + Date.now();
      const refreshToken = 'refresh_token_' + Date.now();
      
      // Store tokens and user data
      await AsyncStorage.setItem(STORAGE_KEYS.authToken, token);
      await AsyncStorage.setItem(STORAGE_KEYS.refreshToken, refreshToken);
      await AsyncStorage.setItem(STORAGE_KEYS.user, JSON.stringify(user));
      
      // 🔥 LOG TO CONSOLE - DATABASE READY JSON
      const loginData = {
        event: 'CLINICIAN_LOGIN',
        timestamp: new Date().toISOString(),
        clinician: {
          id: user.id,
          username: user.username,
          fullName: user.fullName,
          email: user.email,
          role: user.role,
          clinicId: user.clinicId,
          hospitalId: user.clinicId, // Hospital ID
          hospitalName: user.hospitalName || 'Not specified',
        },
        authentication: {
          token: token,
          refreshToken: refreshToken,
          loginTime: new Date().toISOString(),
          expiresIn: '24h',
        },
        success: true,
      };

      console.log('\n');
      console.log('╔════════════════════════════════════════════════════════════╗');
      console.log('║                                                            ║');
      console.log('║           🔐 CLINICIAN LOGIN SUCCESS                      ║');
      console.log('║                                                            ║');
      console.log('╚════════════════════════════════════════════════════════════╝');
      console.log('\n📊 DATABASE-READY JSON (Copy this):');
      console.log('\n' + JSON.stringify(loginData, null, 2));
      console.log('\n✅ Stored in AsyncStorage → Key: CLINICIAN_LOGINS');
      console.log('🏥 Hospital ID:', user.clinicId);
      console.log('🏥 Hospital Name:', user.hospitalName || 'Not specified');
      console.log('👤 Clinician:', user.fullName);
      console.log('👤 Username:', user.username);
      console.log('📧 Email:', user.email);
      console.log('👔 Role:', user.role);
      console.log('\n════════════════════════════════════════════════════════════\n');

      // Also store for later retrieval
      const existingLogins = await AsyncStorage.getItem('CLINICIAN_LOGINS');
      const logins = existingLogins ? JSON.parse(existingLogins) : [];
      logins.push(loginData);
      await AsyncStorage.setItem('CLINICIAN_LOGINS', JSON.stringify(logins, null, 2));
      
      dispatch({
        type: 'LOGIN_SUCCESS',
        payload: { user: user, token: token, refreshToken: refreshToken },
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
        role: (data.role || 'doctor') as 'doctor' | 'admin' | 'clinician',
        clinicId: data.clinicId || 'clinic_001',
        hospitalName: data.hospitalName,
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
      
      // Store user credentials for login validation
      const registeredUsersData = await AsyncStorage.getItem('REGISTERED_USERS');
      const registeredUsers = registeredUsersData ? JSON.parse(registeredUsersData) : [];
      
      // Add new user to registered users list
      registeredUsers.push({
        id: mockUser.id,
        username: data.username,
        email: data.email,
        password: data.password, // In real app, this would be hashed
        fullName: data.fullName,
        role: data.role || 'doctor',
        clinicId: data.clinicId || 'clinic_001',
        hospitalName: data.hospitalName || 'Not specified',
        createdAt: new Date().toISOString(),
      });
      
      await AsyncStorage.setItem('REGISTERED_USERS', JSON.stringify(registeredUsers, null, 2));
      
      // 🔥 LOG TO CONSOLE - DATABASE READY JSON
      const registrationData = {
        event: 'CLINICIAN_REGISTRATION',
        timestamp: new Date().toISOString(),
        clinician: {
          id: mockUser.id,
          username: mockUser.username,
          fullName: mockUser.fullName,
          email: mockUser.email,
          role: mockUser.role,
          clinicId: mockUser.clinicId,
          hospitalId: mockUser.clinicId, // Hospital ID
          hospitalName: mockUser.hospitalName || 'Not specified',
        },
        hospital: {
          hospitalId: data.clinicId || 'clinic_001',
          hospitalName: data.hospitalName || 'Not specified',
        },
        registrationDetails: {
          username: data.username,
          email: data.email,
          fullName: data.fullName,
          role: data.role || 'doctor',
          registeredAt: new Date().toISOString(),
        },
        authentication: {
          token: mockToken,
          refreshToken: mockRefreshToken,
          expiresIn: '24h',
        },
        success: true,
      };

      console.log('\n');
      console.log('╔════════════════════════════════════════════════════════════╗');
      console.log('║                                                            ║');
      console.log('║        📝 CLINICIAN REGISTRATION SUCCESS                  ║');
      console.log('║                                                            ║');
      console.log('╚════════════════════════════════════════════════════════════╝');
      console.log('\n📊 DATABASE-READY JSON (Copy this):');
      console.log('\n' + JSON.stringify(registrationData, null, 2));
      console.log('\n✅ Stored in AsyncStorage → Keys: CLINICIAN_REGISTRATIONS, REGISTERED_USERS');
      console.log('🏥 Hospital ID:', data.clinicId || 'clinic_001');
      console.log('🏥 Hospital Name:', data.hospitalName || 'Not specified');
      console.log('👤 Clinician:', data.fullName);
      console.log('👤 Username:', data.username);
      console.log('📧 Email:', data.email);
      console.log('👔 Role:', data.role || 'doctor');
      console.log('✅ User can now login with these credentials!');
      console.log('\n════════════════════════════════════════════════════════════\n');

      // Also store for later retrieval
      const existingRegistrations = await AsyncStorage.getItem('CLINICIAN_REGISTRATIONS');
      const registrations = existingRegistrations ? JSON.parse(existingRegistrations) : [];
      registrations.push(registrationData);
      await AsyncStorage.setItem('CLINICIAN_REGISTRATIONS', JSON.stringify(registrations, null, 2));
      
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

