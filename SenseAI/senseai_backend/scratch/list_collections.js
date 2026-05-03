const { db } = require('../firebase');

async function listCollections() {
  console.log('🔍 Listing collections...');
  const collections = await db.listCollections();
  console.log('📊 Collections found:');
  collections.forEach(collection => {
    console.log(`- ${collection.id}`);
  });
  process.exit(0);
}

listCollections().catch(err => {
  console.error(err);
  process.exit(1);
});
