import os
import cv2
import numpy as np
import pandas as pd
from typing import List, Tuple, Dict
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import json
import pickle

class RRBDataLoader:
    """Data loader for RRB video dataset"""
    
    def __init__(self, dataset_root: str, sequence_length: int = 30, img_size: Tuple[int, int] = (224, 224)):
        """
        Initialize data loader
        
        Args:
            dataset_root: Root directory of dataset
            sequence_length: Number of frames per sequence
            img_size: Target image size
        """
        self.dataset_root = dataset_root
        self.sequence_length = sequence_length
        self.img_size = img_size
        self.label_encoder = LabelEncoder()
        
        # Define dataset structure based on folder organization
        self.category_mapping = {
            'Atypical Children Hand Movements': 'atypical_hand_movements',
            'Atypical Children Head and Hand Movements/Hand_Flapping': 'hand_flapping',
            'Atypical Children Head and Hand Movements/Head_Bagging': 'head_banging',
            'Head Nodding': 'head_nodding_atypical',
            'Spinning': 'spinning',
            'Normal/Children': 'normal',
            'Normal/Adults': 'normal'
        }
    
    def scan_dataset(self) -> List[Dict[str, str]]:
        """
        Scan dataset directory and create file list with labels
        
        Returns:
            List of dictionaries containing video paths and labels
        """
        dataset_files = []
        
        for folder_path, label in self.category_mapping.items():
            full_path = os.path.join(self.dataset_root, folder_path)
            
            if not os.path.exists(full_path):
                print(f"Warning: Path not found: {full_path}")
                continue
            
            # Get all video files
            for filename in os.listdir(full_path):
                if filename.endswith(('.mp4', '.avi', '.mov', '.MP4')) and not filename.startswith('.'):
                    video_path = os.path.join(full_path, filename)
                    dataset_files.append({
                        'path': video_path,
                        'label': label,
                        'filename': filename,
                        'category_folder': folder_path
                    })
        
        print(f"Found {len(dataset_files)} videos across {len(set([d['label'] for d in dataset_files]))} categories")
        return dataset_files
    
    def load_video_frames(self, video_path: str, max_frames: int = None) -> np.ndarray:
        """
        Load and preprocess video frames
        
        Args:
            video_path: Path to video file
            max_frames: Maximum number of frames to load
            
        Returns:
            Array of frames [num_frames, height, width, channels]
        """
        cap = cv2.VideoCapture(video_path)
        frames = []
        frame_count = 0
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            # Resize and normalize
            frame_resized = cv2.resize(frame, self.img_size)
            frame_normalized = frame_resized.astype(np.float32) / 255.0
            frames.append(frame_normalized)
            
            frame_count += 1
            if max_frames and frame_count >= max_frames:
                break
        
        cap.release()
        return np.array(frames)
    
    def create_sequences_from_video(self, frames: np.ndarray, overlap: float = 0.5) -> List[np.ndarray]:
        """
        Create fixed-length sequences from video frames
        
        Args:
            frames: Array of video frames
            overlap: Overlap ratio between sequences
            
        Returns:
            List of sequences
        """
        if len(frames) < self.sequence_length:
            # Pad with last frame if video is too short
            padding_needed = self.sequence_length - len(frames)
            if len(frames) > 0:
                padding = np.repeat(frames[-1:], padding_needed, axis=0)
                frames = np.concatenate([frames, padding], axis=0)
            else:
                # Empty video, return zeros
                return [np.zeros((self.sequence_length, *self.img_size, 3), dtype=np.float32)]
        
        step = max(1, int(self.sequence_length * (1 - overlap)))
        sequences = []
        
        for i in range(0, len(frames) - self.sequence_length + 1, step):
            sequence = frames[i:i + self.sequence_length]
            sequences.append(sequence)
        
        # If no sequences created, take the first sequence_length frames
        if len(sequences) == 0:
            sequences.append(frames[:self.sequence_length])
        
        return sequences
    
    def prepare_dataset(self, test_size: float = 0.2, val_size: float = 0.1, 
                       random_state: int = 42) -> Tuple[np.ndarray, np.ndarray, np.ndarray, 
                                                         np.ndarray, np.ndarray, np.ndarray]:
        """
        Prepare complete dataset with train/val/test splits
        
        Args:
            test_size: Proportion of test set
            val_size: Proportion of validation set (from training data)
            random_state: Random seed
            
        Returns:
            Tuple of (X_train, X_val, X_test, y_train, y_val, y_test)
        """
        # Scan dataset
        dataset_files = self.scan_dataset()
        
        if len(dataset_files) == 0:
            raise ValueError("No video files found in dataset")
        
        # Prepare data
        X_all = []
        y_all = []
        
        print("Loading videos and creating sequences...")
        for i, file_info in enumerate(dataset_files):
            if i % 10 == 0:
                print(f"Processing {i}/{len(dataset_files)}...")
            
            try:
                # Load video frames
                frames = self.load_video_frames(file_info['path'])
                
                # Create sequences
                sequences = self.create_sequences_from_video(frames)
                
                # Add to dataset
                for seq in sequences:
                    X_all.append(seq)
                    y_all.append(file_info['label'])
                    
            except Exception as e:
                print(f"Error processing {file_info['path']}: {e}")
                continue
        
        X_all = np.array(X_all)
        y_all = np.array(y_all)
        
        print(f"\nTotal sequences created: {len(X_all)}")
        print(f"Sequence shape: {X_all.shape}")
        print(f"Label distribution: {np.unique(y_all, return_counts=True)}")
        
        # Encode labels
        y_encoded = self.label_encoder.fit_transform(y_all)
        
        # Split into train and test
        X_train_val, X_test, y_train_val, y_test = train_test_split(
            X_all, y_encoded, test_size=test_size, random_state=random_state, stratify=y_encoded
        )
        
        # Split train into train and validation
        X_train, X_val, y_train, y_val = train_test_split(
            X_train_val, y_train_val, test_size=val_size, random_state=random_state, stratify=y_train_val
        )
        
        print(f"\nDataset splits:")
        print(f"Train: {len(X_train)} sequences")
        print(f"Validation: {len(X_val)} sequences")
        print(f"Test: {len(X_test)} sequences")
        
        return X_train, X_val, X_test, y_train, y_val, y_test
    
    def save_preprocessed_data(self, output_dir: str, X_train, X_val, X_test, 
                               y_train, y_val, y_test):
        """
        Save preprocessed data to disk
        
        Args:
            output_dir: Directory to save data
            X_train, X_val, X_test: Feature arrays
            y_train, y_val, y_test: Label arrays
        """
        os.makedirs(output_dir, exist_ok=True)
        
        # Save arrays
        np.save(os.path.join(output_dir, 'X_train.npy'), X_train)
        np.save(os.path.join(output_dir, 'X_val.npy'), X_val)
        np.save(os.path.join(output_dir, 'X_test.npy'), X_test)
        np.save(os.path.join(output_dir, 'y_train.npy'), y_train)
        np.save(os.path.join(output_dir, 'y_val.npy'), y_val)
        np.save(os.path.join(output_dir, 'y_test.npy'), y_test)
        
        # Save label encoder
        with open(os.path.join(output_dir, 'label_encoder.pkl'), 'wb') as f:
            pickle.dump(self.label_encoder, f)
        
        # Save metadata
        metadata = {
            'sequence_length': self.sequence_length,
            'img_size': self.img_size,
            'num_classes': len(self.label_encoder.classes_),
            'classes': self.label_encoder.classes_.tolist(),
            'train_samples': len(X_train),
            'val_samples': len(X_val),
            'test_samples': len(X_test)
        }
        
        with open(os.path.join(output_dir, 'metadata.json'), 'w') as f:
            json.dump(metadata, f, indent=2)
        
        print(f"Preprocessed data saved to {output_dir}")
    
    def load_preprocessed_data(self, data_dir: str) -> Tuple:
        """
        Load preprocessed data from disk
        
        Args:
            data_dir: Directory containing preprocessed data
            
        Returns:
            Tuple of (X_train, X_val, X_test, y_train, y_val, y_test, label_encoder)
        """
        X_train = np.load(os.path.join(data_dir, 'X_train.npy'))
        X_val = np.load(os.path.join(data_dir, 'X_val.npy'))
        X_test = np.load(os.path.join(data_dir, 'X_test.npy'))
        y_train = np.load(os.path.join(data_dir, 'y_train.npy'))
        y_val = np.load(os.path.join(data_dir, 'y_val.npy'))
        y_test = np.load(os.path.join(data_dir, 'y_test.npy'))
        
        with open(os.path.join(data_dir, 'label_encoder.pkl'), 'rb') as f:
            label_encoder = pickle.load(f)
        
        self.label_encoder = label_encoder
        
        return X_train, X_val, X_test, y_train, y_val, y_test, label_encoder
    
    def get_class_weights(self, y_train: np.ndarray) -> Dict[int, float]:
        """
        Calculate class weights for imbalanced dataset
        
        Args:
            y_train: Training labels
            
        Returns:
            Dictionary of class weights
        """
        from sklearn.utils.class_weight import compute_class_weight
        
        classes = np.unique(y_train)
        weights = compute_class_weight('balanced', classes=classes, y=y_train)
        
        return dict(zip(classes, weights))

