import AsyncStorage from '@react-native-async-storage/async-storage';
import { Child, Session } from '../types';
import { STORAGE_KEYS } from '../constants';
import { calculateAge } from '../utils/ageCalculator';

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
      
      const isNewChild = existingIndex < 0;
      
      if (existingIndex >= 0) {
        children[existingIndex] = child;
      } else {
        children.push(child);
      }
      
      await AsyncStorage.setItem('children', JSON.stringify(children));

      // 🔥 LOG TO CONSOLE - DATABASE READY JSON
      const childData = {
        event: isNewChild ? 'CHILD_ADDED' : 'CHILD_UPDATED',
        timestamp: new Date().toISOString(),
        child: {
          id: child.id,
          name: child.name,
          age: child.age,
          dateOfBirth: child.dateOfBirth,
          gender: child.gender,
          language: child.language,
          hospitalId: child.hospitalId,
          hospitalName: child.hospitalName,
          testCompleted: child.testCompleted,
          riskLevel: child.riskLevel,
          createdAt: child.createdAt,
        },
        action: isNewChild ? 'created' : 'updated',
        totalChildren: children.length,
        success: true,
      };

      console.log('\n');
      console.log('╔════════════════════════════════════════════════════════════╗');
      console.log('║                                                            ║');
      console.log(`║           ${isNewChild ? '👶 NEW CHILD ADDED' : '✏️  CHILD UPDATED'}                       ║`);
      console.log('║                                                            ║');
      console.log('╚════════════════════════════════════════════════════════════╝');
      console.log('\n📊 DATABASE-READY JSON (Copy this):');
      console.log('\n' + JSON.stringify(childData, null, 2));
      console.log('\n✅ Stored in AsyncStorage → Key: children');
      console.log('👶 Child Name:', child.name);
      console.log('🎂 Age:', child.age);
      console.log('🏥 Hospital ID:', child.hospitalId || 'Not specified');
      console.log('📊 Total Children:', children.length);
      console.log('\n════════════════════════════════════════════════════════════\n');
    } catch (error) {
      console.error('Failed to save child:', error);
      throw error;
    }
  }

  async getChildren(): Promise<Child[]> {
    try {
      const childrenData = await AsyncStorage.getItem('children');
      const children = childrenData ? JSON.parse(childrenData) : [];

      // 🔥 LOG TO CONSOLE - DATABASE READY JSON
      const loadData = {
        event: 'CHILDREN_DATA_LOADED',
        timestamp: new Date().toISOString(),
        summary: {
          totalChildren: children.length,
          byHospital: this.groupByHospital(children),
          byAge: this.groupByAge(children),
          byGender: this.groupByGender(children),
          byRiskLevel: this.groupByRiskLevel(children),
        },
        children: children.map((child: Child) => ({
          id: child.id,
          name: child.name,
          age: child.age,
          gender: child.gender,
          hospitalId: child.hospitalId,
          hospitalName: child.hospitalName,
          testCompleted: child.testCompleted,
          riskLevel: child.riskLevel,
        })),
        success: true,
      };

      console.log('\n');
      console.log('╔════════════════════════════════════════════════════════════╗');
      console.log('║                                                            ║');
      console.log('║           📂 CHILDREN DATA LOADED                         ║');
      console.log('║                                                            ║');
      console.log('╚════════════════════════════════════════════════════════════╝');
      console.log('\n📊 DATABASE-READY JSON (Copy this):');
      console.log('\n' + JSON.stringify(loadData, null, 2));
      console.log('\n✅ Loaded from AsyncStorage → Key: children');
      console.log('📊 Total Children:', children.length);
      console.log('🏥 Hospitals:', Object.keys(this.groupByHospital(children)).length);
      console.log('\n════════════════════════════════════════════════════════════\n');

      return children;
    } catch (error) {
      console.error('Failed to get children:', error);
      return [];
    }
  }

  // Helper methods for grouping
  private groupByHospital(children: Child[]): Record<string, number> {
    return children.reduce((acc: Record<string, number>, child: Child) => {
      const hospitalId = child.hospitalId || 'unassigned';
      acc[hospitalId] = (acc[hospitalId] || 0) + 1;
      return acc;
    }, {});
  }

  private groupByAge(children: Child[]): Record<string, number> {
    return children.reduce((acc: Record<string, number>, child: Child) => {
      // Safety check: if dateOfBirth is missing, use fallback age
      if (!child.dateOfBirth) {
        // Fallback to old age field if dateOfBirth is missing
        const fallbackAge = child.age || 0;
        const fallbackGroup = fallbackAge <= 3 ? '2-3' : fallbackAge <= 5 ? '4-5' : '5-6';
        acc[fallbackGroup] = (acc[fallbackGroup] || 0) + 1;
        return acc;
      }
      
      // Use precise age calculation from date of birth
      const ageData = calculateAge(child.dateOfBirth);
      
      // Age groups based on assessment ranges
      let ageGroup: string;
      if (ageData.ageInYears < 2) {
        ageGroup = 'Under 2';
      } else if (ageData.ageInYears >= 2 && ageData.ageInYears < 3.5) {
        ageGroup = '2-3.5';
      } else if (ageData.ageInYears >= 3.5 && ageData.ageInYears < 5.5) {
        ageGroup = '3.5-5.5';
      } else if (ageData.ageInYears >= 5.5 && ageData.ageInYears <= 6) {
        ageGroup = '5.5-6';
      } else {
        ageGroup = 'Over 6';
      }
      
      acc[ageGroup] = (acc[ageGroup] || 0) + 1;
      return acc;
    }, {});
  }

  private groupByGender(children: Child[]): Record<string, number> {
    return children.reduce((acc: Record<string, number>, child: Child) => {
      acc[child.gender] = (acc[child.gender] || 0) + 1;
      return acc;
    }, {});
  }

  private groupByRiskLevel(children: Child[]): Record<string, number> {
    return children.reduce((acc: Record<string, number>, child: Child) => {
      const risk = child.riskLevel || 'unknown';
      acc[risk] = (acc[risk] || 0) + 1;
      return acc;
    }, {});
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
      
      const isNewSession = existingIndex < 0;
      
      if (existingIndex >= 0) {
        sessions[existingIndex] = session;
      } else {
        sessions.push(session);
      }
      
      await AsyncStorage.setItem('sessions', JSON.stringify(sessions));

      // 🔥 LOG TO CONSOLE - DATABASE READY JSON
      const sessionData = {
        event: 'ASSESSMENT_SESSION_SAVED',
        timestamp: new Date().toISOString(),
        session: {
          id: session.id,
          childId: session.childId,
          componentType: session.componentType,
          gameType: session.gameType,
          ageGroup: session.ageGroup,
          startTime: session.startTime,
          endTime: session.endTime,
          duration: session.duration,
          status: session.status,
          clinicianNotes: session.clinicianNotes,
        },
        action: isNewSession ? 'created' : 'updated',
        totalSessions: sessions.length,
        success: true,
      };

      console.log('\n');
      console.log('╔════════════════════════════════════════════════════════════╗');
      console.log('║                                                            ║');
      console.log('║           🎮 ASSESSMENT SESSION SAVED                     ║');
      console.log('║                                                            ║');
      console.log('╚════════════════════════════════════════════════════════════╝');
      console.log('\n📊 DATABASE-READY JSON (Copy this):');
      console.log('\n' + JSON.stringify(sessionData, null, 2));
      console.log('\n✅ Stored in AsyncStorage → Key: sessions');
      console.log('🎮 Game Type:', session.gameType);
      console.log('👶 Child ID:', session.childId);
      console.log('⏱️  Duration:', session.duration, 'seconds');
      console.log('📊 Total Sessions:', sessions.length);
      console.log('\n════════════════════════════════════════════════════════════\n');
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

