"""
Complete Training Script for Age 3.5-5.5 Frog Jump Model

Includes:
- Data loading (game + auxiliary questionnaire)
- Feature engineering
- Outlier detection
- Data augmentation
- Model training
- Evaluation
- Model persistence
"""

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
import json
import joblib
from datetime import datetime
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from config import AGE_3_5_5_5_CONFIG, MODELS_DIR, PREPARED_DATA_DIR, OUTPUT_DIR
from utils.feature_engineering import FeatureEngineer
from utils.outlier_detection import OutlierDetector
from utils.data_augmentation import DataAugmenter
from utils.preprocessing import DataPreprocessor
from utils.evaluation import ModelEvaluator

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
MODELS_DIR.mkdir(parents=True, exist_ok=True)


def load_data():
    """Load game data and auxiliary questionnaire data"""
    print("[LOAD] Loading datasets...")
    
    # Load game data (adapt path based on your data)
    game_path = PREPARED_DATA_DIR / "game_age_3_5_5_5_frog_jump.csv"
    if game_path.exists():
        game_df = pd.read_csv(game_path)
    else:
        print("[WARN] Game data not found. Please prepare game data first.")
        game_df = pd.DataFrame()
    
    # Load auxiliary questionnaire data
    aux_path = PREPARED_DATA_DIR / "auxiliary_age_3_5_5_5_questionnaire.csv"
    aux_df = pd.read_csv(aux_path) if aux_path.exists() else pd.DataFrame()
    
    print(f"   Game data: {len(game_df)} samples")
    print(f"   Auxiliary data: {len(aux_df)} samples")
    
    return game_df, aux_df


def combine_features(game_df, aux_df):
    """Combine game features with auxiliary questionnaire features"""
    print("\n[COMBINE] Combining game and auxiliary features...")
    
    if len(game_df) == 0:
        print("[ERROR] No game data available!")
        return pd.DataFrame()
    
    # Start with game features
    combined_df = game_df.copy()
    
    # Add auxiliary features if available
    if len(aux_df) > 0:
        # Match by age (approximate matching)
        # This is simplified - adapt based on your data structure
        for idx, row in combined_df.iterrows():
            age = row.get('age_months', 0)
            # Find closest age match in auxiliary data
            if age > 0:
                closest_aux = aux_df.iloc[(aux_df['age_months'] - age).abs().argsort()[:1]]
                if len(closest_aux) > 0:
                    combined_df.loc[idx, 'questionnaire_score'] = closest_aux.iloc[0]['questionnaire_score']
                    combined_df.loc[idx, 'critical_items_failed'] = closest_aux.iloc[0]['critical_items_failed']
                    combined_df.loc[idx, 'social_responsiveness_score'] = closest_aux.iloc[0]['social_responsiveness_score']
    
    print(f"   [OK] Combined: {len(combined_df)} samples")
    return combined_df


def preprocess_data(df):
    """Preprocess data"""
    print("\n[PREPROCESS] Preprocessing data...")
    
    preprocessor = DataPreprocessor(random_state=AGE_3_5_5_5_CONFIG['random_state'])
    df = preprocessor.clean_data(df)
    
    # Feature engineering
    feature_engineer = FeatureEngineer(
        age_bins=AGE_3_5_5_5_CONFIG['age_bins'],
        random_state=AGE_3_5_5_5_CONFIG['random_state']
    )
    
    df = feature_engineer.engineer_frog_jump_features(df)
    
    return df


