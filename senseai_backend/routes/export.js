const express = require('express');
const { db } = require('../firebase');
const router = express.Router();

const childrenCollection = db.collection('children');
const sessionsCollection = db.collection('sessions');
const trialsCollection = db.collection('trials');

/**
 * GET /api/export/csv
 * Export all assessment data to CSV format for ML training
 * 
 * Query params:
 * - format: 'ml' (for ML training) or 'raw' (raw data export)
 * - sessionType: Filter by session type (optional)
 * - group: Filter by study group (optional)
 * - ageGroup: Filter by age group (optional: '2-3.5', '3.5-5.5', '5.5-6.9')
 */
router.get('/csv', async (req, res) => {
  try {
    const format = req.query.format || 'ml'; // 'ml' or 'raw'
    const sessionType = req.query.sessionType; // Optional filter
    const group = req.query.group; // Optional filter (asd, typically_developing)
    const ageGroup = req.query.ageGroup; // Optional filter (2-3.5, 3.5-5.5, 5.5-6.9)

    console.log(`📊 Exporting data to CSV (format: ${format})`);
    if (ageGroup) {
      console.log(`   Age Group filter: ${ageGroup}`);
    }

    // Get all children
    // Note: When filtering by group, we can't use orderBy with where (requires index)
    // So we fetch all and filter/sort in memory
    let childrenQuery = childrenCollection;
    if (group) {
      // Filter by group first (no orderBy to avoid index requirement)
      childrenQuery = childrenCollection.where('group', '==', group);
    }
    const childrenSnap = await childrenQuery.get();
    // Convert to array, sort by created_at, then convert to object
    const childrenArray = childrenSnap.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));
    
    // Sort by created_at descending
    childrenArray.sort((a, b) => {
      const aTime = a.created_at || 0;
      const bTime = b.created_at || 0;
      return bTime - aTime;
    });
    
    // Convert back to object for easy lookup
    const children = {};
    childrenArray.forEach(child => {
      children[child.id] = child;
    });

    console.log(`   Found ${childrenSnap.size} children`);

    // Get all sessions
    let sessionsQuery = sessionsCollection.orderBy('created_at', 'desc');
    if (sessionType) {
      sessionsQuery = sessionsCollection
        .where('session_type', '==', sessionType)
        .orderBy('created_at', 'desc');
    }
    const sessionsSnap = await sessionsQuery.get();
    const sessions = sessionsSnap.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    console.log(`   Found ${sessions.length} sessions`);

    // Filter sessions by group and age group if specified
    let filteredSessions = sessions;
    if (group) {
      filteredSessions = filteredSessions.filter(s => {
        const child = children[s.child_id];
        return child && child.group === group;
      });
    }
    
    // Filter by age group if specified
    if (ageGroup) {
      filteredSessions = filteredSessions.filter(s => {
        // Check session age_group field first
        if (s.age_group === ageGroup) {
          return true;
        }
        // Also check child's age if age_group not set
        const child = children[s.child_id];
        if (child && child.age_in_months) {
          const ageMonths = child.age_in_months;
          if (ageGroup === '2-3.5' && ageMonths >= 24 && ageMonths < 42) {
            return true;
          } else if (ageGroup === '3.5-5.5' && ageMonths >= 42 && ageMonths < 66) {
            return true;
          } else if (ageGroup === '5.5-6.9' && ageMonths >= 66 && ageMonths < 83) {
            return true;
          }
        }
        return false;
      });
      console.log(`   After age group filter: ${filteredSessions.length} sessions`);
    }

    if (format === 'ml') {
      // Format for ML training
      const csvData = formatForMLTraining(filteredSessions, children);
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="ml_training_data_${Date.now()}.csv"`);
      res.send(csvData);
    } else {
      // Raw data export
      const csvData = formatRawData(filteredSessions, children);
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename="raw_data_export_${Date.now()}.csv"`);
      res.send(csvData);
    }

    console.log(`✅ CSV export completed: ${filteredSessions.length} sessions`);
  } catch (err) {
    console.error('❌ Export error:', err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * Format data for ML training (one row per session with ML features)
 */
function formatForMLTraining(sessions, children) {
  const rows = [];
  
  // Header row
  const headers = [
    'session_id',
    'child_id',
    'child_code',
    'age_months',
    'gender',
    'group', // asd or typically_developing (target variable)
    'session_type',
    'age_group',
    // ML Features from game_results/questionnaire_results
    'completion_time_sec',
    'accuracy_overall',
    'total_score',
    'risk_score',
    'risk_level',
    // Primary ASD markers
    'primary_asd_marker_1', // perseverative_errors or similar
    'primary_asd_marker_2', // perseverative_rate or similar
    'primary_asd_marker_3', // switch_cost_ms or similar
    // Behavioral markers
    'attention_level',
    'engagement_level',
    'frustration_tolerance',
    'instruction_following',
    'overall_behavior',
    // Additional features from ml_features
    'enhanced_risk_score',
    'created_at',
  ];

  rows.push(headers.join(','));

  // Data rows
  for (const session of sessions) {
    const child = children[session.child_id];
    if (!child) continue;

    // Extract ML features from session data
    const mlFeatures = extractMLFeatures(session);
    
    const row = [
      session.id || '',
      session.child_id || '',
      child.child_code || child.name || '',
      child.age_in_months || '',
      child.gender || '',
      child.group || 'unknown', // Target variable for ML
      session.session_type || '',
      session.age_group || '',
      mlFeatures.completion_time_sec || '',
      mlFeatures.accuracy_overall || '',
      mlFeatures.total_score || '',
      session.risk_score || '',
      session.risk_level || '',
      mlFeatures.primary_asd_marker_1 || '',
      mlFeatures.primary_asd_marker_2 || '',
      mlFeatures.primary_asd_marker_3 || '',
      mlFeatures.attention_level || '',
      mlFeatures.engagement_level || '',
      mlFeatures.frustration_tolerance || '',
      mlFeatures.instruction_following || '',
      mlFeatures.overall_behavior || '',
      mlFeatures.enhanced_risk_score || '',
      new Date(session.created_at).toISOString() || '',
    ];

    rows.push(row.map(val => escapeCSVValue(val)).join(','));
  }

  return rows.join('\n');
}

/**
 * Extract ML features from session data
 */
function extractMLFeatures(session) {
  const features = {};

  // Extract from game_results
  if (session.game_results) {
    const gr = session.game_results;
    features.accuracy_overall = gr.accuracy || gr.overall_accuracy || '';
    features.completion_time_sec = gr.completion_time || 
      (session.end_time && session.start_time ? 
        Math.floor((session.end_time - session.start_time) / 1000) : '');
    features.total_score = gr.total_score || gr.correct_trials || '';
    features.primary_asd_marker_1 = gr.perseverative_errors || gr.commission_errors || '';
    features.primary_asd_marker_2 = gr.perseverative_error_rate || gr.commission_error_rate || '';
    features.primary_asd_marker_3 = gr.switch_cost || gr.switch_cost_ms || '';
  }

  // Extract from questionnaire_results
  if (session.questionnaire_results) {
    const qr = session.questionnaire_results;
    features.total_score = qr.total_score || features.total_score || '';
    features.accuracy_overall = qr.percentage_score || features.accuracy_overall || '';
    features.risk_score = qr.risk_score || '';
  }

  // Extract from reflection_results
  if (session.reflection_results) {
    const rr = session.reflection_results;
    features.attention_level = rr.attention_level || '';
    features.engagement_level = rr.engagement_level || '';
    features.frustration_tolerance = rr.frustration_tolerance || '';
    features.instruction_following = rr.instruction_following || '';
    features.overall_behavior = rr.overall_behavior || '';
  }

  // Extract from ml_features if available
  if (session.game_results?.ml_features) {
    const mf = session.game_results.ml_features;
    Object.assign(features, mf);
  }
  if (session.questionnaire_results?.ml_features) {
    const mf = session.questionnaire_results.ml_features;
    Object.assign(features, mf);
  }

  // Calculate completion time if not available
  if (!features.completion_time_sec && session.start_time && session.end_time) {
    features.completion_time_sec = Math.floor((session.end_time - session.start_time) / 1000);
  }

  return features;
}

/**
 * Format raw data export (all fields)
 */
function formatRawData(sessions, children) {
  // This would export all fields - simplified version
  const rows = [];
  rows.push('session_id,child_id,child_code,age_months,gender,group,session_type,data_json');
  
  for (const session of sessions) {
    const child = children[session.child_id];
    if (!child) continue;
    
    const row = [
      session.id || '',
      session.child_id || '',
      child.child_code || child.name || '',
      child.age_in_months || '',
      child.gender || '',
      child.group || '',
      session.session_type || '',
      escapeCSVValue(JSON.stringify(session)),
    ];
    
    rows.push(row.join(','));
  }
  
  return rows.join('\n');
}

/**
 * Escape CSV value (handle commas, quotes, newlines)
 */
function escapeCSVValue(value) {
  if (value === null || value === undefined) return '';
  const str = String(value);
  if (str.includes(',') || str.includes('"') || str.includes('\n')) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

module.exports = router;





