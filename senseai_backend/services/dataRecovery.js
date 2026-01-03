/**
 * Data Recovery and Backup Service
 * Provides backup, restore, and recovery capabilities
 */

const { db } = require('../firebase');
const fs = require('fs').promises;
const path = require('path');

const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');
const cliniciansCollection = db.collection('clinicians');

const BACKUP_DIR = path.join(__dirname, '../backups');

/**
 * Ensure backup directory exists
 */
const ensureBackupDir = async () => {
  try {
    await fs.mkdir(BACKUP_DIR, { recursive: true });
  } catch (error) {
    console.error('Error creating backup directory:', error);
  }
};

/**
 * Create a backup of all data
 */
const createBackup = async (backupName = null) => {
  try {
    await ensureBackupDir();
    
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupId = backupName || `backup-${timestamp}`;
    const backupPath = path.join(BACKUP_DIR, `${backupId}.json`);
    
    console.log(`📦 Creating backup: ${backupId}`);
    
    // Collect all data
    const [childrenSnap, sessionsSnap, trialsSnap, cliniciansSnap] = await Promise.all([
      childrenCollection.get(),
      sessionsCollection.get(),
      trialsCollection.get(),
      cliniciansCollection.get(),
    ]);
    
    const backup = {
      metadata: {
        backupId,
        timestamp: Date.now(),
        version: '1.0',
      },
      data: {
        children: childrenSnap.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        })),
        sessions: sessionsSnap.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        })),
        trials: trialsSnap.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        })),
        clinicians: cliniciansSnap.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
        })),
      },
      stats: {
        children: childrenSnap.size,
        sessions: sessionsSnap.size,
        trials: trialsSnap.size,
        clinicians: cliniciansSnap.size,
      },
    };
    
    // Write backup to file
    await fs.writeFile(backupPath, JSON.stringify(backup, null, 2));
    
    console.log(`✅ Backup created: ${backupPath}`);
    console.log(`   Children: ${backup.stats.children}, Sessions: ${backup.stats.sessions}, Trials: ${backup.stats.trials}, Clinicians: ${backup.stats.clinicians}`);
    
    return {
      success: true,
      backupId,
      backupPath,
      stats: backup.stats,
      timestamp: backup.metadata.timestamp,
    };
  } catch (error) {
    console.error('❌ Error creating backup:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Restore data from backup
 */
const restoreBackup = async (backupId, options = {}) => {
  try {
    const { dryRun = false, collections = ['children', 'sessions', 'trials', 'clinicians'] } = options;
    
    const backupPath = path.join(BACKUP_DIR, `${backupId}.json`);
    
    // Check if backup exists
    try {
      await fs.access(backupPath);
    } catch {
      throw new Error(`Backup ${backupId} not found`);
    }
    
    // Read backup file
    const backupContent = await fs.readFile(backupPath, 'utf8');
    const backup = JSON.parse(backupContent);
    
    console.log(`📥 Restoring backup: ${backupId}`);
    console.log(`   Dry run: ${dryRun}`);
    console.log(`   Collections: ${collections.join(', ')}`);
    
    if (dryRun) {
      return {
        success: true,
        dryRun: true,
        stats: backup.stats,
        message: 'Dry run completed - no data was modified',
      };
    }
    
    const batch = db.batch();
    let restoredCount = 0;
    
    // Restore children
    if (collections.includes('children') && backup.data.children) {
      for (const child of backup.data.children) {
        const { id, ...data } = child;
        const ref = childrenCollection.doc(id);
        batch.set(ref, data);
        restoredCount++;
      }
    }
    
    // Restore sessions
    if (collections.includes('sessions') && backup.data.sessions) {
      for (const session of backup.data.sessions) {
        const { id, ...data } = session;
        const ref = sessionsCollection.doc(id);
        batch.set(ref, data);
        restoredCount++;
      }
    }
    
    // Restore trials
    if (collections.includes('trials') && backup.data.trials) {
      for (const trial of backup.data.trials) {
        const { id, ...data } = trial;
        const ref = trialsCollection.doc(id);
        batch.set(ref, data);
        restoredCount++;
      }
    }
    
    // Restore clinicians
    if (collections.includes('clinicians') && backup.data.clinicians) {
      for (const clinician of backup.data.clinicians) {
        const { id, ...data } = clinician;
        const ref = cliniciansCollection.doc(id);
        batch.set(ref, data);
        restoredCount++;
      }
    }
    
    // Commit batch
    await batch.commit();
    
    console.log(`✅ Restore complete: ${restoredCount} documents restored`);
    
    return {
      success: true,
      restoredCount,
      stats: backup.stats,
    };
  } catch (error) {
    console.error('❌ Error restoring backup:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * List all available backups
 */
const listBackups = async () => {
  try {
    await ensureBackupDir();
    
    const files = await fs.readdir(BACKUP_DIR);
    const backups = [];
    
    for (const file of files) {
      if (file.endsWith('.json')) {
        const backupPath = path.join(BACKUP_DIR, file);
        const stats = await fs.stat(backupPath);
        const backupId = file.replace('.json', '');
        
        try {
          const content = await fs.readFile(backupPath, 'utf8');
          const backup = JSON.parse(content);
          
          backups.push({
            backupId,
            timestamp: backup.metadata.timestamp,
            stats: backup.stats,
            size: stats.size,
            path: backupPath,
          });
        } catch (err) {
          console.warn(`Warning: Could not parse backup file ${file}:`, err.message);
        }
      }
    }
    
    // Sort by timestamp (newest first)
    backups.sort((a, b) => b.timestamp - a.timestamp);
    
    return backups;
  } catch (error) {
    console.error('Error listing backups:', error);
    return [];
  }
};

/**
 * Delete a backup
 */
const deleteBackup = async (backupId) => {
  try {
    const backupPath = path.join(BACKUP_DIR, `${backupId}.json`);
    await fs.unlink(backupPath);
    
    console.log(`🗑️  Backup deleted: ${backupId}`);
    
    return {
      success: true,
      message: `Backup ${backupId} deleted successfully`,
    };
  } catch (error) {
    console.error('Error deleting backup:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Create backup before major operation
 */
const createPreOperationBackup = async (operationName) => {
  const backupName = `pre-${operationName}-${Date.now()}`;
  return await createBackup(backupName);
};

/**
 * Rollback to previous state (restore most recent backup)
 */
const rollback = async () => {
  const backups = await listBackups();
  
  if (backups.length === 0) {
    return {
      success: false,
      error: 'No backups available for rollback',
    };
  }
  
  const latestBackup = backups[0];
  console.log(`🔄 Rolling back to backup: ${latestBackup.backupId}`);
  
  return await restoreBackup(latestBackup.backupId);
};

module.exports = {
  createBackup,
  restoreBackup,
  listBackups,
  deleteBackup,
  createPreOperationBackup,
  rollback,
};


