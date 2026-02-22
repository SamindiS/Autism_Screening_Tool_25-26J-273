import cv2
import os
import subprocess
import tempfile
from typing import Dict, Tuple, Optional
import logging

logger = logging.getLogger(__name__)

class VideoValidator:
    """Validate and repair video files before processing"""
    
    def __init__(self):
        """Initialize video validator"""
        self.supported_codecs = ['h264', 'mpeg4', 'vp8', 'vp9', 'av1']
        self.max_validation_frames = 10  # Number of frames to test-read
    
    def validate_video(self, video_path: str) -> Tuple[bool, str, Optional[Dict]]:
        """
        Validate video file for processing
        
        Args:
            video_path: Path to video file
            
        Returns:
            Tuple of (is_valid, error_message, video_info)
        """
        # Check file exists
        if not os.path.exists(video_path):
            return False, "Video file not found", None
        
        # Check file size
        file_size = os.path.getsize(video_path)
        if file_size == 0:
            return False, "Video file is empty", None
        
        if file_size < 1024:  # Less than 1KB
            return False, "Video file is too small (possibly corrupted)", None
        
        # Try to open with OpenCV
        cap = cv2.VideoCapture(video_path)
        
        if not cap.isOpened():
            cap.release()
            return False, "Cannot open video file. File may be corrupted or in unsupported format", None
        
        # Get video properties
        fps = cap.get(cv2.CAP_PROP_FPS)
        frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        
        # Validate properties
        if fps <= 0 or fps > 240:
            cap.release()
            return False, f"Invalid FPS: {fps}. Video may be corrupted", None
        
        if frame_count <= 0:
            cap.release()
            return False, "Video has no frames or frame count cannot be determined", None
        
        if width <= 0 or height <= 0:
            cap.release()
            return False, f"Invalid video dimensions: {width}x{height}", None
        
        # Try to read first few frames to ensure video is readable
        frames_read = 0
        frames_to_test = min(self.max_validation_frames, frame_count)
        
        for i in range(frames_to_test):
            ret, frame = cap.read()
            if not ret:
                cap.release()
                return False, f"Cannot read frame {i+1}. Video may be corrupted or incomplete", None
            
            if frame is None or frame.size == 0:
                cap.release()
                return False, f"Frame {i+1} is empty. Video may be corrupted", None
            
            frames_read += 1
        
        cap.release()
        
        # Calculate duration
        duration = frame_count / fps if fps > 0 else 0
        
        video_info = {
            'fps': fps,
            'frame_count': frame_count,
            'width': width,
            'height': height,
            'duration': duration,
            'file_size': file_size,
            'frames_validated': frames_read
        }
        
        return True, "Video is valid", video_info
    
    def repair_video(self, video_path: str, output_path: Optional[str] = None) -> Tuple[bool, str, Optional[str]]:
        """
        Attempt to repair/re-encode video to a compatible format
        
        Args:
            video_path: Path to input video
            output_path: Path for repaired video (optional)
            
        Returns:
            Tuple of (success, message, repaired_video_path)
        """
        if output_path is None:
            # Create temporary file
            temp_dir = tempfile.gettempdir()
            base_name = os.path.splitext(os.path.basename(video_path))[0]
            output_path = os.path.join(temp_dir, f"{base_name}_repaired.mp4")
        
        try:
            # Check if ffmpeg is available
            try:
                subprocess.run(['ffmpeg', '-version'], 
                             stdout=subprocess.PIPE, 
                             stderr=subprocess.PIPE, 
                             check=True)
            except (subprocess.CalledProcessError, FileNotFoundError):
                return False, "FFmpeg not available for video repair", None
            
            # Try aggressive repair first (for severely corrupted videos)
            cmd_aggressive = [
                'ffmpeg',
                '-err_detect', 'ignore_err',  # Ignore errors
                '-i', video_path,
                '-c:v', 'libx264',
                '-preset', 'ultrafast',  # Fast encoding
                '-crf', '28',  # Lower quality for speed
                '-c:a', 'aac',
                '-b:a', '128k',
                '-movflags', '+faststart',
                '-max_muxing_queue_size', '1024',  # Handle sync issues
                '-fflags', '+genpts',  # Generate presentation timestamps
                '-y',
                output_path
            ]

            logger.info("Attempting aggressive video repair...")
            result = subprocess.run(
                cmd_aggressive,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=300
            )

            # If aggressive repair failed, try standard repair
            if result.returncode != 0 or not os.path.exists(output_path):
                logger.info("Aggressive repair failed, trying standard repair...")

                cmd_standard = [
                    'ffmpeg',
                    '-i', video_path,
                    '-c:v', 'libx264',
                    '-preset', 'fast',
                    '-crf', '23',
                    '-c:a', 'aac',
                    '-b:a', '128k',
                    '-movflags', '+faststart',
                    '-y',
                    output_path
                ]

                result = subprocess.run(
                    cmd_standard,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    timeout=300
                )

            if result.returncode == 0 and os.path.exists(output_path):
                # Validate repaired video
                is_valid, msg, _ = self.validate_video(output_path)
                if is_valid:
                    logger.info("Video repaired successfully")
                    return True, "Video repaired successfully", output_path
                else:
                    logger.warning(f"Repaired video still invalid: {msg}")
                    return False, f"Repaired video is still invalid: {msg}", None
            else:
                error_msg = result.stderr.decode('utf-8', errors='ignore')
                logger.error(f"FFmpeg repair failed: {error_msg[:500]}")

                # Return a user-friendly message
                if "Invalid NAL unit" in error_msg or "moov atom" in error_msg:
                    return False, "Video is too corrupted to repair automatically. Please re-encode the video manually using a video converter.", None
                else:
                    return False, f"Video repair failed. The video may be too corrupted or in an unsupported format.", None
                
        except subprocess.TimeoutExpired:
            return False, "Video repair timed out", None
        except Exception as e:
            return False, f"Error during video repair: {str(e)}", None

