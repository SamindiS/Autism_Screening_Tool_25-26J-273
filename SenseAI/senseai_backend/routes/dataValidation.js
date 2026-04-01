/**
 * Data Validation and Integrity Routes
 * Provides endpoints for data validation, integrity checks, and recovery
 */

const express = require('express');
const router = express.Router();

const dataValidation = require('../services/dataValidation');
const dataIntegrity = require('../services/dataIntegrity');
const dataRecovery = require('../services/dataRecovery');

/**
 * POST /api/validation/child
 * Validate child data
 */
router.post('/child', async (req, res) => {
  try {
    const { childData, isUpdate } = req.body;
    const result = await dataValidation.validateChild(childData, isUpdate || false);
    
    res.json({
      success: result.valid,
      valid: result.valid,
      errors: result.errors,
      warnings: result.warnings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/validation/session
 * Validate session data
 */
router.post('/session', async (req, res) => {
  try {
    const { sessionData, isUpdate } = req.body;
    const result = await dataValidation.validateSession(sessionData, isUpdate || false);
    
    res.json({
      success: result.valid,
      valid: result.valid,
      errors: result.errors,
      warnings: result.warnings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/validation/trial
 * Validate trial data
 */
router.post('/trial', async (req, res) => {
  try {
    const { trialData } = req.body;
    const result = await dataValidation.validateTrial(trialData);
    
    res.json({
      success: result.valid,
      valid: result.valid,
      errors: result.errors,
      warnings: result.warnings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/integrity/check
 * Run all integrity checks
 */
router.get('/check', async (req, res) => {
  try {
    const results = await dataIntegrity.runAllIntegrityChecks();
    res.json({
      success: true,
      ...results,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/integrity/orphaned-sessions
 * Check for orphaned sessions
 */
router.get('/orphaned-sessions', async (req, res) => {
  try {
    const issues = await dataIntegrity.checkOrphanedSessions();
    res.json({
      success: true,
      issues,
      count: issues.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/integrity/orphaned-trials
 * Check for orphaned trials
 */
router.get('/orphaned-trials', async (req, res) => {
  try {
    const issues = await dataIntegrity.checkOrphanedTrials();
    res.json({
      success: true,
      issues,
      count: issues.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/integrity/consistency
 * Check data consistency
 */
router.get('/consistency', async (req, res) => {
  try {
    const issues = await dataIntegrity.checkDataConsistency();
    res.json({
      success: true,
      issues,
      count: issues.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/backup/create
 * Create a backup
 */
router.post('/create', async (req, res) => {
  try {
    const { backupName } = req.body;
    const result = await dataRecovery.createBackup(backupName);
    res.json(result);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/backup/restore
 * Restore from backup
 */
router.post('/restore', async (req, res) => {
  try {
    const { backupId, dryRun, collections } = req.body;
    const result = await dataRecovery.restoreBackup(backupId, {
      dryRun: dryRun || false,
      collections: collections || ['children', 'sessions', 'trials', 'clinicians'],
    });
    res.json(result);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/backup/list
 * List all backups
 */
router.get('/list', async (req, res) => {
  try {
    const backups = await dataRecovery.listBackups();
    res.json({
      success: true,
      backups,
      count: backups.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * DELETE /api/backup/:backupId
 * Delete a backup
 */
router.delete('/:backupId', async (req, res) => {
  try {
    const { backupId } = req.params;
    const result = await dataRecovery.deleteBackup(backupId);
    res.json(result);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/backup/rollback
 * Rollback to most recent backup
 */
router.post('/rollback', async (req, res) => {
  try {
    const result = await dataRecovery.rollback();
    res.json(result);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

module.exports = router;



