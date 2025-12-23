"""
Autism Screening ML Model Training
===================================

This script trains a machine learning model to classify autism risk levels
based on gaze pattern features extracted during the screening games.

The model learns to identify patterns associated with:
- Typical development (TD)
- Autism Spectrum Disorder (ASD) indicators

Features Used:
--------------
1. Fixation metrics (duration, count, stability)
2. Saccade metrics (amplitude, velocity, frequency)
3. Attention metrics (time on target, switches)
4. Exploration patterns (dispersion, preferred regions)
5. Tracking ability (smooth pursuit ratio)

Usage:
------
1. Collect screening data from multiple children
2. Label data with clinical assessments
3. Run: python train_autism_classifier.py

Output:
-------
- autism_classifier.pkl (scikit-learn model)
- autism_classifier_scaler.pkl (feature scaler)
- training_report.json (model performance metrics)
"""

import json
import pickle
import numpy as np
from pathlib import Path
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
import warnings
warnings.filterwarnings('ignore')

# Try to import ML libraries
try:
    from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
    from sklearn.preprocessing import StandardScaler
    from sklearn.model_selection import train_test_split, cross_val_score
    from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score
    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False
    print("Warning: scikit-learn not installed. Run: pip install scikit-learn")


@dataclass
class GazeFeatures:
    """Features extracted from gaze data for ML classification"""
    # Fixation features
    fixation_count: float
    mean_fixation_duration: float
    std_fixation_duration: float
    fixation_rate: float
    
    # Saccade features
    saccade_count: float
    mean_saccade_amplitude: float
    mean_saccade_velocity: float
    saccade_rate: float
    
    # Attention features
    time_on_target: float
    time_in_center: float
    time_in_periphery: float
    attention_switches: float
    
    # Exploration features
    gaze_dispersion: float
    
    # Tracking features
    smooth_pursuit_ratio: float
    lag_behind_target: float
    
    # Session features
    total_duration: float
    total_events: float
    
    def to_array(self) -> np.ndarray:
        """Convert to numpy array for ML model"""
        return np.array([
            self.fixation_count,
            self.mean_fixation_duration,
            self.std_fixation_duration,
            self.fixation_rate,
            self.saccade_count,
            self.mean_saccade_amplitude,
            self.mean_saccade_velocity,
            self.saccade_rate,
            self.time_on_target,
            self.time_in_center,
            self.time_in_periphery,
            self.attention_switches,
            self.gaze_dispersion,
            self.smooth_pursuit_ratio,
            self.lag_behind_target,
            self.total_duration,
            self.total_events,
        ])
    
    @staticmethod
    def feature_names() -> List[str]:
        return [
            'fixation_count', 'mean_fixation_duration', 'std_fixation_duration', 'fixation_rate',
            'saccade_count', 'mean_saccade_amplitude', 'mean_saccade_velocity', 'saccade_rate',
            'time_on_target', 'time_in_center', 'time_in_periphery', 'attention_switches',
            'gaze_dispersion', 'smooth_pursuit_ratio', 'lag_behind_target',
            'total_duration', 'total_events'
        ]


def extract_features_from_metrics(metrics: Dict) -> GazeFeatures:
    """Extract ML features from gaze analyzer metrics"""
    return GazeFeatures(
        fixation_count=metrics.get('fixation_count', 0),
        mean_fixation_duration=metrics.get('mean_fixation_duration', 0),
        std_fixation_duration=metrics.get('std_fixation_duration', 0),
        fixation_rate=metrics.get('fixation_rate', 0),
        saccade_count=metrics.get('saccade_count', 0),
        mean_saccade_amplitude=metrics.get('mean_saccade_amplitude', 0),
        mean_saccade_velocity=metrics.get('mean_saccade_velocity', 0),
        saccade_rate=metrics.get('saccade_rate', 0),
        time_on_target=metrics.get('time_on_target', 0),
        time_in_center=metrics.get('time_in_center', 0),
        time_in_periphery=metrics.get('time_in_periphery', 0),
        attention_switches=metrics.get('attention_switches', 0),
        gaze_dispersion=metrics.get('gaze_dispersion', 0),
        smooth_pursuit_ratio=metrics.get('smooth_pursuit_ratio', 0),
        lag_behind_target=metrics.get('lag_behind_target', 0),
        total_duration=metrics.get('total_duration', 0),
        total_events=metrics.get('total_events', 0),
    )


