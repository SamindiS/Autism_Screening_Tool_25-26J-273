const express = require('express');
const Joi = require('joi');
const { db } = require('../firebase');

const router = express.Router();
const sessionsCollection = db.collection('sessions');
const childrenCollection = db.collection('children');
const trialsCollection = db.collection('trials');

const sessionSchema = Joi.object({
  child_id: Joi.string().required(),
  session_type: Joi.string()
    .valid('ai_doctor_bot', 'frog_jump', 'color_shape', 'manual_assessment')
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
    const { error, value } = sessionSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const childDoc = await childrenCollection.doc(value.child_id).get();
    if (!childDoc.exists) {
      return res.status(404).json({ error: 'Child not found' });
    }

    const session = {
      ...value,
      created_at: Date.now(),
      updated_at: Date.now(),
    };

    const ref = await sessionsCollection.add(session);
    const saved = await ref.get();
    res.status(201).json({ session: toSession(saved) });
  } catch (err) {
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

router.get('/', async (_req, res) => {
  try {
    const snap = await sessionsCollection.orderBy('created_at', 'desc').get();
    const sessions = snap.docs.map(toSession);
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

