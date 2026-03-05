"""
Prepare Training and Test Datasets for Age 2-3.5 Questionnaire Model

Strategy:
- Training Set: External datasets (~2,314 samples)
- Test Set: Your hospital data (40 samples)
- Integration: M-CHAT, DSM-5, NIH Toolbox (when available)
"""

import pandas as pd
import numpy as np
from scipy import stats
import json
import os

def extract_features_from_external(df, age_col, qchat_col=None):
    """
    Extract your model features from external dataset structure
    
    Args:
        df: External dataset DataFrame
        age_col: Column name for age (e.g., 'Age_Mons' or 'Age')
        qchat_col: Column name for Q-CHAT score (optional)
    
    Returns:
        DataFrame with your model features
    """
    features = pd.DataFrame()
    
    # 1. age_months (direct)
    features['age_months'] = df[age_col].astype(float)
    
    # 2. Extract A1-A10 features
    a_cols = [f'A{i}' for i in range(1, 11)]
    
    # Check if columns exist
    available_a_cols = [col for col in a_cols if col in df.columns]
    
    if len(available_a_cols) < 10:
        print(f"[WARN] Warning: Only {len(available_a_cols)} A-columns found")
        # Fill missing with 0
        for col in a_cols:
            if col not in df.columns:
                df[col] = 0
    
    # 3. critical_items_failed
    # Count how many A1-A10 are 1 (ASD indicators)
    features['critical_items_failed'] = df[a_cols].sum(axis=1).astype(int)
    
    # 4. completion_time_sec (missing - impute with median from your data)
    # Your hospital data median: ~300 seconds
    features['completion_time_sec'] = 300.0
    
    # 5. Calculate domain scores from A1-A10
    # Social Responsiveness: A1 (name response), A4 (eye contact), A5 (pointing)
    social_items = ['A1', 'A4', 'A5']
    features['social_responsiveness_raw'] = (
        df[social_items].sum(axis=1) / len(social_items) * 100
    )
    
    # Joint Attention: A5 (pointing), A9 (joint attention)
    joint_items = ['A5', 'A9']
    features['joint_attention_raw'] = (
        df[joint_items].sum(axis=1) / len(joint_items) * 100
    )
    
    # Total Score: Sum of A1-A10, convert to 0-100 scale
    if qchat_col and qchat_col in df.columns:
        # Q-CHAT is 0-10, convert to 0-100
        features['total_score_raw'] = df[qchat_col] * 10
    else:
        # Sum A1-A10 (each 0-1), convert to 0-100
        features['total_score_raw'] = df[a_cols].sum(axis=1) * 10
    
    # 6. Age-normalize (z-scores) by age bins
    age_bins = [24, 30, 36, 42]
    features['age_bin'] = pd.cut(
        features['age_months'], 
        bins=age_bins, 
        labels=['24-30', '30-36', '36-42'],
        include_lowest=True
    )
    
    # Calculate z-scores within age bins
    for col in ['social_responsiveness_raw', 'joint_attention_raw', 'total_score_raw']:
        zscore_col = col.replace('_raw', '_zscore')
        features[zscore_col] = features.groupby('age_bin')[col].transform(
            lambda x: stats.zscore(x.fillna(x.mean())) if len(x) > 1 else 0
        )
        # Fill NaN z-scores with 0
        features[zscore_col] = features[zscore_col].fillna(0)
    
    # 7. Binary flags
    # Low attention: A1 or A4 indicates attention issues
    features['low_attention_flag'] = (
        (df['A1'] == 1) | (df['A4'] == 1)
    ).astype(int)
    
    # High critical items: ≥3 critical items failed
    features['high_critical_items_flag'] = (
        features['critical_items_failed'] >= 3
    ).astype(int)
    
    # Low social: Social responsiveness < 50%
    features['low_social_flag'] = (
        features['social_responsiveness_raw'] < 50
    ).astype(int)
    
    # 8. Target variable
    if 'Class/ASD Traits ' in df.columns:
        features['group'] = df['Class/ASD Traits '].map({'Yes': 1, 'No': 0})
    elif 'Class' in df.columns:
        features['group'] = df['Class'].map({'YES': 1, 'NO': 0})
    else:
        print("[WARN] Warning: No target column found")
        features['group'] = 0
    
    # Select final features matching your model
    final_features = [
        'age_months',
        'critical_items_failed',
        'completion_time_sec',
        'social_responsiveness_zscore',
        'joint_attention_zscore',
        'total_score_zscore',
        'low_attention_flag',
        'high_critical_items_flag',
        'low_social_flag',
        'group'
    ]
    
    return features[final_features]