def handle_outliers(df):
    """Detect and handle outliers"""
    print("\n[OUTLIER] Detecting and handling outliers...")
    
    detector = OutlierDetector(
        method=AGE_3_5_5_5_CONFIG['outlier_detection']['method'],
        iqr_factor=AGE_3_5_5_5_CONFIG['outlier_detection']['iqr_factor']
    )
    
    # Get numerical columns
    all_features = AGE_3_5_5_5_CONFIG['game_features'] + AGE_3_5_5_5_CONFIG['auxiliary_features']
    numerical_cols = [col for col in all_features if col in df.columns and col != 'group']
    
    if AGE_3_5_5_5_CONFIG['outlier_detection']['winsorize']:
        df = detector.winsorize(
            df,
            numerical_cols,
            limits=AGE_3_5_5_5_CONFIG['outlier_detection']['winsorize_limits']
        )
        print("   [OK] Outliers winsorized")
    else:
        df = detector.remove_outliers(df, numerical_cols)
        summary = detector.get_outlier_summary()
        print(f"   [OK] Removed {summary['removed_count']} outliers")
    
    return df


def augment_data(X_train, y_train):
    """Augment training data"""
    print("\n[AUGMENT] Augmenting training data...")
    
    augmenter = DataAugmenter(random_state=AGE_3_5_5_5_CONFIG['random_state'])
    
    if AGE_3_5_5_5_CONFIG['augmentation']['enabled']:
        X_aug, y_aug = augmenter.augment(
            X_train,
            y_train,
            method=AGE_3_5_5_5_CONFIG['augmentation']['method'],
            target_samples=AGE_3_5_5_5_CONFIG['augmentation']['target_samples']
        )
        print(f"   [OK] Augmented: {len(X_aug)} samples (from {len(X_train)})")
        return X_aug, y_aug
    
    return X_train, y_train


def train_models(X_train, y_train, X_test, y_test):
    """Train models"""
    print("\n[TRAIN] Training models...")
    
    models = {}
    results = {}
    
    # Prepare features
    all_features = AGE_3_5_5_5_CONFIG['game_features'] + AGE_3_5_5_5_CONFIG['auxiliary_features']
    feature_cols = [col for col in all_features if col in X_train.columns and col != 'group']
    X_train_features = X_train[feature_cols]
    X_test_features = X_test[feature_cols] if len(X_test) > 0 else pd.DataFrame()
    
    # Scale features
    preprocessor = DataPreprocessor(random_state=AGE_3_5_5_5_CONFIG['random_state'])
    X_train_scaled, X_test_scaled = preprocessor.scale_features(
        X_train_features,
        X_test_features,
        method="standard"
    )
    
    # Train Logistic Regression
    print("\n   Training Logistic Regression...")
    lr_model = LogisticRegression(**AGE_3_5_5_5_CONFIG['logistic_regression'])
    lr_model.fit(X_train_scaled, y_train)
    models['logistic_regression'] = lr_model
    
    evaluator = ModelEvaluator()
    y_pred_lr = lr_model.predict(X_train_scaled)
    y_proba_lr = lr_model.predict_proba(X_train_scaled)
    train_metrics = evaluator.calculate_metrics(y_train, y_pred_lr, y_proba_lr)
    
    if len(X_test_scaled) > 0:
        y_pred_test_lr = lr_model.predict(X_test_scaled)
        y_proba_test_lr = lr_model.predict_proba(X_test_scaled)
        test_metrics = evaluator.calculate_metrics(y_test, y_pred_test_lr, y_proba_test_lr)
    else:
        test_metrics = {}
    
    results['logistic_regression'] = {'train': train_metrics, 'test': test_metrics}
    print(f"   [OK] LR - Train Accuracy: {train_metrics['accuracy']:.3f}")
    if test_metrics:
        print(f"   [OK] LR - Test Accuracy: {test_metrics['accuracy']:.3f}")
    
    # Train Random Forest
    print("\n   Training Random Forest...")
    rf_model = RandomForestClassifier(**AGE_3_5_5_5_CONFIG['random_forest'])
    rf_model.fit(X_train_scaled, y_train)
    models['random_forest'] = rf_model
    
    y_pred_rf = rf_model.predict(X_train_scaled)
    y_proba_rf = rf_model.predict_proba(X_train_scaled)
    train_metrics_rf = evaluator.calculate_metrics(y_train, y_pred_rf, y_proba_rf)
    
    if len(X_test_scaled) > 0:
        y_pred_test_rf = rf_model.predict(X_test_scaled)
        y_proba_test_rf = rf_model.predict_proba(X_test_scaled)
        test_metrics_rf = evaluator.calculate_metrics(y_test, y_pred_test_rf, y_proba_test_rf)
    else:
        test_metrics_rf = {}
    
    results['random_forest'] = {'train': train_metrics_rf, 'test': test_metrics_rf}
    print(f"   [OK] RF - Train Accuracy: {train_metrics_rf['accuracy']:.3f}")
    if test_metrics_rf:
        print(f"   [OK] RF - Test Accuracy: {test_metrics_rf['accuracy']:.3f}")
    
    return models, results, preprocessor.get_scaler()


