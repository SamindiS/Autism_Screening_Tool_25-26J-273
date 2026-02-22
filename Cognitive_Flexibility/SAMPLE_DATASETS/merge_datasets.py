import pandas as pd
import numpy as np

# Load all datasets
print("Loading datasets...")
q_asd = pd.read_csv('age_2_3_questionnaire_asd.csv')
q_ctrl = pd.read_csv('age_2_3_questionnaire_control.csv')
fj_asd = pd.read_csv('age_3_5_frog_jump_asd.csv')
fj_ctrl = pd.read_csv('age_3_5_frog_jump_control.csv')
dccs_asd = pd.read_csv('age_5_6_dccs_asd.csv')
dccs_ctrl = pd.read_csv('age_5_6_dccs_control.csv')

# Define all possible columns (union of all datasets)
all_columns = [
    # Common metadata
    'child_id', 'child_code', 'age_months', 'age_group', 'gender', 'language',
    'study_group', 'asd_level', 'clinician_id', 'hospital', 'session_date',
    'assessment_type', 'completion_time_sec',
    # Clinical reflection (common to all)
    'attention_level', 'engagement_level', 'frustration_tolerance',
    'instruction_following', 'overall_behavior', 'enhanced_risk_score',
    'risk_level', 'asd_label', 'severity_label',
    # Questionnaire features (age 2-3)
    'total_questions', 'total_score', 'percentage_score',
    'critical_items_failed', 'critical_items_fail_rate',
    'q1_name_response', 'q4_eye_contact', 'q5_pointing', 'q7_imitation',
    'q9_joint_attention', 'q2_routine_change', 'q3_toy_switching',
    'q6_sensory_reaction', 'q8_peer_play', 'q10_communication',
    'social_responsiveness_score', 'cognitive_flexibility_score',
    'joint_attention_score', 'social_communication_score',
    'sensory_processing_score', 'communication_score',
    'failed_items_total', 'failed_items_rate', 'risk_score',
    # Frog Jump features (age 3.5-5)
    'total_trials', 'go_trials', 'nogo_trials', 'go_accuracy', 'nogo_accuracy',
    'overall_accuracy', 'commission_errors', 'omission_errors',
    'commission_error_rate', 'omission_error_rate', 'avg_rt_go_ms',
    'rt_variability', 'fastest_rt_ms', 'slowest_rt_ms', 'rt_range',
    'inhibition_failure_rate', 'anticipatory_responses', 'anticipatory_rate',
    'late_responses', 'late_response_rate', 'longest_correct_streak',
    'longest_error_streak', 'total_error_streak',
    # DCCS features (age 5.5-6+)
    'pre_switch_accuracy', 'post_switch_accuracy', 'mixed_block_accuracy',
    'avg_reaction_time_ms', 'avg_rt_pre_switch_ms', 'avg_rt_post_switch_ms',
    'avg_rt_post_correct_ms', 'switch_cost_ms', 'total_perseverative_errors',
    'perseverative_error_rate_post_switch', 'number_of_consecutive_perseverations',
    'total_rule_switch_errors', 'longest_streak_correct',
]

# Function to add missing columns with NaN
def add_missing_columns(df, all_cols):
    for col in all_cols:
        if col not in df.columns:
            df[col] = np.nan
    return df[all_cols]

# Add missing columns to each dataset
print("Standardizing columns...")
q_asd = add_missing_columns(q_asd.copy(), all_columns)
q_ctrl = add_missing_columns(q_ctrl.copy(), all_columns)
fj_asd = add_missing_columns(fj_asd.copy(), all_columns)
fj_ctrl = add_missing_columns(fj_ctrl.copy(), all_columns)
dccs_asd = add_missing_columns(dccs_asd.copy(), all_columns)
dccs_ctrl = add_missing_columns(dccs_ctrl.copy(), all_columns)

# Merge all datasets
print("Merging datasets...")
merged = pd.concat([
    q_asd, q_ctrl,
    fj_asd, fj_ctrl,
    dccs_asd, dccs_ctrl
], ignore_index=True)

# Sort by age_months and child_id
merged = merged.sort_values(['age_months', 'child_id']).reset_index(drop=True)

# Save merged dataset
print("Saving merged dataset...")
merged.to_csv('merged_complete_dataset.csv', index=False)

print("\nMerged dataset created successfully!")
print(f"Total records: {len(merged)}")
print(f"ASD records: {len(merged[merged['asd_label'] == 1])}")
print(f"Control records: {len(merged[merged['asd_label'] == 0])}")
print("Age groups:")
print(merged['age_group'].value_counts())
print("\nASD severity distribution:")
print(merged[merged['asd_label'] == 1]['severity_label'].value_counts())

