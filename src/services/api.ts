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
    
    const result = {
      user: mockUser,
      token: 'mock_token_' + Date.now(),
      refreshToken: 'mock_refresh_token_' + Date.now()
    };

    // Store login activity in DevTools-viewable format
    await this.logClinicianActivity('login', {
      clinician: mockUser,
      loginTime: new Date().toISOString(),
      email: email,
      success: true,
    });

    // Print to console immediately
    console.log('\n========================================');
    console.log('🔐 LOGIN SUCCESSFUL - DATA SAVED');
    console.log('========================================');
    console.log('📧 Email:', email);
    console.log('👤 Clinician:', mockUser.fullName);
    console.log('🏥 Clinic ID:', mockUser.clinicId);
    console.log('⏰ Login Time:', new Date().toISOString());
    console.log('========================================\n');
    
    // Print all stored data
    await this.printDataToConsole();
    
    return result;
  }

  async register(userData: {
    username: string;
    email: string;
    password: string;
    fullName: string;
    clinicId?: string;
    hospitalName?: string;
    role?: 'doctor' | 'admin';
  }): Promise<{ user: Clinician; token: string; refreshToken: string }> {
    // Mock response for demo purposes
    const mockUser: Clinician = {
      id: Date.now().toString(),
      username: userData.username,
      name: userData.fullName,
      fullName: userData.fullName,
      email: userData.email,
      role: (userData.role || 'doctor') as 'clinician' | 'admin',
      clinicId: userData.clinicId || 'clinic_001',
      hospitalName: userData.hospitalName,
      isActive: true,
      isVerified: true,
      twoFactorEnabled: false,
      lastLogin: new Date(),
      createdAt: new Date(),
    };
    
    const result = {
      user: mockUser,
      token: 'mock_token_' + Date.now(),
      refreshToken: 'mock_refresh_token_' + Date.now()
    };

    // Store registration activity in DevTools-viewable format
    await this.logClinicianActivity('register', {
      clinician: mockUser,
      registrationTime: new Date().toISOString(),
      registrationData: {
        username: userData.username,
        email: userData.email,
        fullName: userData.fullName,
        clinicId: userData.clinicId,
      },
      success: true,
    });

    // Print to console immediately
    console.log('\n========================================');
    console.log('📝 REGISTRATION SUCCESSFUL - DATA SAVED');
    console.log('========================================');
    console.log('👤 Username:', userData.username);
    console.log('📧 Email:', userData.email);
    console.log('📛 Full Name:', userData.fullName);
    console.log('🏥 Clinic ID:', userData.clinicId || 'clinic_001');
    console.log('⏰ Registration Time:', new Date().toISOString());
    console.log('========================================\n');
    
    // Print all stored data
    await this.printDataToConsole();
    
    return result;
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

  // ========================================
  // CLINICIAN ACTIVITY LOGGING (FOR DATABASE)
  // ========================================

  /**
   * Log clinician activity (login/register) in AsyncStorage
   * This data can be viewed in React Native DevTools and exported for database
   */
  private async logClinicianActivity(activityType: 'login' | 'register', data: any): Promise<void> {
    try {
      // Get existing activity log
      const existingLog = await AsyncStorage.getItem('CLINICIAN_ACTIVITY_LOG');
      const activityLog = existingLog ? JSON.parse(existingLog) : [];

      // Add new activity
      const newActivity = {
        id: Date.now().toString(),
        type: activityType,
        timestamp: new Date().toISOString(),
        data: data,
      };

      activityLog.push(newActivity);

      // Store updated log
      await AsyncStorage.setItem('CLINICIAN_ACTIVITY_LOG', JSON.stringify(activityLog, null, 2));

      // Also store individual records for easy access
      if (activityType === 'login') {
        await this.storeLoginRecord(data);
      } else if (activityType === 'register') {
        await this.storeRegistrationRecord(data);
      }

      console.log(`✅ ${activityType.toUpperCase()} activity logged successfully`);
      console.log(`💾 Data saved to AsyncStorage key: CLINICIAN_${activityType.toUpperCase()}S`);
      console.log(`📱 View in DevTools: Application → Storage → AsyncStorage`);
    } catch (error) {
      console.error('❌ Error logging clinician activity:', error);
    }
  }

  /**
   * Store login records separately
   */
  private async storeLoginRecord(loginData: any): Promise<void> {
    try {
      const existingLogins = await AsyncStorage.getItem('CLINICIAN_LOGINS');
      const logins = existingLogins ? JSON.parse(existingLogins) : [];

      logins.push({
        id: Date.now().toString(),
        clinicianId: loginData.clinician.id,
        email: loginData.email,
        name: loginData.clinician.fullName,
        role: loginData.clinician.role,
        clinicId: loginData.clinician.clinicId,
        loginTime: loginData.loginTime,
        success: loginData.success,
      });

      await AsyncStorage.setItem('CLINICIAN_LOGINS', JSON.stringify(logins, null, 2));
    } catch (error) {
      console.error('Error storing login record:', error);
    }
  }

  /**
   * Store registration records separately
   */
  private async storeRegistrationRecord(regData: any): Promise<void> {
    try {
      const existingRegistrations = await AsyncStorage.getItem('CLINICIAN_REGISTRATIONS');
      const registrations = existingRegistrations ? JSON.parse(existingRegistrations) : [];

      registrations.push({
        id: Date.now().toString(),
        clinicianId: regData.clinician.id,
        username: regData.registrationData.username,
        email: regData.registrationData.email,
        fullName: regData.registrationData.fullName,
        role: regData.clinician.role,
        clinicId: regData.registrationData.clinicId || regData.clinician.clinicId,
        registrationTime: regData.registrationTime,
        isActive: regData.clinician.isActive,
        isVerified: regData.clinician.isVerified,
        success: regData.success,
      });

      await AsyncStorage.setItem('CLINICIAN_REGISTRATIONS', JSON.stringify(registrations, null, 2));
    } catch (error) {
      console.error('Error storing registration record:', error);
    }
  }

  /**
   * Get all activity logs (for export)
   */
  async getAllActivityLogs(): Promise<any> {
    try {
      const activityLog = await AsyncStorage.getItem('CLINICIAN_ACTIVITY_LOG');
      const logins = await AsyncStorage.getItem('CLINICIAN_LOGINS');
      const registrations = await AsyncStorage.getItem('CLINICIAN_REGISTRATIONS');

      return {
        allActivity: activityLog ? JSON.parse(activityLog) : [],
        logins: logins ? JSON.parse(logins) : [],
        registrations: registrations ? JSON.parse(registrations) : [],
      };
    } catch (error) {
      console.error('Error getting activity logs:', error);
      return {
        allActivity: [],
        logins: [],
        registrations: [],
      };
    }
  }

  /**
   * Export all data as formatted JSON string
   */
  async exportClinicianDataAsJSON(): Promise<string> {
    try {
      const data = await this.getAllActivityLogs();
      return JSON.stringify(data, null, 2);
    } catch (error) {
      console.error('Error exporting data:', error);
      return '{}';
    }
  }

  /**
   * Clear all activity logs (use with caution)
   */
  async clearActivityLogs(): Promise<void> {
    try {
      await AsyncStorage.multiRemove([
        'CLINICIAN_ACTIVITY_LOG',
        'CLINICIAN_LOGINS',
        'CLINICIAN_REGISTRATIONS',
      ]);
      console.log('✅ All activity logs cleared');
    } catch (error) {
      console.error('Error clearing activity logs:', error);
    }
  }

  /**
   * Print all data to console in JSON format
   */
  async printDataToConsole(): Promise<void> {
    try {
      const data = await this.getAllActivityLogs();
      
      console.log('\n╔════════════════════════════════════════╗');
      console.log('║  📊 CLINICIAN DATA FOR DATABASE       ║');
      console.log('╚════════════════════════════════════════╝\n');
      
      console.log('📊 SUMMARY:');
      console.log(`   Total Activities: ${data.allActivity.length}`);
      console.log(`   Total Logins: ${data.logins.length}`);
      console.log(`   Total Registrations: ${data.registrations.length}\n`);
      
      console.log('📋 ALL ACTIVITY (Complete Log):');
      console.log(JSON.stringify(data.allActivity, null, 2));
      
      console.log('\n🔐 LOGINS ONLY (Database Ready):');
      console.log(JSON.stringify(data.logins, null, 2));
      
      console.log('\n📝 REGISTRATIONS ONLY (Database Ready):');
      console.log(JSON.stringify(data.registrations, null, 2));
      
      console.log('\n╔════════════════════════════════════════╗');
      console.log('║  ✅ Data logged successfully!         ║');
      console.log('║  📋 Copy JSON from above              ║');
      console.log('╚════════════════════════════════════════╝\n');
    } catch (error) {
      console.error('❌ Error printing data:', error);
    }
  }
}

export const apiService = new ApiService();
export default apiService;

