// routes/sessions.js - Assessment Sessions Routes
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
const sessionSchema = Joi.object({
  child_id: Joi.string().required(),
  session_type: Joi.string().valid('ai_doctor_bot', 'frog_jump', 'color_shape', 'manual_assessment').required(),
  age_group: Joi.string().allow(null, '').optional(),
  start_time: Joi.number().integer().positive().required(),
  end_time: Joi.number().integer().positive().allow(null).optional(),
  metrics: Joi.object().allow(null).optional(),
  game_results: Joi.object().allow(null).optional(),
  questionnaire_results: Joi.object().allow(null).optional(),
  reflection_results: Joi.object().allow(null).optional(),
  risk_score: Joi.number().min(0).max(100).allow(null).optional(),
  risk_level: Joi.string().valid('low', 'moderate', 'high').allow(null).optional()
});

// Create a new session
// POST /api/sessions
router.post('/', async (req, res, next) => {
  try {
    const { error, value } = sessionSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const {
      child_id,
      session_type,
      age_group,
      start_time,
      end_time,
      metrics,
      game_results,
      questionnaire_results,
      reflection_results,
      risk_score,
      risk_level
    } = value;

    // Verify child exists
    const child = await db.promisify.get('SELECT * FROM children WHERE id = ?', [child_id]);
    if (!child) {
      return res.status(404).json({
        error: 'Child not found'
      });
    }

    // Generate unique ID
    const id = generateUUID();
    const createdAt = Date.now();

    // Convert objects to JSON strings for storage
    const metricsJson = metrics ? JSON.stringify(metrics) : null;
    const gameResultsJson = game_results ? JSON.stringify(game_results) : null;
    const questionnaireResultsJson = questionnaire_results ? JSON.stringify(questionnaire_results) : null;
    const reflectionResultsJson = reflection_results ? JSON.stringify(reflection_results) : null;

    await db.promisify.run(
      `INSERT INTO sessions (
        id, child_id, session_type, age_group, start_time, end_time,
        metrics, game_results, questionnaire_results, reflection_results,
        risk_score, risk_level, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id, child_id, session_type, age_group || null, start_time, end_time || null,
        metricsJson, gameResultsJson, questionnaireResultsJson, reflectionResultsJson,
        risk_score || null, risk_level || null, createdAt
      ]
    );

    res.status(201).json({
      message: 'Session created successfully',
      session: {
        id: id,
        child_id: child_id,
        session_type: session_type,
        age_group: age_group,
        start_time: start_time,
        end_time: end_time,
        risk_score: risk_score,
        risk_level: risk_level,
        created_at: createdAt
      }
    });
  } catch (err) {
    next(err);
  }
});

// Get all sessions
// GET /api/sessions
router.get('/', async (req, res, next) => {
  try {
    const sessions = await db.promisify.all(
      'SELECT * FROM sessions ORDER BY created_at DESC'
    );

    // Parse JSON strings back to objects
    const parsedSessions = sessions.map(session => ({
      ...session,
      metrics: session.metrics ? JSON.parse(session.metrics) : null,
      game_results: session.game_results ? JSON.parse(session.game_results) : null,
      questionnaire_results: session.questionnaire_results ? JSON.parse(session.questionnaire_results) : null,
      reflection_results: session.reflection_results ? JSON.parse(session.reflection_results) : null
    }));

    res.json({
      count: parsedSessions.length,
      sessions: parsedSessions
    });
  } catch (err) {
    next(err);
  }
});

// Get session by ID
// GET /api/sessions/:id
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const session = await db.promisify.get(
      'SELECT * FROM sessions WHERE id = ?',
      [id]
    );

    if (!session) {
      return res.status(404).json({
        error: 'Session not found'
      });
    }

    // Parse JSON strings back to objects
    const parsedSession = {
      ...session,
      metrics: session.metrics ? JSON.parse(session.metrics) : null,
      game_results: session.game_results ? JSON.parse(session.game_results) : null,
      questionnaire_results: session.questionnaire_results ? JSON.parse(session.questionnaire_results) : null,
      reflection_results: session.reflection_results ? JSON.parse(session.reflection_results) : null
    };

    res.json({ session: parsedSession });
  } catch (err) {
    next(err);
  }
});

// Get sessions by child ID
// GET /api/sessions/child/:childId
router.get('/child/:childId', async (req, res, next) => {
  try {
    const { childId } = req.params;
    
    const sessions = await db.promisify.all(
      'SELECT * FROM sessions WHERE child_id = ? ORDER BY created_at DESC',
      [childId]
    );

    // Parse JSON strings back to objects
    const parsedSessions = sessions.map(session => ({
      ...session,
      metrics: session.metrics ? JSON.parse(session.metrics) : null,
      game_results: session.game_results ? JSON.parse(session.game_results) : null,
      questionnaire_results: session.questionnaire_results ? JSON.parse(session.questionnaire_results) : null,
      reflection_results: session.reflection_results ? JSON.parse(session.reflection_results) : null
    }));

    res.json({
      count: parsedSessions.length,
      sessions: parsedSessions
    });
  } catch (err) {
    next(err);
  }
});

// Update session
// PUT /api/sessions/:id
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    // Check if session exists
    const existing = await db.promisify.get(
      'SELECT * FROM sessions WHERE id = ?',
      [id]
    );

    if (!existing) {
      return res.status(404).json({
        error: 'Session not found'
      });
    }

    // Allow partial updates
    const updateSchema = Joi.object({
      end_time: Joi.number().integer().positive().allow(null).optional(),
      metrics: Joi.object().allow(null).optional(),
      game_results: Joi.object().allow(null).optional(),
      questionnaire_results: Joi.object().allow(null).optional(),
      reflection_results: Joi.object().allow(null).optional(),
      risk_score: Joi.number().min(0).max(100).allow(null).optional(),
      risk_level: Joi.string().valid('low', 'moderate', 'high').allow(null).optional()
    });

    const { error, value } = updateSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];

    if (value.end_time !== undefined) {
      updates.push('end_time = ?');
      values.push(value.end_time);
    }
    if (value.metrics !== undefined) {
      updates.push('metrics = ?');
      values.push(value.metrics ? JSON.stringify(value.metrics) : null);
    }
    if (value.game_results !== undefined) {
      updates.push('game_results = ?');
      values.push(value.game_results ? JSON.stringify(value.game_results) : null);
    }
    if (value.questionnaire_results !== undefined) {
      updates.push('questionnaire_results = ?');
      values.push(value.questionnaire_results ? JSON.stringify(value.questionnaire_results) : null);
    }
    if (value.reflection_results !== undefined) {
      updates.push('reflection_results = ?');
      values.push(value.reflection_results ? JSON.stringify(value.reflection_results) : null);
    }
    if (value.risk_score !== undefined) {
      updates.push('risk_score = ?');
      values.push(value.risk_score);
    }
    if (value.risk_level !== undefined) {
      updates.push('risk_level = ?');
      values.push(value.risk_level);
    }

    if (updates.length === 0) {
      return res.status(400).json({
        error: 'No fields to update'
      });
    }

    values.push(id);

    await db.promisify.run(
      `UPDATE sessions SET ${updates.join(', ')} WHERE id = ?`,
      values
    );

    // Get updated session
    const updated = await db.promisify.get('SELECT * FROM sessions WHERE id = ?', [id]);
    const parsedSession = {
      ...updated,
      metrics: updated.metrics ? JSON.parse(updated.metrics) : null,
      game_results: updated.game_results ? JSON.parse(updated.game_results) : null,
      questionnaire_results: updated.questionnaire_results ? JSON.parse(updated.questionnaire_results) : null,
      reflection_results: updated.reflection_results ? JSON.parse(updated.reflection_results) : null
    };

    res.json({
      message: 'Session updated successfully',
      session: parsedSession
    });
  } catch (err) {
    next(err);
  }
});

// Delete session
// DELETE /api/sessions/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if session exists
    const existing = await db.promisify.get(
      'SELECT * FROM sessions WHERE id = ?',
      [id]
    );

    if (!existing) {
      return res.status(404).json({
        error: 'Session not found'
      });
    }

    // Delete session (cascade will delete related trials)
    await db.promisify.run('DELETE FROM sessions WHERE id = ?', [id]);

    res.json({
      message: 'Session deleted successfully'
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