def generate_synthetic_training_data(n_samples: int = 10000) -> Tuple[np.ndarray, np.ndarray]:
    """
    Generate synthetic training data based on research literature.
    
    This creates realistic gaze patterns for both typical development (TD)
    and ASD cases based on published research findings.
    
    Research basis:
    - Klin et al. (2002): Reduced attention to social stimuli in ASD
    - Jones & Klin (2013): Atypical fixation patterns
    - Falck-Ytter et al. (2013): Reduced smooth pursuit in ASD
    - Chita-Tegmark (2016): Meta-analysis of eye-tracking in ASD
    - Frazier et al. (2017): Gaze patterns in young children with ASD
    
    v2: Enhanced with:
    - More samples (10,000 default)
    - Age-based variation (2-6 years)
    - Session duration variation
    - Equipment noise simulation
    - Borderline/ambiguous cases
    - Multiple ASD phenotypes
    """
    np.random.seed(42)
    
    X = []
    y = []  # 0 = typical, 1 = ASD indicators
    
    # Generate 45% typical, 35% ASD, 20% borderline
    n_typical = int(n_samples * 0.45)
    n_asd = int(n_samples * 0.35)
    n_borderline = n_samples - n_typical - n_asd
    
    print(f"Generating {n_typical} typical, {n_asd} ASD, {n_borderline} borderline samples...")
    
    # =========================================================================
    # TYPICAL DEVELOPMENT (TD) PATTERNS
    # =========================================================================
    for i in range(n_typical):
        # Age variation (2-6 years) affects metrics
        age_factor = np.random.uniform(0.7, 1.3)  # Younger = lower values
        
        # Session duration variation (20-60 seconds)
        duration = np.random.uniform(20, 60)
        
        # Equipment noise factor
        noise = np.random.uniform(0.9, 1.1)
        
        features = GazeFeatures(
            # Typical fixation: moderate count, 200-400ms duration
            fixation_count=max(5, np.random.normal(25 * age_factor, 6) * noise),
            mean_fixation_duration=np.random.normal(0.30, 0.06) * noise,
            std_fixation_duration=np.random.normal(0.10, 0.03),
            fixation_rate=max(0.5, np.random.normal(2.0, 0.4) * age_factor),
            
            # Typical saccades: regular frequency
            saccade_count=max(5, np.random.normal(30 * age_factor, 10)),
            mean_saccade_amplitude=np.random.normal(0.15, 0.04),
            mean_saccade_velocity=np.random.normal(0.40, 0.12),
            saccade_rate=max(0.5, np.random.normal(2.5, 0.5)),
            
            # Good attention to targets (varies by age)
            time_on_target=np.random.normal(70 + age_factor * 10, 12),
            time_in_center=np.random.normal(50, 12),
            time_in_periphery=np.random.normal(30, 10),
            attention_switches=max(2, np.random.normal(8 * age_factor, 3)),
            
            # Moderate exploration
            gaze_dispersion=np.random.normal(0.25, 0.06),
            
            # Good tracking (improves with age)
            smooth_pursuit_ratio=min(100, np.random.normal(75 + age_factor * 10, 12)),
            lag_behind_target=max(0.01, np.random.normal(0.06, 0.03)),
            
            # Session data
            total_duration=duration,
            total_events=max(100, np.random.normal(duration * 15, duration * 3)),
        )
        X.append(features.to_array())
        y.append(0)  # Typical
    
    # =========================================================================
    # ASD INDICATOR PATTERNS - Multiple Phenotypes
    # =========================================================================
    # ASD is heterogeneous, so we model different subtypes
    
    for i in range(n_asd):
        age_factor = np.random.uniform(0.7, 1.3)
        duration = np.random.uniform(20, 60)
        
        # Different ASD phenotypes
        phenotype = np.random.choice(['restricted', 'scattered', 'slow', 'variable'])
        
        if phenotype == 'restricted':
            # Restricted/focused pattern - limited exploration
            features = GazeFeatures(
                fixation_count=max(3, np.random.normal(15, 5)),
                mean_fixation_duration=np.random.normal(0.55, 0.18),  # Longer fixations
                std_fixation_duration=np.random.normal(0.15, 0.05),
                fixation_rate=max(0.3, np.random.normal(1.2, 0.4)),
                
                saccade_count=max(3, np.random.normal(18, 8)),
                mean_saccade_amplitude=np.random.normal(0.10, 0.04),  # Smaller saccades
                mean_saccade_velocity=np.random.normal(0.30, 0.12),
                saccade_rate=max(0.3, np.random.normal(1.5, 0.5)),
                
                time_on_target=np.random.normal(45, 18),
                time_in_center=np.random.normal(60, 15),  # More center fixation
                time_in_periphery=np.random.normal(25, 10),
                attention_switches=max(1, np.random.normal(3, 2)),  # Few switches
                
                gaze_dispersion=np.random.normal(0.10, 0.04),  # Low dispersion
                
                smooth_pursuit_ratio=np.random.normal(50, 18),
                lag_behind_target=np.random.normal(0.14, 0.06),
                
                total_duration=duration,
                total_events=max(50, np.random.normal(duration * 10, duration * 4)),
            )
        
        elif phenotype == 'scattered':
            # Scattered/unfocused pattern - erratic gaze
            features = GazeFeatures(
                fixation_count=max(3, np.random.normal(12, 6)),
                mean_fixation_duration=np.random.normal(0.18, 0.08),  # Short fixations
                std_fixation_duration=np.random.normal(0.25, 0.08),  # High variability
                fixation_rate=max(0.3, np.random.normal(1.0, 0.5)),
                
                saccade_count=max(5, np.random.normal(35, 15)),  # Many saccades
                mean_saccade_amplitude=np.random.normal(0.22, 0.08),  # Larger jumps
                mean_saccade_velocity=np.random.normal(0.55, 0.18),
                saccade_rate=max(0.5, np.random.normal(2.8, 0.8)),
                
                time_on_target=np.random.normal(35, 15),  # Poor target focus
                time_in_center=np.random.normal(30, 12),
                time_in_periphery=np.random.normal(50, 15),  # More periphery
                attention_switches=max(2, np.random.normal(12, 5)),  # Many switches
                
                gaze_dispersion=np.random.normal(0.42, 0.10),  # High dispersion
                
                smooth_pursuit_ratio=np.random.normal(40, 20),
                lag_behind_target=np.random.normal(0.18, 0.08),
                
                total_duration=duration,
                total_events=max(80, np.random.normal(duration * 12, duration * 5)),
            )
        
        elif phenotype == 'slow':
            # Slow processing pattern - delayed responses
            features = GazeFeatures(
                fixation_count=max(3, np.random.normal(20, 7)),
                mean_fixation_duration=np.random.normal(0.45, 0.15),
                std_fixation_duration=np.random.normal(0.18, 0.06),
                fixation_rate=max(0.3, np.random.normal(1.4, 0.4)),
                
                saccade_count=max(3, np.random.normal(20, 8)),
                mean_saccade_amplitude=np.random.normal(0.13, 0.05),
                mean_saccade_velocity=np.random.normal(0.28, 0.10),  # Slower
                saccade_rate=max(0.3, np.random.normal(1.6, 0.5)),
                
                time_on_target=np.random.normal(50, 15),
                time_in_center=np.random.normal(45, 12),
                time_in_periphery=np.random.normal(35, 12),
                attention_switches=max(1, np.random.normal(5, 2)),
                
                gaze_dispersion=np.random.normal(0.20, 0.07),
                
                smooth_pursuit_ratio=np.random.normal(45, 15),  # Poor pursuit
                lag_behind_target=np.random.normal(0.20, 0.08),  # Significant lag
                
                total_duration=duration,
                total_events=max(50, np.random.normal(duration * 8, duration * 3)),
            )
        
        else:  # 'variable'
            # High variability pattern
            features = GazeFeatures(
                fixation_count=max(3, np.random.normal(18, 10)),  # High variance
                mean_fixation_duration=np.random.normal(0.40, 0.20),
                std_fixation_duration=np.random.normal(0.30, 0.10),  # Very variable
                fixation_rate=max(0.3, np.random.normal(1.5, 0.6)),
                
                saccade_count=max(3, np.random.normal(25, 12)),
                mean_saccade_amplitude=np.random.normal(0.15, 0.08),
                mean_saccade_velocity=np.random.normal(0.38, 0.18),
                saccade_rate=max(0.3, np.random.normal(2.0, 0.8)),
                
                time_on_target=np.random.normal(55, 20),  # Inconsistent
                time_in_center=np.random.normal(42, 18),
                time_in_periphery=np.random.normal(38, 15),
                attention_switches=max(1, np.random.normal(6, 4)),
                
                gaze_dispersion=np.random.uniform(0.08, 0.45),  # Random
                
                smooth_pursuit_ratio=np.random.normal(50, 22),
                lag_behind_target=np.random.normal(0.12, 0.08),
                
                total_duration=duration,
                total_events=max(50, np.random.normal(duration * 11, duration * 5)),
            )
        
        X.append(features.to_array())
        y.append(1)  # ASD indicators
    
    # =========================================================================
    # BORDERLINE CASES - Help model learn nuance
    # =========================================================================
    for i in range(n_borderline):
        age_factor = np.random.uniform(0.7, 1.3)
        duration = np.random.uniform(20, 60)
        
        # Mix of typical and atypical features
        label = np.random.choice([0, 1], p=[0.5, 0.5])  # Random label for borderline
        
        features = GazeFeatures(
            fixation_count=max(5, np.random.normal(20, 8)),
            mean_fixation_duration=np.random.normal(0.38, 0.12),
            std_fixation_duration=np.random.normal(0.15, 0.05),
            fixation_rate=max(0.5, np.random.normal(1.7, 0.5)),
            
            saccade_count=max(5, np.random.normal(25, 10)),
            mean_saccade_amplitude=np.random.normal(0.14, 0.05),
            mean_saccade_velocity=np.random.normal(0.36, 0.12),
            saccade_rate=max(0.5, np.random.normal(2.0, 0.6)),
            
            time_on_target=np.random.normal(60, 15),
            time_in_center=np.random.normal(45, 12),
            time_in_periphery=np.random.normal(35, 10),
            attention_switches=max(2, np.random.normal(6, 3)),
            
            gaze_dispersion=np.random.normal(0.22, 0.08),
            
            smooth_pursuit_ratio=np.random.normal(62, 18),
            lag_behind_target=np.random.normal(0.09, 0.05),
            
            total_duration=duration,
            total_events=max(80, np.random.normal(duration * 12, duration * 4)),
        )
        X.append(features.to_array())
        y.append(label)
    
    # Clip negative values
    X = np.array(X)
    X = np.clip(X, 0, None)
    y = np.array(y)
    
    # Shuffle
    indices = np.random.permutation(len(X))
    print(f"Generated {len(X)} total samples")
    print(f"Class distribution: Typical={np.sum(y==0)}, ASD={np.sum(y==1)}")
    
    return X[indices], y[indices]


