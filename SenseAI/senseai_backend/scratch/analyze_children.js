const { db } = require('../firebase');

async function analyzeChildren() {
  console.log('🔍 Analyzing children structure...');
  const snap = await db.collection('children').limit(5).get();
  
  snap.docs.forEach(doc => {
    console.log(`\nChild ID: ${doc.id}`);
    console.log(JSON.stringify(doc.data(), null, 2));
  });
  
  process.exit(0);
}

analyzeChildren().catch(err => {
  console.error(err);
  process.exit(1);
});
