const express = require('express');
const bcrypt = require('bcrypt');
const Joi = require('joi');
const { db } = require('../firebase');

const router = express.Router();
const collection = db.collection('clinicians');

const registerSchema = Joi.object({
  name: Joi.string().min(3).max(100).required(),
  hospital: Joi.string().min(3).max(200).required(),
  pin: Joi.string()
    .pattern(/^\d{4}$/)
    .required()
    .messages({ 'string.pattern.base': 'PIN must be exactly 4 digits' }),
});

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

const getSingleClinician = async () => {
  const snap = await collection.limit(1).get();
  if (snap.empty) return null;
  return snap.docs[0];
};

router.post('/register', async (req, res) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    // Check if PIN is exactly 4 digits for clinicians
    if (!/^\d{4}$/.test(value.pin)) {
      return res.status(400).json({ error: 'Clinician PIN must be exactly 4 digits' });
    }

    const pinHash = await bcrypt.hash(value.pin, 10);
    const now = Date.now();
    const payload = {
      name: value.name,
      hospital: value.hospital,
      pin_hash: pinHash,
      created_at: now,
      updated_at: now,
    };

    // Allow multiple clinicians - just add new one
    const ref = await collection.add(payload);
    const saved = await ref.get();
    res.status(201).json({
      message: 'Clinician registered successfully',
      clinician: docToClinician(saved),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    // Get PIN from request body
    const pin = req.body?.pin || req.body;
    
    // Check if PIN is provided
    if (!pin) {
      return res.status(400).json({ error: 'PIN is required' });
    }

    // Check if admin login FIRST (before any validation) - this bypasses all validation
    if (pin === 'admin123') {
      console.log('✅ Admin login detected');
      return res.json({
        success: true,
        message: 'Admin login successful',
        role: 'admin',
        isAdmin: true,
        user: {
          id: 'admin',
          name: 'Administrator',
          hospital: 'All Hospitals',
          role: 'admin',
        },
      });
    }

    // Validate for regular clinician login (only if not admin)
    const { error, value } = loginSchema.validate({ pin });
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    // Regular clinician login - check all clinicians
    const allClinicians = await collection.get();
    let matchedClinician = null;

    for (const doc of allClinicians.docs) {
      const data = doc.data();
      const match = await bcrypt.compare(value.pin || pin, data.pin_hash);
      if (match) {
        matchedClinician = doc;
        break;
      }
    }

    if (!matchedClinician) {
      return res.status(401).json({ error: 'Invalid PIN' });
    }

    res.json({
      success: true,
      message: 'Login successful',
      role: 'clinician',
      isAdmin: false,
      user: {
        ...docToClinician(matchedClinician),
        role: 'clinician',
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all clinicians (for admin)
router.get('/', async (req, res) => {
  try {
    const hospital = req.query.hospital; // Optional filter by hospital
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

// Get single clinician by ID
router.get('/:id', async (req, res) => {
  try {
    const doc = await collection.doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ error: 'Clinician not found' });
    }
    res.json({ clinician: docToClinician(doc) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

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

