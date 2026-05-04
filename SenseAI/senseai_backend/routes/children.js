/**
 * Children Routes - SenseAI Backend
 * =================================
 * This file handles all API endpoints related to Child profiles.
 * It manages creation, retrieval, updates, and deletion of child records in Firestore.
 */

const express = require('express');
const Joi = require('joi'); // For request body validation
const { db } = require('../firebase'); // Firestore database instance
const dataValidation = require('../services/dataValidation'); // Custom data integrity service
const dataRecovery = require('../services/dataRecovery'); // Automated backup service

const router = express.Router();

// Reference to Firestore collections
const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');

/**
 * Joi Schema for Child Data Validation
 * Ensures that incoming data from the Flutter app or Web app matches expected types and values.
 */
const childSchema = Joi.object({
  child_code: Joi.string().min(1).max(50).optional(),
  name: Joi.string().min(1).max(100).required(),
  date_of_birth: Joi.number().integer().positive().required(),
  age_in_months: Joi.number().integer().min(0).optional(),
  gender: Joi.string().valid('male', 'female', 'other').required(),
  language: Joi.string().valid('en', 'si', 'ta').required(),
  hospital_id: Joi.string().allow(null, '').optional(),
  // Pilot study fields
  group: Joi.string().valid('asd', 'typically_developing').optional(),
  asd_level: Joi.string().valid('level_1', 'level_2', 'level_3', null).optional().allow(null),
  diagnosis_source: Joi.string().max(200).optional(),
  // Clinician info for ASD group
  clinician_id: Joi.string().max(50).allow(null, '').optional(),
  clinician_name: Joi.string().max(200).allow(null, '').optional(),
  // Who created this child (for dashboard filtering)
  created_by_clinician_id: Joi.string().max(50).allow(null, '').optional(),
  // NEW: Ground truth for v3+ training
  external_diagnosis: Joi.string().valid('asd', 'typically_developing', 'suspected', 'other', 'unknown', null).optional().allow(null),
  previous_diagnosis: Joi.string().max(200).allow(null, '').optional(),
  data_source: Joi.string().valid('pilot', 'app_live', 'unknown').default('app_live').optional(),
  // Legacy field support
  diagnosis_type: Joi.string().allow(null, '').optional(),
});

/**
 * Utility: Calculate age in decimal years based on DOB
 */
const calculateAge = (dobMs) => {
  const now = Date.now();
  return (now - dobMs) / (1000 * 60 * 60 * 24 * 365.25);
};

/**
 * Utility: Calculate exact age in months for clinical precision
 */
const calculateAgeInMonths = (dobMs) => {
  const dob = new Date(dobMs);
  const now = new Date();
  let months = (now.getFullYear() - dob.getFullYear()) * 12;
  months += now.getMonth() - dob.getMonth();
  if (now.getDate() < dob.getDate()) months--;
  return months;
};

/**
 * Utility: Convert Firestore document to a plain JavaScript object
 */
const toChild = (doc) => ({
  id: doc.id,
  ...doc.data(),
});

/**
 * Cleanup Helper: Recursively delete all trials associated with a session
 */
const deleteTrialsForSession = async (sessionId) => {
  const trialsSnap = await trialsCollection.where('session_id', '==', sessionId).get();
  if (trialsSnap.empty) return;
  const batch = db.batch();
  trialsSnap.docs.forEach((trial) => batch.delete(trial.ref));
  await batch.commit();
};

/**
 * Cleanup Helper: Recursively delete all sessions (and their trials) for a child
 * This ensures data integrity when a child record is deleted.
 */
const deleteSessionsForChild = async (childId) => {
  const sessionsSnap = await sessionsCollection.where('child_id', '==', childId).get();
  if (sessionsSnap.empty) return;
  for (const sessionDoc of sessionsSnap.docs) {
    await deleteTrialsForSession(sessionDoc.id);
    await sessionDoc.ref.delete();
  }
};

/**
 * POST / - Register a new child
 * 1. Validates input data
 * 2. Creates an automated backup
 * 3. Calculates clinical metrics (age in months)
 * 4. Saves to Firestore
 */
