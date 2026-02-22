"""
Prepare Training and Test Datasets for Age 2-3.5 Questionnaire Model

Strategy:
- Training Set: External datasets (Toddler Autism July 2018, Autism Screening Combined)
- Test Set: Hospital-collected data
- Features: A1-A10, Q-CHAT-10, age-normalized scores
"""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
import json
from scipy import stats
from config import AGE_2_3_5_CONFIG, PREPARED_DATA_DIR
from utils.feature_engineering import FeatureEngineer
from utils.preprocessing import DataPreprocessor

PREPARED_DATA_DIR.mkdir(parents=True, exist_ok=True)


def extract_features_from_external(df, age_col, qchat_col=None):
    """Extract features from external dataset structure"""
    features = pd.DataFrame()
    
    # Age
    features['age_months'] = df[age_col].astype(float)
    
    # A1-A10 columns
    a_cols = [f'A{i}' for i in range(1, 11)]
    for col in a_cols:
        if col not in df.columns:
            df[col] = 0
    
    # Critical items failed
    features['critical_items_failed'] = df[a_cols].sum(axis=1).astype(int)
    
    # Completion time (impute with median)
    features['completion_time_sec'] = 300.0
    
    # Domain scores
    social_items = ['A1', 'A4', 'A5']
    features['social_responsiveness_raw'] = (
        df[social_items].sum(axis=1) / len(social_items) * 100
    )
    
    joint_items = ['A5', 'A9']
    features['joint_attention_raw'] = (
        df[joint_items].sum(axis=1) / len(joint_items) * 100
    )
    
    # Total score
    if qchat_col and qchat_col in df.columns:
        features['total_score_raw'] = df[qchat_col] * 10
    else:
        features['total_score_raw'] = df[a_cols].sum(axis=1) * 10
    
    # Age-normalize
    age_bins = [24, 30, 36, 42]
    features['age_bin'] = pd.cut(
        features['age_months'],
        bins=age_bins,
        labels=['24-30', '30-36', '36-42'],
        include_lowest=True
    )
    
    for col in ['social_responsiveness_raw', 'joint_attention_raw', 'total_score_raw']:
        zscore_col = col.replace('_raw', '_zscore')
        features[zscore_col] = features.groupby('age_bin')[col].transform(
            lambda x: stats.zscore(x.fillna(x.mean())) if len(x) > 1 and x.std() > 0 else 0
        )
        features[zscore_col] = features[zscore_col].fillna(0)
    
    # Binary flags
    features['low_attention_flag'] = (
        (df['A1'] == 1) | (df['A4'] == 1)
    ).astype(int)
    
    features['high_critical_items_flag'] = (
        features['critical_items_failed'] >= 3
    ).astype(int)
    
    features['low_social_flag'] = (
        features['social_responsiveness_raw'] < 50
    ).astype(int)
    
    # Target variable
    if 'Class/ASD Traits' in df.columns:
        features['group'] = df['Class/ASD Traits'].map({'Yes': 1, 'No': 0, 'YES': 1, 'NO': 0}).fillna(0)
    elif 'Class/ASD Traits ' in df.columns:
        features['group'] = df['Class/ASD Traits '].map({'Yes': 1, 'No': 0, 'YES': 1, 'NO': 0}).fillna(0)
    elif 'Class' in df.columns:
        features['group'] = df['Class'].map({'YES': 1, 'NO': 0, 'Yes': 1, 'No': 0}).fillna(0)
    else:
        features['group'] = 0
    
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


