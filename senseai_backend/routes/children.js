const express = require('express');
const Joi = require('joi');
const { db } = require('../firebase');

const router = express.Router();
const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');

const childSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  date_of_birth: Joi.number().integer().positive().required(),
  gender: Joi.string().valid('male', 'female', 'other').required(),
  language: Joi.string().valid('en', 'si', 'ta').required(),
  hospital_id: Joi.string().allow(null, '').optional(),
  clinician_id: Joi.string().allow(null, '').optional(),
});

const calculateAge = (dobMs) => {
  const now = Date.now();
  return (now - dobMs) / (1000 * 60 * 60 * 24 * 365.25);
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
      ...value,
      age: value.date_of_birth ? calculateAge(value.date_of_birth) : null,
      created_at: now,
      updated_at: now,
    };

    const ref = await childrenCollection.add(child);
    const snapshot = await ref.get();
    res.status(201).json({ child: toChild(snapshot) });
  } catch (err) {
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
      ...value,
      age: value.date_of_birth ? calculateAge(value.date_of_birth) : null,
      updated_at: Date.now(),
    };

    await docRef.update(update);
    const updated = await docRef.get();
    res.json({ child: toChild(updated) });
  } catch (err) {
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
    res.json({ message: 'Child deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

