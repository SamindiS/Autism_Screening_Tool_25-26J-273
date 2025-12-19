// firebase.js
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Check if serviceAccountKey.json exists
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

if (!fs.existsSync(serviceAccountPath)) {
  console.error('❌ ERROR: serviceAccountKey.json not found!');
  console.error('   Please download it from Firebase Console:');
  console.error('   1. Go to Firebase Console > Project Settings > Service Accounts');
  console.error('   2. Click "Generate new private key"');
  console.error('   3. Save as serviceAccountKey.json in senseai_backend/');
  process.exit(1);
}

let serviceAccount;
try {
  serviceAccount = require(serviceAccountPath);
  
  // Validate service account structure
  if (!serviceAccount.project_id || !serviceAccount.private_key || !serviceAccount.client_email) {
    console.error('❌ ERROR: Invalid serviceAccountKey.json format!');
    console.error('   The file must contain: project_id, private_key, and client_email');
    process.exit(1);
  }
} catch (err) {
  console.error('❌ ERROR: Failed to load serviceAccountKey.json:', err.message);
  console.error('   Please check if the file is valid JSON');
  process.exit(1);
}

// Initialize Firebase Admin
let app;
try {
  app = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log("✅ Firebase Firestore connected successfully!");
  console.log(`   Project ID: ${serviceAccount.project_id}`);
} catch (err) {
  console.error('❌ ERROR: Failed to initialize Firebase:', err.message);
  if (err.message.includes('UNAUTHENTICATED') || err.message.includes('invalid')) {
    console.error('   This usually means:');
    console.error('   1. Service account key is expired or revoked');
    console.error('   2. Service account was deleted from Firebase');
    console.error('   3. Wrong Firebase project');
    console.error('   Solution: Download a new serviceAccountKey.json from Firebase Console');
  }
  process.exit(1);
}

const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });

// Test Firebase connection
db.collection('_test').limit(1).get()
  .then(() => {
    console.log("✅ Firebase connection test successful!");
  })
  .catch((err) => {
    console.error('⚠️  WARNING: Firebase connection test failed:', err.message);
    console.error('   The app may still work, but some operations might fail.');
  });

module.exports = { db };