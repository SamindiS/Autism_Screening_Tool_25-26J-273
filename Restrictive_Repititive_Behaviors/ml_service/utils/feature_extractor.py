import numpy as np
from scipy import signal
from typing import List, Dict, Tuple
import warnings
warnings.filterwarnings('ignore')

class FeatureExtractor:
    """Extract kinematic features from pose landmarks for RRB detection"""
    
    def __init__(self, fps: int = 30):
        """
        Initialize feature extractor
        
        Args:
            fps: Frames per second of the video
        """
        self.fps = fps
        self.dt = 1.0 / fps  # Time between frames
        
        # Key body parts for RRB analysis
        self.body_parts = {
            'head': [0, 2, 5, 7, 8],  # nose, eyes, ears
            'left_hand': [15],  # left wrist
            'right_hand': [16],  # right wrist
            'left_arm': [11, 13, 15],  # shoulder, elbow, wrist
            'right_arm': [12, 14, 16],
            'torso': [11, 12, 23, 24],  # shoulders and hips
        }
    
    def extract_position_sequence(self, landmarks_sequence: List[np.ndarray]) -> Dict[str, np.ndarray]:
        """
        Extract position sequences for key body parts
        
        Args:
            landmarks_sequence: List of landmark arrays from video frames
            
        Returns:
            Dictionary mapping body part names to position sequences [frames, 3]
        """
        positions = {}
        
        for part_name, landmark_indices in self.body_parts.items():
            part_positions = []
            
            for landmarks in landmarks_sequence:
                # Reshape landmarks to [33, 4] (x, y, z, visibility)
                landmarks_reshaped = landmarks.reshape(33, 4)
                
                # Get average position of landmarks for this body part
                part_coords = landmarks_reshaped[landmark_indices, :3]  # x, y, z only
                avg_position = np.mean(part_coords, axis=0)
                part_positions.append(avg_position)
            
            positions[part_name] = np.array(part_positions)
        
        return positions
    
    def compute_velocity(self, positions: np.ndarray) -> np.ndarray:
        """
        Compute velocity from position sequence
        
        Args:
            positions: Position array [frames, 3]
            
        Returns:
            Velocity array [frames-1, 3]
        """
        if len(positions) < 2:
            return np.zeros((1, 3))
        
        velocity = np.diff(positions, axis=0) / self.dt
        return velocity
    
    def compute_acceleration(self, velocity: np.ndarray) -> np.ndarray:
        """
        Compute acceleration from velocity sequence
        
        Args:
            velocity: Velocity array [frames, 3]
            
        Returns:
            Acceleration array [frames-1, 3]
        """
        if len(velocity) < 2:
            return np.zeros((1, 3))
        
        acceleration = np.diff(velocity, axis=0) / self.dt
        return acceleration
    
    def compute_jerk(self, acceleration: np.ndarray) -> np.ndarray:
        """
        Compute jerk (rate of change of acceleration)
        
        Args:
            acceleration: Acceleration array [frames, 3]
            
        Returns:
            Jerk array [frames-1, 3]
        """
        if len(acceleration) < 2:
            return np.zeros((1, 3))
        
        jerk = np.diff(acceleration, axis=0) / self.dt
        return jerk
    
    def compute_magnitude(self, vector_sequence: np.ndarray) -> np.ndarray:
        """
        Compute magnitude of 3D vectors
        
        Args:
            vector_sequence: Array of 3D vectors [frames, 3]
            
        Returns:
            Magnitude array [frames]
        """
        return np.linalg.norm(vector_sequence, axis=1)
    
    def compute_frequency_features(self, signal_data: np.ndarray, axis: int = 0) -> Dict[str, float]:
        """
        Compute frequency domain features using FFT
        
        Args:
            signal_data: Time series signal
            axis: Axis along which to compute (0 for x, 1 for y, 2 for z)
            
        Returns:
            Dictionary of frequency features
        """
        if len(signal_data) < 4:
            return {
                'dominant_frequency': 0.0,
                'frequency_power': 0.0,
                'frequency_entropy': 0.0
            }
        
        # Apply FFT
        fft_vals = np.fft.fft(signal_data[:, axis] if signal_data.ndim > 1 else signal_data)
        fft_freq = np.fft.fftfreq(len(signal_data), self.dt)
        
        # Get positive frequencies only
        positive_freq_idx = fft_freq > 0
        fft_power = np.abs(fft_vals[positive_freq_idx]) ** 2
        fft_freq_positive = fft_freq[positive_freq_idx]
        
        if len(fft_power) == 0:
            return {
                'dominant_frequency': 0.0,
                'frequency_power': 0.0,
                'frequency_entropy': 0.0
            }
        
        # Dominant frequency
        dominant_idx = np.argmax(fft_power)
        dominant_frequency = fft_freq_positive[dominant_idx]
        
        # Total power
        total_power = np.sum(fft_power)
        
        # Spectral entropy
        power_normalized = fft_power / (total_power + 1e-10)
        entropy = -np.sum(power_normalized * np.log2(power_normalized + 1e-10))
        
        return {
            'dominant_frequency': float(dominant_frequency),
            'frequency_power': float(total_power),
            'frequency_entropy': float(entropy)
        }
    
    def compute_angular_velocity(self, positions: np.ndarray) -> np.ndarray:
        """
        Compute angular velocity for rotational movements (e.g., spinning)
        
        Args:
            positions: Position array [frames, 3]
            
        Returns:
            Angular velocity array [frames-1]
        """
        if len(positions) < 2:
            return np.zeros(1)
        
        # Compute angle changes in XY plane
        angles = np.arctan2(positions[:, 1], positions[:, 0])
        angular_velocity = np.diff(angles) / self.dt
        
        return angular_velocity
    
    def extract_statistical_features(self, data: np.ndarray) -> Dict[str, float]:
        """
        Extract statistical features from time series data
        
        Args:
            data: Time series data
            
        Returns:
            Dictionary of statistical features
        """
        if len(data) == 0:
            return {
                'mean': 0.0, 'std': 0.0, 'min': 0.0, 'max': 0.0,
                'median': 0.0, 'q25': 0.0, 'q75': 0.0, 'range': 0.0
            }
        
        return {
            'mean': float(np.mean(data)),
            'std': float(np.std(data)),
            'min': float(np.min(data)),
            'max': float(np.max(data)),
            'median': float(np.median(data)),
            'q25': float(np.percentile(data, 25)),
            'q75': float(np.percentile(data, 75)),
            'range': float(np.max(data) - np.min(data))
        }
    
    def extract_all_features(self, landmarks_sequence: List[np.ndarray]) -> Dict[str, any]:
        """
        Extract all kinematic features from landmark sequence
        
        Args:
            landmarks_sequence: List of landmark arrays
            
        Returns:
            Dictionary containing all extracted features
        """
        # Get position sequences for all body parts
        positions = self.extract_position_sequence(landmarks_sequence)
        
        features = {}
        
        for part_name, part_positions in positions.items():
            # Velocity features
            velocity = self.compute_velocity(part_positions)
            velocity_mag = self.compute_magnitude(velocity)
            
            # Acceleration features
            acceleration = self.compute_acceleration(velocity)
            acceleration_mag = self.compute_magnitude(acceleration)
            
            # Jerk features
            jerk = self.compute_jerk(acceleration)
            jerk_mag = self.compute_magnitude(jerk)
            
            # Angular velocity (for spinning detection)
            angular_vel = self.compute_angular_velocity(part_positions)
            
            # Statistical features
            features[f'{part_name}_velocity'] = self.extract_statistical_features(velocity_mag)
            features[f'{part_name}_acceleration'] = self.extract_statistical_features(acceleration_mag)
            features[f'{part_name}_jerk'] = self.extract_statistical_features(jerk_mag)
            features[f'{part_name}_angular_velocity'] = self.extract_statistical_features(angular_vel)
            
            # Frequency features for each axis
            if len(part_positions) > 4:
                for axis, axis_name in enumerate(['x', 'y', 'z']):
                    freq_features = self.compute_frequency_features(part_positions, axis)
                    features[f'{part_name}_frequency_{axis_name}'] = freq_features
        
        return features
    
    def features_to_vector(self, features: Dict[str, any]) -> np.ndarray:
        """
        Convert feature dictionary to flat feature vector
        
        Args:
            features: Dictionary of features
            
        Returns:
            Flat numpy array of features
        """
        feature_vector = []
        
        for key, value in sorted(features.items()):
            if isinstance(value, dict):
                for sub_key, sub_value in sorted(value.items()):
                    feature_vector.append(sub_value)
            else:
                feature_vector.append(value)
        
        return np.array(feature_vector, dtype=np.float32)

