/**
 * Firebase Data Cleanup Script
 * Helps delete unwanted data from Firebase
 * 
 * Usage:
 *   node scripts/cleanup_firebase_data.js
 * 
 * Options:
 *   --delete-test-children    Delete children with "Test" in name
 *   --delete-old-sessions     Delete sessions older than 90 days
 *   --delete-orphaned         Delete orphaned sessions/trials
 *   --dry-run                 Preview what will be deleted (no actual deletion)
 */

const { db } = require('../firebase');

const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');

// Parse command line arguments
const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');
const deleteTestChildren = args.includes('--delete-test-children');
const deleteOldSessions = args.includes('--delete-old-sessions');
const deleteOrphaned = args.includes('--delete-orphaned');

async function deleteTestChildren() {
  console.log('🔍 Finding test children...');
  
  const allChildren = await childrenCollection.get();
  const testChildren = [];
  
  for (const doc of allChildren.docs) {
    const data = doc.data();
    const name = (data.name || '').toLowerCase();
    
    // Check for test indicators
    if (name.includes('test') || 
        name.includes('demo') || 
        name.includes('sample') ||
        data.child_code?.toLowerCase().includes('test')) {
      testChildren.push({ id: doc.id, name: data.name });
    }
  }
  
  console.log(`📊 Found ${testChildren.length} test children`);
  
  if (testChildren.length === 0) {
    console.log('✅ No test children found');
    return;
  }
  
  if (isDryRun) {
    console.log('🔍 DRY RUN - Would delete:');
    testChildren.forEach(c => console.log(`   - ${c.name} (${c.id})`));
    return;
  }
  
  // Delete in batches
  const batch = db.batch();
  let count = 0;
  
  for (const child of testChildren) {
    const ref = childrenCollection.doc(child.id);
    batch.delete(ref);
    count++;
    
    // Firestore batch limit is 500
    if (count >= 500) {
      await batch.commit();
      console.log(`✅ Deleted batch of ${count} children`);
      count = 0;
    }
  }
  
  if (count > 0) {
    await batch.commit();
    console.log(`✅ Deleted ${count} children`);
  }
  
  console.log(`✅ Total deleted: ${testChildren.length} test children`);
}

async function deleteOldSessions(daysOld = 90) {
  console.log(`🔍 Finding sessions older than ${daysOld} days...`);
  
  const cutoff = Date.now() - (daysOld * 24 * 60 * 60 * 1000);
  const oldSessions = await sessionsCollection
    .where('created_at', '<', cutoff)
    .get();
  
  console.log(`📊 Found ${oldSessions.size} old sessions`);
  
  if (oldSessions.size === 0) {
    console.log('✅ No old sessions found');
    return;
  }
  
  if (isDryRun) {
    console.log('🔍 DRY RUN - Would delete:');
    oldSessions.docs.slice(0, 10).forEach(doc => {
      const data = doc.data();
      const date = new Date(data.created_at).toLocaleDateString();
      console.log(`   - Session ${doc.id} (${data.session_type}, ${date})`);
    });
    if (oldSessions.size > 10) {
      console.log(`   ... and ${oldSessions.size - 10} more`);
    }
    return;
  }
  
  // Delete in batches
  const batch = db.batch();
  let count = 0;
  
  for (const doc of oldSessions.docs) {
    batch.delete(doc.ref);
    count++;
    
    if (count >= 500) {
      await batch.commit();
      console.log(`✅ Deleted batch of ${count} sessions`);
      count = 0;
    }
  }
  
  if (count > 0) {
    await batch.commit();
    console.log(`✅ Deleted ${count} sessions`);
  }
  
  console.log(`✅ Total deleted: ${oldSessions.size} old sessions`);
}

