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
      console.log('❌ Registration validation error:', error.details[0].message);
      return res.status(400).json({ error: error.details[0].message });
    }

    // Check if PIN is exactly 4 digits for clinicians
    const pin = String(value.pin).trim();
    if (!/^\d{4}$/.test(pin)) {
      console.log('❌ Registration failed: PIN must be exactly 4 digits');
      return res.status(400).json({ error: 'Clinician PIN must be exactly 4 digits' });
    }

    console.log(`📝 Registering clinician: ${value.name} from ${value.hospital}`);

    const pinHash = await bcrypt.hash(pin, 10);
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

router.post('/login', async (req, res) => {
  try {
    console.log('\n' + '='.repeat(50));
    console.log('🔐 LOGIN REQUEST RECEIVED');
    console.log('='.repeat(50));
    console.log('Request body:', JSON.stringify(req.body, null, 2));
    console.log('Request headers:', JSON.stringify(req.headers, null, 2));
    
    // Get PIN from request body
    const pin = req.body?.pin || req.body;
    console.log(`📌 PIN received: ${pin ? (pin.length > 0 ? pin.substring(0, 2) + '***' : 'empty') : 'null'}`);
    
    // Check if PIN is provided
    if (!pin) {
      console.log('❌ Login failed: PIN is required');
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
        // Also include 'clinician' for backward compatibility
        clinician: {
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

    // Use the validated PIN from Joi, or fallback to original pin
    const pinToCompare = String(value.pin || pin).trim();
    console.log(`🔍 Attempting login with PIN (length: ${pinToCompare.length})`);

    for (const doc of allClinicians.docs) {
      const data = doc.data();
      
      // Check if pin_hash exists
      if (!data.pin_hash) {
        console.log(`⚠️  Clinician ${doc.id} has no pin_hash`);
        continue;
      }

      // Compare PIN
      const match = await bcrypt.compare(pinToCompare, data.pin_hash);
      if (match) {
        matchedClinician = doc;
        console.log(`✅ PIN match found for clinician: ${doc.id}`);
        break;
      }
    }

    if (!matchedClinician) {
      console.log('❌ Login failed: Invalid PIN');
      return res.status(401).json({ error: 'Invalid PIN' });
    }

    const clinicianData = docToClinician(matchedClinician);
    console.log('✅ Login successful for clinician:', clinicianData.id, clinicianData.name);

    res.json({
      success: true,
      message: 'Login successful',
      role: 'clinician',
      isAdmin: false,
      user: {
        ...clinicianData,
        role: 'clinician',
      },
      // Also include 'clinician' for backward compatibility with Flutter app
      clinician: {
        ...clinicianData,
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

