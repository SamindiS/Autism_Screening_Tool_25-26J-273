#!/usr/bin/env node
/**
 * Standalone script to export Firebase data to CSV
 * 
 * Usage:
 *   node scripts/export_firebase_to_csv.js [options]
 * 
 * Options:
 *   --format=ml|raw     Export format (default: ml)
 *   --group=asd|typically_developing  Filter by group
 *   --sessionType=color_shape|frog_jump|ai_doctor_bot  Filter by type
 *   --ageGroup=2-3.5|3.5-5.5|5.5-6.9  Filter by age group
 *   --output=filename.csv  Output filename (default: export_<timestamp>.csv)
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();

// Parse command line arguments
const args = process.argv.slice(2);
const options = {
  format: 'ml',
  group: null,
  sessionType: null,
  ageGroup: null,
  output: null,
};

args.forEach(arg => {
  if (arg.startsWith('--format=')) {
    options.format = arg.split('=')[1];
  } else if (arg.startsWith('--group=')) {
    options.group = arg.split('=')[1];
  } else if (arg.startsWith('--sessionType=')) {
    options.sessionType = arg.split('=')[1];
  } else if (arg.startsWith('--ageGroup=')) {
    options.ageGroup = arg.split('=')[1];
  } else if (arg.startsWith('--output=')) {
    options.output = arg.split('=')[1];
  }
});

if (!options.output) {
  options.output = `export_${Date.now()}.csv`;
}

console.log('📊 Firebase Data Export');
console.log('='.repeat(50));
console.log(`Format: ${options.format}`);
console.log(`Group filter: ${options.group || 'all'}`);
console.log(`Session type filter: ${options.sessionType || 'all'}`);
console.log(`Age group filter: ${options.ageGroup || 'all'}`);
console.log(`Output: ${options.output}`);
console.log('='.repeat(50));

async function exportData() {
  try {
    // Get children
    let childrenQuery = db.collection('children').orderBy('created_at', 'desc');
    if (options.group) {
      childrenQuery = db.collection('children')
        .where('group', '==', options.group)
        .orderBy('created_at', 'desc');
    }
    const childrenSnap = await childrenQuery.get();
    const children = {};
    childrenSnap.docs.forEach(doc => {
      children[doc.id] = { id: doc.id, ...doc.data() };
    });
    console.log(`✅ Found ${childrenSnap.size} children`);

    // Get sessions
    let sessionsQuery = db.collection('sessions').orderBy('created_at', 'desc');
    if (options.sessionType) {
      sessionsQuery = db.collection('sessions')
        .where('session_type', '==', options.sessionType)
        .orderBy('created_at', 'desc');
    }
    const sessionsSnap = await sessionsQuery.get();
    let sessions = sessionsSnap.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Filter by group if specified
    if (options.group) {
      sessions = sessions.filter(s => {
        const child = children[s.child_id];
        return child && child.group === options.group;
      });
    }

    // Filter by age group if specified
    // IMPORTANT: Each age group must only include its corresponding session type
    // Age 2-3.5 → ai_doctor_bot (Questionnaire)
    // Age 3.5-5.5 → frog_jump (Go/No-Go)
    // Age 5.5-6.9 → color_shape (DCCS)
    if (options.ageGroup) {
      // Map age group to required session type
      const requiredSessionType = {
        '2-3.5': 'ai_doctor_bot',
        '3.5-5.5': 'frog_jump',
        '5.5-6.9': 'color_shape'
      }[options.ageGroup];

      sessions = sessions.filter(s => {
        // CRITICAL: Must match the required session type for this age group
        if (s.session_type !== requiredSessionType) {
          return false;
        }

        // Additional validation: Check age_group field or child's age
        if (s.age_group === options.ageGroup) {
          return true;
        }
        
        // Also check child's age if age_group not set
        const child = children[s.child_id];
        if (child && child.age_in_months) {
          const ageMonths = child.age_in_months;
          if (options.ageGroup === '2-3.5' && ageMonths >= 24 && ageMonths < 42) {
            return true;
          } else if (options.ageGroup === '3.5-5.5' && ageMonths >= 42 && ageMonths < 66) {
            return true;
          } else if (options.ageGroup === '5.5-6.9' && ageMonths >= 66 && ageMonths < 83) {
            return true;
          }
        }
        return false;
      });
      console.log(`   After age group filter (${options.ageGroup} → ${requiredSessionType}): ${sessions.length} sessions`);
    }

    console.log(`✅ Found ${sessions.length} sessions`);

    // Generate CSV
    let csvData;
    if (options.format === 'ml') {
      csvData = formatForMLTraining(sessions, children);
    } else {
      csvData = formatRawData(sessions, children);
    }

    // Write to file
    fs.writeFileSync(options.output, csvData, 'utf8');
    console.log(`✅ CSV exported to: ${options.output}`);
    console.log(`   File size: ${(csvData.length / 1024).toFixed(2)} KB`);

  } catch (err) {
    console.error('❌ Export error:', err);
    process.exit(1);
  }
}

function formatForMLTraining(sessions, children) {
  const rows = [];
  
  // Comprehensive header with all ML features
  const headers = [
    // Basic identifiers
    'session_id', 'child_id', 'child_code', 'age_months', 'gender', 'group',
    'session_type', 'age_group', 'created_at',
    
    // Basic metrics
    'completion_time_sec', 'accuracy_overall', 'total_score', 'risk_score', 'risk_level',
    
    // DCCS (Color-Shape) Features
    'pre_switch_accuracy', 'post_switch_accuracy', 'mixed_block_accuracy',
    'total_perseverative_errors', 'perseverative_error_rate_post_switch',
    'avg_rt_pre_switch_ms', 'avg_rt_post_switch_correct_ms',
    'switch_cost_ms', 'accuracy_drop_percent',
    'number_of_consecutive_perseverations', 'total_rule_switch_errors',
    'longest_streak_correct', 'avg_reaction_time_ms',
    
    // Frog Jump (Go/No-Go) Features
    'go_accuracy', 'nogo_accuracy', 'overall_accuracy',
    'commission_errors', 'omission_errors',
    'commission_error_rate', 'omission_error_rate',
    'avg_rt_go_ms', 'rt_variability',
    'inhibition_failure_rate', 'anticipatory_responses', 'late_responses',
    'anticipatory_rate', 'late_response_rate',
    'longest_correct_streak', 'longest_error_streak', 'total_error_streak',
    'fastest_rt_ms', 'slowest_rt_ms', 'rt_range',
    
    // Questionnaire Features
    'critical_items_failed', 'critical_items_fail_rate',
    'social_responsiveness_score', 'cognitive_flexibility_score',
    'joint_attention_score', 'social_communication_score',
    
    // Reflection/Behavioral Features
    'attention_level', 'engagement_level', 'frustration_tolerance',
    'instruction_following', 'overall_behavior',
    
    // Legacy markers (for backward compatibility)
    'primary_asd_marker_1', 'primary_asd_marker_2', 'primary_asd_marker_3',
    'enhanced_risk_score',
  ];

  rows.push(headers.join(','));

  for (const session of sessions) {
    const child = children[session.child_id];
    if (!child) continue;

    const mlFeatures = extractMLFeatures(session);
    
    // Build row with all features in header order
    const row = [
      // Basic identifiers
      session.id || '',
      session.child_id || '',
      child.child_code || child.name || '',
      child.age_in_months || '',
      child.gender || '',
      child.group || 'unknown',
      session.session_type || '',
      session.age_group || '',
      new Date(session.created_at).toISOString() || '',
      
      // Basic metrics
      mlFeatures.completion_time_sec || '',
      mlFeatures.accuracy_overall || '',
      mlFeatures.total_score || '',
      session.risk_score || '',
      session.risk_level || '',
      
      // DCCS Features
      mlFeatures.pre_switch_accuracy || '',
      mlFeatures.post_switch_accuracy || '',
      mlFeatures.mixed_block_accuracy || '',
      mlFeatures.total_perseverative_errors || '',
      mlFeatures.perseverative_error_rate_post_switch || '',
      mlFeatures.avg_rt_pre_switch_ms || '',
      mlFeatures.avg_rt_post_switch_correct_ms || '',
      mlFeatures.switch_cost_ms || '',
      mlFeatures.accuracy_drop_percent || '',
      mlFeatures.number_of_consecutive_perseverations || '',
      mlFeatures.total_rule_switch_errors || '',
      mlFeatures.longest_streak_correct || '',
      mlFeatures.avg_reaction_time_ms || '',
      
      // Frog Jump Features
      mlFeatures.go_accuracy || '',
      mlFeatures.nogo_accuracy || '',
      mlFeatures.overall_accuracy || '',
      mlFeatures.commission_errors || '',
      mlFeatures.omission_errors || '',
      mlFeatures.commission_error_rate || '',
      mlFeatures.omission_error_rate || '',
      mlFeatures.avg_rt_go_ms || '',
      mlFeatures.rt_variability || '',
      mlFeatures.inhibition_failure_rate || '',
      mlFeatures.anticipatory_responses || '',
      mlFeatures.late_responses || '',
      mlFeatures.anticipatory_rate || '',
      mlFeatures.late_response_rate || '',
      mlFeatures.longest_correct_streak || '',
      mlFeatures.longest_error_streak || '',
      mlFeatures.total_error_streak || '',
      mlFeatures.fastest_rt_ms || '',
      mlFeatures.slowest_rt_ms || '',
      mlFeatures.rt_range || '',
      
      // Questionnaire Features
      mlFeatures.critical_items_failed || '',
      mlFeatures.critical_items_fail_rate || '',
      mlFeatures.social_responsiveness_score || '',
      mlFeatures.cognitive_flexibility_score || '',
      mlFeatures.joint_attention_score || '',
      mlFeatures.social_communication_score || '',
      
      // Reflection Features
      mlFeatures.attention_level || '',
      mlFeatures.engagement_level || '',
      mlFeatures.frustration_tolerance || '',
      mlFeatures.instruction_following || '',
      mlFeatures.overall_behavior || '',
      
      // Legacy markers
      mlFeatures.primary_asd_marker_1 || '',
      mlFeatures.primary_asd_marker_2 || '',
      mlFeatures.primary_asd_marker_3 || '',
      mlFeatures.enhanced_risk_score || '',
    ];

    rows.push(row.map(val => escapeCSVValue(val)).join(','));
  }

  return rows.join('\n');
}

function extractMLFeatures(session) {
  const features = {};

  // Extract from game_results (basic metrics)
  if (session.game_results) {
    const gr = session.game_results;
    features.accuracy_overall = gr.accuracy || gr.overall_accuracy || '';
    features.completion_time_sec = gr.completion_time || 
      (session.end_time && session.start_time ? 
        Math.floor((session.end_time - session.start_time) / 1000) : '');
    features.total_score = gr.total_score || gr.correct_trials || '';
    
    // Legacy markers (for backward compatibility)
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
    
    // Questionnaire-specific features
    if (qr.critical_items) {
      features.critical_items_failed = qr.critical_items.failed || '';
      features.critical_items_fail_rate = qr.critical_items.fail_rate || '';
    }
    if (qr.domain_scores) {
      features.social_responsiveness_score = qr.domain_scores.social_responsiveness || '';
      features.cognitive_flexibility_score = qr.domain_scores.cognitive_flexibility || '';
      features.joint_attention_score = qr.domain_scores.joint_attention || '';
      features.social_communication_score = qr.domain_scores.social_communication || '';
    }
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

  // Extract ALL ML features from ml_features object (most comprehensive)
  if (session.game_results?.ml_features) {
    Object.assign(features, session.game_results.ml_features);
  }
  if (session.questionnaire_results?.ml_features) {
    Object.assign(features, session.questionnaire_results.ml_features);
  }

  // Calculate completion time if not available
  if (!features.completion_time_sec && session.start_time && session.end_time) {
    features.completion_time_sec = Math.floor((session.end_time - session.start_time) / 1000);
  }

  return features;
}

function formatRawData(sessions, children) {
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

function escapeCSVValue(value) {
  if (value === null || value === undefined) return '';
  const str = String(value);
  if (str.includes(',') || str.includes('"') || str.includes('\n')) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

// Run export
exportData().then(() => {
  console.log('✅ Export completed');
  process.exit(0);
}).catch(err => {
  console.error('❌ Export failed:', err);
  process.exit(1);
});







