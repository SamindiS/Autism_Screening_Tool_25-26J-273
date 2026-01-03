import numpy as np
import cv2
import tensorflow as tf
from tensorflow import keras
import pickle
from typing import List, Dict, Tuple, Optional
import os

from .pose_estimator import PoseEstimator
from .feature_extractor import FeatureExtractor
from .video_processor import VideoProcessor

class RRBInference:
    """Inference engine for RRB detection"""
    
    def __init__(self, 
                 model_path: str,
                 label_encoder_path: str,
                 sequence_length: int = 30,
                 img_size: Tuple[int, int] = (224, 224),
                 confidence_threshold: float = 0.70,
                 min_duration: float = 3.0):
        """
        Initialize inference engine
        
        Args:
            model_path: Path to trained model
            label_encoder_path: Path to label encoder
            sequence_length: Number of frames per sequence
            img_size: Image size for model input
            confidence_threshold: Minimum confidence for detection
            min_duration: Minimum duration in seconds for valid detection
        """
        self.sequence_length = sequence_length
        self.img_size = img_size
        self.confidence_threshold = confidence_threshold
        self.min_duration = min_duration
        
        # Load model
        print(f"Loading model from {model_path}...")
        self.model = keras.models.load_model(model_path)
        
        # Load label encoder
        print(f"Loading label encoder from {label_encoder_path}...")
        with open(label_encoder_path, 'rb') as f:
            self.label_encoder = pickle.load(f)
        
        # Initialize processors
        self.video_processor = VideoProcessor(img_size=img_size)
        self.pose_estimator = PoseEstimator()
        
        print("Inference engine initialized successfully")
    
    def preprocess_video(self, video_path: str) -> Tuple[np.ndarray, Dict]:
        """
        Preprocess video for inference
        
        Args:
            video_path: Path to video file
            
        Returns:
            Tuple of (preprocessed sequences, video info)
        """
        # Get video info
        video_info = self.video_processor.get_video_info(video_path)
        
        # Extract frames
        frames = self.video_processor.extract_frames(video_path)
        
        if len(frames) == 0:
            raise ValueError("No frames extracted from video")
        
        # Create sequences
        sequences = self.video_processor.create_sequences(
            frames, 
            self.sequence_length,
            overlap=0.5
        )
        
        # Normalize
        sequences = [self.video_processor.normalize_frames(seq) for seq in sequences]
        sequences = np.array(sequences)
        
        return sequences, video_info
    
    def predict_sequences(self, sequences: np.ndarray) -> List[Dict]:
        """
        Predict RRB for each sequence
        
        Args:
            sequences: Array of video sequences
            
        Returns:
            List of predictions for each sequence
        """
        # Get predictions
        predictions = self.model.predict(sequences, verbose=0)
        
        results = []
        for i, pred in enumerate(predictions):
            class_idx = np.argmax(pred)
            confidence = float(pred[class_idx])
            class_name = self.label_encoder.classes_[class_idx]
            
            results.append({
                'sequence_index': i,
                'class': class_name,
                'confidence': confidence,
                'all_probabilities': {
                    self.label_encoder.classes_[j]: float(pred[j])
                    for j in range(len(pred))
                }
            })
        
        return results
    
    def filter_detections(self, predictions: List[Dict], video_info: Dict, 
                         fps: int = 30) -> List[Dict]:
        """
        Filter detections based on confidence and duration
        
        Args:
            predictions: List of predictions
            video_info: Video metadata
            fps: Frames per second
            
        Returns:
            Filtered detections
        """
        filtered = []
        
        for pred in predictions:
            # Filter by confidence
            if pred['confidence'] < self.confidence_threshold:
                continue
            
            # Filter out 'normal' class unless it's the only detection
            if pred['class'] == 'normal' and len(predictions) > 1:
                continue
            
            # Calculate duration of this sequence
            sequence_duration = self.sequence_length / fps
            
            # Filter by minimum duration
            if sequence_duration >= self.min_duration:
                pred['duration'] = sequence_duration
                filtered.append(pred)
        
        return filtered
    
    def aggregate_detections(self, detections: List[Dict]) -> Dict:
        """
        Aggregate multiple detections into final result
        
        Args:
            detections: List of filtered detections
            
        Returns:
            Aggregated detection result
        """
        if not detections:
            return {
                'detected': False,
                'primary_behavior': 'normal',
                'confidence': 0.0,
                'behaviors': []
            }
        
        # Group by behavior type
        behavior_groups = {}
        for det in detections:
            behavior = det['class']
            if behavior not in behavior_groups:
                behavior_groups[behavior] = []
            behavior_groups[behavior].append(det)
        
        # Calculate average confidence for each behavior
        behavior_summary = []
        for behavior, dets in behavior_groups.items():
            avg_confidence = np.mean([d['confidence'] for d in dets])
            total_duration = sum([d.get('duration', 0) for d in dets])
            
            behavior_summary.append({
                'behavior': behavior,
                'confidence': float(avg_confidence),
                'occurrences': len(dets),
                'total_duration': float(total_duration)
            })
        
        # Sort by confidence
        behavior_summary.sort(key=lambda x: x['confidence'], reverse=True)
        
        # Primary behavior is the one with highest confidence
        primary = behavior_summary[0] if behavior_summary else None
        
        return {
            'detected': len(behavior_summary) > 0,
            'primary_behavior': primary['behavior'] if primary else 'normal',
            'confidence': primary['confidence'] if primary else 0.0,
            'behaviors': behavior_summary
        }
    
    def detect_rrb(self, video_path: str) -> Dict:
        """
        Main detection pipeline
        
        Args:
            video_path: Path to video file
            
        Returns:
            Detection results
        """
        try:
            # Preprocess video
            sequences, video_info = self.preprocess_video(video_path)
            
            # Predict
            predictions = self.predict_sequences(sequences)
            
            # Filter detections
            fps = video_info.get('fps', 30)
            filtered_detections = self.filter_detections(predictions, video_info, fps)
            
            # Aggregate results
            result = self.aggregate_detections(filtered_detections)
            
            # Add metadata
            result['video_info'] = video_info
            result['total_sequences_analyzed'] = len(sequences)
            result['sequences_with_detections'] = len(filtered_detections)
            
            return result
            
        except Exception as e:
            return {
                'detected': False,
                'error': str(e),
                'primary_behavior': 'error',
                'confidence': 0.0,
                'behaviors': []
            }
    
    def detect_with_pose_analysis(self, video_path: str) -> Dict:
        """
        Enhanced detection with pose analysis
        
        Args:
            video_path: Path to video file
            
        Returns:
            Detection results with pose features
        """
        # Standard detection
        result = self.detect_rrb(video_path)
        
        try:
            # Extract pose landmarks
            landmarks_sequence, fps = self.pose_estimator.process_video(video_path)
            
            if len(landmarks_sequence) > 0:
                # Extract features
                feature_extractor = FeatureExtractor(fps=fps)
                features = feature_extractor.extract_all_features(landmarks_sequence)
                
                # Add pose analysis to result
                result['pose_analysis'] = {
                    'landmarks_extracted': len(landmarks_sequence),
                    'fps': fps,
                    'features_extracted': True
                }
            else:
                result['pose_analysis'] = {
                    'landmarks_extracted': 0,
                    'error': 'No pose detected in video'
                }
                
        except Exception as e:
            result['pose_analysis'] = {
                'error': str(e)
            }
        
        return result
    
    def batch_detect(self, video_paths: List[str]) -> List[Dict]:
        """
        Batch detection for multiple videos
        
        Args:
            video_paths: List of video paths
            
        Returns:
            List of detection results
        """
        results = []
        
        for i, video_path in enumerate(video_paths):
            print(f"Processing video {i+1}/{len(video_paths)}: {video_path}")
            result = self.detect_rrb(video_path)
            result['video_path'] = video_path
            results.append(result)
        
        return results

