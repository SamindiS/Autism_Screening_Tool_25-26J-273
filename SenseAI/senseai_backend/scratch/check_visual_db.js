const { visualDb } = require('../firebase');

async function checkVisualData() {
  if (!visualDb) {
    console.error('❌ visualDb is not initialized. Check firebase.js and config/visual_service_key.json');
    return;
  }

  try {
    console.log('📡 Fetching reports from visualDb...');
    const snap = await visualDb.collection('reports').get();
    console.log(`✅ Found ${snap.docs.length} reports.`);
    
    if (snap.docs.length > 0) {
      console.log('📄 Sample Report Data (First 1):');
      console.log(JSON.stringify(snap.docs[0].data(), null, 2));
    }
  } catch (err) {
    console.error('❌ Error fetching from visualDb:', err.message);
  }
}

checkVisualData();
