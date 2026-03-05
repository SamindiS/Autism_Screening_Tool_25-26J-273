"""
Autism Detection Model Training Script
Trains a model to distinguish between autism and typical responses to name calling.
Supports: random_forest, svm, gradient_boosting, ensemble (RF+GB+SVM, ~5-10% accuracy gain).
Feature engineering: interaction terms, age-normalized scores, temporal features, game correlation.
"""
import os
import sys
import cv2
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import joblib
import json
from datetime import datetime
from pathlib import Path

# For deep learning (optional - uncomment if using TensorFlow)
# import tensorflow as tf
# from tensorflow import keras
# from tensorflow.keras import layers


class AutismDetectionTrainer:
    """Train model to detect autism vs typical responses"""
    
    def __init__(self, data_dir='training_data', model_dir='models'):
        self.data_dir = Path(data_dir)
        self.model_dir = Path(model_dir)
        self.model_dir.mkdir(exist_ok=True)
        self.scaler = StandardScaler()
        self.model = None  # Single model or dict for ensemble: {'ensemble': [rf, gb, svm], 'weights': [...]}
        
    def extract_features_from_video(self, video_path):
        """
        Extract features from a video file
        
        Features extracted:
        - Response time (RTN)
        - Head movement patterns
        - Eye contact duration
        - Attention shift frequency
        - Body movement patterns
        - Response consistency
        """
        features = {}
        
        try:
            cap = cv2.VideoCapture(str(video_path))
            if not cap.isOpened():
                return None
            
            fps = cap.get(cv2.CAP_PROP_FPS)
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            duration = total_frames / fps if fps > 0 else 0
            
            # Frame analysis
            frames = []
            head_positions = []
            eye_contact_frames = 0
            attention_shifts = 0
            movement_intensities = []
            
            frame_count = 0
            sample_rate = max(1, int(fps / 2))  # Sample 2 frames per second
            
            prev_gray = None
            
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                
                if frame_count % sample_rate == 0:
                    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                    
                    # Calculate movement intensity
                    if prev_gray is not None:
                        diff = cv2.absdiff(gray, prev_gray)
                        movement = np.mean(diff)
                        movement_intensities.append(movement)
                        
                        # Detect attention shifts (significant movement changes)
                        if len(movement_intensities) > 1:
                            if abs(movement_intensities[-1] - movement_intensities[-2]) > 10:
                                attention_shifts += 1
                    
                    # Detect head position (simplified - using face detection region)
                    head_region = self._detect_head_region(gray)
                    if head_region:
                        head_positions.append(head_region)
                    
                    # Detect eye contact (simplified - looking at camera)
                    if self._detect_eye_contact(gray):
                        eye_contact_frames += 1
                    
                    frames.append(gray)
                    prev_gray = gray
                
                frame_count += 1
            
            cap.release()
            
            # Calculate features
            timestamp = frame_count / fps if fps > 0 else 0
            
            # 1. Response Time (RTN)
            response_time = self._calculate_response_time(frames, head_positions)
            features['response_time'] = response_time
            
            # 2. Head Movement Patterns
            if head_positions:
                head_variance = np.var([pos[0] for pos in head_positions if pos])
                head_movement_range = max([pos[0] for pos in head_positions if pos]) - min([pos[0] for pos in head_positions if pos])
            else:
                head_variance = 0
                head_movement_range = 0
            features['head_movement_variance'] = head_variance
            features['head_movement_range'] = head_movement_range
            
            # 3. Eye Contact Duration
            eye_contact_ratio = eye_contact_frames / len(frames) if frames else 0
            features['eye_contact_ratio'] = eye_contact_ratio
            
            # 4. Attention Shift Frequency
            attention_shift_rate = attention_shifts / duration if duration > 0 else 0
            features['attention_shift_rate'] = attention_shift_rate
            
            # 5. Body Movement Patterns
            avg_movement = np.mean(movement_intensities) if movement_intensities else 0
            movement_variance = np.var(movement_intensities) if movement_intensities else 0
            features['avg_movement_intensity'] = avg_movement
            features['movement_variance'] = movement_variance
            
            # 6. Response Consistency
            response_consistency = self._calculate_consistency(head_positions, movement_intensities)
            features['response_consistency'] = response_consistency
            
            # 7. Video Duration
            features['video_duration'] = duration
            
            # 8. Frame Count
            features['total_frames'] = len(frames)
            
            # 9. Response Time (RTN) - critical for distinguishing response vs no-response
            # Lower response_time typically indicates clear response, high or 0 indicates no response
            features['response_time_normalized'] = response_time / max(duration, 1.0)  # Normalize by video duration
            
            # 10. Movement patterns - sustained movement vs random motion
            if movement_intensities:
                movement_peak = max(movement_intensities) if movement_intensities else 0
                movement_trend = self._calculate_movement_trend(movement_intensities)
                features['movement_peak'] = movement_peak
                features['movement_trend'] = movement_trend  # Positive = increasing, negative = decreasing
            else:
                features['movement_peak'] = 0
                features['movement_trend'] = 0
            
            # --- Expanded behavioral markers (for ML; some derived from existing loop) ---
            # Facial expression (proxy: eye contact + movement as engagement)
            features['smile_detected_ratio'] = min(1.0, eye_contact_ratio * 1.2)  # proxy
            features['emotional_positive_ratio'] = eye_contact_ratio  # proxy for positive engagement
            features['emotional_neutral_ratio'] = max(0, 1.0 - eye_contact_ratio - attention_shift_rate)
            features['emotional_negative_ratio'] = min(1.0, attention_shift_rate)
            # Body language
            features['body_orientation_change_count'] = attention_shifts  # proxy for orientation changes
            features['hand_arm_movement_rate'] = (movement_variance / 100.0) if movement_intensities else 0
            features['stimming_candidate'] = 1 if (movement_intensities and np.var(movement_intensities) > 500) else 0
            features['proximity_seeking_count'] = 0  # would need full pipeline
            # Vocalization (would need audio pipeline in trainer)
            features['verbal_response_detected'] = 0
            features['babbling_as_response_count'] = 0
            features['echolalia_score'] = 0.0
            # Attention maintenance
            features['eye_contact_duration_seconds'] = eye_contact_ratio * duration if duration > 0 else 0
            features['return_to_activity_speed_seconds'] = 0.0  # would need full pipeline
            
            # Child age (default 3; overwrite from labels at train time for age-normalized features)
            features['child_age'] = 3
            
            # Proxy for "missed responses" (high when no clear response)
            features['missed_responses_proxy'] = 1.0 - response_consistency if response_consistency is not None else 0.5
            
            return features
            
        except Exception as e:
            print(f"Error extracting features from {video_path}: {e}")
            return None
    
    def _detect_head_region(self, gray_frame):
        """Detect head region in frame (simplified)"""
        try:
            # Use Haar cascade for face detection if available
            # For now, use upper portion of frame as head region
            height, width = gray_frame.shape
            upper_portion = gray_frame[:height//2, :]
            
            # Calculate center of mass
            moments = cv2.moments(upper_portion)
            if moments['m00'] != 0:
                cx = int(moments['m10'] / moments['m00'])
                cy = int(moments['m01'] / moments['m00'])
                return (cx, cy)
            return None
        except:
            return None
    
    def _detect_eye_contact(self, gray_frame):
        """Detect if child is making eye contact (simplified)"""
        try:
            # Simplified: check if face is centered and looking forward
            height, width = gray_frame.shape
            center_x = width // 2
            center_region = gray_frame[:, center_x - 50:center_x + 50]
            
            # High variance suggests eye contact (face looking at camera)
            variance = np.var(center_region)
            return variance > 500
        except:
            return False
    
    def _calculate_response_time(self, frames, head_positions):
        """Calculate response time based on movement patterns"""
        if not frames or not head_positions:
            return 0.0
        
        # Response typically shows as first significant head movement
        for i, pos in enumerate(head_positions):
            if pos and i > 0:
                prev_pos = head_positions[i-1]
                if prev_pos:
                    movement = abs(pos[0] - prev_pos[0])
                    if movement > 20:  # Threshold for significant movement
                        return i * 0.5  # Assuming 2 fps sampling
        
        return len(frames) * 0.5  # No clear response detected
    
    def _calculate_consistency(self, head_positions, movements):
        """Calculate response consistency"""
        if not head_positions or not movements:
            return 0.0
        
        # Consistency = low variance in movements
        if len(movements) > 1:
            movement_std = np.std(movements)
            # Normalize to 0-1 scale (lower std = higher consistency)
            consistency = 1.0 / (1.0 + movement_std / 100.0)
            return consistency
        
        return 0.5  # Default moderate consistency
    
    def _calculate_movement_trend(self, movements):
        """
        Calculate movement trend over time
        Returns positive value if movement increases (response pattern),
        negative if decreases (no response pattern)
        """
        if not movements or len(movements) < 2:
            return 0.0
        
        # Split into halves and compare average movement
        mid_point = len(movements) // 2
        first_half = movements[:mid_point]
        second_half = movements[mid_point:]
        
        avg_first = np.mean(first_half) if first_half else 0
        avg_second = np.mean(second_half) if second_half else 0
        
        # Trend = difference (positive means increasing movement, like a response)
        trend = avg_second - avg_first
        
        # Normalize by overall average movement
        overall_avg = np.mean(movements) if movements else 1.0
        if overall_avg > 0:
            trend_normalized = trend / overall_avg
        else:
            trend_normalized = 0.0
        
        return trend_normalized
    
    def _add_engineered_features(self, features_df):
        """
        Feature engineering: interaction terms, age-normalized scores,
        temporal features, game performance correlation with RTN.
        """
        df = features_df.copy()
        # Interaction terms (e.g. response_time × missed_responses)
        rt = df.get('response_time', pd.Series(0, index=df.index))
        mr = df.get('missed_responses_proxy', pd.Series(0.5, index=df.index))
        df['interaction_rt_missed'] = rt * mr
        df['interaction_rt_consistency'] = rt * (1 - df.get('response_consistency', 0.5))
        # Age-normalized scores (2-year-old vs 5-year-old)
        age = df.get('child_age', 3)
        df['age_normalized_response_time'] = rt / (age + 1)
        df['age_normalized_eye_contact'] = df.get('eye_contact_ratio', 0) * (age + 1) / 6.0
        df['age_normalized_attention_shift'] = df.get('attention_shift_rate', 0) * (6.0 - age) / 6.0  # younger = more weight
        # Temporal features (variability proxy from movement)
        df['temporal_variability'] = df.get('movement_variance', 0)
        df['movement_trend_abs'] = np.abs(df.get('movement_trend', 0))
        # Game performance correlation with RTN (if game_accuracy present)
        if 'game_accuracy' in df.columns:
            df['game_rtn_correlation'] = df['game_accuracy'] * df.get('response_consistency', 0.5)
        else:
            df['game_rtn_correlation'] = 0.0  # placeholder
        return df
    
    def load_training_data(self, labels_file='training_data/labels.csv'):
        """
        Load training data from directory structure:
        training_data/
          autism/
            video1.mp4
            video2.mp4
          typical/
            video1.mp4
            video2.mp4
        labels.csv should have: video_path, label (autism/typical), child_age, etc.
        """
        labels_path = Path(labels_file)
        
        if not labels_path.exists():
            print(f"Labels file not found: {labels_file}")
            print("Creating sample labels file...")
            self._create_sample_labels_file(labels_path)
            return None
        
        # Load labels
        df = pd.read_csv(labels_path)
        # Resolve paths relative to project root (parent of labels dir) so paths work from any CWD
        labels_dir = labels_path.resolve().parent
        project_root = labels_dir.parent

        features_list = []
        labels_list = []

        print("Extracting features from training videos...")
        for idx, row in df.iterrows():
            video_path = Path(row['video_path'])
            if not video_path.is_absolute():
                video_path = (project_root / video_path).resolve()
            label = row['label']  # 'autism' or 'typical'

            if not video_path.exists():
                print(f"Warning: Video not found: {video_path}")
                continue
            
            print(f"Processing {idx+1}/{len(df)}: {video_path.name}")
            features = self.extract_features_from_video(video_path)
            
            if features:
                # Override child_age from labels for age-normalized features
                if 'child_age' in row and pd.notna(row.get('child_age')):
                    try:
                        features['child_age'] = float(row['child_age'])
                    except (TypeError, ValueError):
                        features['child_age'] = 3
                if 'game_accuracy' in row and pd.notna(row.get('game_accuracy')):
                    try:
                        features['game_accuracy'] = float(row['game_accuracy'])
                    except (TypeError, ValueError):
                        pass
                features_list.append(features)
                labels_list.append(1 if label.lower() == 'autism' else 0)  # 1 = autism, 0 = typical
        
        if not features_list:
            print("No features extracted. Check video paths in labels.csv")
            return None
        
        # Convert to DataFrame
        features_df = pd.DataFrame(features_list)
        labels_df = pd.Series(labels_list)
        
        # Feature engineering: interaction terms, age-normalized, temporal, game correlation
        features_df = self._add_engineered_features(features_df)
        
        print(f"\nExtracted {len(features_list)} samples")
        print(f"Features: {list(features_df.columns)}")
        print(f"Autism samples: {sum(labels_list)}")
        print(f"Typical samples: {len(labels_list) - sum(labels_list)}")
        
        return features_df, labels_df
    
    def _create_sample_labels_file(self, labels_path):
        """Create a sample labels CSV file"""
        sample_data = {
            'video_path': [
                'training_data/autism/video1.mp4',
                'training_data/autism/video2.mp4',
                'training_data/typical/video1.mp4',
                'training_data/typical/video2.mp4',
            ],
            'label': ['autism', 'autism', 'typical', 'typical'],
            'child_age': [3, 4, 3, 4],
            'notes': ['Sample', 'Sample', 'Sample', 'Sample']
        }
        df = pd.DataFrame(sample_data)
        df.to_csv(labels_path, index=False)
        print(f"Created sample labels file: {labels_path}")
        print("Please update with your actual video paths and labels")
    
    def train_model(self, features_df, labels_df, model_type='random_forest'):
        """
        Train the model.
        Args:
            features_df: DataFrame with features
            labels_df: Series with labels (1=autism, 0=typical)
            model_type: 'random_forest', 'svm', 'gradient_boosting', or 'ensemble'
        """
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            features_df, labels_df, test_size=0.2, random_state=42, stratify=labels_df
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        if model_type == 'ensemble':
            # Ensemble: RF + Gradient Boosting + SVM with weighted voting (typically 5-10% accuracy gain)
            print("\nTraining ensemble (Random Forest + Gradient Boosting + SVM)...")
            rf = RandomForestClassifier(
                n_estimators=200, max_depth=15, min_samples_split=5, min_samples_leaf=2,
                max_features='sqrt', random_state=42, class_weight='balanced', n_jobs=-1
            )
            gb = GradientBoostingClassifier(
                n_estimators=100, max_depth=5, learning_rate=0.1,
                min_samples_split=5, random_state=42
            )
            svm = SVC(kernel='rbf', C=1.0, probability=True, class_weight='balanced')
            rf.fit(X_train_scaled, y_train)
            gb.fit(X_train_scaled, y_train)
            svm.fit(X_train_scaled, y_train)
            # Weights: can tune via validation; default equal then RF slightly higher
            weights = np.array([0.40, 0.35, 0.25])  # RF, GB, SVM
            self.model = {'ensemble': [rf, gb, svm], 'weights': weights}
            # Evaluate ensemble
            proba_rf = rf.predict_proba(X_test_scaled)
            proba_gb = gb.predict_proba(X_test_scaled)
            proba_svm = svm.predict_proba(X_test_scaled)
            proba_avg = weights[0] * proba_rf + weights[1] * proba_gb + weights[2] * proba_svm
            y_pred = np.argmax(proba_avg, axis=1)
            accuracy = accuracy_score(y_test, y_pred)
            print(f"\nEnsemble Accuracy: {accuracy:.2%}")
            print("\nClassification Report:")
            print(classification_report(y_test, y_pred, target_names=['Typical', 'Autism']))
            print("\nConfusion Matrix:")
            print(confusion_matrix(y_test, y_pred))
            return accuracy
        else:
            # Single model
            if model_type == 'random_forest':
                self.model = RandomForestClassifier(
                    n_estimators=200, max_depth=15, min_samples_split=5, min_samples_leaf=2,
                    max_features='sqrt', random_state=42, class_weight='balanced', n_jobs=-1
                )
            elif model_type == 'svm':
                self.model = SVC(kernel='rbf', C=1.0, probability=True, class_weight='balanced')
            elif model_type == 'gradient_boosting':
                self.model = GradientBoostingClassifier(
                    n_estimators=100, max_depth=5, learning_rate=0.1,
                    min_samples_split=5, random_state=42
                )
            else:
                raise ValueError(f"Unknown model type: {model_type}. Use random_forest, svm, gradient_boosting, or ensemble.")
            
            print(f"\nTraining {model_type} model...")
            self.model.fit(X_train_scaled, y_train)
            
            y_pred = self.model.predict(X_test_scaled)
            accuracy = accuracy_score(y_test, y_pred)
            print(f"\nModel Accuracy: {accuracy:.2%}")
            print("\nClassification Report:")
            print(classification_report(y_test, y_pred, target_names=['Typical', 'Autism']))
            print("\nConfusion Matrix:")
            print(confusion_matrix(y_test, y_pred))
            return accuracy
    
    def save_model(self, model_name='autism_detection_model'):
        """Save trained model and scaler (single or ensemble)."""
        if self.model is None:
            print("No model to save. Train model first.")
            return
        
        scaler_path = self.model_dir / f"{model_name}_scaler.pkl"
        joblib.dump(self.scaler, scaler_path)
        print(f"Scaler saved to: {scaler_path}")
        
        if isinstance(self.model, dict) and 'ensemble' in self.model:
            # Save ensemble: RF, GB, SVM + metadata
            names = ['rf', 'gb', 'svm']
            for i, m in enumerate(self.model['ensemble']):
                p = self.model_dir / f"{model_name}_{names[i]}.pkl"
                joblib.dump(m, p)
                print(f"Ensemble model saved: {p}")
            metadata = {
                'model_name': model_name,
                'model_type': 'ensemble',
                'ensemble_weights': self.model['weights'].tolist(),
                'training_date': datetime.now().isoformat(),
                'feature_names': list(self.scaler.feature_names_in_) if hasattr(self.scaler, 'feature_names_in_') else []
            }
            # Also save single .pkl for backward compat (first model only)
            joblib.dump(self.model['ensemble'][0], self.model_dir / f"{model_name}.pkl")
        else:
            model_path = self.model_dir / f"{model_name}.pkl"
            joblib.dump(self.model, model_path)
            print(f"Model saved to: {model_path}")
            metadata = {
                'model_name': model_name,
                'model_type': type(self.model).__name__,
                'training_date': datetime.now().isoformat(),
                'feature_names': list(self.scaler.feature_names_in_) if hasattr(self.scaler, 'feature_names_in_') else []
            }
        
        metadata_path = self.model_dir / f"{model_name}_metadata.json"
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2)
        print(f"Metadata saved to: {metadata_path}")
    
    def load_model(self, model_name='autism_detection_model'):
        """Load trained model and scaler (single or ensemble)."""
        scaler_path = self.model_dir / f"{model_name}_scaler.pkl"
        metadata_path = self.model_dir / f"{model_name}_metadata.json"
        if not scaler_path.exists():
            print(f"Scaler not found: {scaler_path}")
            return False
        
        self.scaler = joblib.load(scaler_path)
        
        if metadata_path.exists():
            with open(metadata_path) as f:
                meta = json.load(f)
            if meta.get('model_type') == 'ensemble':
                rf_path = self.model_dir / f"{model_name}_rf.pkl"
                gb_path = self.model_dir / f"{model_name}_gb.pkl"
                svm_path = self.model_dir / f"{model_name}_svm.pkl"
                if rf_path.exists() and gb_path.exists() and svm_path.exists():
                    self.model = {
                        'ensemble': [
                            joblib.load(rf_path),
                            joblib.load(gb_path),
                            joblib.load(svm_path),
                        ],
                        'weights': np.array(meta.get('ensemble_weights', [1/3, 1/3, 1/3])),
                    }
                    print(f"Ensemble model loaded: {model_name}")
                    return True
        # Single model
        model_path = self.model_dir / f"{model_name}.pkl"
        if not model_path.exists():
            print(f"Model file not found: {model_path}")
            return False
        self.model = joblib.load(model_path)
        print(f"Model loaded from: {model_path}")
        return True
    
    def predict(self, video_path):
        """Predict autism vs typical for a video"""
        if self.model is None:
            print("Model not loaded. Load or train model first.")
            return None
        
        features = self.extract_features_from_video(video_path)
        if features is None:
            return None
        
        # Convert to DataFrame and add engineered features (same as training)
        features_df = pd.DataFrame([features])
        features_df = self._add_engineered_features(features_df)
        
        # Use only columns the scaler was trained on (backward compatibility with older models)
        expected = getattr(self.scaler, 'feature_names_in_', None)
        if expected is not None:
            features_df = features_df.reindex(columns=expected, fill_value=0)
        
        # Scale features
        features_scaled = self.scaler.transform(features_df)
        
        # Predict (single model or ensemble weighted voting)
        if isinstance(self.model, dict) and 'ensemble' in self.model:
            weights = self.model['weights']
            proba_avg = np.zeros(2)
            for i, m in enumerate(self.model['ensemble']):
                proba_avg += weights[i] * m.predict_proba(features_scaled)[0]
            probability = proba_avg / proba_avg.sum()
            prediction = int(np.argmax(probability))
        else:
            prediction = self.model.predict(features_scaled)[0]
            probability = self.model.predict_proba(features_scaled)[0]
        
        result = {
            'prediction': 'autism' if prediction == 1 else 'typical',
            'autism_probability': float(probability[1]),
            'typical_probability': float(probability[0]),
            'confidence': float(max(probability))
        }
        return result
    
    def evaluate_model(self, features_df, labels_df, test_size=0.2):
        """
        Evaluate the loaded model on test data
        
        Args:
            features_df: DataFrame with features
            labels_df: Series with labels (1=autism, 0=typical)
            test_size: Proportion of data to use for testing
            
        Returns:
            dict: Dictionary containing accuracy and other metrics
        """
        if self.model is None:
            print("Model not loaded. Load or train model first.")
            return None
        
        # Split data (using same random_state as training for consistency)
        X_train, X_test, y_train, y_test = train_test_split(
            features_df, labels_df, test_size=test_size, random_state=42, stratify=labels_df
        )
        
        # Scale features using the same scaler
        X_test_scaled = self.scaler.transform(X_test)
        
        # Predict
        y_pred = self.model.predict(X_test_scaled)
        y_pred_proba = self.model.predict_proba(X_test_scaled)
        
        # Calculate accuracy
        accuracy = accuracy_score(y_test, y_pred)
        
        # Print results
        print("\n" + "=" * 60)
        print("Model Evaluation Results")
        print("=" * 60)
        print(f"\nTest Set Size: {len(X_test)} samples")
        print(f"Model Accuracy: {accuracy:.2%}")
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred, target_names=['Typical', 'Autism']))
        print("\nConfusion Matrix:")
        cm = confusion_matrix(y_test, y_pred)
        print(cm)
        print(f"\nTrue Negatives (Typical correctly predicted): {cm[0][0]}")
        print(f"False Positives (Typical predicted as Autism): {cm[0][1]}")
        print(f"False Negatives (Autism predicted as Typical): {cm[1][0]}")
        print(f"True Positives (Autism correctly predicted): {cm[1][1]}")
        print("=" * 60)
        
        # Return metrics dictionary
        metrics = {
            'accuracy': float(accuracy),
            'test_size': len(X_test),
            'confusion_matrix': cm.tolist(),
            'predictions': y_pred.tolist(),
            'true_labels': y_test.tolist(),
            'probabilities': y_pred_proba.tolist()
        }
        
        return metrics


