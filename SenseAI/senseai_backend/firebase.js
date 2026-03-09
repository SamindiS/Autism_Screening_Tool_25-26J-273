// firebase.js
//
// Firebase Admin initialization for both local development and cloud
// environments (e.g. Vercel). In production you should use environment
// variables instead of committing serviceAccountKey.json.

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Prefer environment variables when available (for Vercel, Railway, etc.).
// Expected env vars:
// - FIREBASE_PROJECT_ID
// - FIREBASE_CLIENT_EMAIL
// - FIREBASE_PRIVATE_KEY  (with \n sequences)
const hasEnvCredentials =
  process.env.FIREBASE_PROJECT_ID &&
  process.env.FIREBASE_CLIENT_EMAIL &&
  process.env.FIREBASE_PRIVATE_KEY;

let credentialConfig;

if (hasEnvCredentials) {
  // Cloud / server environment: build credential from env vars
  credentialConfig = {
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    // On platforms like Vercel the private key is usually stored with \n,
    // so we need to convert them back to real newlines.
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  };
} else {
  // Local development fallback: load serviceAccountKey.json from disk
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

  if (!fs.existsSync(serviceAccountPath)) {
    console.error('❌ ERROR: serviceAccountKey.json not found, and FIREBASE_* env vars not set.');
    console.error('   For local development:');
    console.error('   1. Go to Firebase Console > Project Settings > Service Accounts');
    console.error('   2. Click "Generate new private key"');
    console.error('   3. Save as senseai_backend/serviceAccountKey.json');
    console.error('');
    console.error('   For production (e.g. Vercel), set these env vars instead:');
    console.error('   - FIREBASE_PROJECT_ID');
    console.error('   - FIREBASE_CLIENT_EMAIL');
    console.error('   - FIREBASE_PRIVATE_KEY');
    process.exit(1);
  }

  let serviceAccount;
  try {
    serviceAccount = require(serviceAccountPath);

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

  credentialConfig = {
    projectId: serviceAccount.project_id,
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  };
}

// Initialize Firebase Admin with the chosen credential config
let app;
try {
  app = admin.initializeApp({
    credential: admin.credential.cert(credentialConfig),
  });
  console.log('✅ Firebase Firestore connected successfully!');
  console.log(`   Project ID: ${credentialConfig.projectId}`);
} catch (err) {
  console.error('❌ ERROR: Failed to initialize Firebase:', err.message);
  if (err.message.includes('UNAUTHENTICATED') || err.message.includes('invalid')) {
    console.error('   This usually means:');
    console.error('   1. Service account key is expired or revoked');
    console.error('   2. Service account was deleted from Firebase');
    console.error('   3. Wrong Firebase project or env vars');
    console.error('   Solution: update Firebase credentials (env vars or serviceAccountKey.json).');
  }
  process.exit(1);
}

const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });

// Lightweight connection test so failures surface clearly at startup.
db.collection('_test')
  .limit(1)
  .get()
  .then(() => {
    console.log('✅ Firebase connection test successful!');
  })
  .catch((err) => {
    if (err.code === 16 || err.message.includes('UNAUTHENTICATED')) {
      console.error('⚠️  WARNING: Firebase authentication error');
      console.error('   Error:', err.message);
      console.error('   Check your service account / env vars and roles.');
    } else {
      console.error('⚠️  WARNING: Firebase connection test failed:', err.message);
    }
  });

module.exports = { db };