const { db } = require('../firebase');

async function analyzeMetrics() {
  console.log('🔍 Analyzing color_shape sessions...');
  const snap = await db.collection('sessions').where('session_type', '==', 'color_shape').limit(5).get();
  
  snap.docs.forEach(doc => {
    console.log(`\nSession ID: ${doc.id}`);
    const data = doc.data();
    console.log('Metrics:', JSON.stringify(data.metrics, null, 2));
    console.log('Game Results Keys:', data.game_results ? Object.keys(data.game_results) : 'None');
  });
  
  process.exit(0);
}

analyzeMetrics().catch(err => {
  console.error(err);
  process.exit(1);
});
