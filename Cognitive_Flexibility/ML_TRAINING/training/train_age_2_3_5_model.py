"""
Complete Training Script for Age 2-3.5 Questionnaire Model

Includes:
- Data loading and preprocessing
- Feature engineering
- Outlier detection and handling
- Data augmentation
- Model training (Logistic Regression + Random Forest)
- Evaluation and reporting
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
from sklearn.model_selection import cross_val_score, StratifiedKFold
from config import AGE_2_3_5_CONFIG, MODELS_DIR, PREPARED_DATA_DIR, OUTPUT_DIR
from utils.feature_engineering import FeatureEngineer
from utils.outlier_detection import OutlierDetector
from utils.data_augmentation import DataAugmenter
from utils.preprocessing import DataPreprocessor
from utils.evaluation import ModelEvaluator

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
MODELS_DIR.mkdir(parents=True, exist_ok=True)


def load_data():
    """Load prepared training and test data"""
    print("[LOAD] Loading datasets...")
    
    train_path = PREPARED_DATA_DIR / "train_age_2_3_5_questionnaire.csv"
    test_path = PREPARED_DATA_DIR / "test_age_2_3_5_questionnaire.csv"
    
    train_df = pd.read_csv(train_path)
    test_df = pd.read_csv(test_path) if test_path.exists() else pd.DataFrame()
    
    print(f"   Training: {len(train_df)} samples")
    print(f"   Test: {len(test_df)} samples")
    
    return train_df, test_df


def preprocess_data(train_df, test_df):
    """Preprocess data"""
    print("\n[PREPROCESS] Preprocessing data...")
    
    preprocessor = DataPreprocessor(random_state=AGE_2_3_5_CONFIG['random_state'])
    
    # Clean data
    train_df = preprocessor.clean_data(train_df)
    if len(test_df) > 0:
        test_df = preprocessor.clean_data(test_df)
    
    # Feature engineering
    feature_engineer = FeatureEngineer(
        age_bins=AGE_2_3_5_CONFIG['age_bins'],
        random_state=AGE_2_3_5_CONFIG['random_state']
    )
    
    train_df = feature_engineer.engineer_questionnaire_features(train_df)
    if len(test_df) > 0:
        test_df = feature_engineer.engineer_questionnaire_features(test_df)
    
    return train_df, test_df


def handle_outliers(df):
    """Detect and handle outliers"""
    print("\n[OUTLIER] Detecting and handling outliers...")
    
    detector = OutlierDetector(
        method=AGE_2_3_5_CONFIG['outlier_detection']['method'],
        iqr_factor=AGE_2_3_5_CONFIG['outlier_detection']['iqr_factor']
    )
    
    # Get numerical columns (exclude target)
    numerical_cols = [col for col in AGE_2_3_5_CONFIG['features'] 
                     if col != 'group' and col in df.columns]
    
    if AGE_2_3_5_CONFIG['outlier_detection']['winsorize']:
        # Winsorize (cap outliers)
        df = detector.winsorize(
            df,
            numerical_cols,
            limits=AGE_2_3_5_CONFIG['outlier_detection']['winsorize_limits']
        )
        print("   [OK] Outliers winsorized")
    else:
        # Remove outliers
        df = detector.remove_outliers(df, numerical_cols)
        summary = detector.get_outlier_summary()
        print(f"   [OK] Removed {summary['removed_count']} outliers")
    
    return df


def augment_data(X_train, y_train):
    """Augment training data"""
    print("\n[AUGMENT] Augmenting training data...")
    
    augmenter = DataAugmenter(random_state=AGE_2_3_5_CONFIG['random_state'])
    
    if AGE_2_3_5_CONFIG['augmentation']['enabled']:
        X_aug, y_aug = augmenter.augment(
            X_train,
            y_train,
            method=AGE_2_3_5_CONFIG['augmentation']['method'],
            target_samples=AGE_2_3_5_CONFIG['augmentation']['target_samples']
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
    feature_cols = [col for col in AGE_2_3_5_CONFIG['features'] if col != 'group']
    X_train_features = X_train[feature_cols]
    X_test_features = X_test[feature_cols] if len(X_test) > 0 else pd.DataFrame()
    
    # Scale features
    preprocessor = DataPreprocessor(random_state=AGE_2_3_5_CONFIG['random_state'])
    X_train_scaled, X_test_scaled = preprocessor.scale_features(
        X_train_features,
        X_test_features,
        method="standard"
    )
    
    # Train Logistic Regression
    print("\n   Training Logistic Regression...")
    lr_model = LogisticRegression(**AGE_2_3_5_CONFIG['logistic_regression'])
    lr_model.fit(X_train_scaled, y_train)
    models['logistic_regression'] = lr_model
    
    # Evaluate Logistic Regression
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
    
    results['logistic_regression'] = {
        'train': train_metrics,
        'test': test_metrics
    }
    
    print(f"   [OK] LR - Train Accuracy: {train_metrics['accuracy']:.3f}")
    if test_metrics:
        print(f"   [OK] LR - Test Accuracy: {test_metrics['accuracy']:.3f}")
    
    # Train Random Forest
    print("\n   Training Random Forest...")
    rf_model = RandomForestClassifier(**AGE_2_3_5_CONFIG['random_forest'])
    rf_model.fit(X_train_scaled, y_train)
    models['random_forest'] = rf_model
    
    # Evaluate Random Forest
    y_pred_rf = rf_model.predict(X_train_scaled)
    y_proba_rf = rf_model.predict_proba(X_train_scaled)
    train_metrics_rf = evaluator.calculate_metrics(y_train, y_pred_rf, y_proba_rf)
    
    if len(X_test_scaled) > 0:
        y_pred_test_rf = rf_model.predict(X_test_scaled)
        y_proba_test_rf = rf_model.predict_proba(X_test_scaled)
        test_metrics_rf = evaluator.calculate_metrics(y_test, y_pred_test_rf, y_proba_test_rf)
    else:
        test_metrics_rf = {}
    
    results['random_forest'] = {
        'train': train_metrics_rf,
        'test': test_metrics_rf
    }
    
    print(f"   [OK] RF - Train Accuracy: {train_metrics_rf['accuracy']:.3f}")
    if test_metrics_rf:
        print(f"   [OK] RF - Test Accuracy: {test_metrics_rf['accuracy']:.3f}")
    
    return models, results, preprocessor.get_scaler()


def save_model(model, scaler, feature_cols, model_name):
    """Save trained model"""
    print(f"\n[SAVE] Saving {model_name}...")
    
    # Save model
    model_path = MODELS_DIR / f"{AGE_2_3_5_CONFIG['model_name']}.pkl"
    joblib.dump(model, model_path)
    print(f"   [OK] Model saved: {model_path}")
    
    # Save scaler
    scaler_path = MODELS_DIR / f"scaler_{AGE_2_3_5_CONFIG['model_name']}.pkl"
    joblib.dump(scaler, scaler_path)
    print(f"   [OK] Scaler saved: {scaler_path}")
    
    # Save features
    features_path = MODELS_DIR / f"features_{AGE_2_3_5_CONFIG['model_name']}.json"
    with open(features_path, 'w') as f:
        json.dump(feature_cols, f, indent=2)
    print(f"   [OK] Features saved: {features_path}")
    
    # Save metadata
    metadata = {
        "model_name": AGE_2_3_5_CONFIG['model_name'],
        "age_range": AGE_2_3_5_CONFIG['age_range'],
        "session_type": AGE_2_3_5_CONFIG['session_type'],
        "features": feature_cols,
        "training_date": datetime.now().isoformat(),
        "algorithm": model_name
    }
    
    metadata_path = MODELS_DIR / f"model_metadata_{AGE_2_3_5_CONFIG['model_name']}.json"
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    print(f"   [OK] Metadata saved: {metadata_path}")


def main():
    """Main training function"""
    print("\n" + "="*60)
    print("TRAINING AGE 2-3.5 QUESTIONNAIRE MODEL")
    print("="*60)
    
    # Load data
    train_df, test_df = load_data()
    
    # Preprocess
    train_df, test_df = preprocess_data(train_df, test_df)
    
    # Handle outliers
    train_df = handle_outliers(train_df)
    
    # Split features and target
    feature_cols = [col for col in AGE_2_3_5_CONFIG['features'] if col != 'group']
    X_train = train_df[feature_cols]
    y_train = train_df['group']
    
    X_test = test_df[feature_cols] if len(test_df) > 0 else pd.DataFrame()
    y_test = test_df['group'] if len(test_df) > 0 else pd.Series()
    
    # Augment data
    X_train_aug, y_train_aug = augment_data(X_train, y_train)
    
    # Train models
    models, results, scaler = train_models(X_train_aug, y_train_aug, X_test, y_test)
    
    # Save best model (Logistic Regression)
    save_model(
        models['logistic_regression'],
        scaler,
        feature_cols,
        "logistic_regression"
    )
    
    # Save results
    results_path = OUTPUT_DIR / f"training_results_{AGE_2_3_5_CONFIG['model_name']}.json"
    with open(results_path, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    print(f"\n[OK] Results saved: {results_path}")
    
    print("\n" + "="*60)
    print("[OK] Training complete!")
    print("="*60)


if __name__ == "__main__":
    main()
