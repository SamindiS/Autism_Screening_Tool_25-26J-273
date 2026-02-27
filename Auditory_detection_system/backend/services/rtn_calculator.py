"""
RTN (Response to Name) Calculator
Detects if a child responds to their name being called
Improved version with balanced thresholds to reduce false positives and false negatives
"""
import cv2
import numpy as np
from collections import deque


class RTNCalculator:
    """Calculates RTN response from video frames"""
    
    def __init__(self):
        # Balanced thresholds - strict enough to reduce false positives, but not miss real responses
        self.response_threshold = 0.25  # Lowered from 0.5 - allows for subtle but real responses
        self.motion_threshold = 20  # Lowered from 30 - detects genuine motion without being too strict
        self.frame_variance_threshold = 600  # Lowered from 800 - still strict but allows for clearer face movements
        
        # Track previous frames for better motion detection
        self.previous_frames = deque(maxlen=5)  # Keep last 5 frames for comparison
        self.baseline_variance = None  # Baseline for comparison
        
        # Response detection requires sustained movement (not just random motion)
        self.movement_history = deque(maxlen=10)  # Track movement over time
        self.sustained_movement_frames = 0  # Count frames with consistent movement
        self.required_sustained_frames = 2  # Lowered from 3 - allows for quicker responses (2 frames = ~0.5-1 sec)
        
        # Head turning indicators (response typically involves head/face movement toward camera)
        self.head_turn_threshold = 0.10  # Lowered from 0.15 - more sensitive to head turns
        
    def check_response(self, frame, timestamp):
        """
        Check if frame shows a response to name
        
        Args:
            frame: Video frame (numpy array)
            timestamp: Current time in video (seconds)
        
        Returns:
            dict: Response detection result
        """
        try:
            # Convert to grayscale for motion detection
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            
            # Store frame for comparison
            self.previous_frames.append(gray.copy())
            
            # Initialize baseline if needed (first frame)
            if self.baseline_variance is None and len(self.previous_frames) > 1:
                self.baseline_variance = np.var(gray)
            
            # Calculate motion compared to previous frames (more accurate than single frame)
            motion_detected = False
            motion_score = 0.0
            
            if len(self.previous_frames) >= 2:
                # Compare with previous frame
                prev_gray = self.previous_frames[-2]
                frame_diff = cv2.absdiff(gray, prev_gray)
                motion_score = np.mean(frame_diff)
                
                # Require significant movement (not just noise)
                motion_detected = motion_score > self.motion_threshold
            
            # Detect edges (movement indicators) - but with stricter threshold
            edges = cv2.Canny(gray, 50, 150)
            edge_density = np.sum(edges > 0) / (gray.shape[0] * gray.shape[1])
            
            # Detect face/head movement with stricter criteria
            face_movement = self._detect_face_movement(gray)
            
            # Detect head turn (response typically involves turning head toward camera/parent)
            head_turn = self._detect_head_turn(gray)
            
            # Track movement history for sustained movement detection
            current_movement = motion_detected and (edge_density > 0.4 or face_movement or head_turn)
            self.movement_history.append(current_movement)
            
            # Count sustained movement frames
            if current_movement:
                self.sustained_movement_frames += 1
            else:
                self.sustained_movement_frames = 0
            
            # Response detection uses flexible criteria:
            # Strong head/face response OR sustained motion with clear pattern
            # This reduces false negatives while still avoiding false positives
            
            # Option 1: Clear head/face response (most reliable indicator)
            clear_head_response = (face_movement or head_turn) and motion_score > self.motion_threshold
            
            # Option 2: Sustained motion pattern (for cases where head turn isn't clearly detected)
            sustained_motion_response = (
                motion_score > self.motion_threshold and
                edge_density > self.response_threshold and
                self.sustained_movement_frames >= self.required_sustained_frames
            )
            
            # Accept if EITHER condition is met (flexible but still accurate)
            response_criteria_met = clear_head_response or sustained_motion_response
            
            detected = response_criteria_met
            
            if detected:
                # Determine response type based on timing
                if timestamp < 1.0:
                    status = 'immediateResponse'
                elif timestamp < 3.0:
                    status = 'delayedResponse'
                else:
                    status = 'partialResponse'
                
                # Higher confidence for earlier, clearer responses
                confidence = min(100, int(80 + (20 * (1.0 / max(timestamp, 0.1)))))
            else:
                status = 'noResponse'
                confidence = max(0, int(30 - (motion_score / 2)))  # Lower confidence for ambiguous cases
            
            return {
                'detected': detected,
                'time': timestamp if detected else 0.0,
                'status': status,
                'confidence': confidence,
                'motion_score': float(motion_score),
                'edge_density': float(edge_density),
                'face_movement': face_movement,
                'head_turn': head_turn
            }
            
        except Exception as e:
            return {
                'detected': False,
                'time': 0.0,
                'status': 'noResponse',
                'confidence': 0,
                'error': str(e)
            }
    
    def _detect_face_movement(self, gray_frame):
        """
        Improved face movement detection with balanced criteria
        """
        try:
            # Calculate frame variance
            frame_variance = np.var(gray_frame)
            
            # Compare with baseline if available
            if self.baseline_variance is not None:
                variance_change = abs(frame_variance - self.baseline_variance) / max(self.baseline_variance, 1)
                # Require noticeable change from baseline (lowered from 0.2 to 0.15)
                return variance_change > 0.15 and frame_variance > self.frame_variance_threshold
            
            # If no baseline, use absolute threshold
            return frame_variance > self.frame_variance_threshold
            
        except Exception:
            return False
    
    def _detect_head_turn(self, gray_frame):
        """
        Detect if head is turning toward camera (indicative of response)
        """
        try:
            height, width = gray_frame.shape
            
            # Focus on upper portion where head would be
            upper_portion = gray_frame[:height//2, :]
            
            # Check for face-like structure in center (where person would look when responding)
            center_region = upper_portion[:, width//2 - width//4:width//2 + width//4]
            center_variance = np.var(center_region)
            
            # Compare with edges (where head wouldn't be if turning toward camera)
            left_region = upper_portion[:, :width//4]
            right_region = upper_portion[:, 3*width//4:]
            edge_variance = (np.var(left_region) + np.var(right_region)) / 2
            
            # Head turn toward camera: center should have higher variance than edges
            # (face features are more visible when looking at camera)
            if edge_variance > 0:
                center_to_edge_ratio = center_variance / edge_variance
                return center_to_edge_ratio > (1.0 + self.head_turn_threshold)
            
            return False
            
        except Exception:
            return False
    
    def reset(self):
        """Reset calculator state for new video"""
        self.previous_frames.clear()
        self.baseline_variance = None
        self.movement_history.clear()
        self.sustained_movement_frames = 0
