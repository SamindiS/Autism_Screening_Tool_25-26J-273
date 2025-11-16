// server.js - Main Express Server
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const db = require('./db');

// Import routes
const clinicianRoutes = require('./routes/clinicians');
const childRoutes = require('./routes/children');
const sessionRoutes = require('./routes/sessions');
const trialRoutes = require('./routes/trials');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api/clinicians', clinicianRoutes);
app.use('/api/children', childRoutes);
app.use('/api/sessions', sessionRoutes);
app.use('/api/trials', trialRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    database: 'connected'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'SenseAI Local Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      clinicians: '/api/clinicians',
      children: '/api/children',
      sessions: '/api/sessions',
      trials: '/api/trials'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.path,
    method: req.method
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('='.repeat(50));
  console.log('SenseAI Local Backend Server');
  console.log('='.repeat(50));
  console.log(`✓ Server running on http://localhost:${PORT}`);
  console.log(`✓ API available at http://0.0.0.0:${PORT}/api`);
  console.log(`✓ Health check: http://localhost:${PORT}/health`);
  console.log('='.repeat(50));
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down server...');
  db.close((err) => {
    if (err) {
      console.error('Error closing database:', err.message);
    } else {
      console.log('✓ Database connection closed');
    }
    process.exit(0);
  });
});

module.exports = app;

