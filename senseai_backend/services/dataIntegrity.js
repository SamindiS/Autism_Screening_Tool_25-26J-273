/**
 * Data Integrity Checking Service
 * Verifies data consistency, relationships, and identifies issues
 */

const { db } = require('../firebase');

const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');
const cliniciansCollection = db.collection('clinicians');

/**
 * Check for orphaned sessions (sessions without valid child)
 */
const checkOrphanedSessions = async () => {
  const issues = [];
  
  try {
    const sessionsSnap = await sessionsCollection.get();
    const childrenSnap = await childrenCollection.get();
    const childIds = new Set(childrenSnap.docs.map(doc => doc.id));
    
    for (const sessionDoc of sessionsSnap.docs) {
      const sessionData = sessionDoc.data();
      if (!childIds.has(sessionData.child_id)) {
        issues.push({
          type: 'orphaned_session',
          severity: 'high',
          sessionId: sessionDoc.id,
          childId: sessionData.child_id,
          message: `Session ${sessionDoc.id} references non-existent child ${sessionData.child_id}`,
        });
      }
    }
  } catch (error) {
    issues.push({
      type: 'error',
      severity: 'critical',
      message: `Error checking orphaned sessions: ${error.message}`,
    });
  }
  
  return issues;
};

/**
 * Check for orphaned trials (trials without valid session)
 */
const checkOrphanedTrials = async () => {
  const issues = [];
  
  try {
    const trialsSnap = await trialsCollection.get();
    const sessionsSnap = await sessionsCollection.get();
    const sessionIds = new Set(sessionsSnap.docs.map(doc => doc.id));
    
    for (const trialDoc of trialsSnap.docs) {
      const trialData = trialDoc.data();
      if (!sessionIds.has(trialData.session_id)) {
        issues.push({
          type: 'orphaned_trial',
          severity: 'high',
          trialId: trialDoc.id,
          sessionId: trialData.session_id,
          message: `Trial ${trialDoc.id} references non-existent session ${trialData.session_id}`,
        });
      }
    }
  } catch (error) {
    issues.push({
      type: 'error',
      severity: 'critical',
      message: `Error checking orphaned trials: ${error.message}`,
    });
  }
  
  return issues;
};

/**
 * Check for children with invalid clinician references
 */
const checkInvalidClinicianReferences = async () => {
  const issues = [];
  
  try {
    const childrenSnap = await childrenCollection.get();
    const cliniciansSnap = await cliniciansCollection.get();
    const clinicianIds = new Set(cliniciansSnap.docs.map(doc => doc.id));
    
    for (const childDoc of childrenSnap.docs) {
      const childData = childDoc.data();
      if (childData.clinician_id && !clinicianIds.has(childData.clinician_id)) {
        issues.push({
          type: 'invalid_clinician_reference',
          severity: 'medium',
          childId: childDoc.id,
          clinicianId: childData.clinician_id,
          message: `Child ${childDoc.id} references non-existent clinician ${childData.clinician_id}`,
        });
      }
    }
  } catch (error) {
    issues.push({
      type: 'error',
      severity: 'critical',
      message: `Error checking clinician references: ${error.message}`,
    });
  }
  
  return issues;
};

/**
 * Check for data consistency issues
 */
const checkDataConsistency = async () => {
  const issues = [];
  
  try {
    // Check sessions with invalid timestamps
    const sessionsSnap = await sessionsCollection.get();
    const now = Date.now();
    
    for (const sessionDoc of sessionsSnap.docs) {
      const sessionData = sessionDoc.data();
      
      // Check start_time is not in future
      if (sessionData.start_time > now + 60000) {
        issues.push({
          type: 'invalid_timestamp',
          severity: 'medium',
          sessionId: sessionDoc.id,
          field: 'start_time',
          message: `Session ${sessionDoc.id} has start_time in the future`,
        });
      }
      
      // Check end_time is after start_time
      if (sessionData.end_time && sessionData.end_time < sessionData.start_time) {
        issues.push({
          type: 'invalid_timestamp',
          severity: 'high',
          sessionId: sessionDoc.id,
          field: 'end_time',
          message: `Session ${sessionDoc.id} has end_time before start_time`,
        });
      }
      
      // Check risk_score and risk_level consistency
      if (sessionData.risk_score !== null && sessionData.risk_score !== undefined) {
        let expectedLevel = 'low';
        if (sessionData.risk_score >= 70) expectedLevel = 'high';
        else if (sessionData.risk_score >= 40) expectedLevel = 'moderate';
        
        if (sessionData.risk_level && sessionData.risk_level !== expectedLevel) {
          issues.push({
            type: 'inconsistent_risk_assessment',
            severity: 'medium',
            sessionId: sessionDoc.id,
            riskScore: sessionData.risk_score,
            riskLevel: sessionData.risk_level,
            expectedLevel,
            message: `Session ${sessionDoc.id} has inconsistent risk_score (${sessionData.risk_score}) and risk_level (${sessionData.risk_level})`,
          });
        }
      }
    }
    
    // Check children with invalid age calculations
    const childrenSnap = await childrenCollection.get();
    for (const childDoc of childrenSnap.docs) {
      const childData = childDoc.data();
      
      if (childData.date_of_birth) {
        const calculatedAge = (Date.now() - childData.date_of_birth) / (1000 * 60 * 60 * 24 * 365.25);
        const storedAge = childData.age || 0;
        
        if (Math.abs(calculatedAge - storedAge) > 0.1) {
          issues.push({
            type: 'inconsistent_age',
            severity: 'low',
            childId: childDoc.id,
            calculatedAge: calculatedAge.toFixed(2),
            storedAge: storedAge.toFixed(2),
            message: `Child ${childDoc.id} has inconsistent age calculation`,
          });
        }
      }
    }
  } catch (error) {
    issues.push({
      type: 'error',
      severity: 'critical',
      message: `Error checking data consistency: ${error.message}`,
    });
  }
  
  return issues;
};

