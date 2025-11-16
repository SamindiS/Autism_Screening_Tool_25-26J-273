// routes/trials.js - Trial Data Routes
const express = require('express');
const Joi = require('joi');
const db = require('../db');
const crypto = require('crypto');

// UUID generation with fallback for older Node.js versions
const generateUUID = () => {
  try {
    if (typeof crypto.randomUUID === 'function') {
      return crypto.randomUUID();
    }
  } catch (e) {
    // Fall through to fallback
  }
  // Fallback for Node.js < 14.17.0
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
};

const router = express.Router();

// Validation schema
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
  additional_data: Joi.object().allow(null).optional()
});

// Create a new trial
// POST /api/trials
router.post('/', async (req, res, next) => {
  try {
    const { error, value } = trialSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const {
      session_id,
      trial_number,
      stimulus,
      rule,
      response,
      correct,
      reaction_time,
      timestamp,
      is_post_switch,
      is_perseverative_error,
      additional_data
    } = value;

    // Verify session exists
    const session = await db.promisify.get('SELECT * FROM sessions WHERE id = ?', [session_id]);
    if (!session) {
      return res.status(404).json({
        error: 'Session not found'
      });
    }

      // Generate unique ID
      const id = generateUUID();

    // Convert additional_data to JSON string
    const additionalDataJson = additional_data ? JSON.stringify(additional_data) : null;

    await db.promisify.run(
      `INSERT INTO trials (
        id, session_id, trial_number, stimulus, rule, response,
        correct, reaction_time, timestamp, is_post_switch,
        is_perseverative_error, additional_data
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id, session_id, trial_number, stimulus || null, rule || null, response || null,
        correct ? 1 : 0, reaction_time || null, timestamp,
        is_post_switch !== null && is_post_switch !== undefined ? (is_post_switch ? 1 : 0) : null,
        is_perseverative_error !== null && is_perseverative_error !== undefined ? (is_perseverative_error ? 1 : 0) : null,
        additionalDataJson
      ]
    );

    res.status(201).json({
      message: 'Trial created successfully',
      trial: {
        id: id,
        session_id: session_id,
        trial_number: trial_number,
        stimulus: stimulus,
        rule: rule,
        response: response,
        correct: correct,
        reaction_time: reaction_time,
        timestamp: timestamp,
        is_post_switch: is_post_switch,
        is_perseverative_error: is_perseverative_error,
        additional_data: additional_data
      }
    });
  } catch (err) {
    next(err);
  }
});

// Get all trials for a session
// GET /api/trials/session/:sessionId
router.get('/session/:sessionId', async (req, res, next) => {
  try {
    const { sessionId } = req.params;
    
    const trials = await db.promisify.all(
      'SELECT * FROM trials WHERE session_id = ? ORDER BY trial_number ASC',
      [sessionId]
    );

    // Parse JSON strings and convert integers to booleans
    const parsedTrials = trials.map(trial => ({
      ...trial,
      correct: trial.correct === 1,
      is_post_switch: trial.is_post_switch !== null ? trial.is_post_switch === 1 : null,
      is_perseverative_error: trial.is_perseverative_error !== null ? trial.is_perseverative_error === 1 : null,
      additional_data: trial.additional_data ? JSON.parse(trial.additional_data) : null
    }));

    res.json({
      count: parsedTrials.length,
      trials: parsedTrials
    });
  } catch (err) {
    next(err);
  }
});

// Get trial by ID
// GET /api/trials/:id
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const trial = await db.promisify.get(
      'SELECT * FROM trials WHERE id = ?',
      [id]
    );

    if (!trial) {
      return res.status(404).json({
        error: 'Trial not found'
      });
    }

    // Parse JSON and convert integers to booleans
    const parsedTrial = {
      ...trial,
      correct: trial.correct === 1,
      is_post_switch: trial.is_post_switch !== null ? trial.is_post_switch === 1 : null,
      is_perseverative_error: trial.is_perseverative_error !== null ? trial.is_perseverative_error === 1 : null,
      additional_data: trial.additional_data ? JSON.parse(trial.additional_data) : null
    };

    res.json({ trial: parsedTrial });
  } catch (err) {
    next(err);
  }
});

// Batch create trials
// POST /api/trials/batch
router.post('/batch', async (req, res, next) => {
  try {
    const { trials } = req.body;

    if (!Array.isArray(trials) || trials.length === 0) {
      return res.status(400).json({
        error: 'trials must be a non-empty array'
      });
    }

    // Validate all trials
    const validationResults = trials.map(trial => {
      const { error } = trialSchema.validate(trial);
      return { trial, error };
    });

    const errors = validationResults.filter(r => r.error);
    if (errors.length > 0) {
      return res.status(400).json({
        error: 'Validation errors',
        details: errors.map(e => e.error.details[0].message)
      });
    }

    // Insert all trials
    const insertedTrials = [];
    for (const trialData of trials) {
      const {
        session_id,
        trial_number,
        stimulus,
        rule,
        response,
        correct,
        reaction_time,
        timestamp,
        is_post_switch,
        is_perseverative_error,
        additional_data
      } = trialData;

      // Verify session exists
      const session = await db.promisify.get('SELECT * FROM sessions WHERE id = ?', [session_id]);
      if (!session) {
        return res.status(404).json({
          error: `Session not found: ${session_id}`
        });
      }

      const id = generateUUID();
      const additionalDataJson = additional_data ? JSON.stringify(additional_data) : null;

      await db.promisify.run(
        `INSERT INTO trials (
          id, session_id, trial_number, stimulus, rule, response,
          correct, reaction_time, timestamp, is_post_switch,
          is_perseverative_error, additional_data
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          id, session_id, trial_number, stimulus || null, rule || null, response || null,
          correct ? 1 : 0, reaction_time || null, timestamp,
          is_post_switch !== null && is_post_switch !== undefined ? (is_post_switch ? 1 : 0) : null,
          is_perseverative_error !== null && is_perseverative_error !== undefined ? (is_perseverative_error ? 1 : 0) : null,
          additionalDataJson
        ]
      );

      insertedTrials.push({
        id: id,
        ...trialData
      });
    }

    res.status(201).json({
      message: `${insertedTrials.length} trials created successfully`,
      count: insertedTrials.length,
      trials: insertedTrials
    });
  } catch (err) {
    next(err);
  }
});

// Delete trial
// DELETE /api/trials/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if trial exists
    const existing = await db.promisify.get(
      'SELECT * FROM trials WHERE id = ?',
      [id]
    );

    if (!existing) {
      return res.status(404).json({
        error: 'Trial not found'
      });
    }

    await db.promisify.run('DELETE FROM trials WHERE id = ?', [id]);

    res.json({
      message: 'Trial deleted successfully'
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

