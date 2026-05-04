/**
 * Clinicians Routes - SenseAI Backend
 * ===================================
 * This file manages Clinician (Doctor) accounts, including authentication,
 * registration, and administrative access.
 */

const express = require('express');
const bcrypt = require('bcrypt'); // For secure password/PIN hashing
const Joi = require('joi'); // For request body validation
const { db } = require('../firebase'); // Firestore instance

const router = express.Router();
const collection = db.collection('clinicians');

/**
 * Joi Schema for Registration
 * Clinicians use a 4-digit PIN for quick access in clinical settings.
 */
const registerSchema = Joi.object({
  name: Joi.string().min(3).max(100).required(),
  hospital: Joi.string().min(3).max(200).required(),
  pin: Joi.string()
    .pattern(/^\d{4}$/)
    .required()
    .messages({ 'string.pattern.base': 'PIN must be exactly 4 digits' }),
});

/**
 * Joi Schema for Login
 * Accepts PINs for authentication.
 */
const loginSchema = Joi.object({
  pin: Joi.string()
    .min(4)
    .max(20)
    .required()
    .messages({ 
      'string.min': 'PIN must be at least 4 characters',
      'any.required': 'PIN is required'
    }),
});

/**
 * Utility: Clean up Firestore document for API response (removes sensitive hash)
 */
const docToClinician = (doc) => {
  const data = doc.data();
  return {
    id: doc.id,
    name: data.name,
    hospital: data.hospital,
    created_at: data.created_at,
    updated_at: data.updated_at,
  };
};

/**
 * Utility: Fetch any single clinician (used for health checks or simplified flows)
 */
const getSingleClinician = async () => {
  const snap = await collection.limit(1).get();
  if (snap.empty) return null;
  return snap.docs[0];
};

/**
 * Error Helper: Detects if a Firebase error is related to authentication
 */
const isFirestoreAuthError = (err) => {
  const msg = String(err?.message || '');
  return (
    err?.code === 16 ||
    err?.code === 7 ||
    msg.includes('UNAUTHENTICATED') ||
    msg.includes('PERMISSION_DENIED') ||
    msg.toLowerCase().includes('permission') ||
    msg.toLowerCase().includes('unauthenticated')
  );
};

/**
 * Admin Management: Load static admin accounts from environment variables
 * This allows "Super Admins" to login without being registered in the Firestore collection.
 * Supports ADMIN_USERS_JSON or comma-separated ADMIN_PINS.
 */
const loadManualAdmins = () => {
  const admins = [];

  // Method 1: Load from complex JSON env var
  const rawJson = (process.env.ADMIN_USERS_JSON || '').trim();
  if (rawJson) {
    try {
      const parsed = JSON.parse(rawJson);
      if (Array.isArray(parsed)) {
        parsed.forEach((a) => {
          const pin = a?.pin == null ? '' : String(a.pin).trim();
          if (!pin) return;
          admins.push({
            pin,
            id: a?.id ? String(a.id) : `admin_${pin}`,
            name: a?.name ? String(a.name) : 'Administrator',
            hospital: a?.hospital ? String(a.hospital) : 'All Hospitals',
            role: 'admin',
            isAdmin: true,
          });
        });
      }
    } catch (e) {
      console.warn('⚠️  ADMIN_USERS_JSON is not valid JSON. Ignoring it.');
    }
  }

  // Method 2: Load from simple comma-separated PINs
  const rawPins = (process.env.ADMIN_PINS || '').trim();
  if (rawPins) {
    rawPins
      .split(',')
      .map((p) => p.trim())
      .filter(Boolean)
      .forEach((pin) => {
        if (admins.some((a) => a.pin === pin)) return;
        admins.push({
          pin,
          id: `admin_${pin}`,
          name: 'Administrator',
          hospital: 'All Hospitals',
          role: 'admin',
          isAdmin: true,
        });
      });
  }

  // Fallback: Default local admin for development
  if (!admins.some((a) => a.pin === 'admin123')) {
    admins.push({
      pin: 'admin123',
      id: 'admin',
      name: 'Administrator',
      hospital: 'All Hospitals',
      role: 'admin',
      isAdmin: true,
    });
  }

  return admins;
};

/**
 * POST /register - Register a new doctor
 * Hashes the PIN using bcrypt before storing in Firestore.
 */
