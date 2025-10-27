import AsyncStorage from '@react-native-async-storage/async-storage';
import SQLite from 'react-native-sqlite-2';
import { Child, Session } from '../types';
import { STORAGE_KEYS } from '../constants';

class StorageService {
  private db: SQLite.SQLiteDatabase | null = null;

  isInitialized(): boolean {
    return this.db !== null;
  }

  // Helper method to execute SQL queries using transaction
  private async executeQuery(query: string, params: any[] = []): Promise<any> {
    if (!this.db) throw new Error('Database not initialized');

    return new Promise((resolve, reject) => {
      this.db!.transaction((tx) => {
        tx.executeSql(query, params, 
          (_, results) => resolve(results),
          (_, error) => {
            console.error('SQL execution error:', error);
            reject(error);
            return false;
          }
        );
      }, (error) => {
        console.error('Transaction error:', error);
        reject(error);
      });
    });
  }

  async initialize(): Promise<void> {
    try {
      // SQLite configuration for react-native-sqlite-2
      this.db = await SQLite.openDatabase({
        name: 'AutismApp.db',
        location: 'default',
        version: 1,
      });

      await this.createTables();
    } catch (error) {
      console.error('Database initialization failed:', error);
      throw error;
    }
  }

  private async createTables(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    const createChildrenTable = `
      CREATE TABLE IF NOT EXISTS children (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        language TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    `;

    const createSessionsTable = `
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        component_type TEXT NOT NULL,
        game_type TEXT NOT NULL,
        age_group TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration INTEGER,
        status TEXT NOT NULL,
        data TEXT NOT NULL,
        ml_prediction TEXT,
        clinician_notes TEXT,
        FOREIGN KEY (child_id) REFERENCES children (id)
      );
    `;

    const createOfflineDataTable = `
      CREATE TABLE IF NOT EXISTS offline_data (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      );
    `;

    try {
      // Use transaction for react-native-sqlite-2
      await new Promise<void>((resolve, reject) => {
        this.db!.transaction((tx) => {
          tx.executeSql(createChildrenTable, [], 
            () => console.log('Children table created'),
            (_, error) => {
              console.error('Error creating children table:', error);
              reject(error);
              return false;
            }
          );
          
          tx.executeSql(createSessionsTable, [], 
            () => console.log('Sessions table created'),
            (_, error) => {
              console.error('Error creating sessions table:', error);
              reject(error);
              return false;
            }
          );
          
          tx.executeSql(createOfflineDataTable, [], 
            () => console.log('Offline data table created'),
            (_, error) => {
              console.error('Error creating offline data table:', error);
              reject(error);
              return false;
            }
          );
        }, (error) => {
          console.error('Transaction error:', error);
          reject(error);
        }, () => {
          console.log('All tables created successfully');
          resolve();
        });
      });
    } catch (error) {
      console.error('Table creation failed:', error);
      throw error;
    }
  }

