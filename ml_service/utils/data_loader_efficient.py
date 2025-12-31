"""
Memory-efficient data loader for RRB video dataset
"""

import os
import cv2
import numpy as np
import pandas as pd
from typing import List, Tuple, Dict
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import json
import pickle
import logging

logger = logging.getLogger(__name__)


class RRBDataLoaderEfficient:
    """Memory-efficient data loader for RRB video dataset"""
    
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
            'Head Nodding': 'head_nodding',
            'Spinning': 'spinning',
            'Normal/Children': 'normal',
            'Normal/Adults': 'normal'
        }
        
        # Metadata storage
        self.train_metadata = []
        self.val_metadata = []
        self.test_metadata = []
        self.y_train = None
        self.y_val = None
        self.y_test = None
    
    def scan_dataset(self) -> Tuple[List[str], List[str]]:
        """
        Scan dataset directory and create file list with labels
        
        Returns:
            Tuple of (video_paths, labels)
        """
        video_paths = []
        labels = []
        
        for folder_path, label in self.category_mapping.items():
            full_path = os.path.join(self.dataset_root, folder_path)
            
            if not os.path.exists(full_path):
                logger.warning(f"Path not found: {full_path}")
                continue
            
            # Find all video files
            for root, dirs, files in os.walk(full_path):
                for file in files:
                    if file.lower().endswith(('.mp4', '.avi', '.mov', '.mkv')):
                        video_path = os.path.join(root, file)
                        video_paths.append(video_path)
                        labels.append(label)
        
        return video_paths, labels
    
    def prepare_dataset(self, test_size=0.15, val_size=0.15):
        """
        Prepare train/validation/test splits (memory-efficient version)
        
        Args:
            test_size: Proportion of data for testing
            val_size: Proportion of training data for validation
        """
        logger.info("Preparing dataset from scratch (memory-efficient mode)...")
        
        # Scan dataset
        video_paths, labels = self.scan_dataset()
        logger.info(f"Found {len(video_paths)} videos across {len(set(labels))} categories")
        
        # Encode labels
        self.label_encoder = LabelEncoder()
        y_encoded = self.label_encoder.fit_transform(labels)
        
        # Create metadata for sequences (without loading all data)
        logger.info("Creating sequence metadata...")
        sequence_metadata = []
        
        for i, (video_path, label) in enumerate(zip(video_paths, y_encoded)):
            if i % 10 == 0:
                logger.info(f"Processing {i}/{len(video_paths)}...")
            
            try:
                # Get video info without loading all frames
                cap = cv2.VideoCapture(video_path)
                if not cap.isOpened():
                    logger.warning(f"Cannot open video: {video_path}")
                    continue
                
                frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
                cap.release()
                
                if frame_count < self.sequence_length:
                    logger.warning(f"Video {video_path} has only {frame_count} frames, skipping")
                    continue
                
                # Calculate number of sequences with 50% overlap
                stride = self.sequence_length // 2
                num_sequences = max(1, (frame_count - self.sequence_length) // stride + 1)
                
                # Store metadata for each sequence
                for seq_idx in range(num_sequences):
                    sequence_metadata.append({
                        'video_path': video_path,
                        'label': label,
                        'seq_idx': seq_idx,
                        'frame_count': frame_count
                    })
                
            except Exception as e:
                logger.error(f"Error processing {video_path}: {e}")
                continue
        
        logger.info(f"Total sequences: {len(sequence_metadata)}")
        
        # Convert to DataFrame for easier splitting
        df = pd.DataFrame(sequence_metadata)
        
        # Split by video (not by sequence) to avoid data leakage
        unique_videos = df['video_path'].unique()
        video_labels = [df[df['video_path'] == v]['label'].iloc[0] for v in unique_videos]
        
        logger.info(f"Unique videos: {len(unique_videos)}")
        logger.info(f"Label distribution: {pd.Series(video_labels).value_counts().to_dict()}")
        
        # Split videos into train/test
        videos_train_val, videos_test = train_test_split(
            unique_videos, test_size=test_size, random_state=42, stratify=video_labels
        )
        
        # Split train videos into train/val
        train_val_labels = [df[df['video_path'] == v]['label'].iloc[0] for v in videos_train_val]
        videos_train, videos_val = train_test_split(
            videos_train_val, test_size=val_size, random_state=42, stratify=train_val_labels
        )