def main():
    """Main training function. Use ensemble for best accuracy (RF + GB + SVM)."""
    print("=" * 60)
    print("Autism Detection Model Training")
    print("=" * 60)
    
    trainer = AutismDetectionTrainer(
        data_dir='training_data',
        model_dir='models'
    )
    
    # Load training data (includes feature engineering: interaction terms, age-normalized, temporal)
    data = trainer.load_training_data('training_data/labels.csv')
    if data is None:
        print("\nNo training data found. Please:")
        print("1. Create training_data/ directory")
        print("2. Add videos to training_data/autism/ and training_data/typical/")
        print("3. Create labels.csv with video_path, label, child_age (optional: game_accuracy)")
        print("   Run this script from the backend directory so paths resolve correctly.")
        return
    features_df, labels_df = data
    
    # Train model: 'ensemble' (recommended, ~5-10% gain), 'random_forest', 'gradient_boosting', or 'svm'
    model_type = 'ensemble'
    if len(sys.argv) > 1 and sys.argv[1] in ('random_forest', 'svm', 'gradient_boosting', 'ensemble'):
        model_type = sys.argv[1]
    accuracy = trainer.train_model(features_df, labels_df, model_type=model_type)
    
    # Save model
    trainer.save_model('autism_detection_model')
    
    print("\n" + "=" * 60)
    print("Training completed!")
    print("=" * 60)


