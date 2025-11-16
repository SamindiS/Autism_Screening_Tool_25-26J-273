// routes/children.js - Children CRUD Routes
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
const childSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  date_of_birth: Joi.number().integer().positive().required(),
  gender: Joi.string().valid('male', 'female', 'other').required(),
  language: Joi.string().valid('en', 'si', 'ta').required(),
  hospital_id: Joi.string().allow(null, '').optional()
});

// Create a new child
// POST /api/children
router.post('/', async (req, res, next) => {
  try {
    const { error, value } = childSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { name, date_of_birth, gender, language, hospital_id } = value;
    
    // Calculate age in years
    const dob = new Date(date_of_birth);
    const now = new Date();
    const ageInMs = now - dob;
    const ageInYears = ageInMs / (1000 * 60 * 60 * 24 * 365.25);
    
    // Generate unique ID
    const id = generateUUID();
    const createdAt = Date.now();

    await db.promisify.run(
      `INSERT INTO children (id, name, date_of_birth, gender, language, age, hospital_id, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, name, date_of_birth, gender, language, ageInYears, hospital_id || null, createdAt]
    );

    res.status(201).json({
      message: 'Child created successfully',
      child: {
        id: id,
        name: name,
        date_of_birth: date_of_birth,
        gender: gender,
        language: language,
        age: ageInYears,
        hospital_id: hospital_id,
        created_at: createdAt
      }
    });
  } catch (err) {
    next(err);
  }
});

// Get all children
// GET /api/children
router.get('/', async (req, res, next) => {
  try {
    const children = await db.promisify.all(
      'SELECT * FROM children ORDER BY created_at DESC'
    );

    res.json({
      count: children.length,
      children: children
    });
  } catch (err) {
    next(err);
  }
});

// Get child by ID
// GET /api/children/:id
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const child = await db.promisify.get(
      'SELECT * FROM children WHERE id = ?',
      [id]
    );

    if (!child) {
      return res.status(404).json({
        error: 'Child not found'
      });
    }

    res.json({ child });
  } catch (err) {
    next(err);
  }
});

// Update child
// PUT /api/children/:id
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { error, value } = childSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    // Check if child exists
    const existing = await db.promisify.get(
      'SELECT * FROM children WHERE id = ?',
      [id]
    );

    if (!existing) {
      return res.status(404).json({
        error: 'Child not found'
      });
    }

    const { name, date_of_birth, gender, language, hospital_id } = value;
    
    // Recalculate age
    const dob = new Date(date_of_birth);
    const now = new Date();
    const ageInYears = (now - dob) / (1000 * 60 * 60 * 24 * 365.25);

    await db.promisify.run(
      `UPDATE children 
       SET name = ?, date_of_birth = ?, gender = ?, language = ?, age = ?, hospital_id = ?
       WHERE id = ?`,
      [name, date_of_birth, gender, language, ageInYears, hospital_id || null, id]
    );

    res.json({
      message: 'Child updated successfully',
      child: {
        id: id,
        name: name,
        date_of_birth: date_of_birth,
        gender: gender,
        language: language,
        age: ageInYears,
        hospital_id: hospital_id
      }
    });
  } catch (err) {
    next(err);
  }
});

// Delete child
// DELETE /api/children/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if child exists
    const existing = await db.promisify.get(
      'SELECT * FROM children WHERE id = ?',
      [id]
    );

    if (!existing) {
      return res.status(404).json({
        error: 'Child not found'
      });
    }

    // Delete child (cascade will delete related sessions and trials)
    await db.promisify.run('DELETE FROM children WHERE id = ?', [id]);

    res.json({
      message: 'Child deleted successfully'
    });
  } catch (err) {
    next(err);
  }
});

// Get children by clinician
// GET /api/children/clinician/:clinicianId
router.get('/clinician/:clinicianId', async (req, res, next) => {
  try {
    const { clinicianId } = req.params;
    
    const children = await db.promisify.all(
      'SELECT * FROM children WHERE clinician_id = ? ORDER BY created_at DESC',
      [clinicianId]
    );

    res.json({
      count: children.length,
      children: children
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

