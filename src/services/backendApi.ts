/**
 * Backend API Service
 * Handles communication with Node.js/Firebase backend
 */

import axios, { AxiosInstance, AxiosError } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Backend API URL (update for production)
const API_BASE_URL = __DEV__
  ? 'http://localhost:3000/api'  // Development (local server)
  : 'https://your-app.com/api';  // Production (deployed server)

// For Android emulator, use 10.0.2.2 instead of localhost
const getBaseURL = () => {
  if (__DEV__) {
    // For Android emulator
    // return 'http://10.0.2.2:3000/api';
    
    // For iOS simulator or physical device on same network
    return 'http://localhost:3000/api';
  }
  return 'https://your-app.com/api';
};

class BackendApiService {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: getBaseURL(),
      timeout: 30000, // 30 seconds
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor (add auth token if needed)
    this.client.interceptors.request.use(
      async (config) => {
        // Add authentication token if available
        const token = await AsyncStorage.getItem('AUTH_TOKEN');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        console.error('❌ Request error:', error);
        return Promise.reject(error);
      }
    );

    // Response interceptor (handle errors)
    this.client.interceptors.response.use(
      (response) => {
        // Log successful responses in dev mode
        if (__DEV__) {
          console.log('✅ API Response:', {
            method: response.config.method?.toUpperCase(),
            url: response.config.url,
            status: response.status,
            data: response.data,
          });
        }
        return response;
      },
      (error: AxiosError) => {
        // Log errors
        console.error('❌ API Error:', {
          method: error.config?.method?.toUpperCase(),
          url: error.config?.url,
          status: error.response?.status,
          data: error.response?.data,
        });
        return Promise.reject(error);
      }
    );
  }

  /**
   * Health check - Test if backend is online
   */
  async healthCheck() {
    try {
      const response = await this.client.get('/health');
      console.log('🟢 Backend connected:', response.data);
      return response.data;
    } catch (error) {
      console.error('🔴 Backend connection failed:', error);
      throw error;
    }
  }

  /**
   * Upload session data
   */
  async uploadSession(sessionData: any) {
    try {
      console.log('📤 Uploading session:', sessionData.session_id);
      console.log('📊 Session data:', JSON.stringify(sessionData, null, 2));
      
      const response = await this.client.post('/sessions', sessionData);
      
      console.log('✅ Session uploaded:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Session upload failed:', error.message);
      
      // Don't throw error - allow offline mode
      return {
        success: false,
        offline: true,
        error: error.message,
      };
    }
  }

  /**
   * Get session data
   */
  async getSession(sessionId: string, clinicId: string, childId: string) {
    try {
      const response = await this.client.get(`/sessions/${sessionId}`, {
        params: { clinicId, childId },
      });
      
      console.log('✅ Session retrieved:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Get session failed:', error.message);
      throw error;
    }
  }

  /**
   * Get session trials from Storage
   */
  async getSessionTrials(sessionId: string) {
    try {
      const response = await this.client.get(`/sessions/${sessionId}/trials`);
      
      console.log('✅ Trials retrieved:', response.data.data.count, 'trials');
      return response.data;
    } catch (error: any) {
      console.error('❌ Get trials failed:', error.message);
      throw error;
    }
  }

  /**
   * Get all sessions for a child
   */
  async getChildSessions(childId: string, clinicId: string) {
    try {
      const response = await this.client.get(`/sessions/child/${childId}`, {
        params: { clinicId },
      });
      
      console.log('✅ Child sessions retrieved:', response.data.data.count);
      return response.data;
    } catch (error: any) {
      console.error('❌ Get child sessions failed:', error.message);
      throw error;
    }
  }

  /**
   * Upload child profile
   */
  async uploadChild(childData: any) {
    try {
      console.log('📤 Uploading child:', childData.name);
      console.log('📊 Child data:', JSON.stringify(childData, null, 2));
      
      const response = await this.client.post('/children', childData);
      
      console.log('✅ Child uploaded:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Child upload failed:', error.message);
      
      // Don't throw error - allow offline mode
      return {
        success: false,
        offline: true,
        error: error.message,
      };
    }
  }

  /**
   * Get all children for a clinic
   */
  async getChildren(clinicId: string) {
    try {
      const response = await this.client.get('/children', {
        params: { clinicId },
      });
      
      console.log('✅ Children retrieved:', response.data.data.count);
      return response.data;
    } catch (error: any) {
      console.error('❌ Get children failed:', error.message);
      throw error;
    }
  }

  /**
   * Get a specific child
   */
  async getChild(childId: string, clinicId: string) {
    try {
      const response = await this.client.get(`/children/${childId}`, {
        params: { clinicId },
      });
      
      console.log('✅ Child retrieved:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Get child failed:', error.message);
      throw error;
    }
  }

  /**
   * Update child profile
   */
  async updateChild(childId: string, updateData: any) {
    try {
      const response = await this.client.put(`/children/${childId}`, updateData);
      
      console.log('✅ Child updated:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Update child failed:', error.message);
      throw error;
    }
  }

  /**
   * Delete child profile
   */
  async deleteChild(childId: string, clinicId: string) {
    try {
      const response = await this.client.delete(`/children/${childId}`, {
        params: { clinicId },
      });
      
      console.log('✅ Child deleted:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Delete child failed:', error.message);
      throw error;
    }
  }

  /**
   * Trigger ML prediction for a session
   */
  async triggerMLPrediction(
    sessionId: string,
    clinicId: string,
    childId: string,
    useHeuristic = false
  ) {
    try {
      console.log('🤖 Triggering ML prediction for:', sessionId);
      
      const response = await this.client.post('/ml/predict', {
        sessionId,
        clinicId,
        childId,
        useHeuristic,
      });
      
      console.log('✅ ML prediction:', response.data.data.prediction);
      console.log('📊 Prediction details:', JSON.stringify(response.data, null, 2));
      
      return response.data;
    } catch (error: any) {
      console.error('❌ ML prediction failed:', error.message);
      
      // Return a fallback prediction
      return {
        success: false,
        offline: true,
        data: {
          prediction: {
            riskLevel: 'moderate',
            confidence: 0.5,
            drivers: ['Unable to compute - backend offline'],
            modelVersion: 'offline_fallback',
            predictedAt: new Date().toISOString(),
          },
        },
      };
    }
  }

  /**
   * Trigger batch ML predictions
   */
  async triggerBatchMLPrediction(
    sessionIds: string[],
    clinicId: string,
    childId: string
  ) {
    try {
      console.log(`🤖 Triggering batch ML prediction for ${sessionIds.length} sessions`);
      
      const response = await this.client.post('/ml/batch-predict', {
        sessionIds,
        clinicId,
        childId,
      });
      
      console.log('✅ Batch prediction completed:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Batch prediction failed:', error.message);
      throw error;
    }
  }

  /**
   * Get ML statistics for a clinic
   */
  async getMLStats(clinicId: string) {
    try {
      const response = await this.client.get('/ml/stats', {
        params: { clinicId },
      });
      
      console.log('✅ ML stats retrieved:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('❌ Get ML stats failed:', error.message);
      throw error;
    }
  }

  /**
   * Check if backend is online
   */
  async isOnline(): Promise<boolean> {
    try {
      await this.healthCheck();
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * Sync pending data (for offline-first functionality)
   */
  async syncPendingData() {
    try {
      // Get pending sessions from AsyncStorage
      const pendingSessionsStr = await AsyncStorage.getItem('PENDING_SESSIONS');
      if (!pendingSessionsStr) {
        console.log('✅ No pending sessions to sync');
        return { success: true, synced: 0 };
      }

      const pendingSessions = JSON.parse(pendingSessionsStr);
      console.log(`🔄 Syncing ${pendingSessions.length} pending sessions`);

      let syncedCount = 0;
      const failedSessions = [];

      for (const session of pendingSessions) {
        try {
          await this.uploadSession(session);
          syncedCount++;
        } catch (error) {
          failedSessions.push(session);
        }
      }

      // Update pending sessions (keep only failed ones)
      if (failedSessions.length > 0) {
        await AsyncStorage.setItem('PENDING_SESSIONS', JSON.stringify(failedSessions));
      } else {
        await AsyncStorage.removeItem('PENDING_SESSIONS');
      }

      console.log(`✅ Sync complete: ${syncedCount} synced, ${failedSessions.length} failed`);

      return {
        success: true,
        synced: syncedCount,
        failed: failedSessions.length,
      };
    } catch (error: any) {
      console.error('❌ Sync failed:', error.message);
      throw error;
    }
  }
}

// Export singleton instance
export const backendApi = new BackendApiService();
export default backendApi;