def evaluate_saved_model(labels_file='training_data/labels.csv', model_name='autism_detection_model'):
    """
    Helper function to evaluate a saved model
    
    Usage:
        from train_model import evaluate_saved_model
        evaluate_saved_model()
    """
    print("=" * 60)
    print("Evaluating Saved Model")
    print("=" * 60)
    
    trainer = AutismDetectionTrainer(
        data_dir='training_data',
        model_dir='models'
    )
    
    # Load model
    if not trainer.load_model(model_name):
        print(f"\nFailed to load model: {model_name}")
        print("Please train a model first using main() function")
        return None
    
    # Load training data
    features_df, labels_df = trainer.load_training_data(labels_file)
    
    if features_df is None:
        print("\nNo training data found.")
        return None
    
    # Evaluate model
    metrics = trainer.evaluate_model(features_df, labels_df)
    
    return metrics


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'evaluate':
        evaluate_saved_model()
    elif len(sys.argv) > 1 and sys.argv[1] == 'compare':
        # Train ensemble + optional deep model and compare
        try:
            from models.deep_rtn_model import train_and_compare_with_rf
            train_and_compare_with_rf('training_data/labels.csv')
        except ImportError:
            print("Deep comparison: pip install tensorflow, then run from backend/")
            main()
    else:
        main()







