/**
 * Firebase Migration Script
 * Exports data from old Firebase and imports to new Firebase
 * 
 * Usage:
 *   1. Export from old Firebase:
 *      node scripts/migrate_to_new_firebase.js --export
 * 
 *   2. Update serviceAccountKey.json with NEW Firebase key
 * 
 *   3. Import to new Firebase:
 *      node scripts/migrate_to_new_firebase.js --import --backup=backup-file.json
 */

const { db } = require('../firebase');
const fs = require('fs').promises;
const path = require('path');

const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');
const cliniciansCollection = db.collection('clinicians');

const BACKUP_DIR = path.join(__dirname, '../backups');

async function exportData(backupName) {
  console.log('📦 Exporting data from current Firebase...');
  
  await fs.mkdir(BACKUP_DIR, { recursive: true });
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupId = backupName || `migration-export-${timestamp}`;
  const backupPath = path.join(BACKUP_DIR, `${backupId}.json`);
  
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
      source: 'firebase-export',
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
  
  console.log(`✅ Export complete!`);
  console.log(`   File: ${backupPath}`);
  console.log(`   Children: ${backup.stats.children}`);
  console.log(`   Sessions: ${backup.stats.sessions}`);
  console.log(`   Trials: ${backup.stats.trials}`);
  console.log(`   Clinicians: ${backup.stats.clinicians}`);
  
  return backupPath;
}

async function importData(backupPath) {
  console.log('📥 Importing data to new Firebase...');
  
  // Check if backup exists
  try {
    await fs.access(backupPath);
  } catch {
    throw new Error(`Backup file not found: ${backupPath}`);
  }
  
  // Read backup file
  const backupContent = await fs.readFile(backupPath, 'utf8');
  const backup = JSON.parse(backupContent);
  
  console.log(`📊 Importing:`);
  console.log(`   Children: ${backup.stats.children}`);
  console.log(`   Sessions: ${backup.stats.sessions}`);
  console.log(`   Trials: ${backup.stats.trials}`);
  console.log(`   Clinicians: ${backup.stats.clinicians}`);
  
  let importedCount = 0;
  
  // Import children
  if (backup.data.children && backup.data.children.length > 0) {
    console.log('\n📥 Importing children...');
    const batch = db.batch();
    let count = 0;
    
    for (const child of backup.data.children) {
      const { id, ...data } = child;
      const ref = childrenCollection.doc(id);
      batch.set(ref, data);
      count++;
      importedCount++;
      
      if (count >= 500) {
        await batch.commit();
        console.log(`   ✅ Imported batch of ${count} children`);
        count = 0;
      }
    }
    
    if (count > 0) {
      await batch.commit();
      console.log(`   ✅ Imported ${count} children`);
    }
  }
  
  // Import sessions
  if (backup.data.sessions && backup.data.sessions.length > 0) {
    console.log('\n📥 Importing sessions...');
    const batch = db.batch();
    let count = 0;
    
    for (const session of backup.data.sessions) {
      const { id, ...data } = session;
      const ref = sessionsCollection.doc(id);
      batch.set(ref, data);
      count++;
      importedCount++;
      
      if (count >= 500) {
        await batch.commit();
        console.log(`   ✅ Imported batch of ${count} sessions`);
        count = 0;
      }
    }
    
    if (count > 0) {
      await batch.commit();
      console.log(`   ✅ Imported ${count} sessions`);
    }
  }
  
  // Import trials
  if (backup.data.trials && backup.data.trials.length > 0) {
    console.log('\n📥 Importing trials...');
    const batch = db.batch();
    let count = 0;
    
    for (const trial of backup.data.trials) {
      const { id, ...data } = trial;
      const ref = trialsCollection.doc(id);
      batch.set(ref, data);
      count++;
      importedCount++;
      
      if (count >= 500) {
        await batch.commit();
        console.log(`   ✅ Imported batch of ${count} trials`);
        count = 0;
      }
    }
    
    if (count > 0) {
      await batch.commit();
      console.log(`   ✅ Imported ${count} trials`);
    }
  }
  
  // Import clinicians
  if (backup.data.clinicians && backup.data.clinicians.length > 0) {
    console.log('\n📥 Importing clinicians...');
    const batch = db.batch();
    let count = 0;
    
    for (const clinician of backup.data.clinicians) {
      const { id, ...data } = clinician;
      const ref = cliniciansCollection.doc(id);
      batch.set(ref, data);
      count++;
      importedCount++;
      
      if (count >= 500) {
        await batch.commit();
        console.log(`   ✅ Imported batch of ${count} clinicians`);
        count = 0;
      }
    }
    
    if (count > 0) {
      await batch.commit();
      console.log(`   ✅ Imported ${count} clinicians`);
    }
  }
  
  console.log(`\n✅ Import complete!`);
  console.log(`   Total documents imported: ${importedCount}`);
}

async function main() {
  const args = process.argv.slice(2);
  
  if (args.includes('--export')) {
    const backupName = args.find(arg => arg.startsWith('--backup='))?.split('=')[1];
    await exportData(backupName);
  } else if (args.includes('--import')) {
    const backupArg = args.find(arg => arg.startsWith('--backup='));
    if (!backupArg) {
      console.error('❌ Error: --backup=filename.json is required for import');
      console.log('\nUsage:');
      console.log('   node scripts/migrate_to_new_firebase.js --import --backup=backup-file.json');
      process.exit(1);
    }
    const backupFile = backupArg.split('=')[1];
    const backupPath = path.join(BACKUP_DIR, backupFile);
    await importData(backupPath);
  } else {
    console.log('📋 Firebase Migration Tool\n');
    console.log('Usage:');
    console.log('   # Export data from current Firebase');
    console.log('   node scripts/migrate_to_new_firebase.js --export');
    console.log('');
    console.log('   # Import data to new Firebase (after updating serviceAccountKey.json)');
    console.log('   node scripts/migrate_to_new_firebase.js --import --backup=backup-file.json');
    console.log('');
    console.log('Steps:');
    console.log('   1. Export: node scripts/migrate_to_new_firebase.js --export');
    console.log('   2. Create new Firebase project');
    console.log('   3. Download new serviceAccountKey.json');
    console.log('   4. Replace senseai_backend/serviceAccountKey.json');
    console.log('   5. Import: node scripts/migrate_to_new_firebase.js --import --backup=backup-file.json');
  }
  
  process.exit(0);
}

main().catch((error) => {
  console.error('❌ Error:', error);
  process.exit(1);
});


