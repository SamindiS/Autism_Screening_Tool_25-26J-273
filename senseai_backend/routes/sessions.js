const express = require('express');
const Joi = require('joi');
const { db } = require('../firebase');
const dataValidation = require('../services/dataValidation');
const dataRecovery = require('../services/dataRecovery');

const router = express.Router();
const sessionsCollection = db.collection('sessions');
const childrenCollection = db.collection('children');
const trialsCollection = db.collection('trials');

const sessionSchema = Joi.object({
  child_id: Joi.string().required(),
  session_type: Joi.string()
    .valid('ai_doctor_bot', 'frog_jump', 'color_shape', 'color-shape', 'manual_assessment', 'rrb', 'auditory', 'visual')
    .required(),
  age_group: Joi.string().allow(null, '').optional(),
  start_time: Joi.number().integer().positive().required(),
  end_time: Joi.number().integer().positive().allow(null).optional(),
  metrics: Joi.object().allow(null).optional(),
  game_results: Joi.object().allow(null).optional(),
  questionnaire_results: Joi.object().allow(null).optional(),
  reflection_results: Joi.object().allow(null).optional(),
  risk_score: Joi.number().min(0).max(100).allow(null).optional(),
  risk_level: Joi.string().valid('low', 'moderate', 'high').allow(null).optional(),
});

const updateSchema = Joi.object({
  end_time: Joi.number().integer().positive().allow(null).optional(),
  metrics: Joi.object().allow(null).optional(),
  game_results: Joi.object().allow(null).optional(),
  questionnaire_results: Joi.object().allow(null).optional(),
  reflection_results: Joi.object().allow(null).optional(),
  risk_score: Joi.number().min(0).max(100).allow(null).optional(),
  risk_level: Joi.string().valid('low', 'moderate', 'high').allow(null).optional(),
}).min(1);

const toSession = (doc) => ({
  id: doc.id,
  ...doc.data(),
});

const deleteTrialsForSession = async (sessionId) => {
  const snap = await trialsCollection.where('session_id', '==', sessionId).get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach((trial) => batch.delete(trial.ref));
  await batch.commit();
};

router.post('/', async (req, res) => {
  try {
    console.log('📥 Received session creation request:', JSON.stringify(req.body, null, 2));
    
    // Normalize session_type: convert hyphen to underscore (color-shape -> color_shape)
    // This must happen BEFORE Joi validation
    if (req.body.session_type) {
      req.body.session_type = req.body.session_type.replace(/-/g, '_');
    }
    
    // Joi schema validation
    const { error, value } = sessionSchema.validate(req.body);
    if (error) {
      console.error('❌ Validation error:', error.details[0].message);
      return res.status(400).json({ error: error.details[0].message });
    }

    // Create backup before operation
    const backup = await dataRecovery.createPreOperationBackup('create-session');
    console.log(`📦 Pre-operation backup created: ${backup.backupId}`);
    
    // Enhanced validation (warnings don't block, only errors do)
    const validationResult = await dataValidation.validateSession(value, false);
    if (!validationResult.valid) {
      console.error('❌ Enhanced validation failed:', validationResult.errors);
      return res.status(400).json({
        error: 'Data validation failed',
        errors: validationResult.errors,
        warnings: validationResult.warnings,
      });
    }
    
    // Log warnings but don't block creation
    if (validationResult.warnings.length > 0) {
      console.warn('⚠️  Validation warnings (non-blocking):', validationResult.warnings);
    }

    // Try to verify child exists in Firebase, but don't block if Firebase is unavailable
    try {
      const childDoc = await childrenCollection.doc(value.child_id).get();
      if (!childDoc.exists) {
        console.warn(`⚠️  Child ID ${value.child_id} not found in Firebase (may exist locally - allowing session creation)`);
        // Don't block - child might exist locally but not synced to Firebase yet
      }
    } catch (err) {
      // Firebase unavailable - allow session creation anyway (offline mode)
      if (err.code === 16 || err.message.includes('UNAUTHENTICATED') || err.message.includes('authentication')) {
        console.warn(`⚠️  Firebase authentication unavailable - allowing session creation in offline mode: ${err.message}`);
      } else {
        console.warn(`⚠️  Could not verify child in Firebase - allowing session creation anyway: ${err.message}`);
      }
    }

    const session = {
      ...value,
      created_at: Date.now(),
      updated_at: Date.now(),
    };

    // Try to save to Firebase, but don't fail if Firebase is unavailable
    try {
      const ref = await sessionsCollection.add(session);
      const saved = await ref.get();
      console.log(`✅ Session created in Firebase: ${ref.id} (Type: ${session.session_type}, Child: ${session.child_id})`);
      res.status(201).json({ 
        session: toSession(saved),
        saved_to_firebase: true,
        warnings: validationResult.warnings
      });
    } catch (firebaseErr) {
      // Firebase unavailable - return session data anyway (app will save locally)
      if (firebaseErr.code === 16 || firebaseErr.message.includes('UNAUTHENTICATED') || firebaseErr.message.includes('authentication')) {
        console.warn(`⚠️  Firebase authentication unavailable - session will be saved locally only: ${firebaseErr.message}`);
        res.status(201).json({ 
          session: {
            ...session,
            id: `local_${Date.now()}`,
            saved_to_firebase: false
          },
          saved_to_firebase: false,
          warning: 'Session saved locally only (Firebase unavailable)',
          warnings: validationResult.warnings
        });
      } else {
        // Other Firebase errors - still return session for local saving
        console.warn(`⚠️  Firebase save failed - session will be saved locally: ${firebaseErr.message}`);
        res.status(201).json({ 
          session: {
            ...session,
            id: `local_${Date.now()}`,
            saved_to_firebase: false
          },
          saved_to_firebase: false,
          warning: 'Session saved locally only (Firebase error)',
          warnings: validationResult.warnings
        });
      }
    }
  } catch (err) {
    console.error('❌ Error creating session:', err);
    res.status(500).json({ error: err.message });
  }
});

router.get('/child/:childId', async (req, res) => {
  try {
    const snap = await sessionsCollection
      .where('child_id', '==', req.params.childId)
      .orderBy('created_at', 'desc')
      .get();
    const sessions = snap.docs.map(toSession);
    res.json({ count: sessions.length, sessions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const sessionType = req.query.type; // Filter by session type (e.g., 'color_shape', 'frog_jump')
    const hospital = req.query.hospital; // Filter by hospital (via child's hospital)
    
    let query = sessionsCollection.orderBy('created_at', 'desc');
    
    if (sessionType) {
      query = sessionsCollection.where('session_type', '==', sessionType).orderBy('created_at', 'desc');
    }
    
    const snap = await query.get();
    let sessions = snap.docs.map(toSession);
    
    // Filter by hospital if provided
    if (hospital) {
      const childIds = new Set();
      const childrenSnap = await childrenCollection.where('diagnosis_source', '==', hospital).get();
      childrenSnap.docs.forEach(doc => childIds.add(doc.id));
      
      sessions = sessions.filter(s => childIds.has(s.child_id));
    }
    
    res.json({ count: sessions.length, sessions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const doc = await sessionsCollection.doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ error: 'Session not found' });
    }
    res.json({ session: toSession(doc) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { error, value } = updateSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const docRef = sessionsCollection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const update = {
      ...value,
      updated_at: Date.now(),
    };
    await docRef.update(update);
    const updated = await docRef.get();
    res.json({ session: toSession(updated) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const docRef = sessionsCollection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Session not found' });
    }

    await deleteTrialsForSession(req.params.id);
    await docRef.delete();
    res.json({ message: 'Session deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

