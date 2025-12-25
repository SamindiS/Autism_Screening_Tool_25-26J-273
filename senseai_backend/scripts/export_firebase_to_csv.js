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
  output: null,
};

args.forEach(arg => {
  if (arg.startsWith('--format=')) {
    options.format = arg.split('=')[1];
  } else if (arg.startsWith('--group=')) {
    options.group = arg.split('=')[1];
  } else if (arg.startsWith('--sessionType=')) {
    options.sessionType = arg.split('=')[1];
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
  
  const headers = [
    'session_id', 'child_id', 'child_code', 'age_months', 'gender', 'group',
    'session_type', 'age_group', 'completion_time_sec', 'accuracy_overall',
    'total_score', 'risk_score', 'risk_level',
    'primary_asd_marker_1', 'primary_asd_marker_2', 'primary_asd_marker_3',
    'attention_level', 'engagement_level', 'frustration_tolerance',
    'instruction_following', 'overall_behavior', 'enhanced_risk_score', 'created_at',
  ];

  rows.push(headers.join(','));

  for (const session of sessions) {
    const child = children[session.child_id];
    if (!child) continue;

    const mlFeatures = extractMLFeatures(session);
    
    const row = [
      session.id || '',
      session.child_id || '',
      child.child_code || child.name || '',
      child.age_in_months || '',
      child.gender || '',
      child.group || 'unknown',
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

function extractMLFeatures(session) {
  const features = {};

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

  if (session.questionnaire_results) {
    const qr = session.questionnaire_results;
    features.total_score = qr.total_score || features.total_score || '';
    features.accuracy_overall = qr.percentage_score || features.accuracy_overall || '';
    features.risk_score = qr.risk_score || '';
  }

  if (session.reflection_results) {
    const rr = session.reflection_results;
    features.attention_level = rr.attention_level || '';
    features.engagement_level = rr.engagement_level || '';
    features.frustration_tolerance = rr.frustration_tolerance || '';
    features.instruction_following = rr.instruction_following || '';
    features.overall_behavior = rr.overall_behavior || '';
  }

  if (session.game_results?.ml_features) {
    Object.assign(features, session.game_results.ml_features);
  }
  if (session.questionnaire_results?.ml_features) {
    Object.assign(features, session.questionnaire_results.ml_features);
  }

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






