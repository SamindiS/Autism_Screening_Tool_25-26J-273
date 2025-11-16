// routes/clinicians.js - Clinician Authentication Routes
const express = require('express');
const bcrypt = require('bcrypt');
const Joi = require('joi');
const db = require('../db');

const router = express.Router();

// Validation schemas
const registerSchema = Joi.object({
  name: Joi.string().min(3).max(100).required(),
  hospital: Joi.string().min(3).max(200).required(),
  pin: Joi.string().pattern(/^\d{4}$/).required().messages({
    'string.pattern.base': 'PIN must be exactly 4 digits'
  })
});

const loginSchema = Joi.object({
  pin: Joi.string().pattern(/^\d{4}$/).required().messages({
    'string.pattern.base': 'PIN must be exactly 4 digits'
  })
});

// Register or Update Clinician
// POST /api/clinicians/register
router.post('/register', async (req, res, next) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { name, hospital, pin } = value;
    const pinHash = await bcrypt.hash(pin, 10);

    // Check if clinician already exists
    const existing = await db.promisify.get('SELECT * FROM clinicians LIMIT 1');

    if (existing) {
      // Update existing clinician
      await db.promisify.run(
        'UPDATE clinicians SET name = ?, hospital = ?, pin_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [name, hospital, pinHash, existing.id]
      );

      res.json({
        message: 'Clinician updated successfully',
        clinician: {
          id: existing.id,
          name: name,
          hospital: hospital
        }
      });
    } else {
      // Create new clinician
      const result = await db.promisify.run(
        'INSERT INTO clinicians (name, hospital, pin_hash) VALUES (?, ?, ?)',
        [name, hospital, pinHash]
      );

      res.status(201).json({
        message: 'Clinician registered successfully',
        clinician: {
          id: result.lastID,
          name: name,
          hospital: hospital
        }
      });
    }
  } catch (err) {
    next(err);
  }
});

// Login
// POST /api/clinicians/login
router.post('/login', async (req, res, next) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { pin } = value;

    // Get clinician
    const clinician = await db.promisify.get('SELECT * FROM clinicians LIMIT 1');

    if (!clinician) {
      return res.status(404).json({
        error: 'No clinician registered. Please register first.'
      });
    }

    // Verify PIN
    const match = await bcrypt.compare(pin, clinician.pin_hash);

    if (match) {
      res.json({
        success: true,
        message: 'Login successful',
        clinician: {
          id: clinician.id,
          name: clinician.name,
          hospital: clinician.hospital
        }
      });
    } else {
      res.status(401).json({
        error: 'Invalid PIN'
      });
    }
  } catch (err) {
    next(err);
  }
});

// Get current clinician info
// GET /api/clinicians/me
router.get('/me', async (req, res, next) => {
  try {
    const clinician = await db.promisify.get('SELECT id, name, hospital, created_at, updated_at FROM clinicians LIMIT 1');

    if (!clinician) {
      return res.status(404).json({
        error: 'No clinician registered'
      });
    }

    res.json({
      clinician: {
        id: clinician.id,
        name: clinician.name,
        hospital: clinician.hospital,
        created_at: clinician.created_at,
        updated_at: clinician.updated_at
      }
    });
  } catch (err) {
    next(err);
  }
});

// Update clinician
// PUT /api/clinicians/:id
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { error, value } = registerSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        error: 'Validation error',
        details: error.details[0].message
      });
    }

    const { name, hospital, pin } = value;
    
    // Check if clinician exists
    const existing = await db.promisify.get('SELECT * FROM clinicians WHERE id = ?', [id]);
    
    if (!existing) {
      return res.status(404).json({
        error: 'Clinician not found'
      });
    }

    // Hash new PIN if provided
    const pinHash = await bcrypt.hash(pin, 10);

    // Update clinician
    await db.promisify.run(
      'UPDATE clinicians SET name = ?, hospital = ?, pin_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [name, hospital, pinHash, id]
    );

    res.json({
      message: 'Clinician updated successfully',
      clinician: {
        id: id,
        name: name,
        hospital: hospital
      }
    });
  } catch (err) {
    next(err);
  }
});

// Delete clinician
// DELETE /api/clinicians/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if clinician exists
    const existing = await db.promisify.get('SELECT * FROM clinicians WHERE id = ?', [id]);
    
    if (!existing) {
      return res.status(404).json({
        error: 'Clinician not found'
      });
    }

    // Delete clinician
    await db.promisify.run('DELETE FROM clinicians WHERE id = ?', [id]);

    res.json({
      message: 'Clinician deleted successfully'
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;

