const { db } = require('../firebase');

async function analyzeSessionTypes() {
  console.log('🔍 Analyzing session types...');
  const snap = await db.collection('sessions').get();
  const types = {};
  
  snap.docs.forEach(doc => {
    const type = doc.data().session_type;
    types[type] = (types[type] || 0) + 1;
  });
  
  console.log('📊 Session Type Distribution:');
  console.log(JSON.stringify(types, null, 2));
  
  process.exit(0);
}

analyzeSessionTypes().catch(err => {
  console.error(err);
  process.exit(1);
});
