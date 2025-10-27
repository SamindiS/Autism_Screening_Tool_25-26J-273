import axios, { AxiosInstance, AxiosResponse } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { 
  Child, 
  Session, 
  Clinician, 
  MLPrediction, 
  Report
} from '../types';
import { API_ENDPOINTS, STORAGE_KEYS } from '../constants';

class ApiService {
  private api: AxiosInstance;
  private baseURL: string;

  constructor() {
    this.baseURL = API_ENDPOINTS.base;
    this.api = axios.create({
      baseURL: this.baseURL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor to add auth token
    this.api.interceptors.request.use(
      async (config) => {
        const token = await AsyncStorage.getItem(STORAGE_KEYS.authToken);
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Response interceptor to handle token refresh
    this.api.interceptors.response.use(
      (response) => response,
      async (error) => {
        const originalRequest = error.config;

        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;

          try {
            const refreshToken = await AsyncStorage.getItem(STORAGE_KEYS.refreshToken);
            if (refreshToken) {
              const response = await this.refreshAuthToken(refreshToken);
              const newToken = response.data.token;
              
              await AsyncStorage.setItem(STORAGE_KEYS.authToken, newToken);
              originalRequest.headers.Authorization = `Bearer ${newToken}`;
              
              return this.api(originalRequest);
            }
          } catch (refreshError) {
            // Refresh failed, redirect to login
            await this.logout();
            return Promise.reject(refreshError);
          }
        }

        return Promise.reject(error);
      }
    );
  }

  // Auth endpoints
  async login(email: string, password: string): Promise<{ user: Clinician; token: string; refreshToken: string }> {
    // Mock response for demo purposes
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
    
    return {
      user: mockUser,
      token: 'mock_token_' + Date.now(),
      refreshToken: 'mock_refresh_token_' + Date.now()
    };
  }

  async register(userData: {
    username: string;
    email: string;
    password: string;
    fullName: string;
    clinicId?: string;
  }): Promise<{ user: Clinician; token: string; refreshToken: string }> {
    // Mock response for demo purposes
    const mockUser: Clinician = {
      id: Date.now().toString(),
      username: userData.username,
      name: userData.fullName,
      fullName: userData.fullName,
      email: userData.email,
      role: 'clinician',
      clinicId: userData.clinicId || 'clinic_001',
      isActive: true,
      isVerified: true,
      twoFactorEnabled: false,
      lastLogin: new Date(),
      createdAt: new Date(),
    };
    
    return {
      user: mockUser,
      token: 'mock_token_' + Date.now(),
      refreshToken: 'mock_refresh_token_' + Date.now()
    };
  }

  async logout(): Promise<void> {
    // Mock logout - just clear local storage
    await AsyncStorage.multiRemove([
      STORAGE_KEYS.authToken,
      STORAGE_KEYS.refreshToken,
      STORAGE_KEYS.user,
    ]);
  }

  async refreshAuthToken(refreshToken: string): Promise<AxiosResponse<{ token: string }>> {
    // For mock authentication, return a mock response
    return Promise.resolve({
      data: { token: 'mock_token_' + Date.now() },
      status: 200,
      statusText: 'OK',
      headers: {},
      config: {} as any
    } as AxiosResponse<{ token: string }>);
  }

  // Children endpoints
  async getChildren(): Promise<Child[]> {
    try {
      const response = await this.api.get(API_ENDPOINTS.children.list);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async createChild(child: Omit<Child, 'id' | 'createdAt' | 'updatedAt'>): Promise<Child> {
    try {
      const response = await this.api.post(API_ENDPOINTS.children.create, child);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getChild(id: string): Promise<Child> {
    try {
      const response = await this.api.get(API_ENDPOINTS.children.get.replace(':id', id));
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async updateChild(id: string, child: Partial<Child>): Promise<Child> {
    try {
      const response = await this.api.put(API_ENDPOINTS.children.update.replace(':id', id), child);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async deleteChild(id: string): Promise<void> {
    try {
      await this.api.delete(API_ENDPOINTS.children.delete.replace(':id', id));
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Session endpoints
  async getSessions(childId?: string): Promise<Session[]> {
    try {
      const url = childId 
        ? `${API_ENDPOINTS.sessions.list}?childId=${childId}`
        : API_ENDPOINTS.sessions.list;
      const response = await this.api.get(url);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async createSession(session: Omit<Session, 'id' | 'startTime' | 'endTime'>): Promise<Session> {
    try {
      const response = await this.api.post(API_ENDPOINTS.sessions.create, session);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async getSession(id: string): Promise<Session> {
    try {
      const response = await this.api.get(API_ENDPOINTS.sessions.get.replace(':id', id));
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async updateSession(id: string, session: Partial<Session>): Promise<Session> {
    try {
      const response = await this.api.put(API_ENDPOINTS.sessions.update.replace(':id', id), session);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async deleteSession(id: string): Promise<void> {
    try {
      await this.api.delete(API_ENDPOINTS.sessions.delete.replace(':id', id));
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // ML endpoints
  async predictRisk(sessionData: any): Promise<MLPrediction> {
    try {
      const response = await this.api.post(API_ENDPOINTS.ml.predict, sessionData);
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async trainModel(trainingData: any): Promise<void> {
    try {
      await this.api.post(API_ENDPOINTS.ml.train, trainingData);
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Report endpoints
  async generateReport(sessionId: string): Promise<Report> {
    try {
      const response = await this.api.post(API_ENDPOINTS.reports.generate, { sessionId });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  async downloadReport(reportId: string): Promise<Blob> {
    try {
      const response = await this.api.get(API_ENDPOINTS.reports.download.replace(':id', reportId), {
        responseType: 'blob',
      });
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  // Utility methods
  private handleError(error: any): Error {
    if (error.response) {
      // Server responded with error status
      const message = error.response.data?.message || 'Server error occurred';
      return new Error(message);
    } else if (error.request) {
      // Network error
      return new Error('Network error. Please check your connection.');
    } else {
      // Other error
      return new Error(error.message || 'An unexpected error occurred');
    }
  }

  // Health check
  async healthCheck(): Promise<boolean> {
    try {
      await this.api.get('/health');
      return true;
    } catch (error) {
      return false;
    }
  }
}

export const apiService = new ApiService();
export default apiService;