router.post('/', async (req, res) => {
  try {
    console.log('📥 Received child creation request:', JSON.stringify(req.body, null, 2));
    
    // Safety check: Create a backup before modifying the database
    const backup = await dataRecovery.createPreOperationBackup('create-child');
    console.log(`📦 Pre-operation backup created: ${backup.backupId}`);
    
    // Step 1: Basic validation
    const { error, value } = childSchema.validate(req.body);
    if (error) {
      console.error('❌ Validation error:', error.details[0].message);
      return res.status(400).json({ error: error.details[0].message });
    }
    
    // Step 2: Clinical consistency validation (checking age ranges, etc.)
    const validationResult = await dataValidation.validateChild(value, false);
    if (!validationResult.valid) {
      console.error('❌ Enhanced validation failed:', validationResult.errors);
      return res.status(400).json({
        error: 'Data validation failed',
        errors: validationResult.errors,
        warnings: validationResult.warnings,
      });
    }
    
    // Step 3: Log any warnings (non-critical issues like age-group mismatches)
    if (validationResult.warnings.length > 0) {
      console.warn('⚠️  Validation warnings (non-blocking):', validationResult.warnings);
    }

    const now = Date.now();
    
    // Step 4: Construct the final Child object
    const child = {
      child_code: value.child_code || value.name, // Fallback to name if code is missing
      name: value.name,
      date_of_birth: value.date_of_birth,
      age_in_months: value.age_in_months || calculateAgeInMonths(value.date_of_birth),
      gender: value.gender,
      language: value.language,
      age: value.date_of_birth ? calculateAge(value.date_of_birth) : null,
      hospital_id: value.hospital_id || null,
      group: value.group || 'typically_developing',
      asd_level: value.asd_level || null,
      diagnosis_source: value.diagnosis_source || 'Unknown',
      clinician_id: value.clinician_id || null,
      clinician_name: value.clinician_name || null,
      created_by_clinician_id: value.created_by_clinician_id || null,
      external_diagnosis: value.external_diagnosis || 'unknown',
      previous_diagnosis: value.previous_diagnosis || null,
      data_source: value.data_source || 'unknown',
      created_at: now,
      updated_at: now,
    };

    // Step 5: Save to Firestore
    const ref = await childrenCollection.add(child);
    const snapshot = await ref.get();
    console.log(`✅ Child created in Firebase: ${ref.id} (${child.child_code}, Group: ${child.group})`);
    res.status(201).json({ child: toChild(snapshot) });
  } catch (err) {
    console.error('❌ Error creating child:', err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /clinician/:clinicianId - Get all children visible to a specific clinician
 * Uses a "Broad Access" policy:
 * - Children assigned to the clinician
 * - Children created by the clinician
 * - Children in the same hospital as the clinician
 */
router.get('/clinician/:clinicianId', async (req, res) => {
  try {
    const clinicianId = req.params.clinicianId;
    
    // Fetch clinician profile to find their hospital association
    const clinicianDoc = await db.collection('clinicians').doc(clinicianId).get();
    let hospitalName = null;
    if (clinicianDoc.exists) {
      hospitalName = clinicianDoc.data().hospital;
    }

    // Run parallel queries for efficiency
    const queries = [
      childrenCollection.where('clinician_id', '==', clinicianId).get(),
      childrenCollection.where('created_by_clinician_id', '==', clinicianId).get(),
    ];
    
    if (hospitalName) {
      queries.push(childrenCollection.where('hospital_id', '==', hospitalName).get());
    }

    const snapshots = await Promise.all(queries);
    const seen = new Set();
    const children = [];
    
    // Deduplicate results (a child might be assigned to AND created by the same person)
    for (const snap of snapshots) {
      for (const doc of snap.docs) {
        if (!seen.has(doc.id)) {
          seen.add(doc.id);
          children.push(toChild(doc));
        }
      }
    }
    
    // Sort by newest first
    children.sort((a, b) => (b.created_at || 0) - (a.created_at || 0));
    res.json({ count: children.length, children });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET / - List all children (Admin only use)
 */
router.get('/', async (_req, res) => {
  try {
    const snap = await childrenCollection.orderBy('created_at', 'desc').get();
    const children = snap.docs.map(toChild);
    res.json({ count: children.length, children });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /:id - Fetch a single child's details
 */
router.get('/:id', async (req, res) => {
  try {
    const doc = await childrenCollection.doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ error: 'Child not found' });
    }
    res.json({ child: toChild(doc) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * PUT /:id - Update child profile
 * Handles recalculating age and logging updates.
 */
router.put('/:id', async (req, res) => {
  try {
    // Validate the new data
    const { error, value } = childSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const docRef = childrenCollection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Child not found' });
    }

    // Merge existing data with updates
    const update = {
      child_code: value.child_code || value.name,
      name: value.name,
      date_of_birth: value.date_of_birth,
      age_in_months: value.age_in_months || calculateAgeInMonths(value.date_of_birth),
      gender: value.gender,
      language: value.language,
      age: value.date_of_birth ? calculateAge(value.date_of_birth) : null,
      hospital_id: value.hospital_id || null,
      group: value.group || existing.data().group || 'typically_developing',
      asd_level: value.asd_level || null,
      diagnosis_source: value.diagnosis_source || existing.data().diagnosis_source || 'Unknown',
      clinician_id: value.clinician_id || existing.data().clinician_id || null,
      clinician_name: value.clinician_name || existing.data().clinician_name || null,
      external_diagnosis: value.external_diagnosis !== undefined ? value.external_diagnosis : (existing.data().external_diagnosis || 'unknown'),
      previous_diagnosis: value.previous_diagnosis !== undefined ? value.previous_diagnosis : existing.data().previous_diagnosis,
      data_source: value.data_source !== undefined ? value.data_source : (existing.data().data_source || 'unknown'),
      updated_at: Date.now(),
    };

    await docRef.update(update);
    const updated = await docRef.get();
    console.log(`✅ Child updated in Firebase: ${req.params.id} (Group: ${update.group})`);
    res.json({ child: toChild(updated) });
  } catch (err) {
    console.error('❌ Error updating child:', err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * DELETE /:id - Remove a child record
 * DANGER: This also deletes all associated test sessions and trial data!
 */
router.delete('/:id', async (req, res) => {
  try {
    const docRef = childrenCollection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Child not found' });
    }

    // Step 1: Cleanup associated sessions/trials
    await deleteSessionsForChild(req.params.id);
    
    // Step 2: Delete the child document
    await docRef.delete();
    console.log(`✅ Child deleted from Firebase: ${req.params.id}`);
    res.json({ message: 'Child deleted successfully' });
  } catch (err) {
    console.error('❌ Error deleting child:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