def prepare_training_data():
    """Prepare training data from external datasets"""
    print("[PREP] Preparing Training Data for Age 2-3.5...")
    print("="*60)
    
    datasets = []
    
    # Dataset 1: Toddler Autism Dataset (July 2018)
    try:
        print("\n1. Loading: Toddler Autism Dataset (July 2018)...")
        df1 = pd.read_csv(AGE_2_3_5_CONFIG['external_datasets'][0]['path'])
        
        df1_filtered = df1[(df1['Age_Mons'] >= 24) & (df1['Age_Mons'] < 42)]
        print(f"   Filtered: {len(df1_filtered)} samples (age 24-42 months)")
        
        df1_features = extract_features_from_external(
            df1_filtered,
            age_col='Age_Mons',
            qchat_col='Qchat-10-Score'
        )
        print(f"   Extracted features: {len(df1_features)} samples")
        datasets.append(df1_features)
    except Exception as e:
        print(f"   [ERROR] Error: {e}")
    
    # Dataset 2: Autism Screening Data Combined
    try:
        print("\n2. Loading: Autism Screening Data Combined...")
        df2 = pd.read_csv(AGE_2_3_5_CONFIG['external_datasets'][1]['path'])
        
        df2_filtered = df2[(df2['Age'] >= 24) & (df2['Age'] < 42)]
        print(f"   Filtered: {len(df2_filtered)} samples (age 24-42 months)")
        
        df2_features = extract_features_from_external(
            df2_filtered,
            age_col='Age',
            qchat_col=None
        )
        print(f"   Extracted features: {len(df2_features)} samples")
        datasets.append(df2_features)
    except Exception as e:
        print(f"   [ERROR] Error: {e}")
    
    # Combine datasets
    if len(datasets) == 0:
        print("\n[ERROR] No datasets loaded!")
        return pd.DataFrame()
    
    combined = pd.concat(datasets, ignore_index=True)
    print(f"\n[OK] Combined training data: {len(combined)} samples")
    print(f"   - ASD: {combined['group'].sum()}")
    print(f"   - Control: {len(combined) - combined['group'].sum()}")
    
    return combined


def prepare_test_data():
    """Prepare test data from hospital datasets"""
    print("\n[PREP] Preparing Test Data from Hospital Data...")
    print("="*60)
    
    datasets = []
    
    for dataset_path in AGE_2_3_5_CONFIG['hospital_datasets']:
        try:
            print(f"\nLoading: {dataset_path.name}...")
            df = pd.read_csv(dataset_path)
            
            # Filter to age 2-3.5
            if 'age_months' in df.columns:
                df_filtered = df[(df['age_months'] >= 24) & (df['age_months'] < 42)]
            else:
                df_filtered = df
            
            print(f"   Samples: {len(df_filtered)}")
            
            # Extract features (similar to external, but adapt to hospital format)
            # This is a simplified version - adapt based on your actual hospital data structure
            features = pd.DataFrame()
            
            if 'age_months' in df_filtered.columns:
                features['age_months'] = df_filtered['age_months']
            else:
                continue
            
            # Map your hospital data columns to features
            # Adapt this based on your actual data structure
            for col in AGE_2_3_5_CONFIG['features']:
                if col in df_filtered.columns:
                    features[col] = df_filtered[col]
                else:
                    features[col] = 0
            
            # Target
            if 'group' in df_filtered.columns:
                features['group'] = df_filtered['group']
            elif 'asd_label' in df_filtered.columns:
                features['group'] = df_filtered['asd_label']
            else:
                # Assume all are ASD if from ASD file
                features['group'] = 1
            
            datasets.append(features)
        except Exception as e:
            print(f"   [ERROR] Error loading {dataset_path}: {e}")
    
    if len(datasets) == 0:
        print("\n[WARN] No hospital datasets loaded!")
        return pd.DataFrame()
    
    combined = pd.concat(datasets, ignore_index=True)
    print(f"\n[OK] Combined test data: {len(combined)} samples")
    print(f"   - ASD: {combined['group'].sum()}")
    print(f"   - Control: {len(combined) - combined['group'].sum()}")
    
    return combined


def main():
    """Main function"""
    print("\n" + "="*60)
    print("PREPARING DATASETS FOR AGE 2-3.5 QUESTIONNAIRE MODEL")
    print("="*60)
    
    # Prepare training data
    train_df = prepare_training_data()
    if len(train_df) > 0:
        train_path = PREPARED_DATA_DIR / "train_age_2_3_5_questionnaire.csv"
        train_df.to_csv(train_path, index=False)
        print(f"\n[OK] Training data saved: {train_path}")
        print(f"   Samples: {len(train_df)}")
    
    # Prepare test data
    test_df = prepare_test_data()
    if len(test_df) > 0:
        test_path = PREPARED_DATA_DIR / "test_age_2_3_5_questionnaire.csv"
        test_df.to_csv(test_path, index=False)
        print(f"\n[OK] Test data saved: {test_path}")
        print(f"   Samples: {len(test_df)}")
    
    # Save feature list
    feature_list = AGE_2_3_5_CONFIG['features']
    feature_path = PREPARED_DATA_DIR / "features_age_2_3_5_questionnaire.json"
    with open(feature_path, 'w') as f:
        json.dump(feature_list, f, indent=2)
    print(f"\n[OK] Feature list saved: {feature_path}")
    
    print("\n" + "="*60)
    print("[OK] Dataset preparation complete!")
    print("="*60)


if __name__ == "__main__":
    main()
