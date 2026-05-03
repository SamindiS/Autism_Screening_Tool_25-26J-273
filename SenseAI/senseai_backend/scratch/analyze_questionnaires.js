const { db } = require('../firebase');

async function analyzeQuestionnaires() {
  console.log('🔍 Analyzing ai_doctor_bot sessions...');
  const snap = await db.collection('sessions').where('session_type', '==', 'ai_doctor_bot').limit(3).get();
  
  snap.docs.forEach(doc => {
    console.log(`\nSession ID: ${doc.id}`);
    console.log(JSON.stringify(doc.data(), null, 2));
  });
  
  process.exit(0);
}

analyzeQuestionnaires().catch(err => {
  console.error(err);
  process.exit(1);
});