async function deleteOrphanedRecords() {
  console.log('🔍 Finding orphaned records...');
  
  // Get all children IDs
  const childrenSnap = await childrenCollection.get();
  const childIds = new Set(childrenSnap.docs.map(doc => doc.id));
  
  // Get all sessions
  const sessionsSnap = await sessionsCollection.get();
  const orphanedSessions = [];
  
  for (const doc of sessionsSnap.docs) {
    const data = doc.data();
    if (!childIds.has(data.child_id)) {
      orphanedSessions.push({ id: doc.id, childId: data.child_id });
    }
  }
  
  console.log(`📊 Found ${orphanedSessions.length} orphaned sessions`);
  
  // Get all session IDs
  const sessionIds = new Set(sessionsSnap.docs.map(doc => doc.id));
  
  // Get all trials
  const trialsSnap = await trialsCollection.get();
  const orphanedTrials = [];
  
  for (const doc of trialsSnap.docs) {
    const data = doc.data();
    if (!sessionIds.has(data.session_id)) {
      orphanedTrials.push({ id: doc.id, sessionId: data.session_id });
    }
  }
  
  console.log(`📊 Found ${orphanedTrials.length} orphaned trials`);
  
  if (orphanedSessions.length === 0 && orphanedTrials.length === 0) {
    console.log('✅ No orphaned records found');
    return;
  }
  
  if (isDryRun) {
    console.log('🔍 DRY RUN - Would delete:');
    if (orphanedSessions.length > 0) {
      console.log(`   ${orphanedSessions.length} orphaned sessions`);
      orphanedSessions.slice(0, 5).forEach(s => {
        console.log(`     - Session ${s.id} (child: ${s.childId})`);
      });
    }
    if (orphanedTrials.length > 0) {
      console.log(`   ${orphanedTrials.length} orphaned trials`);
    }
    return;
  }
  
  // Delete orphaned sessions
  if (orphanedSessions.length > 0) {
    const batch = db.batch();
    let count = 0;
    
    for (const session of orphanedSessions) {
      batch.delete(sessionsCollection.doc(session.id));
      count++;
      
      if (count >= 500) {
        await batch.commit();
        console.log(`✅ Deleted batch of ${count} orphaned sessions`);
        count = 0;
      }
    }
    
    if (count > 0) {
      await batch.commit();
    }
    
    console.log(`✅ Deleted ${orphanedSessions.length} orphaned sessions`);
  }
  
  // Delete orphaned trials
  if (orphanedTrials.length > 0) {
    const batch = db.batch();
    let count = 0;
    
    for (const trial of orphanedTrials) {
      batch.delete(trialsCollection.doc(trial.id));
      count++;
      
      if (count >= 500) {
        await batch.commit();
        console.log(`✅ Deleted batch of ${count} orphaned trials`);
        count = 0;
      }
    }
    
    if (count > 0) {
      await batch.commit();
    }
    
    console.log(`✅ Deleted ${orphanedTrials.length} orphaned trials`);
  }
}

async function showStatistics() {
  console.log('\n📊 Current Database Statistics:');
  
  const [childrenSnap, sessionsSnap, trialsSnap] = await Promise.all([
    childrenCollection.get(),
    sessionsCollection.get(),
    trialsCollection.get(),
  ]);
  
  console.log(`   Children: ${childrenSnap.size}`);
  console.log(`   Sessions: ${sessionsSnap.size}`);
  console.log(`   Trials: ${trialsSnap.size}`);
  
  // Calculate storage estimate (rough)
  let totalSize = 0;
  childrenSnap.docs.forEach(doc => {
    totalSize += JSON.stringify(doc.data()).length;
  });
  sessionsSnap.docs.forEach(doc => {
    totalSize += JSON.stringify(doc.data()).length;
  });
  trialsSnap.docs.forEach(doc => {
    totalSize += JSON.stringify(doc.data()).length;
  });
  
  const sizeMB = (totalSize / 1024 / 1024).toFixed(2);
  console.log(`   Estimated size: ${sizeMB} MB`);
  console.log(`   Free tier limit: 1024 MB (1 GB)`);
  
  if (totalSize > 1024 * 1024 * 1024) {
    console.log('   ⚠️  WARNING: Exceeds free tier storage limit!');
  }
}

async function main() {
  console.log('🧹 Firebase Data Cleanup Tool\n');
  
  if (isDryRun) {
    console.log('🔍 DRY RUN MODE - No data will be deleted\n');
  }
  
  // Show current statistics
  await showStatistics();
  console.log('');
  
  // Run cleanup operations
  if (deleteTestChildren) {
    await deleteTestChildren();
    console.log('');
  }
  
  if (deleteOldSessions) {
    await deleteOldSessions(90);
    console.log('');
  }
  
  if (deleteOrphaned) {
    await deleteOrphanedRecords();
    console.log('');
  }
  
  // If no specific operation, show help
  if (!deleteTestChildren && !deleteOldSessions && !deleteOrphaned) {
    console.log('📋 Usage:');
    console.log('   node scripts/cleanup_firebase_data.js [options]');
    console.log('');
    console.log('Options:');
    console.log('   --delete-test-children    Delete children with "test" in name');
    console.log('   --delete-old-sessions    Delete sessions older than 90 days');
    console.log('   --delete-orphaned        Delete orphaned sessions/trials');
    console.log('   --dry-run                Preview what will be deleted');
    console.log('');
    console.log('Examples:');
    console.log('   # Preview what would be deleted');
    console.log('   node scripts/cleanup_firebase_data.js --delete-test-children --dry-run');
    console.log('');
    console.log('   # Actually delete test children');
    console.log('   node scripts/cleanup_firebase_data.js --delete-test-children');
    console.log('');
    console.log('   # Delete old sessions (90+ days)');
    console.log('   node scripts/cleanup_firebase_data.js --delete-old-sessions');
    console.log('');
    console.log('   # Delete all unwanted data');
    console.log('   node scripts/cleanup_firebase_data.js --delete-test-children --delete-old-sessions --delete-orphaned');
  } else {
    // Show final statistics
    console.log('\n📊 Final Statistics:');
    await showStatistics();
  }
  
  console.log('\n✅ Cleanup complete!');
  process.exit(0);
}

main().catch((error) => {
  console.error('❌ Error:', error);
  process.exit(1);
});


