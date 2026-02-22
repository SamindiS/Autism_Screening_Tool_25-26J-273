/**
 * Enhanced Data Validation Service
 * Provides comprehensive validation beyond Joi schema validation
 */

const { db } = require('../firebase');

const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');
const cliniciansCollection = db.collection('clinicians');

/**
 * Validate child data with business rules
 */
const validateChild = async (childData, isUpdate = false) => {
  const errors = [];
  const warnings = [];

  // 1. Age validation
  if (childData.date_of_birth) {
    const age = (Date.now() - childData.date_of_birth) / (1000 * 60 * 60 * 24 * 365.25);
    
    if (age < 0) {
      errors.push('Date of birth cannot be in the future');
    } else if (age > 10) {
      warnings.push(`Child age (${age.toFixed(1)} years) is outside typical screening range (2-7 years)`);
    } else if (age < 2) {
      warnings.push(`Child age (${age.toFixed(1)} years) is below minimum screening age (2 years)`);
    }

    // Validate age_in_months matches date_of_birth
    if (childData.age_in_months) {
      const calculatedMonths = Math.floor((Date.now() - childData.date_of_birth) / (1000 * 60 * 60 * 24 * 30.44));
      if (Math.abs(childData.age_in_months - calculatedMonths) > 1) {
        warnings.push(`age_in_months (${childData.age_in_months}) doesn't match calculated age (${calculatedMonths} months)`);
      }
    }
  }

  // 2. Group and ASD level validation
  if (childData.group === 'asd' && !childData.asd_level) {
    warnings.push('ASD child should have an ASD level (level_1, level_2, or level_3)');
  }

  if (childData.group === 'typically_developing' && childData.asd_level) {
    warnings.push('Control group child should not have an ASD level');
  }

  // 3. Clinician validation (warning only, not error - allows manual entry)
  if (childData.clinician_id) {
    try {
      const clinicianDoc = await cliniciansCollection.doc(childData.clinician_id).get();
      if (!clinicianDoc.exists) {
        // Make this a warning instead of error - allows manual clinician ID entry
        warnings.push(`Clinician ID ${childData.clinician_id} does not exist in database (may be manually entered)`);
      }
    } catch (err) {
      warnings.push(`Could not verify clinician ID: ${err.message}`);
    }
  }

  // 4. Name validation
  if (childData.name) {
    // Check for suspicious patterns
    if (childData.name.trim().length < 2) {
      errors.push('Child name must be at least 2 characters');
    }
    if (childData.name.length > 100) {
      errors.push('Child name exceeds maximum length (100 characters)');
    }
    // Check for special characters that might cause issues
    if (/[<>{}[\]\\]/.test(childData.name)) {
      warnings.push('Child name contains special characters that may cause display issues');
    }
  }

  // 5. Child code validation
  if (childData.child_code) {
    // Check for duplicate child codes
    if (!isUpdate) {
      const existingChildren = await childrenCollection
        .where('child_code', '==', childData.child_code)
        .limit(1)
        .get();
      
      if (!existingChildren.empty) {
        warnings.push(`Child code ${childData.child_code} already exists`);
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
};

/**
 * Validate session data with business rules
 */
const validateSession = async (sessionData, isUpdate = false) => {
  const errors = [];
  const warnings = [];

  // 1. Child ID validation
  if (sessionData.child_id) {
    try {
      const childDoc = await childrenCollection.doc(sessionData.child_id).get();
      if (!childDoc.exists) {
        // Make this a warning - child might exist locally but not in Firebase yet
        warnings.push(`Child ID ${sessionData.child_id} not found in Firebase (may exist locally)`);
      } else {
        const childData = childDoc.data();
        
        // 2. Age-appropriate session type validation
        if (childData.date_of_birth) {
          const age = (Date.now() - childData.date_of_birth) / (1000 * 60 * 60 * 24 * 365.25);
          const ageInMonths = Math.floor((Date.now() - childData.date_of_birth) / (1000 * 60 * 60 * 24 * 30.44));
          
          if (sessionData.session_type === 'ai_doctor_bot' && (age < 2 || age > 3.5)) {
            warnings.push(`AI Doctor Bot is recommended for ages 2-3.5 years, child is ${age.toFixed(1)} years`);
          }
          
          if (sessionData.session_type === 'frog_jump' && (age < 3.5 || age > 5.5)) {
            warnings.push(`Frog Jump is recommended for ages 3.5-5.5 years, child is ${age.toFixed(1)} years`);
          }
          
          if (sessionData.session_type === 'color_shape' && (age < 5.5 || age > 6.8)) {
            warnings.push(`Color-Shape Game is recommended for ages 5.5-6.8 years, child is ${age.toFixed(1)} years`);
          }
        }
      }
    } catch (err) {
      // Firebase authentication errors should not block session creation
      // System can work offline - make this a warning instead of error
      if (err.code === 16 || err.message.includes('UNAUTHENTICATED') || err.message.includes('authentication')) {
        warnings.push(`Could not validate child ID with Firebase (authentication issue - system will work offline): ${err.message}`);
      } else {
        // Other errors (network, etc.) also should not block - make warning
        warnings.push(`Could not validate child ID: ${err.message} (system will continue)`);
      }
    }
  } else if (!isUpdate) {
    errors.push('child_id is required');
  }

  // 3. Timestamp validation
  if (sessionData.start_time && sessionData.end_time) {
    if (sessionData.end_time < sessionData.start_time) {
      errors.push('end_time cannot be before start_time');
    }
    
    const duration = (sessionData.end_time - sessionData.start_time) / 1000; // seconds
    if (duration < 10) {
      warnings.push(`Session duration (${duration.toFixed(1)}s) seems too short`);
    }
    if (duration > 3600) {
      warnings.push(`Session duration (${duration.toFixed(1)}s) seems too long`);
    }
  }

  // 4. Risk score validation
  if (sessionData.risk_score !== null && sessionData.risk_score !== undefined) {
    if (sessionData.risk_score < 0 || sessionData.risk_score > 100) {
      errors.push('risk_score must be between 0 and 100');
    }
    
    // Validate risk_level matches risk_score
    if (sessionData.risk_level) {
      let expectedLevel = 'low';
      if (sessionData.risk_score >= 70) expectedLevel = 'high';
      else if (sessionData.risk_score >= 40) expectedLevel = 'moderate';
      
      if (sessionData.risk_level !== expectedLevel) {
        warnings.push(`risk_level (${sessionData.risk_level}) doesn't match risk_score (${sessionData.risk_score}). Expected: ${expectedLevel}`);
      }
    }
  }

  // 5. Session type validation (normalize hyphen to underscore)
  const validSessionTypes = ['ai_doctor_bot', 'frog_jump', 'color_shape', 'manual_assessment', 'rrb', 'auditory', 'visual'];
  // Normalize session_type: convert hyphen to underscore (color-shape -> color_shape)
  let normalizedSessionType = sessionData.session_type;
  if (normalizedSessionType) {
    normalizedSessionType = normalizedSessionType.replace(/-/g, '_');
    // Update the sessionData for further processing
    sessionData.session_type = normalizedSessionType;
  }
  
  if (sessionData.session_type && !validSessionTypes.includes(sessionData.session_type)) {
    errors.push(`Invalid session_type: ${sessionData.session_type}. Must be one of: ${validSessionTypes.join(', ')}`);
  }

  // 6. Data completeness validation
  if (sessionData.session_type === 'color_shape' && !sessionData.game_results) {
    warnings.push('Color-Shape session should have game_results');
  }
  
  if (sessionData.session_type === 'frog_jump' && !sessionData.game_results) {
    warnings.push('Frog Jump session should have game_results');
  }
  
  if (sessionData.session_type === 'ai_doctor_bot' && !sessionData.questionnaire_results) {
    warnings.push('AI Doctor Bot session should have questionnaire_results');
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
};

/**
 * Validate trial data
 */
const validateTrial = async (trialData) => {
  const errors = [];
  const warnings = [];

  // 1. Session ID validation
  if (trialData.session_id) {
    try {
      const sessionDoc = await sessionsCollection.doc(trialData.session_id).get();
      if (!sessionDoc.exists) {
        errors.push(`Session ID ${trialData.session_id} does not exist`);
      }
    } catch (err) {
      errors.push(`Could not validate session ID: ${err.message}`);
    }
  } else {
    errors.push('session_id is required');
  }

  // 2. Trial number validation
  if (trialData.trial_number !== undefined) {
    if (trialData.trial_number < 1) {
      errors.push('trial_number must be at least 1');
    }
    if (trialData.trial_number > 1000) {
      warnings.push('trial_number seems unusually high');
    }
  }

  // 3. Reaction time validation
  if (trialData.reaction_time !== null && trialData.reaction_time !== undefined) {
    if (trialData.reaction_time < 0) {
      errors.push('reaction_time cannot be negative');
    }
    if (trialData.reaction_time > 30000) {
      warnings.push(`reaction_time (${trialData.reaction_time}ms) seems unusually high`);
    }
    if (trialData.reaction_time < 100) {
      warnings.push(`reaction_time (${trialData.reaction_time}ms) seems unusually low`);
    }
  }

  // 4. Timestamp validation
  if (trialData.timestamp) {
    const now = Date.now();
    const trialTime = trialData.timestamp;
    
    if (trialTime > now + 60000) { // 1 minute in future
      warnings.push('Trial timestamp is in the future');
    }
    if (trialTime < now - 31536000000) { // 1 year ago
      warnings.push('Trial timestamp is more than 1 year old');
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
};

/**
 * Validate data ranges
 */
const validateDataRanges = (data, field, min, max, fieldName) => {
  const errors = [];
  if (data[field] !== null && data[field] !== undefined) {
    if (data[field] < min || data[field] > max) {
      errors.push(`${fieldName} must be between ${min} and ${max}, got ${data[field]}`);
    }
  }
  return errors;
};

module.exports = {
  validateChild,
  validateSession,
  validateTrial,
  validateDataRanges,
};