def prepare_training_data_from_external():
    """
    Prepare training data from external datasets
    """
    print("[PREP] Preparing Training Data from External Datasets...")
    print("="*60)
    
    datasets = []
    
    # Dataset 1: Toddler Autism Dataset (July 2018)
    try:
        print("\n1. Loading: Toddler Autism Dataset (July 2018)...")
        df1 = pd.read_csv('Online Datasets/Toddler Autism dataset July 2018.csv')
        
        # Filter to age 2-3.5 (24-42 months)
        df1_filtered = df1[(df1['Age_Mons'] >= 24) & (df1['Age_Mons'] < 42)]
        print(f"   Filtered: {len(df1_filtered)} samples (age 24-42 months)")
        
        # Extract features
        df1_features = extract_features_from_external(
            df1_filtered, 
            age_col='Age_Mons',
            qchat_col='Qchat-10-Score'
        )
        print(f"   Extracted features: {len(df1_features)} samples")
        datasets.append(df1_features)
        
    except FileNotFoundError:
        print("   [WARN] File not found, skipping...")
    except Exception as e:
        print(f"   [ERROR] Error: {e}")
    
    # Dataset 2: Autism Screening Data Combined
    try:
        print("\n2. Loading: Autism Screening Data Combined...")
        df2 = pd.read_csv('Online Datasets/Autism screening data for toddlers/Autism_Screening_Data_Combined.csv')
        
        # Filter to age 2-3.5 (24-42 months)
        df2_filtered = df2[(df2['Age'] >= 24) & (df2['Age'] < 42)]
        print(f"   Filtered: {len(df2_filtered)} samples (age 24-42 months)")
        
        # Extract features
        df2_features = extract_features_from_external(
            df2_filtered,
            age_col='Age',
            qchat_col=None
        )
        print(f"   Extracted features: {len(df2_features)} samples")
        datasets.append(df2_features)
        
    except FileNotFoundError:
        print("   [WARN] File not found, skipping...")
    except Exception as e:
        print(f"   [ERROR] Error: {e}")
    
    # Combine all datasets
    if len(datasets) == 0:
        raise ValueError("No datasets loaded! Check file paths.")
    
    combined_df = pd.concat(datasets, ignore_index=True)
    
    # Remove duplicates (if any)
    combined_df = combined_df.drop_duplicates()
    
    # Handle any remaining missing values
    combined_df = combined_df.fillna(combined_df.median())
    
    # Verify class distribution
    print(f"\n[OK] Training Data Summary:")
    print(f"   Total samples: {len(combined_df)}")
    print(f"   ASD samples: {combined_df['group'].sum()}")
    print(f"   Control samples: {len(combined_df) - combined_df['group'].sum()}")
    print(f"   Class balance: {combined_df['group'].mean()*100:.1f}% ASD")
    
    return combined_df

def prepare_test_data_from_hospital():
    """
    Prepare test data from your hospital-collected data
    """
    print("\n[PREP] Preparing Test Data from Hospital Data...")
    print("="*60)
    
    test_datasets = []
    
    # Load ASD dataset
    try:
        print("\n1. Loading: Hospital ASD Data...")
        df_asd = pd.read_csv('SAMPLE_DATASETS/age_2_3_questionnaire_asd.csv.csv')
        print(f"   Loaded: {len(df_asd)} ASD samples")
        
        # Extract features
        features_asd = extract_features_from_hospital_data(df_asd)
        test_datasets.append(features_asd)
        
    except FileNotFoundError:
        print("   [WARN] File not found, skipping...")
    except Exception as e:
        print(f"   [ERROR] Error: {e}")
    
    # Load Control dataset
    try:
        print("\n2. Loading: Hospital Control Data...")
        df_control = pd.read_csv('SAMPLE_DATASETS/age_2_3_questionnaire_control.csv')
        print(f"   Loaded: {len(df_control)} Control samples")
        
        # Extract features
        features_control = extract_features_from_hospital_data(df_control)
        test_datasets.append(features_control)
        
    except FileNotFoundError:
        print("   [WARN] File not found, skipping...")
    except Exception as e:
        print(f"   [ERROR] Error: {e}")
    
    if len(test_datasets) == 0:
        raise ValueError("No hospital data loaded! Check file paths.")
    
    # Combine
    test_df = pd.concat(test_datasets, ignore_index=True)
    
    # Verify
    print(f"\n[OK] Test Data Summary:")
    print(f"   Total samples: {len(test_df)}")
    print(f"   ASD samples: {test_df['group'].sum()}")
    print(f"   Control samples: {len(test_df) - test_df['group'].sum()}")
    
    return test_df

