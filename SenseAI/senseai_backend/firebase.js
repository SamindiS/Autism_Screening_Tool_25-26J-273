// firebase.js
//
// Firebase Admin initialization for both local development and cloud
// environments (e.g. Vercel).

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// --- 1. Main Project Configuration ---
const hasEnvCredentials =
  process.env.FIREBASE_PROJECT_ID &&
  process.env.FIREBASE_CLIENT_EMAIL &&
  process.env.FIREBASE_PRIVATE_KEY;

let mainConfig;
if (hasEnvCredentials) {
  mainConfig = {
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  };
} else {
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    mainConfig = {
      projectId: serviceAccount.project_id,
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    };
  }
}

// --- 2. Visual Project Configuration ---
let visualConfig = null;
const visualKeyPath = path.join(__dirname, 'config', 'visual_service_key.json');

const hasVisualEnvCredentials =
  process.env.VISUAL_FIREBASE_PROJECT_ID &&
  process.env.VISUAL_FIREBASE_CLIENT_EMAIL &&
  process.env.VISUAL_FIREBASE_PRIVATE_KEY;

if (hasVisualEnvCredentials) {
  visualConfig = {
    projectId: process.env.VISUAL_FIREBASE_PROJECT_ID,
    clientEmail: process.env.VISUAL_FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.VISUAL_FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  };
} else if (process.env.VISUAL_FIREBASE_KEY) {
  // Read from Environment Variable (for Vercel)
  try {
    visualConfig = JSON.parse(process.env.VISUAL_FIREBASE_KEY);
    if (visualConfig.private_key) {
        visualConfig.privateKey = visualConfig.private_key.replace(/\\n/g, '\n');
    }
  } catch (e) {
    console.error('❌ Failed to parse VISUAL_FIREBASE_KEY env var');
  }
} else if (fs.existsSync(visualKeyPath)) {
  // Read from local file
  visualConfig = require(visualKeyPath);
}

// --- 3. Initialize Apps ---
let app;
if (mainConfig) {
  try {
    app = admin.initializeApp({
      credential: admin.credential.cert(mainConfig),
    }, 'main');
    console.log('✅ Main Firebase connected!');
  } catch (err) {
    console.error('❌ Failed to initialize Main Firebase:', err.message);
  }
}

let visualDb = null;
if (visualConfig) {
  try {
    const visualApp = admin.initializeApp({
      credential: admin.credential.cert(visualConfig),
    }, 'visual');
    visualDb = admin.firestore(visualApp);
    console.log(`✅ Visual Firebase connected!`);
  } catch (err) {
    console.error('⚠️  Failed to initialize Visual Firebase:', err.message);
  }
}

const db = app ? admin.firestore(app) : null;
if (db) db.settings({ ignoreUndefinedProperties: true });
else console.error('❌ FATAL: Main Firebase app is not initialized. Check FIREBASE_PRIVATE_KEY env vars.');

if (visualDb) visualDb.settings({ ignoreUndefinedProperties: true });

module.exports = { db, visualDb };