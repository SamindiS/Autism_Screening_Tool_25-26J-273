const express = require('express');
const Joi = require('joi');
const { db } = require('../firebase');

const router = express.Router();
const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');

// Updated schema with pilot study fields + clinician info
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
  // Clinician info for ASD group (one-tap selection, no password)
  clinician_id: Joi.string().max(50).allow(null, '').optional(),
  clinician_name: Joi.string().max(200).allow(null, '').optional(),
});

const calculateAge = (dobMs) => {
  const now = Date.now();
  return (now - dobMs) / (1000 * 60 * 60 * 24 * 365.25);
};

const calculateAgeInMonths = (dobMs) => {
  const dob = new Date(dobMs);
  const now = new Date();
  let months = (now.getFullYear() - dob.getFullYear()) * 12;
  months += now.getMonth() - dob.getMonth();
  if (now.getDate() < dob.getDate()) months--;
  return months;
};

const toChild = (doc) => ({
  id: doc.id,
  ...doc.data(),
});

const deleteTrialsForSession = async (sessionId) => {
  const trialsSnap = await trialsCollection.where('session_id', '==', sessionId).get();
  if (trialsSnap.empty) return;
  const batch = db.batch();
  trialsSnap.docs.forEach((trial) => batch.delete(trial.ref));
  await batch.commit();
};

const deleteSessionsForChild = async (childId) => {
  const sessionsSnap = await sessionsCollection.where('child_id', '==', childId).get();
  if (sessionsSnap.empty) return;
  for (const sessionDoc of sessionsSnap.docs) {
    await deleteTrialsForSession(sessionDoc.id);
    await sessionDoc.ref.delete();
  }
};

router.post('/', async (req, res) => {
  try {
    const { error, value } = childSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const now = Date.now();
    const child = {
      child_code: value.child_code || value.name,
      name: value.name,
      date_of_birth: value.date_of_birth,
      age_in_months: value.age_in_months || calculateAgeInMonths(value.date_of_birth),
      gender: value.gender,
      language: value.language,
      age: value.date_of_birth ? calculateAge(value.date_of_birth) : null,
      hospital_id: value.hospital_id || null,
      // Pilot study fields
      group: value.group || 'typically_developing',
      asd_level: value.asd_level || null,
      diagnosis_source: value.diagnosis_source || 'Unknown',
      // Clinician info for ASD group
      clinician_id: value.clinician_id || null,
      clinician_name: value.clinician_name || null,
      created_at: now,
      updated_at: now,
    };

    const ref = await childrenCollection.add(child);
    const snapshot = await ref.get();
    console.log(`✅ Child created in Firebase: ${ref.id} (${child.child_code}, Group: ${child.group})`);
    res.status(201).json({ child: toChild(snapshot) });
  } catch (err) {
    console.error('❌ Error creating child:', err);
    res.status(500).json({ error: err.message });
  }
});

router.get('/clinician/:clinicianId', async (req, res) => {
  try {
    const snap = await childrenCollection
      .where('clinician_id', '==', req.params.clinicianId)
      .orderBy('created_at', 'desc')
      .get();
    const children = snap.docs.map(toChild);
    res.json({ count: children.length, children });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/', async (_req, res) => {
  try {
    const snap = await childrenCollection.orderBy('created_at', 'desc').get();
    const children = snap.docs.map(toChild);
    res.json({ count: children.length, children });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

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

router.put('/:id', async (req, res) => {
  try {
    const { error, value } = childSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const docRef = childrenCollection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Child not found' });
    }

    const update = {
      child_code: value.child_code || value.name,
      name: value.name,
      date_of_birth: value.date_of_birth,
      age_in_months: value.age_in_months || calculateAgeInMonths(value.date_of_birth),
      gender: value.gender,
      language: value.language,
      age: value.date_of_birth ? calculateAge(value.date_of_birth) : null,
      hospital_id: value.hospital_id || null,
      // Pilot study fields
      group: value.group || existing.data().group || 'typically_developing',
      asd_level: value.asd_level || null,
      diagnosis_source: value.diagnosis_source || existing.data().diagnosis_source || 'Unknown',
      // Clinician info for ASD group
      clinician_id: value.clinician_id || existing.data().clinician_id || null,
      clinician_name: value.clinician_name || existing.data().clinician_name || null,
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

router.delete('/:id', async (req, res) => {
  try {
    const docRef = childrenCollection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Child not found' });
    }

    await deleteSessionsForChild(req.params.id);
    await docRef.delete();
    console.log(`✅ Child deleted from Firebase: ${req.params.id}`);
    res.json({ message: 'Child deleted successfully' });
  } catch (err) {
    console.error('❌ Error deleting child:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