def save_model(model, scaler, feature_cols, model_name):
    """Save trained model"""
    print(f"\n[SAVE] Saving {model_name}...")
    
    model_path = MODELS_DIR / f"{AGE_3_5_5_5_CONFIG['model_name']}.pkl"
    joblib.dump(model, model_path)
    print(f"   [OK] Model saved: {model_path}")
    
    scaler_path = MODELS_DIR / f"scaler_{AGE_3_5_5_5_CONFIG['model_name']}.pkl"
    joblib.dump(scaler, scaler_path)
    print(f"   [OK] Scaler saved: {scaler_path}")
    
    features_path = MODELS_DIR / f"features_{AGE_3_5_5_5_CONFIG['model_name']}.json"
    with open(features_path, 'w') as f:
        json.dump(feature_cols, f, indent=2)
    print(f"   [OK] Features saved: {features_path}")
    
    metadata = {
        "model_name": AGE_3_5_5_5_CONFIG['model_name'],
        "age_range": AGE_3_5_5_5_CONFIG['age_range'],
        "session_type": AGE_3_5_5_5_CONFIG['session_type'],
        "features": feature_cols,
        "training_date": datetime.now().isoformat(),
        "algorithm": model_name
    }
    
    metadata_path = MODELS_DIR / f"model_metadata_{AGE_3_5_5_5_CONFIG['model_name']}.json"
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    print(f"   [OK] Metadata saved: {metadata_path}")


def main():
    """Main training function"""
    print("\n" + "="*60)
    print("TRAINING AGE 3.5-5.5 FROG JUMP MODEL")
    print("="*60)
    
    # Load data
    game_df, aux_df = load_data()
    
    # Combine features
    combined_df = combine_features(game_df, aux_df)
    if len(combined_df) == 0:
        print("[ERROR] No data to train on!")
        return
    
    # Preprocess
    combined_df = preprocess_data(combined_df)
    
    # Handle outliers
    combined_df = handle_outliers(combined_df)
    
    # Split train/test
    preprocessor = DataPreprocessor(random_state=AGE_3_5_5_5_CONFIG['random_state'])
    X_train, X_test, y_train, y_test = preprocessor.split_train_test(
        combined_df,
        target_col='group',
        test_size=AGE_3_5_5_5_CONFIG['test_size']
    )
    
    # Augment data
    X_train_aug, y_train_aug = augment_data(X_train, y_train)
    
    # Train models
    models, results, scaler = train_models(X_train_aug, y_train_aug, X_test, y_test)
    
    # Save best model
    all_features = AGE_3_5_5_5_CONFIG['game_features'] + AGE_3_5_5_5_CONFIG['auxiliary_features']
    feature_cols = [col for col in all_features if col in X_train.columns and col != 'group']
    save_model(models['logistic_regression'], scaler, feature_cols, "logistic_regression")
    
    # Save results
    results_path = OUTPUT_DIR / f"training_results_{AGE_3_5_5_5_CONFIG['model_name']}.json"
    with open(results_path, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    print(f"\n[OK] Results saved: {results_path}")
    
    print("\n" + "="*60)
    print("[OK] Training complete!")
    print("="*60)


if __name__ == "__main__":
    main()
