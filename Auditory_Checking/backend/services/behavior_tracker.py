"""
Behavior Tracker Service
Tracks and detects behavioral patterns in video frames
Only detects actual movement changes, not static frame characteristics

Expanded markers:
- Facial expression: smile detection, emotional response (neutral/positive/negative)
- Body language: full-body orientation, hand/arm movements (stimming), proximity-seeking
- Attention maintenance: eye contact duration, return-to-activity speed
"""
import cv2
import numpy as np
from datetime import datetime
from collections import deque


class BehaviorTracker:
    """Tracks behavioral patterns from video frames"""
    
    def __init__(self):
        self.behavior_types = [
            'head_turning',
            'eye_movement',
            'body_movement',
            'facial_expression',
            'attention_shift',
            'smile_detected',
            'body_orientation_change',
            'hand_arm_movement',
            'proximity_seeking',
            'eye_contact_maintained',
            'return_to_activity'
        ]
        
        # Track previous frames for movement detection
        self.previous_frames = deque(maxlen=3)  # Keep last 3 frames
        self.baseline_frame = None  # Baseline for comparison
        self.frame_count = 0
        
        # Expanded markers: running state for attention maintenance
        self.eye_contact_start_time = None  # timestamp when eye contact began
        self.eye_contact_duration_seconds = 0.0
        self.last_response_time = None  # timestamp of last detected response
        self.return_to_activity_time = None  # timestamp when movement returned to baseline
        self.return_to_activity_speed_seconds = None  # seconds from response to return
        self.smile_detected_count = 0
        self.positive_expression_count = 0
        self.neutral_expression_count = 0
        self.negative_expression_count = 0
        self.body_orientation_changes = []
        self.hand_arm_movement_count = 0
        self.proximity_seeking_count = 0
        self.emotional_codes_per_frame = []  # list of 'neutral'|'positive'|'negative'
    
    def detect_behaviors(self, frame, timestamp):
        """
        Detect behaviors in a video frame by comparing with previous frames
        Only reports actual movement changes, not static characteristics
        
        Args:
            frame: Video frame (numpy array)
            timestamp: Current time in video (seconds)
        
        Returns:
            list: List of detected behaviors (only actual movements)
        """
        behaviors = []
        
        try:
            # Convert to grayscale
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            
            # Establish baseline on first frame
            if self.baseline_frame is None:
                self.baseline_frame = gray.copy()
                self.previous_frames.append(gray.copy())
                self.frame_count += 1
                return []  # No behaviors on first frame
            
            # Store current frame
            self.previous_frames.append(gray.copy())
            self.frame_count += 1
            
            # Need at least 2 frames to detect movement
            if len(self.previous_frames) < 2:
                return []
            
            # Compare with previous frame to detect actual movement
            prev_gray = self.previous_frames[-2]
            frame_diff = cv2.absdiff(gray, prev_gray)
            motion_score = np.mean(frame_diff)
            
            # Filter out noise from video compression and lighting changes
            # Require significant movement to avoid false positives
            if motion_score < 25:  # Increased threshold - child must show clear movement
                return []  # No actual movement detected
            
            # Additional filtering: Check if movement is consistent across frames
            # This helps filter out single-frame artifacts
            if len(self.previous_frames) >= 3:
                # Compare with frame before previous to check consistency
                prev_prev_gray = self.previous_frames[-3]
                prev_frame_diff = cv2.absdiff(prev_gray, prev_prev_gray)
                prev_motion_score = np.mean(prev_frame_diff)
                
                # Require consistent movement (not just a single frame change)
                # If previous frame had low motion, current might be noise
                if prev_motion_score < 15 and motion_score < 40:
                    return []  # Likely noise, not real movement
            
            # Detect head turning (only if actual movement detected with higher threshold)
            # Increased thresholds to reduce false positives
            if motion_score > 35 and self._detect_head_turning(gray, prev_gray, frame_diff):
                behaviors.append({
                    'type': 'head_turning',
                    'time': timestamp,
                    'confidence': min(85, int(60 + motion_score * 0.5))  # Reduced confidence multiplier
                })
            
            # Detect eye movement (only with clear movement in upper frame region)
            # Increased threshold significantly
            if motion_score > 40 and self._detect_eye_movement(gray, prev_gray, frame_diff):
                behaviors.append({
                    'type': 'eye_movement',
                    'time': timestamp,
                    'confidence': min(80, int(55 + motion_score * 0.5))
                })
            
            # Detect body movement (requires significant overall frame change)
            # Increased threshold
            if motion_score > 45 and self._detect_body_movement(frame_diff):
                behaviors.append({
                    'type': 'body_movement',
                    'time': timestamp,
                    'confidence': min(75, int(50 + motion_score * 0.5))
                })
            
            # Detect facial expression changes (subtle changes in face region)
            # Increased threshold and require more significant change
            if motion_score > 35 and self._detect_facial_expression(gray, prev_gray, frame_diff):
                behaviors.append({
                    'type': 'facial_expression',
                    'time': timestamp,
                    'confidence': min(70, int(45 + motion_score * 0.5))
                })
            
            # --- Expanded: Facial expression analysis ---
            smile_detected = self._detect_smile(gray, frame_diff)
            emotional_code = self._code_emotional_response(gray, frame_diff)  # 'neutral'|'positive'|'negative'
            if smile_detected:
                self.smile_detected_count += 1
                self.positive_expression_count += 1
                behaviors.append({
                    'type': 'smile_detected',
                    'time': timestamp,
                    'confidence': 70,
                    'emotional_code': 'positive'
                })
            else:
                if emotional_code == 'positive':
                    self.positive_expression_count += 1
                elif emotional_code == 'negative':
                    self.negative_expression_count += 1
                else:
                    self.neutral_expression_count += 1
            self.emotional_codes_per_frame.append(emotional_code)
            
            # --- Expanded: Body language tracking ---
            if motion_score > 40 and self._detect_full_body_orientation_change(gray, prev_gray, frame_diff):
                self.body_orientation_changes.append(timestamp)
                behaviors.append({
                    'type': 'body_orientation_change',
                    'time': timestamp,
                    'confidence': min(75, int(50 + motion_score * 0.5))
                })
            if motion_score > 30 and self._detect_hand_arm_movement(frame_diff):
                self.hand_arm_movement_count += 1
                behaviors.append({
                    'type': 'hand_arm_movement',
                    'time': timestamp,
                    'confidence': 65,
                    'stimming_candidate': motion_score > 45  # repetitive/high motion
                })
            if motion_score > 35 and self._detect_proximity_seeking(gray, prev_gray, frame_diff):
                self.proximity_seeking_count += 1
                behaviors.append({
                    'type': 'proximity_seeking',
                    'time': timestamp,
                    'confidence': 60
                })
            
            # --- Expanded: Attention maintenance ---
            if motion_score > 25 and self._detect_eye_movement(gray, prev_gray, frame_diff):
                if self.eye_contact_start_time is None:
                    self.eye_contact_start_time = timestamp
                else:
                    self.eye_contact_duration_seconds = timestamp - self.eye_contact_start_time
                behaviors.append({
                    'type': 'eye_contact_maintained',
                    'time': timestamp,
                    'confidence': min(80, int(55 + motion_score * 0.5)),
                    'duration_seconds': self.eye_contact_duration_seconds
                })
            else:
                if self.eye_contact_start_time is not None and self.last_response_time is not None:
                    # Movement dropped back toward baseline → return to activity
                    if self.return_to_activity_time is None and motion_score < 20:
                        self.return_to_activity_time = timestamp
                        self.return_to_activity_speed_seconds = timestamp - self.last_response_time
                        behaviors.append({
                            'type': 'return_to_activity',
                            'time': timestamp,
                            'confidence': 70,
                            'seconds_after_response': self.return_to_activity_speed_seconds
                        })
                self.eye_contact_start_time = None
            
            # Track last response for return-to-activity (use head_turn or clear response as proxy)
            if motion_score > 35 and self._detect_head_turning(gray, prev_gray, frame_diff):
                self.last_response_time = timestamp
            
        except Exception as e:
            # Return empty list on error
            pass
        
        return behaviors
    
    def get_expanded_summary(self, video_duration_seconds=0):
        """
        Return aggregated expanded behavioral markers for the analyzed video.
        Call after frame loop. video_duration_seconds used for ratios.
        """
        total_frames = max(len(self.emotional_codes_per_frame), 1)
        return {
            'facial_expression': {
                'smile_detected_when_name_called': self.smile_detected_count > 0,
                'smile_detected_count': self.smile_detected_count,
                'emotional_response_coding': {
                    'neutral': self.neutral_expression_count,
                    'positive': self.positive_expression_count,
                    'negative': self.negative_expression_count,
                },
                'dominant_expression': (
                    'positive' if self.positive_expression_count >= self.negative_expression_count and self.positive_expression_count > self.neutral_expression_count
                    else 'negative' if self.negative_expression_count > self.positive_expression_count
                    else 'neutral'
                ),
            },
            'body_language': {
                'full_body_orientation_changes': len(self.body_orientation_changes),
                'hand_arm_movements_detected': self.hand_arm_movement_count,
                'stimming_candidate': self.hand_arm_movement_count > 5,  # heuristic
                'proximity_seeking_count': self.proximity_seeking_count,
            },
            'attention_maintenance': {
                'eye_contact_duration_seconds': round(self.eye_contact_duration_seconds, 2),
                'return_to_activity_speed_seconds': round(self.return_to_activity_speed_seconds, 2) if self.return_to_activity_speed_seconds is not None else None,
                'return_to_activity_detected': self.return_to_activity_time is not None,
            },
        }
    
    def reset(self):
        """Reset tracker for new video"""
        self.previous_frames.clear()
        self.baseline_frame = None
        self.frame_count = 0
        self.eye_contact_start_time = None
        self.eye_contact_duration_seconds = 0.0
        self.last_response_time = None
        self.return_to_activity_time = None
        self.return_to_activity_speed_seconds = None
        self.smile_detected_count = 0
        self.positive_expression_count = 0
        self.neutral_expression_count = 0
        self.negative_expression_count = 0
        self.body_orientation_changes = []
        self.hand_arm_movement_count = 0
        self.proximity_seeking_count = 0
        self.emotional_codes_per_frame = []
    
    def _detect_head_turning(self, current_frame, previous_frame, frame_diff):
        """Detect head turning movement by comparing frames"""
        try:
            # Focus on upper portion where head would be
            height, width = current_frame.shape
            upper_portion = frame_diff[:height//2, :]
            
            # Head turning creates significant change in upper frame
            upper_motion = np.mean(upper_portion)
            
            # Require clear, sustained movement in upper region
            # Increased threshold significantly to reduce false positives
            # Also check that movement is focused (not just overall noise)
            upper_std = np.std(upper_portion)
            
            # Head turning should have focused movement (higher std = more localized change)
            return upper_motion > 30 and upper_std > 10
            
        except Exception:
            return False
    
    def _detect_eye_movement(self, current_frame, previous_frame, frame_diff):
        """Detect eye movement by comparing frames"""
        try:
            # Focus on upper portion (where eyes would be)
            height, width = current_frame.shape
            eye_region = frame_diff[:height//3, :]  # Top third of frame
            
            # Eye movement creates localized changes
            eye_motion = np.mean(eye_region)
            
            # Require clear, significant movement in eye region
            # Increased threshold to reduce false positives from lighting/compression
            # Also check for localized change (not just overall frame change)
            eye_std = np.std(eye_region)
            
            return eye_motion > 28 and eye_std > 8
            
        except Exception:
            return False
    
    def _detect_body_movement(self, frame_diff):
        """Detect body movement by analyzing frame difference"""
        try:
            # Body movement creates changes in lower/central portion
            height, width = frame_diff.shape
            body_region = frame_diff[height//3:, :]  # Lower 2/3 of frame
            
            # Require significant change in body region
            # Increased threshold to reduce false positives
            body_motion = np.mean(body_region)
            body_std = np.std(body_region)
            
            # Body movement should be substantial and focused
            return body_motion > 35 and body_std > 12
            
        except Exception:
            return False
    
    def _detect_facial_expression(self, current_frame, previous_frame, frame_diff):
        """Detect facial expression changes by comparing frames"""
        try:
            # Focus on upper portion where face would be
            height, width = current_frame.shape
            face_region = frame_diff[:height//2, :]
            
            # Facial expression creates subtle but clear changes
            # Increased threshold significantly - facial expressions are subtle
            # and we want to avoid false positives from lighting/compression
            face_motion = np.mean(face_region)
            face_std = np.std(face_region)
            
            # Require noticeable, localized change in face region
            return face_motion > 30 and face_std > 10
            
        except Exception:
            return False
    
    def _detect_smile(self, gray_frame, frame_diff):
        """Smile detection: heuristic via lower-face brightness and curvature (mouth region)"""
        try:
            height, width = gray_frame.shape
            # Mouth region: lower third of face (middle half horizontally)
            mouth_region = gray_frame[int(height * 0.5):int(height * 0.75), width//4:3*width//4]
            mouth_mean = np.mean(mouth_region)
            mouth_std = np.std(mouth_region)
            # Smile often increases brightness and variance in mouth area
            face_upper = gray_frame[:height//2, :]
            face_mean = np.mean(face_upper)
            return mouth_mean > face_mean * 0.95 and mouth_std > 15
        except Exception:
            return False
    
    def _code_emotional_response(self, gray_frame, frame_diff):
        """Emotional response coding: neutral, positive, negative (heuristic from face region)"""
        try:
            height, width = gray_frame.shape
            face_region = gray_frame[:height//2, :]
            mean_val = np.mean(face_region)
            std_val = np.std(face_region)
            # Positive: brighter, more variance (e.g. smile). Negative: darker, tense.
            if std_val > 35 and mean_val > 100:
                return 'positive'
            if mean_val < 80 or (std_val < 15 and mean_val < 90):
                return 'negative'
            return 'neutral'
        except Exception:
            return 'neutral'
    
    def _detect_full_body_orientation_change(self, current_frame, previous_frame, frame_diff):
        """Full-body orientation change: significant change in lower 2/3 of frame"""
        try:
            height, width = frame_diff.shape
            lower_portion = frame_diff[height//3:, :]
            left_half = np.mean(lower_portion[:, :width//2])
            right_half = np.mean(lower_portion[:, width//2:])
            body_motion = np.mean(lower_portion)
            return body_motion > 40 and (abs(left_half - right_half) > 15)
        except Exception:
            return False
    
    def _detect_hand_arm_movement(self, frame_diff):
        """Hand/arm movement: lateral regions (sides of frame) - stimming candidate if repetitive"""
        try:
            height, width = frame_diff.shape
            left_region = frame_diff[:, :width//4]
            right_region = frame_diff[:, 3*width//4:]
            left_motion = np.mean(left_region)
            right_motion = np.mean(right_region)
            return left_motion > 25 or right_motion > 25
        except Exception:
            return False
    
    def _detect_proximity_seeking(self, current_frame, previous_frame, frame_diff):
        """Proximity-seeking: movement toward center (parent/camera) - center region activation"""
        try:
            height, width = frame_diff.shape
            center_region = frame_diff[:, width//4:3*width//4]
            center_motion = np.mean(center_region)
            edge_motion = (np.mean(frame_diff[:, :width//4]) + np.mean(frame_diff[:, 3*width//4:])) / 2
            return center_motion > 30 and center_motion > edge_motion * 1.1
        except Exception:
            return False