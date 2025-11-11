/**
 * Firebase Admin SDK Configuration
 */

import * as admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

// Initialize Firebase Admin SDK
const initializeFirebase = () => {
  try {
    // Check if already initialized
    if (admin.apps.length > 0) {
      console.log('✅ Firebase already initialized');
      return admin.app();
    }

    // Initialize with environment variables
    const serviceAccount = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    };

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
      storageBucket: process.env.STORAGE_BUCKET,
    });

    console.log('✅ Firebase Admin SDK initialized successfully');
    return admin.app();
  } catch (error) {
    console.error('❌ Error initializing Firebase:', error);
    throw error;
  }
};

// Initialize Firebase
initializeFirebase();

// Export Firestore, Storage, and Auth instances
export const db = admin.firestore();
export const storage = admin.storage();
export const auth = admin.auth();

// Firestore settings
db.settings({ ignoreUndefinedProperties: true });

export default admin;