class AutismScreeningClassifier:
    """
    Machine learning classifier for autism screening based on gaze patterns.
    
    Uses an ensemble approach combining Random Forest and Gradient Boosting
    for robust predictions.
    """
    
    def __init__(self):
        self.scaler = StandardScaler() if SKLEARN_AVAILABLE else None
        self.model = None
        self.is_trained = False
        self.feature_names = GazeFeatures.feature_names()
        self.training_metrics = {}
    
    def train(self, X: np.ndarray, y: np.ndarray, test_size: float = 0.2):
        """Train the classifier on gaze feature data"""
        if not SKLEARN_AVAILABLE:
            raise ImportError("scikit-learn required for training")
        
        print(f"\n{'='*60}")
        print(f"TRAINING AUTISM SCREENING CLASSIFIER")
        print(f"{'='*60}")
        print(f"Dataset: {len(X)} samples, {X.shape[1]} features")
        print(f"Class distribution: Typical={np.sum(y==0)}, ASD={np.sum(y==1)}")
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42, stratify=y
        )
        
        print(f"Training set: {len(X_train)} samples")
        print(f"Test set: {len(X_test)} samples")
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train ensemble model with better hyperparameters for larger dataset
        print(f"\nTraining Gradient Boosting Classifier...")
        self.model = GradientBoostingClassifier(
            n_estimators=200,  # More trees
            max_depth=6,       # Slightly deeper
            learning_rate=0.1,
            min_samples_split=10,  # Prevent overfitting
            min_samples_leaf=5,
            subsample=0.8,     # Bagging for robustness
            random_state=42,
            verbose=0
        )
        
        self.model.fit(X_train_scaled, y_train)
        
        # Evaluate
        y_pred = self.model.predict(X_test_scaled)
        y_prob = self.model.predict_proba(X_test_scaled)[:, 1]
        
        # Calculate metrics
        accuracy = np.mean(y_pred == y_test)
        auc = roc_auc_score(y_test, y_prob)
        
        # Cross-validation
        cv_scores = cross_val_score(self.model, X_train_scaled, y_train, cv=5)
        
        self.training_metrics = {
            'accuracy': float(accuracy),
            'auc_roc': float(auc),
            'cv_mean': float(cv_scores.mean()),
            'cv_std': float(cv_scores.std()),
            'n_train': len(X_train),
            'n_test': len(X_test),
        }
        
        print(f"\n=== Training Results ===")
        print(f"Accuracy: {accuracy:.3f}")
        print(f"AUC-ROC: {auc:.3f}")
        print(f"Cross-validation: {cv_scores.mean():.3f} (+/- {cv_scores.std()*2:.3f})")
        
        print(f"\nClassification Report:")
        print(classification_report(y_test, y_pred, 
              target_names=['Typical', 'ASD Indicators']))
        
        print(f"\nFeature Importance:")
        importance = self.model.feature_importances_
        for name, imp in sorted(zip(self.feature_names, importance), 
                                 key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {name}: {imp:.4f}")
        
        self.is_trained = True
        return self.training_metrics
    
    def predict(self, features: np.ndarray) -> Dict:
        """
        Predict autism risk from gaze features.
        
        Returns:
            Dict with:
            - risk_probability: 0-1 probability of ASD indicators
            - risk_category: Low/Moderate/Elevated/High
            - confidence: Model confidence in prediction
            - scores: Detailed breakdown
        """
        if not self.is_trained:
            raise ValueError("Model not trained. Call train() first.")
        
        # Ensure 2D array
        if features.ndim == 1:
            features = features.reshape(1, -1)
        
        # Scale
        features_scaled = self.scaler.transform(features)
        
        # Predict
        prob = self.model.predict_proba(features_scaled)[0]
        asd_prob = prob[1]  # Probability of ASD indicators
        
        # Convert to risk category
        if asd_prob < 0.25:
            risk_category = 'Low Risk'
            overall_score = 85 + (0.25 - asd_prob) * 60  # 85-100
        elif asd_prob < 0.50:
            risk_category = 'Moderate - Further Evaluation Recommended'
            overall_score = 65 + (0.50 - asd_prob) * 80  # 65-85
        elif asd_prob < 0.75:
            risk_category = 'Elevated Risk - Professional Consultation Advised'
            overall_score = 40 + (0.75 - asd_prob) * 100  # 40-65
        else:
            risk_category = 'High Risk - Immediate Professional Evaluation Recommended'
            overall_score = max(10, 40 - (asd_prob - 0.75) * 120)  # 10-40
        
        return {
            'risk_probability': float(asd_prob),
            'risk_category': risk_category,
            'overall_score': float(np.clip(overall_score, 0, 100)),
            'confidence': float(max(prob)),
            'typical_probability': float(prob[0]),
        }
    
    def save(self, model_path: str = 'autism_classifier.pkl',
             scaler_path: str = 'autism_classifier_scaler.pkl'):
        """Save trained model and scaler"""
        if not self.is_trained:
            raise ValueError("Model not trained")
        
        with open(model_path, 'wb') as f:
            pickle.dump(self.model, f)
        
        with open(scaler_path, 'wb') as f:
            pickle.dump(self.scaler, f)
        
        # Save training metrics
        metrics_path = model_path.replace('.pkl', '_metrics.json')
        with open(metrics_path, 'w') as f:
            json.dump(self.training_metrics, f, indent=2)
        
        print(f"\nModel saved to: {model_path}")
        print(f"Scaler saved to: {scaler_path}")
        print(f"Metrics saved to: {metrics_path}")
    
    def load(self, model_path: str = 'autism_classifier.pkl',
             scaler_path: str = 'autism_classifier_scaler.pkl'):
        """Load trained model and scaler"""
        with open(model_path, 'rb') as f:
            self.model = pickle.load(f)
        
        with open(scaler_path, 'rb') as f:
            self.scaler = pickle.load(f)
        
        self.is_trained = True
        print(f"Model loaded from: {model_path}")


def main():
    """Main training script"""
    if not SKLEARN_AVAILABLE:
        print("Error: scikit-learn is required.")
        print("Install with: pip install scikit-learn")
        return
    
    print("=" * 60)
    print("AUTISM SCREENING MODEL TRAINING")
    print("=" * 60)
    
    # Check for real training data
    data_files = list(Path('.').glob('screening_data_*.json'))
    
    if data_files:
        print(f"\nFound {len(data_files)} data files:")
        for f in data_files:
            print(f"  - {f}")
        # TODO: Load real data when available
        print("\nUsing synthetic data for now (real data loader not implemented)")
    
    # Generate synthetic training data
    print("\nGenerating synthetic training data based on research literature...")
    X, y = generate_synthetic_training_data(n_samples=10000)
    
    # Train classifier
    classifier = AutismScreeningClassifier()
    metrics = classifier.train(X, y)
    
    # Save model
    classifier.save()
    
    # Test prediction
    print("\n" + "=" * 60)
    print("TEST PREDICTIONS")
    print("=" * 60)
    
    # Test with typical pattern
    typical_features = GazeFeatures(
        fixation_count=25, mean_fixation_duration=0.28, std_fixation_duration=0.08,
        fixation_rate=2.1, saccade_count=32, mean_saccade_amplitude=0.14,
        mean_saccade_velocity=0.42, saccade_rate=2.6, time_on_target=78,
        time_in_center=52, time_in_periphery=28, attention_switches=9,
        gaze_dispersion=0.24, smooth_pursuit_ratio=82, lag_behind_target=0.04,
        total_duration=32, total_events=520
    )
    
    result = classifier.predict(typical_features.to_array())
    print(f"\nTypical Development Pattern:")
    print(f"  Risk Probability: {result['risk_probability']:.2%}")
    print(f"  Overall Score: {result['overall_score']:.1f}")
    print(f"  Category: {result['risk_category']}")
    
    # Test with ASD indicator pattern
    asd_features = GazeFeatures(
        fixation_count=15, mean_fixation_duration=0.55, std_fixation_duration=0.22,
        fixation_rate=1.3, saccade_count=18, mean_saccade_amplitude=0.10,
        mean_saccade_velocity=0.30, saccade_rate=1.5, time_on_target=48,
        time_in_center=35, time_in_periphery=45, attention_switches=4,
        gaze_dispersion=0.38, smooth_pursuit_ratio=45, lag_behind_target=0.15,
        total_duration=28, total_events=350
    )
    
    result = classifier.predict(asd_features.to_array())
    print(f"\nASD Indicator Pattern:")
    print(f"  Risk Probability: {result['risk_probability']:.2%}")
    print(f"  Overall Score: {result['overall_score']:.1f}")
    print(f"  Category: {result['risk_category']}")
    
    print("\n" + "=" * 60)
    print("Training complete!")
    print("=" * 60)


if __name__ == '__main__':
    main()