/**
 * Check for missing required data
 */
const checkMissingData = async () => {
  const issues = [];
  
  try {
    // Check children without required fields
    const childrenSnap = await childrenCollection.get();
    for (const childDoc of childrenSnap.docs) {
      const childData = childDoc.data();
      const missing = [];
      
      if (!childData.name) missing.push('name');
      if (!childData.date_of_birth) missing.push('date_of_birth');
      if (!childData.gender) missing.push('gender');
      if (!childData.language) missing.push('language');
      
      if (missing.length > 0) {
        issues.push({
          type: 'missing_required_fields',
          severity: 'high',
          childId: childDoc.id,
          missingFields: missing,
          message: `Child ${childDoc.id} is missing required fields: ${missing.join(', ')}`,
        });
      }
    }
    
    // Check sessions without required fields
    const sessionsSnap = await sessionsCollection.get();
    for (const sessionDoc of sessionsSnap.docs) {
      const sessionData = sessionDoc.data();
      const missing = [];
      
      if (!sessionData.child_id) missing.push('child_id');
      if (!sessionData.session_type) missing.push('session_type');
      if (!sessionData.start_time) missing.push('start_time');
      
      if (missing.length > 0) {
        issues.push({
          type: 'missing_required_fields',
          severity: 'high',
          sessionId: sessionDoc.id,
          missingFields: missing,
          message: `Session ${sessionDoc.id} is missing required fields: ${missing.join(', ')}`,
        });
      }
    }
  } catch (error) {
    issues.push({
      type: 'error',
      severity: 'critical',
      message: `Error checking missing data: ${error.message}`,
    });
  }
  
  return issues;
};

/**
 * Run all integrity checks
 */
const runAllIntegrityChecks = async () => {
  console.log('🔍 Running data integrity checks...');
  
  const results = {
    timestamp: Date.now(),
    checks: {},
    summary: {
      total: 0,
      critical: 0,
      high: 0,
      medium: 0,
      low: 0,
    },
  };
  
  // Run all checks
  results.checks.orphanedSessions = await checkOrphanedSessions();
  results.checks.orphanedTrials = await checkOrphanedTrials();
  results.checks.invalidClinicianReferences = await checkInvalidClinicianReferences();
  results.checks.dataConsistency = await checkDataConsistency();
  results.checks.missingData = await checkMissingData();
  
  // Calculate summary
  const allIssues = [
    ...results.checks.orphanedSessions,
    ...results.checks.orphanedTrials,
    ...results.checks.invalidClinicianReferences,
    ...results.checks.dataConsistency,
    ...results.checks.missingData,
  ];
  
  results.summary.total = allIssues.length;
  results.summary.critical = allIssues.filter(i => i.severity === 'critical').length;
  results.summary.high = allIssues.filter(i => i.severity === 'high').length;
  results.summary.medium = allIssues.filter(i => i.severity === 'medium').length;
  results.summary.low = allIssues.filter(i => i.severity === 'low').length;
  
  console.log(`✅ Integrity check complete: ${results.summary.total} issues found`);
  console.log(`   Critical: ${results.summary.critical}, High: ${results.summary.high}, Medium: ${results.summary.medium}, Low: ${results.summary.low}`);
  
  return results;
};

module.exports = {
  checkOrphanedSessions,
  checkOrphanedTrials,
  checkInvalidClinicianReferences,
  checkDataConsistency,
  checkMissingData,
  runAllIntegrityChecks,
};



