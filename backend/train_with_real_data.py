"""
Train Autism Screening Model with Real Toddler ASD Eye-Tracking Data

This script uses the dataset from:
"How Attention to Faces and Objects Changes Over Time in Toddlers with 
Autism Spectrum Disorders: Preliminary Evidence from An Eye Tracking Study"
(Zenodo: https://zenodo.org/records/4062063)

Dataset contains:
- 27 toddlers (18-33 months old)
- Group 1 = ASD, Group 0 = Typically Developing (TD)
- Eye tracking metrics: Fixation Duration (FD), Transition patterns, etc.
- ADOS scores (Autism Diagnostic Observation Schedule)

Key metrics we'll use for training:
- FD_F = Fixation Duration on Faces
- FD_O = Fixation Duration on Objects
- FD_TO = Fixation Duration on Target Object
- freq = Frequency of gaze shifts
- DS = Dwell time / scan path metrics
- trans* = Transition patterns between AOIs (Areas of Interest)
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import GradientBoostingClassifier, RandomForestClassifier
from sklearn.model_selection import cross_val_score, LeaveOneOut
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, confusion_matrix
import joblib
import os
import json
from datetime import datetime

# Paths
DATASET_PATH = "datasets/toddler_asd_eye_tracking.xlsx"
MODEL_OUTPUT_PATH = "models/autism_classifier_real_data.pkl"
SCALER_OUTPUT_PATH = "models/scaler_real_data.pkl"

def load_and_prepare_data():
    """Load the toddler ASD dataset and prepare features"""
    print("=" * 60)
    print("LOADING TODDLER ASD EYE-TRACKING DATASET")
    print("=" * 60)
    
    df = pd.read_excel(DATASET_PATH)
    
    print(f"\nDataset shape: {df.shape}")
    print(f"Groups: {df['Group'].value_counts().to_dict()}")
    print(f"  Group 1 (ASD): {(df['Group'] == 1).sum()} toddlers")
    print(f"  Group 0 (TD):  {(df['Group'] == 0).sum()} toddlers")
    print(f"Age range: {df['AgeT0'].min()}-{df['AgeT0'].max()} months")
    
    return df

def extract_features(df, time_point='T0'):
    """
    Extract relevant eye-tracking features that map to our app's capabilities.
    
    Our app collects:
    - Gaze position over time (x, y coordinates)
    - Fixation patterns
    - Saccade patterns (gaze shifts)
    - Target tracking accuracy
    
    Dataset features that map to these:
    - FD_F = Fixation Duration on Faces (social attention)
    - FD_O = Fixation Duration on Objects
    - FD_TO = Fixation Duration on Target Objects
    - freq = Frequency of gaze shifts (saccade rate)
    - DS = Dwell time metrics
    - trans* = Gaze transition patterns
    """
    
    # Feature columns we'll use (T0 = first time point)
    feature_cols = [
        # Responding to Joint Attention (RJA) - following gaze/pointing
        f'TransFTO_RJA_{time_point}',   # Transitions Face->Target Object
        f'transFO_RJA_{time_point}',    # Transitions Face->Object  
        f'freq_RJA_{time_point}',       # Frequency of gaze shifts
        f'freq_norm_RJA_{time_point}',  # Normalized frequency
        f'DS_RJA_{time_point}',         # Dwell time / scan path
        f'DS_norm_RJA_{time_point}',    # Normalized dwell time
        f'FD_F_RJA_{time_point}',       # Fixation Duration on Faces
        f'FD_TO_RJA_{time_point}',      # Fixation Duration on Target Object
        f'FD_O_RJA_{time_point}',       # Fixation Duration on Other Objects
        
        # Initiating Joint Attention 1 (IJA1)
        f'transTOF_IJA1_{time_point}',  # Target Object -> Face
        f'transOF_IJA1_{time_point}',   # Object -> Face
        f'transFTO_IJA1_{time_point}',  # Face -> Target Object
        f'transFO_IJA1_{time_point}',   # Face -> Object
        f'transTOO_IJA1_{time_point}',  # Target Object -> Object
        f'freq_IJA1_{time_point}',      # Gaze shift frequency
        f'freq_norm_IJA1_{time_point}', 
        f'DS_IJA1_{time_point}',
        f'DS_norm_IJA1_{time_point}',
        f'FD_F_IJA1_{time_point}',      # Face fixation
        f'FD_TO_IJA1_{time_point}',     # Target fixation
        f'FD_O_IJA1_{time_point}',      # Object fixation
        
        # Initiating Joint Attention 2 (IJA2)
        f'transTOF_IJA2_{time_point}',
        f'transFTO_IJA2_{time_point}',
        f'FD_F_IJA2_{time_point}',
        f'FD_TO_IJA2_{time_point}',
    ]
    
    # Also include age as a feature
    feature_cols_with_age = ['AgeT0'] + feature_cols
    
    # Filter to available columns
    available_cols = [c for c in feature_cols_with_age if c in df.columns]
    print(f"\nUsing {len(available_cols)} features")
    
    X = df[available_cols].copy()
    y = df['Group'].values  # 1 = ASD, 0 = TD
    
    # Convert all columns to numeric, coercing errors to NaN
    for col in X.columns:
        X[col] = pd.to_numeric(X[col], errors='coerce')
    
    # Handle missing values
    X = X.fillna(X.mean())
    
    return X, y, available_cols

def compute_derived_features(X):
    """
    Compute additional features that match our app's metrics.
    These are derived from the raw eye-tracking data.
    """
    X_derived = X.copy()
    
    # Ratio features (important ASD markers)
    # Face-to-Object attention ratio (lower in ASD)
    if 'FD_F_RJA_T0' in X.columns and 'FD_O_RJA_T0' in X.columns:
        face_fix = X['FD_F_RJA_T0'].replace(0, 0.001)
        obj_fix = X['FD_O_RJA_T0'].replace(0, 0.001)
        X_derived['face_object_ratio'] = face_fix / (face_fix + obj_fix)
    
    # Social attention index
    if 'FD_F_IJA1_T0' in X.columns:
        X_derived['social_attention_index'] = (
            X.get('FD_F_RJA_T0', 0) + 
            X.get('FD_F_IJA1_T0', 0) + 
            X.get('FD_F_IJA2_T0', 0)
        ) / 3
    
    # Gaze shift variability (higher variability = potential ASD marker)
    freq_cols = [c for c in X.columns if 'freq' in c.lower()]
    if freq_cols:
        X_derived['gaze_shift_variability'] = X[freq_cols].std(axis=1)
    
    # Target tracking accuracy proxy
    if 'FD_TO_RJA_T0' in X.columns:
        X_derived['target_tracking'] = (
            X.get('FD_TO_RJA_T0', 0) + 
            X.get('FD_TO_IJA1_T0', 0) + 
            X.get('FD_TO_IJA2_T0', 0)
        ) / 3
    
    # Joint attention response (transitions to face)
    trans_face_cols = [c for c in X.columns if 'transOF' in c or 'transTOF' in c]
    if trans_face_cols:
        X_derived['joint_attention_response'] = X[trans_face_cols].mean(axis=1)
    
    return X_derived

def map_to_app_features():
    """
    Define mapping from dataset features to our app's feature space.
    This helps us understand how to use the trained model with our app's data.
    """
    mapping = {
        # Dataset feature -> App feature description
        'FD_F_*': 'fixation_duration_target (when target is face/social)',
        'FD_TO_*': 'fixation_duration_target (when following butterfly)',
        'FD_O_*': 'fixation_duration_target (when looking at distractors)',
        'freq_*': 'saccade_rate (gaze shifts per second)',
        'DS_*': 'mean_fixation_duration (dwell time)',
        'trans*': 'smooth_pursuit_ratio (gaze transition patterns)',
        'face_object_ratio': 'social_attention_ratio (face vs object preference)',
        'target_tracking': 'tracking_accuracy',
    }
    return mapping

def train_model(X, y):
    """Train the autism classifier using real data"""
    print("\n" + "=" * 60)
    print("TRAINING MODEL WITH REAL TODDLER DATA")
    print("=" * 60)
    
    # Scale features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Use Gradient Boosting (same as our current model)
    model = GradientBoostingClassifier(
        n_estimators=100,
        max_depth=3,
        learning_rate=0.1,
        min_samples_split=3,  # Allow smaller splits for small dataset
        min_samples_leaf=2,
        random_state=42
    )
    
    # Leave-One-Out cross-validation (best for small datasets)
    print("\nPerforming Leave-One-Out Cross-Validation...")
    loo = LeaveOneOut()
    loo_scores = cross_val_score(model, X_scaled, y, cv=loo, scoring='accuracy')
    print(f"LOO CV Accuracy: {loo_scores.mean():.3f} (+/- {loo_scores.std()*2:.3f})")
    
    # Also try 5-fold CV for comparison
    cv_scores = cross_val_score(model, X_scaled, y, cv=5, scoring='accuracy')
    print(f"5-Fold CV Accuracy: {cv_scores.mean():.3f} (+/- {cv_scores.std()*2:.3f})")
    
    # Train final model on all data
    model.fit(X_scaled, y)
    
    # Feature importance
    print("\nTop 10 Most Important Features:")
    importance = pd.DataFrame({
        'feature': X.columns,
        'importance': model.feature_importances_
    }).sort_values('importance', ascending=False)
    print(importance.head(10).to_string(index=False))
    
    return model, scaler, importance

def generate_synthetic_augmentation(X, y, n_samples=200):
    """
    Generate synthetic samples to augment the small real dataset.
    Uses the statistical properties of the real data.
    """
    print("\n" + "=" * 60)
    print("GENERATING SYNTHETIC AUGMENTATION DATA")
    print("=" * 60)
    
    X_aug = []
    y_aug = []
    
    for label in [0, 1]:  # TD and ASD
        X_class = X[y == label]
        n_class_samples = n_samples // 2
        
        # Calculate statistics for this class
        means = X_class.mean()
        stds = X_class.std()
        
        # Generate samples with noise
        for _ in range(n_class_samples):
            sample = {}
            for col in X.columns:
                # Add Gaussian noise based on the feature's variability
                noise = np.random.normal(0, stds[col] * 0.3)
                sample[col] = means[col] + noise
            X_aug.append(sample)
            y_aug.append(label)
    
    X_aug_df = pd.DataFrame(X_aug)
    y_aug = np.array(y_aug)
    
    # Combine original and augmented
    X_combined = pd.concat([X, X_aug_df], ignore_index=True)
    y_combined = np.concatenate([y, y_aug])
    
    print(f"Original samples: {len(X)}")
    print(f"Augmented samples: {len(X_aug_df)}")
    print(f"Total combined: {len(X_combined)}")
    
    return X_combined, y_combined

def create_app_compatible_model(model, scaler, feature_importance):
    """
    Create a model configuration that can be used with our app's feature extraction.
    Maps dataset features to app features.
    """
    config = {
        'model_type': 'GradientBoostingClassifier',
        'trained_on': 'Toddler ASD Eye-Tracking Dataset (Zenodo)',
        'n_subjects': 27,
        'age_range_months': '18-33',
        'target_age_range': '2-6 years',
        'feature_mapping': {
            # Map our app's features to similar dataset features
            'app_feature': 'dataset_equivalent',
            'fixation_duration_target': ['FD_TO_RJA_T0', 'FD_TO_IJA1_T0'],
            'saccade_count': ['freq_RJA_T0', 'freq_IJA1_T0'],
            'smooth_pursuit_ratio': ['TransFTO_RJA_T0', 'transFTO_IJA1_T0'],
            'gaze_variability': ['DS_RJA_T0', 'DS_IJA1_T0'],
            'social_attention': ['FD_F_RJA_T0', 'FD_F_IJA1_T0'],
        },
        'top_features': feature_importance.head(10).to_dict('records'),
        'interpretation': {
            0: {'label': 'Low Risk', 'description': 'Typical Development Pattern'},
            1: {'label': 'High Risk', 'description': 'ASD-like Gaze Pattern'},
        },
        'trained_date': datetime.now().isoformat(),
    }
    return config

def save_model(model, scaler, config, feature_cols):
    """Save the trained model and configuration"""
    os.makedirs('models', exist_ok=True)
    
    # Save model
    joblib.dump(model, MODEL_OUTPUT_PATH)
    print(f"\nModel saved to: {MODEL_OUTPUT_PATH}")
    
    # Save scaler
    joblib.dump(scaler, SCALER_OUTPUT_PATH)
    print(f"Scaler saved to: {SCALER_OUTPUT_PATH}")
    
    # Save feature list
    with open('models/feature_columns_real_data.json', 'w') as f:
        json.dump(feature_cols, f, indent=2)
    
    # Save config
    with open('models/model_config_real_data.json', 'w') as f:
        json.dump(config, f, indent=2)
    print(f"Config saved to: models/model_config_real_data.json")

def analyze_asd_markers(df, X):
    """Analyze key ASD markers in the dataset"""
    print("\n" + "=" * 60)
    print("ANALYZING ASD MARKERS IN DATASET")
    print("=" * 60)
    
    asd = df[df['Group'] == 1].copy()
    td = df[df['Group'] == 0].copy()
    
    # Convert columns to numeric
    for col in ['FD_F_RJA_T0', 'FD_O_RJA_T0', 'freq_RJA_T0', 'ADOStot_T0']:
        if col in asd.columns:
            asd[col] = pd.to_numeric(asd[col], errors='coerce')
        if col in td.columns:
            td[col] = pd.to_numeric(td[col], errors='coerce')
    
    print("\nKey differences between ASD and TD groups:")
    print("-" * 50)
    
    # Face fixation (typically lower in ASD)
    if 'FD_F_RJA_T0' in X.columns:
        asd_face = asd['FD_F_RJA_T0'].mean()
        td_face = td['FD_F_RJA_T0'].mean() if len(td) > 0 else 0
        print(f"Face Fixation (RJA): ASD={asd_face:.2f}, TD={td_face:.2f}")
    
    # Object fixation (sometimes higher in ASD)
    if 'FD_O_RJA_T0' in X.columns:
        asd_obj = asd['FD_O_RJA_T0'].mean()
        td_obj = td['FD_O_RJA_T0'].mean() if len(td) > 0 else 0
        print(f"Object Fixation (RJA): ASD={asd_obj:.2f}, TD={td_obj:.2f}")
    
    # Gaze shift frequency
    if 'freq_RJA_T0' in X.columns:
        asd_freq = asd['freq_RJA_T0'].mean()
        td_freq = td['freq_RJA_T0'].mean() if len(td) > 0 else 0
        print(f"Gaze Shift Freq: ASD={asd_freq:.2f}, TD={td_freq:.2f}")
    
    # ADOS scores (clinical severity)
    if 'ADOStot_T0' in asd.columns:
        print(f"\nADOS Total Score (ASD group): {asd['ADOStot_T0'].mean():.1f} (range: {asd['ADOStot_T0'].min()}-{asd['ADOStot_T0'].max()})")

def main():
    """Main training pipeline"""
    print("\n" + "=" * 60)
    print("AUTISM SCREENING MODEL - REAL DATA TRAINING")
    print("=" * 60)
    print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    
    # Load data
    df = load_and_prepare_data()
    
    # Extract features
    X, y, feature_cols = extract_features(df, time_point='T0')
    
    # Add derived features
    X = compute_derived_features(X)
    
    # Analyze ASD markers
    analyze_asd_markers(df, X)
    
    # Generate augmented data (since dataset is small)
    X_aug, y_aug = generate_synthetic_augmentation(X, y, n_samples=200)
    
    # Train model
    model, scaler, importance = train_model(X_aug, y_aug)
    
    # Create app-compatible config
    config = create_app_compatible_model(model, scaler, importance)
    
    # Save everything
    save_model(model, scaler, config, list(X.columns))
    
    print("\n" + "=" * 60)
    print("TRAINING COMPLETE!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. The model is trained on real toddler ASD eye-tracking data")
    print("2. Use models/autism_classifier_real_data.pkl for predictions")
    print("3. Feature mapping is saved in models/model_config_real_data.json")
    print("4. Integrate with main.py to use the new model")
    
    return model, scaler, config

if __name__ == "__main__":
    main()
