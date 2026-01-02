// server.js - SenseAI Backend bridged to Firebase
const express = require('express');
const cors = require('cors');

require('./firebase'); // Initialize Firebase Admin SDK / Firestore

const app = express();
const PORT = process.env.PORT || 3000;

// Core middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request logging middleware (for debugging)
app.use((req, res, next) => {
  console.log(`\n${new Date().toISOString()} ${req.method} ${req.path}`);
  if (req.body && Object.keys(req.body).length > 0) {
    // Mask sensitive data
    const logBody = { ...req.body };
    if (logBody.pin) logBody.pin = '***';
    console.log('Body:', JSON.stringify(logBody, null, 2));
  }
  next();
});

// API routes
app.use('/api/children', require('./routes/children'));
app.use('/api/sessions', require('./routes/sessions'));
app.use('/api/trials', require('./routes/trials'));
app.use('/api/clinicians', require('./routes/clinicians'));
app.use('/api/ml', require('./routes/ml_predictions'));
app.use('/api/export', require('./routes/export'));
app.use('/api/validation', require('./routes/dataValidation'));
app.use('/api/integrity', require('./routes/dataValidation'));
app.use('/api/backup', require('./routes/dataValidation'));

// Health check (required for tablet sync)
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('='.repeat(50));
  console.log('SenseAI Backend + Firebase running');
  console.log('='.repeat(50));
  console.log(`→ Listening on http://0.0.0.0:${PORT}`);
  console.log(`→ Health check: http://YOUR_LAPTOP_IP:${PORT}/health`);
  console.log('='.repeat(50));
});

module.exports = app;

