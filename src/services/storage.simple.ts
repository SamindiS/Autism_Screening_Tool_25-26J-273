import AsyncStorage from '@react-native-async-storage/async-storage';
import { Child, Session } from '../types';
import { STORAGE_KEYS } from '../constants';

class SimpleStorageService {
  async initialize(): Promise<void> {
    // No initialization needed for AsyncStorage
    console.log('SimpleStorageService initialized');
  }

  // Children CRUD operations
  async saveChild(child: Child): Promise<void> {
    try {
      const children = await this.getChildren();
      const existingIndex = children.findIndex(c => c.id === child.id);
      
      if (existingIndex >= 0) {
        children[existingIndex] = child;
      } else {
        children.push(child);
      }
      
      await AsyncStorage.setItem('children', JSON.stringify(children));
    } catch (error) {
      console.error('Failed to save child:', error);
      throw error;
    }
  }

  async getChildren(): Promise<Child[]> {
    try {
      const childrenData = await AsyncStorage.getItem('children');
      return childrenData ? JSON.parse(childrenData) : [];
    } catch (error) {
      console.error('Failed to get children:', error);
      return [];
    }
  }

  async getChild(id: string): Promise<Child | null> {
    try {
      const children = await this.getChildren();
      return children.find(c => c.id === id) || null;
    } catch (error) {
      console.error('Failed to get child:', error);
      return null;
    }
  }

  async deleteChild(id: string): Promise<void> {
    try {
      const children = await this.getChildren();
      const filteredChildren = children.filter(c => c.id !== id);
      await AsyncStorage.setItem('children', JSON.stringify(filteredChildren));
    } catch (error) {
      console.error('Failed to delete child:', error);
      throw error;
    }
  }

  // Session CRUD operations
  async saveSession(session: Session): Promise<void> {
    try {
      const sessions = await this.getSessions();
      const existingIndex = sessions.findIndex(s => s.id === session.id);
      
      if (existingIndex >= 0) {
        sessions[existingIndex] = session;
      } else {
        sessions.push(session);
      }
      
      await AsyncStorage.setItem('sessions', JSON.stringify(sessions));
    } catch (error) {
      console.error('Failed to save session:', error);
      throw error;
    }
  }

  async getSessions(childId?: string): Promise<Session[]> {
    try {
      const sessionsData = await AsyncStorage.getItem('sessions');
      const sessions = sessionsData ? JSON.parse(sessionsData) : [];
      
      if (childId) {
        return sessions.filter((s: Session) => s.childId === childId);
      }
      
      return sessions;
    } catch (error) {
      console.error('Failed to get sessions:', error);
      return [];
    }
  }

  async getSession(id: string): Promise<Session | null> {
    try {
      const sessions = await this.getSessions();
      return sessions.find(s => s.id === id) || null;
    } catch (error) {
      console.error('Failed to get session:', error);
      return null;
    }
  }

  async deleteSession(id: string): Promise<void> {
    try {
      const sessions = await this.getSessions();
      const filteredSessions = sessions.filter(s => s.id !== id);
      await AsyncStorage.setItem('sessions', JSON.stringify(filteredSessions));
    } catch (error) {
      console.error('Failed to delete session:', error);
      throw error;
    }
  }

  // Offline data management
  async saveOfflineData(type: string, data: any): Promise<void> {
    try {
      const offlineData = await this.getOfflineData();
      const newItem = {
        id: `${type}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        type,
        data,
        createdAt: new Date().toISOString(),
        synced: false,
      };
      
      offlineData.push(newItem);
      await AsyncStorage.setItem('offline_data', JSON.stringify(offlineData));
    } catch (error) {
      console.error('Failed to save offline data:', error);
      throw error;
    }
  }

  async getOfflineData(type?: string): Promise<any[]> {
    try {
      const offlineData = await AsyncStorage.getItem('offline_data');
      const data = offlineData ? JSON.parse(offlineData) : [];
      
      if (type) {
        return data.filter((item: any) => item.type === type && !item.synced);
      }
      
      return data.filter((item: any) => !item.synced);
    } catch (error) {
      console.error('Failed to get offline data:', error);
      return [];
    }
  }

  async markDataAsSynced(id: string): Promise<void> {
    try {
      const offlineData = await AsyncStorage.getItem('offline_data');
      const data = offlineData ? JSON.parse(offlineData) : [];
      
      const item = data.find((item: any) => item.id === id);
      if (item) {
        item.synced = true;
        await AsyncStorage.setItem('offline_data', JSON.stringify(data));
      }
    } catch (error) {
      console.error('Failed to mark data as synced:', error);
      throw error;
    }
  }

  // AsyncStorage methods for simple key-value storage
  async setItem(key: string, value: any): Promise<void> {
    try {
      await AsyncStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error('Failed to set item:', error);
      throw error;
    }
  }

  async getItem(key: string): Promise<any> {
    try {
      const value = await AsyncStorage.getItem(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('Failed to get item:', error);
      throw error;
    }
  }

  async removeItem(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error('Failed to remove item:', error);
      throw error;
    }
  }

  async clear(): Promise<void> {
    try {
      await AsyncStorage.clear();
    } catch (error) {
      console.error('Failed to clear storage:', error);
      throw error;
    }
  }

  // Database maintenance
  async getDatabaseSize(): Promise<number> {
    try {
      const sessions = await this.getSessions();
      return sessions.length;
    } catch (error) {
      console.error('Failed to get database size:', error);
      return 0;
    }
  }

  async cleanupOldData(daysToKeep: number = 30): Promise<void> {
    try {
      const sessions = await this.getSessions();
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);
      
      const filteredSessions = sessions.filter((session: Session) => 
        new Date(session.startTime) > cutoffDate
      );
      
      await AsyncStorage.setItem('sessions', JSON.stringify(filteredSessions));
    } catch (error) {
      console.error('Failed to cleanup old data:', error);
      throw error;
    }
  }
}

export const storageService = new SimpleStorageService();
export default storageService;

