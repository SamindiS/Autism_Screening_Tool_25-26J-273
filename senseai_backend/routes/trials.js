const express = require('express');
const Joi = require('joi');
const { db } = require('../firebase');

const router = express.Router();
const trialsCollection = db.collection('trials');
const sessionsCollection = db.collection('sessions');

const trialSchema = Joi.object({
  session_id: Joi.string().required(),
  trial_number: Joi.number().integer().min(1).required(),
  stimulus: Joi.string().allow(null, '').optional(),
  rule: Joi.string().allow(null, '').optional(),
  response: Joi.string().allow(null, '').optional(),
  correct: Joi.boolean().required(),
  reaction_time: Joi.number().integer().min(0).allow(null).optional(),
  timestamp: Joi.number().integer().positive().required(),
  is_post_switch: Joi.boolean().allow(null).optional(),
  is_perseverative_error: Joi.boolean().allow(null).optional(),
  additional_data: Joi.object().allow(null).optional(),
});

const toTrial = (doc) => ({
  id: doc.id,
  ...doc.data(),
});

const ensureSessionExists = async (sessionId) => {
  const session = await sessionsCollection.doc(sessionId).get();
  return session.exists;
};

router.post('/', async (req, res) => {
  try {
    const { error, value } = trialSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const sessionExists = await ensureSessionExists(value.session_id);
    if (!sessionExists) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const trial = {
      ...value,
      created_at: Date.now(),
      updated_at: Date.now(),
    };

    const ref = await trialsCollection.add(trial);
    const saved = await ref.get();
    res.status(201).json({ trial: toTrial(saved) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/session/:sessionId', async (req, res) => {
  try {
    const snap = await trialsCollection
      .where('session_id', '==', req.params.sessionId)
      .orderBy('trial_number', 'asc')
      .get();
    const trials = snap.docs.map(toTrial);
    res.json({ count: trials.length, trials });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const doc = await trialsCollection.doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ error: 'Trial not found' });
    }
    res.json({ trial: toTrial(doc) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/batch', async (req, res) => {
  try {
    const { trials } = req.body;
    if (!Array.isArray(trials) || trials.length === 0) {
      return res.status(400).json({ error: 'trials must be a non-empty array' });
    }

    for (const trial of trials) {
      const { error } = trialSchema.validate(trial);
      if (error) {
        return res.status(400).json({ error: error.details[0].message });
      }

      const exists = await ensureSessionExists(trial.session_id);
      if (!exists) {
        return res.status(404).json({ error: `Session not found: ${trial.session_id}` });
      }
    }

    const inserted = [];
    for (const trial of trials) {
      const payload = {
        ...trial,
        created_at: Date.now(),
        updated_at: Date.now(),
      };
      const ref = await trialsCollection.add(payload);
      const saved = await ref.get();
      inserted.push(toTrial(saved));
    }

    res.status(201).json({
      message: `${inserted.length} trials created successfully`,
      count: inserted.length,
      trials: inserted,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const docRef = trialsCollection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Trial not found' });
    }

    await docRef.delete();
    res.json({ message: 'Trial deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

