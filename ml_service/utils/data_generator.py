"""
Memory-efficient data generator for RRB video dataset
"""

import os
import cv2
import numpy as np
import tensorflow as tf
from typing import List, Tuple, Dict
import logging

logger = logging.getLogger(__name__)


class RRBDataGenerator(tf.keras.utils.Sequence):
    """
    Memory-efficient data generator for RRB video sequences
    Loads data on-the-fly instead of loading everything into memory
    """
    
    def __init__(self, 
                 metadata: List[Dict],
                 batch_size: int = 8,
                 sequence_length: int = 30,
                 img_size: Tuple[int, int] = (224, 224),
                 shuffle: bool = True,
                 augment: bool = False):
        """
        Initialize data generator
        
        Args:
            metadata: List of sequence metadata dicts with 'video_path', 'label', 'seq_idx'
            batch_size: Number of sequences per batch
            sequence_length: Number of frames per sequence
            img_size: Target image size (height, width)
            shuffle: Whether to shuffle data after each epoch
            augment: Whether to apply data augmentation
        """
        self.metadata = metadata
        self.batch_size = batch_size
        self.sequence_length = sequence_length
        self.img_size = img_size
        self.shuffle = shuffle
        self.augment = augment
        
        self.indexes = np.arange(len(self.metadata))
        if self.shuffle:
            np.random.shuffle(self.indexes)
        
        # Cache for loaded videos to avoid reloading
        self.video_cache = {}
        self.max_cache_size = 10  # Keep max 10 videos in memory
    
    def __len__(self):
        """Number of batches per epoch"""
        return int(np.ceil(len(self.metadata) / self.batch_size))
    
    def __getitem__(self, index):
        """Generate one batch of data"""
        # Get batch indexes
        batch_indexes = self.indexes[index * self.batch_size:(index + 1) * self.batch_size]
        
        # Generate data
        X, y = self._generate_batch(batch_indexes)
        
        return X, y
    
    def on_epoch_end(self):
        """Updates indexes after each epoch"""
        if self.shuffle:
            np.random.shuffle(self.indexes)
        
        # Clear video cache to free memory
        self.video_cache.clear()
    
    def _load_video_frames(self, video_path: str) -> np.ndarray:
        """
        Load all frames from a video
        
        Args:
            video_path: Path to video file
            
        Returns:
            Array of frames (num_frames, height, width, 3)
        """
        # Check cache first
        if video_path in self.video_cache:
            return self.video_cache[video_path]
        
        frames = []
        cap = cv2.VideoCapture(video_path)
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Resize frame
            frame = cv2.resize(frame, self.img_size)
            # Convert BGR to RGB
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frames.append(frame)
        
        cap.release()
        
        if len(frames) == 0:
            raise ValueError(f"No frames loaded from {video_path}")
        
        frames = np.array(frames, dtype=np.float32)
        
        # Cache if not too many videos cached
        if len(self.video_cache) < self.max_cache_size:
            self.video_cache[video_path] = frames
        
        return frames
    
    def _extract_sequence(self, frames: np.ndarray, seq_idx: int) -> np.ndarray:
        """
        Extract a sequence from video frames
        
        Args:
            frames: All frames from video
            seq_idx: Sequence index
            
        Returns:
            Sequence of frames (sequence_length, height, width, 3)
        """
        total_frames = len(frames)
        
        # Calculate start frame with 50% overlap
        stride = self.sequence_length // 2
        start_frame = seq_idx * stride
        end_frame = start_frame + self.sequence_length
        
        # Handle edge cases
        if end_frame > total_frames:
            # Take last sequence_length frames
            start_frame = max(0, total_frames - self.sequence_length)
            end_frame = total_frames
        
        sequence = frames[start_frame:end_frame]
        
        # Pad if necessary
        if len(sequence) < self.sequence_length:
            padding = np.zeros((self.sequence_length - len(sequence), *self.img_size, 3), dtype=np.float32)
            sequence = np.concatenate([sequence, padding], axis=0)
        
        return sequence
    
    def _augment_sequence(self, sequence: np.ndarray) -> np.ndarray:
        """
        Apply data augmentation to sequence
        
        Args:
            sequence: Input sequence
            
        Returns:
            Augmented sequence
        """
        # Random horizontal flip
        if np.random.random() > 0.5:
            sequence = np.flip(sequence, axis=2)  # Flip width dimension
        
        # Random brightness adjustment
        if np.random.random() > 0.5:
            brightness_factor = np.random.uniform(0.8, 1.2)
            sequence = np.clip(sequence * brightness_factor, 0, 255)
        
        # Random rotation (small angle)
        if np.random.random() > 0.5:
            angle = np.random.uniform(-10, 10)
            h, w = self.img_size
            center = (w // 2, h // 2)
            M = cv2.getRotationMatrix2D(center, angle, 1.0)
            
            rotated_sequence = []
            for frame in sequence:
                rotated_frame = cv2.warpAffine(frame, M, (w, h))
                rotated_sequence.append(rotated_frame)
            sequence = np.array(rotated_sequence)
        
        return sequence
    
    def _normalize_sequence(self, sequence: np.ndarray) -> np.ndarray:
        """
        Normalize sequence to [0, 1]
        
        Args:
            sequence: Input sequence
            
        Returns:
            Normalized sequence
        """
        return sequence / 255.0
    
    def _generate_batch(self, batch_indexes: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """
        Generate one batch of data
        
        Args:
            batch_indexes: Indexes of sequences in this batch
            
        Returns:
            Tuple of (X, y) where X is sequences and y is labels
        """
        X_batch = []
        y_batch = []
        
        for idx in batch_indexes:
            metadata = self.metadata[idx]
            video_path = metadata['video_path']
            label = metadata['label']
            seq_idx = metadata['seq_idx']
            
            try:
                # Load video frames
                frames = self._load_video_frames(video_path)
                
                # Extract sequence
                sequence = self._extract_sequence(frames, seq_idx)
                
                # Apply augmentation if enabled
                if self.augment:
                    sequence = self._augment_sequence(sequence)
                
                # Normalize
                sequence = self._normalize_sequence(sequence)
                
                X_batch.append(sequence)
                y_batch.append(label)
                
            except Exception as e:
                logger.warning(f"Error loading sequence from {video_path}: {e}")
                # Use zero sequence as fallback
                zero_sequence = np.zeros((self.sequence_length, *self.img_size, 3), dtype=np.float32)
                X_batch.append(zero_sequence)
                y_batch.append(label)
        
        return np.array(X_batch, dtype=np.float32), np.array(y_batch, dtype=np.int32)


def create_generators(data_loader, batch_size=8, augment_train=True):
    """
    Create train, validation, and test generators
    
    Args:
        data_loader: RRBDataLoader instance with prepared metadata
        batch_size: Batch size for generators
        augment_train: Whether to augment training data
        
    Returns:
        Tuple of (train_gen, val_gen, test_gen)
    """
    train_gen = RRBDataGenerator(
        metadata=data_loader.train_metadata,
        batch_size=batch_size,
        sequence_length=data_loader.sequence_length,
        img_size=data_loader.img_size,
        shuffle=True,
        augment=augment_train
    )
    
    val_gen = RRBDataGenerator(
        metadata=data_loader.val_metadata,
        batch_size=batch_size,
        sequence_length=data_loader.sequence_length,
        img_size=data_loader.img_size,
        shuffle=False,
        augment=False
    )
    
    test_gen = RRBDataGenerator(
        metadata=data_loader.test_metadata,
        batch_size=batch_size,
        sequence_length=data_loader.sequence_length,
        img_size=data_loader.img_size,
        shuffle=False,
        augment=False
    )
    
    return train_gen, val_gen, test_gen

