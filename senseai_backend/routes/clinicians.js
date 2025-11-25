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
    .pattern(/^\d{4}$/)
    .required()
    .messages({ 'string.pattern.base': 'PIN must be exactly 4 digits' }),
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

    const pinHash = await bcrypt.hash(value.pin, 10);
    const now = Date.now();
    const payload = {
      name: value.name,
      hospital: value.hospital,
      pin_hash: pinHash,
      created_at: now,
      updated_at: now,
    };

    const existing = await getSingleClinician();
    if (existing) {
      await existing.ref.update({ ...payload, created_at: existing.data().created_at });
      const updated = await existing.ref.get();
      return res.json({
        message: 'Clinician updated successfully',
        clinician: docToClinician(updated),
      });
    }

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
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const clinicianDoc = await getSingleClinician();
    if (!clinicianDoc) {
      return res.status(404).json({ error: 'No clinician registered. Please register first.' });
    }

    const match = await bcrypt.compare(value.pin, clinicianDoc.data().pin_hash);
    if (!match) {
      return res.status(401).json({ error: 'Invalid PIN' });
    }

    res.json({
      success: true,
      message: 'Login successful',
      clinician: docToClinician(clinicianDoc),
    });
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

