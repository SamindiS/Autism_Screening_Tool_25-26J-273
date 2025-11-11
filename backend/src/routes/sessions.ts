/**
 * Session Routes - Handle assessment session data
 */

import express, { Request, Response } from 'express';
import { db, storage } from '../config/firebase';
import { sessionSchema, validate } from '../utils/validation';
import logger from '../utils/logger';
import pako from 'pako';

const router = express.Router();

/**
 * POST /api/sessions
 * Create a new assessment session
 */
router.post('/', validate(sessionSchema), async (req: Request, res: Response) => {
  try {
    const sessionData = req.body;
    logger.info(`📥 Received session data: ${sessionData.session_id}`);

    // Extract trial data if exists
    const trials = sessionData.game_data?.trials || [];
    let trialsStoragePath = null;

    // Step 1: Upload trials to Storage if > 10 trials (compress as NDJSON)
    if (trials.length > 0) {
      logger.info(`📤 Uploading ${trials.length} trials to Storage`);
      
      // Convert to NDJSON (newline-delimited JSON)
      const ndjson = trials.map((trial: any) => JSON.stringify(trial)).join('\n');
      
      // Compress with gzip
      const compressed = pako.gzip(ndjson);
      
      // Upload to Firebase Storage
      const bucket = storage.bucket();
      const fileName = `sessions/${sessionData.session_id}/trials.ndjson.gz`;
      const file = bucket.file(fileName);
      
      await file.save(compressed, {
        contentType: 'application/gzip',
        metadata: {
          metadata: {
            originalSize: ndjson.length.toString(),
            compressedSize: compressed.length.toString(),
            trialCount: trials.length.toString(),
            uploadedAt: new Date().toISOString(),
          },
        },
      });

      trialsStoragePath = fileName;
      logger.info(`✅ Trials uploaded: ${fileName}`);
      
      // Remove trials from session data to save space in Firestore
      delete sessionData.game_data.trials;
    }

    // Step 2: Upload questionnaire to Storage if exists
    let questionnaireStoragePath = null;
    if (sessionData.questionnaire_data) {
      const bucket = storage.bucket();
      const fileName = `sessions/${sessionData.session_id}/questionnaire.json`;
      const file = bucket.file(fileName);
      
      await file.save(JSON.stringify(sessionData.questionnaire_data, null, 2), {
        contentType: 'application/json',
      });

      questionnaireStoragePath = fileName;
      logger.info(`✅ Questionnaire uploaded: ${fileName}`);
    }

    // Step 3: Create Firestore document with summary + storage references
    const sessionDoc = {
      ...sessionData,
      storage_refs: {
        trials: trialsStoragePath,
        questionnaire: questionnaireStoragePath,
      },
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      status: 'completed',
      ml_status: 'pending', // Will be updated by ML function
    };

    // Save to Firestore
    const docRef = db
      .collection('clinics')
      .doc(sessionData.clinic_id)
      .collection('children')
      .doc(sessionData.child.child_id)
      .collection('assessments')
      .doc(sessionData.session_id);

    await docRef.set(sessionDoc);

    logger.info(`✅ Session saved to Firestore: ${sessionData.session_id}`);

    // Step 4: Trigger ML prediction (asynchronously)
    // This will be handled by a Cloud Function or separate endpoint
    
    // Return success response
    res.status(201).json({
      success: true,
      message: 'Session data saved successfully',
      data: {
        session_id: sessionData.session_id,
        storage_refs: {
          trials: trialsStoragePath,
          questionnaire: questionnaireStoragePath,
        },
        firestore_path: docRef.path,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error saving session: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error saving session data',
      error: error.message,
    });
  }
});

/**
 * GET /api/sessions/:sessionId
 * Get a specific session
 */
router.get('/:sessionId', async (req: Request, res: Response) => {
  try {
    const { sessionId } = req.params;
    const { clinicId, childId } = req.query;

    if (!clinicId || !childId) {
      return res.status(400).json({
        success: false,
        message: 'clinicId and childId are required',
      });
    }

    const docRef = db
      .collection('clinics')
      .doc(clinicId as string)
      .collection('children')
      .doc(childId as string)
      .collection('assessments')
      .doc(sessionId);

    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Session not found',
      });
    }

    res.json({
      success: true,
      data: {
        ...doc.data(),
        id: doc.id,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error fetching session: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching session',
      error: error.message,
    });
  }
});

/**
 * GET /api/sessions/:sessionId/trials
 * Get trial data from Storage
 */
router.get('/:sessionId/trials', async (req: Request, res: Response) => {
  try {
    const { sessionId } = req.params;
    
    const bucket = storage.bucket();
    const fileName = `sessions/${sessionId}/trials.ndjson.gz`;
    const file = bucket.file(fileName);

    // Check if file exists
    const [exists] = await file.exists();
    if (!exists) {
      return res.status(404).json({
        success: false,
        message: 'Trial data not found',
      });
    }

    // Download and decompress
    const [contents] = await file.download();
    const decompressed = pako.ungzip(contents, { to: 'string' });
    
    // Parse NDJSON to array
    const trials = decompressed.split('\n').filter(line => line.trim()).map(line => JSON.parse(line));

    res.json({
      success: true,
      data: {
        trials,
        count: trials.length,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error fetching trials: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching trial data',
      error: error.message,
    });
  }
});

/**
 * GET /api/sessions/child/:childId
 * Get all sessions for a child
 */
router.get('/child/:childId', async (req: Request, res: Response) => {
  try {
    const { childId } = req.params;
    const { clinicId } = req.query;

    if (!clinicId) {
      return res.status(400).json({
        success: false,
        message: 'clinicId is required',
      });
    }

    const querySnapshot = await db
      .collection('clinics')
      .doc(clinicId as string)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .orderBy('created_at', 'desc')
      .get();

    const sessions = querySnapshot.docs.map(doc => ({
      ...doc.data(),
      id: doc.id,
    }));

    res.json({
      success: true,
      data: {
        sessions,
        count: sessions.length,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error fetching child sessions: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching sessions',
      error: error.message,
    });
  }
});

export default router;






