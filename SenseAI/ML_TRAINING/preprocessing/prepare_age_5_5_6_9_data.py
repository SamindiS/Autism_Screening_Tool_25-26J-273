"""
Prepare Training and Test Datasets for Age 5.5-6.9 Color-Shape Model

Strategy:
- Training Set: External questionnaire data (auxiliary) + Hospital game data
- Test Set: Hospital game data (separate children)
- Features: DCCS game metrics (primary) + Questionnaire scores (auxiliary)
"""

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
import json
from config import AGE_5_5_6_9_CONFIG, PREPARED_DATA_DIR
from utils.feature_engineering import FeatureEngineer

PREPARED_DATA_DIR.mkdir(parents=True, exist_ok=True)


def prepare_auxiliary_questionnaire_data():
    """Prepare auxiliary questionnaire data from external dataset"""
    print("[PREP] Preparing Auxiliary Questionnaire Data for Age 5.5-6.9...")
    print("="*60)
    
    try:
        dataset_path = AGE_5_5_6_9_CONFIG['external_datasets'][0]['path']
        print(f"\nLoading: {dataset_path.name}...")
        df = pd.read_csv(dataset_path)
        
        # Filter to age 5.5-6.9
        df_filtered = df[(df['Age'] >= 66) & (df['Age'] < 83)]
        print(f"   Filtered: {len(df_filtered)} samples (age 66-83 months)")
        
        # Extract questionnaire features
        auxiliary_df = pd.DataFrame()
        auxiliary_df['age_months'] = df_filtered['Age']
        
        # A1-A10 scores
        a_cols = [f'A{i}' for i in range(1, 11)]
        for col in a_cols:
            if col not in df_filtered.columns:
                df_filtered[col] = 0
        
        auxiliary_df['questionnaire_score'] = df_filtered[a_cols].sum(axis=1)
        auxiliary_df['critical_items_failed'] = df_filtered[a_cols].sum(axis=1)
        auxiliary_df['social_responsiveness_score'] = (
            df_filtered[['A1', 'A4', 'A5']].sum(axis=1) / 3 * 100
        )
        
        # Target
        auxiliary_df['group'] = df_filtered['Class'].map({'YES': 1, 'NO': 0, 'Yes': 1, 'No': 0}).fillna(0)
        
        print(f"[OK] Auxiliary data: {len(auxiliary_df)} samples")
        print(f"   - ASD: {auxiliary_df['group'].sum()}")
        print(f"   - Control: {len(auxiliary_df) - auxiliary_df['group'].sum()}")
        
        return auxiliary_df
    
    except Exception as e:
        print(f"[ERROR] Error: {e}")
        return pd.DataFrame()


def prepare_game_data():
    """Prepare game data from hospital datasets"""
    print("\n[PREP] Preparing Game Data from Hospital Data...")
    print("="*60)
    
    # This is a placeholder - adapt based on your actual hospital game data structure
    # You need to load your actual Color-Shape game data here
    
    print("[WARN] Hospital game data loading not implemented yet.")
    print("       Please adapt this function to load your actual game data.")
    
    return pd.DataFrame()


def main():
    """Main function"""
    print("\n" + "="*60)
    print("PREPARING DATASETS FOR AGE 5.5-6.9 COLOR-SHAPE MODEL")
    print("="*60)
    
    # Prepare auxiliary questionnaire data
    auxiliary_df = prepare_auxiliary_questionnaire_data()
    if len(auxiliary_df) > 0:
        aux_path = PREPARED_DATA_DIR / "auxiliary_age_5_5_6_9_questionnaire.csv"
        auxiliary_df.to_csv(aux_path, index=False)
        print(f"\n[OK] Auxiliary data saved: {aux_path}")
    
    # Prepare game data (adapt based on your data)
    game_df = prepare_game_data()
    if len(game_df) > 0:
        game_path = PREPARED_DATA_DIR / "game_age_5_5_6_9_color_shape.csv"
        game_df.to_csv(game_path, index=False)
        print(f"\n[OK] Game data saved: {game_path}")
    
    print("\n" + "="*60)
    print("[OK] Dataset preparation complete!")
    print("="*60)


if __name__ == "__main__":
    main()