router.post('/register', async (req, res) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      console.log('❌ Registration validation error:', error.details[0].message);
      return res.status(400).json({ error: error.details[0].message });
    }

    const pin = String(value.pin).trim();
    if (!/^\d{4}$/.test(pin)) {
      console.log('❌ Registration failed: PIN must be exactly 4 digits');
      return res.status(400).json({ error: 'Clinician PIN must be exactly 4 digits' });
    }

    console.log(`📝 Registering clinician: ${value.name} from ${value.hospital}`);

    // Hash the PIN (bcrypt)
    const pinHash = await bcrypt.hash(pin, 10);
    const now = Date.now();
    const payload = {
      name: value.name,
      hospital: value.hospital,
      pin_hash: pinHash,
      created_at: now,
      updated_at: now,
    };

    const ref = await collection.add(payload);
    const saved = await ref.get();
    const clinicianData = docToClinician(saved);
    
    console.log('✅ Clinician registered successfully:', clinicianData.id);
    
    res.status(201).json({
      message: 'Clinician registered successfully',
      clinician: clinicianData,
    });
  } catch (err) {
    console.error('❌ Registration error:', err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * POST /login - Clinician & Admin Login
 * 1. Checks hardcoded/env admin PINs first (Fast path)
 * 2. If not admin, checks Firestore clinician collection
 * 3. Verifies PIN hash using bcrypt
 */
router.post('/login', async (req, res) => {
  try {
    console.log('\n🔐 LOGIN REQUEST RECEIVED');
    
    let rawPin = '';
    if (req.body && typeof req.body === 'object') {
      rawPin = req.body.pin != null ? String(req.body.pin).trim() : '';
    } else {
      rawPin = req.body != null ? String(req.body).trim() : '';
    }
    
    const pin = rawPin;
    if (!pin) {
      return res.status(400).json({ error: 'PIN is required' });
    }

    // Step 1: Check Admin List (Environment Variables)
    const manualAdmins = loadManualAdmins();
    const matchedAdmin = manualAdmins.find((a) => a.pin === pin);
    if (matchedAdmin) {
      console.log('✅ Admin login detected');
      return res.json({
        success: true,
        message: 'Admin login successful',
        role: 'admin',
        isAdmin: true,
        user: {
          id: matchedAdmin.id,
          name: matchedAdmin.name,
          hospital: matchedAdmin.hospital,
          role: 'admin',
        },
        clinician: {
          id: matchedAdmin.id,
          name: matchedAdmin.name,
          hospital: matchedAdmin.hospital,
          role: 'admin',
        },
      });
    }

    // Step 2: Regular Clinician Login (Firestore)
    let allClinicians;
    try {
      allClinicians = await collection.get();
    } catch (err) {
      if (isFirestoreAuthError(err)) {
        return res.status(503).json({
          error: 'Database connection error. Please check backend credentials.',
        });
      }
      return res.status(500).json({ error: err.message });
    }

    let matchedClinician = null;

    // Step 3: Iterate and verify PIN hash
    for (const doc of allClinicians.docs) {
      const data = doc.data();
      if (!data.pin_hash) continue;

      const match = await bcrypt.compare(pin, data.pin_hash);
      if (match) {
        matchedClinician = doc;
        break;
      }
    }

    if (!matchedClinician) {
      console.log('❌ Login failed: Invalid PIN');
      return res.status(401).json({ error: 'Invalid PIN' });
    }

    const clinicianData = docToClinician(matchedClinician);
    console.log('✅ Login successful:', clinicianData.name);

    res.json({
      success: true,
      message: 'Login successful',
      role: 'clinician',
      isAdmin: false,
      user: {
        ...clinicianData,
        role: 'clinician',
      },
      clinician: {
        ...clinicianData,
        role: 'clinician',
      },
    });
  } catch (err) {
    console.error('❌ Login error:', err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET / - List all clinicians (Admin use)
 */
router.get('/', async (req, res) => {
  try {
    const hospital = req.query.hospital;
    let query = collection.orderBy('created_at', 'desc');
    
    if (hospital) {
      query = collection.where('hospital', '==', hospital).orderBy('created_at', 'desc');
    }
    
    const snap = await query.get();
    const clinicians = snap.docs.map(doc => docToClinician(doc));
    res.json({ count: clinicians.length, clinicians });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /me - Get currently active clinician (Legacy support)
 */
router.get('/me', async (_req, res) => {
  try {
    const clinicianDoc = await getSingleClinician();
    if (!clinicianDoc) {
      return res.status(404).json({ error: 'No clinician registered' });
    }
    res.json({ clinician: docToClinician(clinicianDoc) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * PUT /:id - Update clinician details
 */
router.put('/:id', async (req, res) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const docRef = collection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Clinician not found' });
    }

    const pinHash = await bcrypt.hash(value.pin, 10);
    await docRef.update({
      name: value.name,
      hospital: value.hospital,
      pin_hash: pinHash,
      updated_at: Date.now(),
    });

    const updated = await docRef.get();
    res.json({
      message: 'Clinician updated successfully',
      clinician: docToClinician(updated),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * DELETE /:id - Delete a clinician account
 */
router.delete('/:id', async (req, res) => {
  try {
    const docRef = collection.doc(req.params.id);
    const existing = await docRef.get();
    if (!existing.exists) {
      return res.status(404).json({ error: 'Clinician not found' });
    }

    await docRef.delete();
    res.json({ message: 'Clinician deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