  // Children CRUD operations
  async saveChild(child: Child): Promise<void> {
    const query = `
      INSERT OR REPLACE INTO children (id, name, age, gender, language, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    try {
      await this.executeQuery(query, [
        child.id,
        child.name,
        child.age,
        child.gender,
        child.language,
        child.createdAt.toISOString(),
        child.updatedAt.toISOString(),
      ]);
    } catch (error) {
      console.error('Failed to save child:', error);
      throw error;
    }
  }

  async getChildren(): Promise<Child[]> {
    const query = 'SELECT * FROM children ORDER BY created_at DESC';
    
    try {
      const results = await this.executeQuery(query);
      const children: Child[] = [];

      for (let i = 0; i < results.rows.length; i++) {
        const row = results.rows.item(i);
        children.push({
          id: row.id,
          name: row.name,
          age: row.age,
          gender: row.gender,
          language: row.language,
          createdAt: new Date(row.created_at),
          updatedAt: new Date(row.updated_at),
        });
      }

      return children;
    } catch (error) {
      console.error('Failed to get children:', error);
      throw error;
    }
  }

  async getChild(id: string): Promise<Child | null> {
    const query = 'SELECT * FROM children WHERE id = ?';
    
    try {
      const results = await this.executeQuery(query, [id]);
      
      if (results.rows.length > 0) {
        const row = results.rows.item(0);
        return {
          id: row.id,
          name: row.name,
          age: row.age,
          gender: row.gender,
          language: row.language,
          createdAt: new Date(row.created_at),
          updatedAt: new Date(row.updated_at),
        };
      }

      return null;
    } catch (error) {
      console.error('Failed to get child:', error);
      throw error;
    }
  }

  async deleteChild(id: string): Promise<void> {
    const query = 'DELETE FROM children WHERE id = ?';
    
    try {
      await this.executeQuery(query, [id]);
    } catch (error) {
      console.error('Failed to delete child:', error);
      throw error;
    }
  }

  // Sessions CRUD operations
  async saveSession(session: Session): Promise<void> {
    const query = `
      INSERT OR REPLACE INTO sessions (
        id, child_id, component_type, game_type, age_group,
        start_time, end_time, duration, status, data,
        ml_prediction, clinician_notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    try {
      await this.executeQuery(query, [
        session.id,
        session.childId,
        session.componentType,
        session.gameType,
        session.ageGroup,
        session.startTime.toISOString(),
        session.endTime?.toISOString() || null,
        session.duration || null,
        session.status,
        JSON.stringify(session.data),
        session.mlPrediction ? JSON.stringify(session.mlPrediction) : null,
        session.clinicianNotes || null,
      ]);
    } catch (error) {
      console.error('Failed to save session:', error);
      throw error;
    }
  }

  async getSessions(childId?: string): Promise<Session[]> {
    const query = childId 
      ? 'SELECT * FROM sessions WHERE child_id = ? ORDER BY start_time DESC'
      : 'SELECT * FROM sessions ORDER BY start_time DESC';
    
    const params = childId ? [childId] : [];

    try {
      const results = await this.executeQuery(query, params);
      const sessions: Session[] = [];

      for (let i = 0; i < results.rows.length; i++) {
        const row = results.rows.item(i);
        sessions.push({
          id: row.id,
          childId: row.child_id,
          componentType: row.component_type,
          gameType: row.game_type,
          ageGroup: row.age_group,
          startTime: new Date(row.start_time),
          endTime: row.end_time ? new Date(row.end_time) : undefined,
          duration: row.duration,
          status: row.status,
          data: JSON.parse(row.data),
          mlPrediction: row.ml_prediction ? JSON.parse(row.ml_prediction) : undefined,
          clinicianNotes: row.clinician_notes,
        });
      }

      return sessions;
    } catch (error) {
      console.error('Failed to get sessions:', error);
      throw error;
    }
  }

  async getSession(id: string): Promise<Session | null> {
    const query = 'SELECT * FROM sessions WHERE id = ?';
    
    try {
      const results = await this.executeQuery(query, [id]);
      
      if (results.rows.length > 0) {
        const row = results.rows.item(0);
        return {
          id: row.id,
          childId: row.child_id,
          componentType: row.component_type,
          gameType: row.game_type,
          ageGroup: row.age_group,
          startTime: new Date(row.start_time),
          endTime: row.end_time ? new Date(row.end_time) : undefined,
          duration: row.duration,
          status: row.status,
          data: JSON.parse(row.data),
          mlPrediction: row.ml_prediction ? JSON.parse(row.ml_prediction) : undefined,
          clinicianNotes: row.clinician_notes,
        };
      }

      return null;
    } catch (error) {
      console.error('Failed to get session:', error);
      throw error;
    }
  }

  async deleteSession(id: string): Promise<void> {
    const query = 'DELETE FROM sessions WHERE id = ?';
    
    try {
      await this.executeQuery(query, [id]);
    } catch (error) {
      console.error('Failed to delete session:', error);
      throw error;
    }
  }

  // Offline data management
  async saveOfflineData(type: string, data: any): Promise<void> {
    const query = `
      INSERT INTO offline_data (id, type, data, created_at)
      VALUES (?, ?, ?, ?)
    `;

    const id = `${type}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    try {
      await this.executeQuery(query, [
        id,
        type,
        JSON.stringify(data),
        new Date().toISOString(),
      ]);
    } catch (error) {
      console.error('Failed to save offline data:', error);
      throw error;
    }
  }

  async getOfflineData(type?: string): Promise<any[]> {
    const query = type 
      ? 'SELECT * FROM offline_data WHERE type = ? AND synced = 0 ORDER BY created_at ASC'
      : 'SELECT * FROM offline_data WHERE synced = 0 ORDER BY created_at ASC';
    
    const params = type ? [type] : [];

    try {
      const results = await this.executeQuery(query, params);
      const data: any[] = [];

      for (let i = 0; i < results.rows.length; i++) {
        const row = results.rows.item(i);
        data.push({
          id: row.id,
          type: row.type,
          data: JSON.parse(row.data),
          createdAt: new Date(row.created_at),
          synced: row.synced === 1,
        });
      }

      return data;
    } catch (error) {
      console.error('Failed to get offline data:', error);
      throw error;
    }
  }

  async markDataAsSynced(id: string): Promise<void> {
    const query = 'UPDATE offline_data SET synced = 1 WHERE id = ?';
    
    try {
      await this.executeQuery(query, [id]);
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
      if (this.db) {
        await this.db.close();
        this.db = null;
      }
    } catch (error) {
      console.error('Failed to clear storage:', error);
      throw error;
    }
  }

  // Database maintenance
  async getDatabaseSize(): Promise<number> {
    if (!this.db) return 0;

    try {
      const [results] = await this.db.executeSql('SELECT COUNT(*) as count FROM sessions');
      return results.rows.item(0).count;
    } catch (error) {
      console.error('Failed to get database size:', error);
      return 0;
    }
  }

  async cleanupOldData(daysToKeep: number = 30): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);

    const query = 'DELETE FROM sessions WHERE start_time < ?';
    
    try {
      await this.db.executeSql(query, [cutoffDate.toISOString()]);
    } catch (error) {
      console.error('Failed to cleanup old data:', error);
      throw error;
    }
  }
}

export const storageService = new StorageService();
export default storageService;
