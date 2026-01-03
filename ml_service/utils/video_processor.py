import cv2
import numpy as np
from typing import List, Tuple, Optional, Dict
import os

class VideoProcessor:
    """Video preprocessing and frame extraction for RRB detection"""
    
    def __init__(self, target_fps: int = 30, img_size: Tuple[int, int] = (224, 224)):
        """
        Initialize video processor
        
        Args:
            target_fps: Target frames per second for processing
            img_size: Target image size (width, height)
        """
        self.target_fps = target_fps
        self.img_size = img_size
    
    def get_video_info(self, video_path: str) -> Dict[str, any]:
        """
        Get video metadata
        
        Args:
            video_path: Path to video file
            
        Returns:
            Dictionary containing video information
        """
        cap = cv2.VideoCapture(video_path)
        
        info = {
            'fps': int(cap.get(cv2.CAP_PROP_FPS)),
            'frame_count': int(cap.get(cv2.CAP_PROP_FRAME_COUNT)),
            'width': int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)),
            'height': int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)),
            'duration': 0.0
        }
        
        if info['fps'] > 0:
            info['duration'] = info['frame_count'] / info['fps']
        
        cap.release()
        return info
    
    def extract_frames(self, video_path: str, max_frames: Optional[int] = None) -> List[np.ndarray]:
        """
        Extract frames from video
        
        Args:
            video_path: Path to video file
            max_frames: Maximum number of frames to extract
            
        Returns:
            List of frames as numpy arrays
        """
        cap = cv2.VideoCapture(video_path)
        frames = []
        frame_count = 0
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            # Resize frame
            frame_resized = cv2.resize(frame, self.img_size)
            frames.append(frame_resized)
            
            frame_count += 1
            if max_frames and frame_count >= max_frames:
                break
        
        cap.release()
        return frames
    
    def sample_frames(self, video_path: str, num_frames: int) -> List[np.ndarray]:
        """
        Sample fixed number of frames uniformly from video
        
        Args:
            video_path: Path to video file
            num_frames: Number of frames to sample
            
        Returns:
            List of sampled frames
        """
        cap = cv2.VideoCapture(video_path)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        if total_frames <= num_frames:
            # If video has fewer frames, extract all
            return self.extract_frames(video_path)
        
        # Calculate frame indices to sample
        indices = np.linspace(0, total_frames - 1, num_frames, dtype=int)
        
        frames = []
        for idx in indices:
            cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
            ret, frame = cap.read()
            if ret:
                frame_resized = cv2.resize(frame, self.img_size)
                frames.append(frame_resized)
        
        cap.release()
        return frames
    
    def create_sequences(self, frames: List[np.ndarray], sequence_length: int, 
                        overlap: float = 0.5) -> List[np.ndarray]:
        """
        Create overlapping sequences from frames
        
        Args:
            frames: List of video frames
            sequence_length: Number of frames per sequence
            overlap: Overlap ratio between sequences (0.0 to 1.0)
            
        Returns:
            List of frame sequences
        """
        if len(frames) < sequence_length:
            # Pad with last frame if needed
            padding = [frames[-1]] * (sequence_length - len(frames))
            return [np.array(frames + padding)]
        
        step = int(sequence_length * (1 - overlap))
        sequences = []
        
        for i in range(0, len(frames) - sequence_length + 1, step):
            sequence = frames[i:i + sequence_length]
            sequences.append(np.array(sequence))
        
        return sequences
    
    def normalize_frames(self, frames: np.ndarray) -> np.ndarray:
        """
        Normalize frame pixel values to [0, 1]
        
        Args:
            frames: Array of frames
            
        Returns:
            Normalized frames
        """
        return frames.astype(np.float32) / 255.0
    
    def augment_frame(self, frame: np.ndarray, 
                     flip: bool = False,
                     brightness: float = 0.0,
                     rotation: float = 0.0) -> np.ndarray:
        """
        Apply data augmentation to a frame
        
        Args:
            frame: Input frame
            flip: Whether to flip horizontally
            brightness: Brightness adjustment (-1.0 to 1.0)
            rotation: Rotation angle in degrees
            
        Returns:
            Augmented frame
        """
        augmented = frame.copy()
        
        # Horizontal flip
        if flip:
            augmented = cv2.flip(augmented, 1)
        
        # Brightness adjustment
        if brightness != 0.0:
            hsv = cv2.cvtColor(augmented, cv2.COLOR_BGR2HSV)
            h, s, v = cv2.split(hsv)
            v = np.clip(v * (1 + brightness), 0, 255).astype(np.uint8)
            hsv = cv2.merge([h, s, v])
            augmented = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
        
        # Rotation
        if rotation != 0.0:
            h, w = augmented.shape[:2]
            center = (w // 2, h // 2)
            matrix = cv2.getRotationMatrix2D(center, rotation, 1.0)
            augmented = cv2.warpAffine(augmented, matrix, (w, h))
        
        return augmented
    
    def save_video(self, frames: List[np.ndarray], output_path: str, fps: int = 30):
        """
        Save frames as video file
        
        Args:
            frames: List of frames
            output_path: Output video path
            fps: Frames per second
        """
        if not frames:
            return
        
        height, width = frames[0].shape[:2]
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
        
        for frame in frames:
            out.write(frame)
        
        out.release()
    
    def extract_thumbnail(self, video_path: str, output_path: str, 
                         frame_index: Optional[int] = None):
        """
        Extract a thumbnail from video
        
        Args:
            video_path: Path to video file
            output_path: Output image path
            frame_index: Frame index to extract (None for middle frame)
        """
        cap = cv2.VideoCapture(video_path)
        
        if frame_index is None:
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            frame_index = total_frames // 2
        
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
        ret, frame = cap.read()
        
        if ret:
            cv2.imwrite(output_path, frame)
        
        cap.release()