def extract_features_from_hospital_data(df):
    """
    Extract features from your hospital-collected data
    """
    features = pd.DataFrame()
    
    # Direct features
    features['age_months'] = df['age_months'].astype(float)
    features['critical_items_failed'] = df['critical_items_failed'].astype(int)
    features['completion_time_sec'] = df['completion_time_sec'].astype(float)
    
    # Calculate z-scores from raw scores
    # Social Responsiveness
    if 'social_responsiveness_score' in df.columns:
        features['social_responsiveness_zscore'] = stats.zscore(
            df['social_responsiveness_score'].fillna(df['social_responsiveness_score'].mean())
        )
    else:
        # Calculate from Q1, Q4, Q5
        q_cols = ['q1_name_response', 'q4_eye_contact', 'q5_pointing']
        available_q = [col for col in q_cols if col in df.columns]
        if len(available_q) > 0:
            social_raw = df[available_q].sum(axis=1) / len(available_q) * 100
            features['social_responsiveness_zscore'] = stats.zscore(social_raw.fillna(social_raw.mean()))
        else:
            features['social_responsiveness_zscore'] = 0
    
    # Joint Attention
    if 'joint_attention_score' in df.columns:
        features['joint_attention_zscore'] = stats.zscore(
            df['joint_attention_score'].fillna(df['joint_attention_score'].mean())
        )
    else:
        # Calculate from Q5, Q9
        q_cols = ['q5_pointing', 'q9_joint_attention']
        available_q = [col for col in q_cols if col in df.columns]
        if len(available_q) > 0:
            joint_raw = df[available_q].sum(axis=1) / len(available_q) * 100
            features['joint_attention_zscore'] = stats.zscore(joint_raw.fillna(joint_raw.mean()))
        else:
            features['joint_attention_zscore'] = 0
    
    # Total Score
    if 'total_score' in df.columns:
        features['total_score_zscore'] = stats.zscore(
            df['total_score'].fillna(df['total_score'].mean())
        )
    else:
        features['total_score_zscore'] = 0
    
    # Binary flags
    if 'attention_level' in df.columns:
        features['low_attention_flag'] = (df['attention_level'] <= 2).astype(int)
    else:
        features['low_attention_flag'] = 0
    
    features['high_critical_items_flag'] = (df['critical_items_failed'] >= 3).astype(int)
    
    if 'social_responsiveness_score' in df.columns:
        features['low_social_flag'] = (df['social_responsiveness_score'] < 50).astype(int)
    else:
        features['low_social_flag'] = 0
    
    # Target variable
    if 'asd_label' in df.columns:
        features['group'] = df['asd_label'].astype(int)
    elif 'study_group' in df.columns:
        features['group'] = df['study_group'].map({'asd': 1, 'typically_developing': 0}).astype(int)
    else:
        # Default: assume all are ASD if from ASD file
        features['group'] = 1
    
    # Select final features
    final_features = [
        'age_months',
        'critical_items_failed',
        'completion_time_sec',
        'social_responsiveness_zscore',
        'joint_attention_zscore',
        'total_score_zscore',
        'low_attention_flag',
        'high_critical_items_flag',
        'low_social_flag',
        'group'
    ]
    
    return features[final_features]

def main():
    """
    Main function to prepare training and test datasets
    """
    print("="*60)
    print("DATASET PREPARATION: Train/Test Split")
    print("="*60)
    print("\nStrategy:")
    print("  [OK] Training Set: External datasets (~2,314 samples)")
    print("  [OK] Test Set: Your hospital data (40 samples)")
    print("  [OK] Keep test set separate (DO NOT use for training)")
    
    # Create output directory
    os.makedirs('SAMPLE_DATASETS/prepared', exist_ok=True)
    
    # Prepare training data
    try:
        train_df = prepare_training_data_from_external()
        train_path = 'SAMPLE_DATASETS/prepared/train_age_2_3_5_external.csv'
        train_df.to_csv(train_path, index=False)
        print(f"\n[OK] Training data saved: {train_path}")
    except Exception as e:
        print(f"\n[ERROR] Error preparing training data: {e}")
        return
    
    # Prepare test data
    try:
        test_df = prepare_test_data_from_hospital()
        test_path = 'SAMPLE_DATASETS/prepared/test_age_2_3_5_hospital.csv'
        test_df.to_csv(test_path, index=False)
        print(f"[OK] Test data saved: {test_path}")
    except Exception as e:
        print(f"\n[ERROR] Error preparing test data: {e}")
        return
    
    # Save feature list (matching your model)
    feature_list = [
        'age_months',
        'critical_items_failed',
        'completion_time_sec',
        'social_responsiveness_zscore',
        'joint_attention_zscore',
        'total_score_zscore',
        'low_attention_flag',
        'high_critical_items_flag',
        'low_social_flag'
    ]
    
    features_path = 'SAMPLE_DATASETS/prepared/features_age_2_3_5_questionnaire.json'
    with open(features_path, 'w') as f:
        json.dump(feature_list, f, indent=2)
    print(f"[OK] Feature list saved: {features_path}")
    
    # Final summary
    print("\n" + "="*60)
    print("[OK] DATASET PREPARATION COMPLETE!")
    print("="*60)
    print(f"\nTraining Set: {len(train_df)} samples")
    print(f"Test Set: {len(test_df)} samples")
    print(f"\nNext Steps:")
    print("  1. Update training notebook to use:")
    print(f"     - Training: {train_path}")
    print(f"     - Test: {test_path}")
    print("  2. Train model on training set")
    print("  3. Evaluate on test set (hospital data)")
    print("  4. Report both training and test metrics")

if __name__ == '__main__':
    main()
