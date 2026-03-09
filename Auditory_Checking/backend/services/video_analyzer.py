"""
Video Analyzer Service
Analyzes video files to detect RTN (Response to Name) and behavioral patterns
Now includes audio detection for name calling and child vocalizations
"""
import cv2
import numpy as np
from datetime import datetime
from .rtn_calculator import RTNCalculator
from .behavior_tracker import BehaviorTracker
from .autism_predictor import AutismPredictor
from .audio_detector import AudioDetector


class VideoAnalyzer:
    """Analyzes video for RTN detection and behavioral analysis"""
    
    def __init__(self):
        self.rtn_calculator = RTNCalculator()
        self.behavior_tracker = BehaviorTracker()
        self.autism_predictor = AutismPredictor()
        self.audio_detector = AudioDetector()
    
    def analyze(self, video_path, child_name, analysis_type='full'):
        """
        Analyze video file
        
        Args:
            video_path: Path to video file
            child_name: Name of the child
            analysis_type: Type of analysis ('full', 'quick', etc.)
        
        Returns:
            dict: Analysis results with RTN status, reaction time, behaviors, etc.
        """
        try:
            # Reset calculators for new video
            self.rtn_calculator.reset()
            self.behavior_tracker.reset()
            
            # Open video file
            cap = cv2.VideoCapture(video_path)
            
            if not cap.isOpened():
                return {
                    'error': 'Failed to open video',
                    'RTN_Status': 'noResponse',
                    'Reaction_Time': 0.0,
                    'Confidence_Score': 0,
                    'Detected_Behaviors': []
                }
            
            # Get video properties
            fps = cap.get(cv2.CAP_PROP_FPS)
            total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            duration = total_frames / fps if fps > 0 else 0
            
            # Analyze frames
            frame_count = 0
            behaviors = []
            reaction_time = 0.0
            rtn_status = 'noResponse'
            rtn_confidence = 0
            
            # Sample frames for analysis (every Nth frame to speed up)
            sample_rate = max(1, int(fps / 2))  # Sample 2 frames per second
            
            # Track all RTN responses for better accuracy
            all_responses = []
            
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                
                current_time = frame_count / fps
                
                if frame_count % sample_rate == 0:
                    # Analyze frame for behaviors
                    frame_behaviors = self.behavior_tracker.detect_behaviors(frame, current_time)
                    behaviors.extend(frame_behaviors)
                    
                    # Check for RTN response (check every sampled frame, not just first)
                    response = self.rtn_calculator.check_response(frame, current_time)
                    
                    # Store response data
                    if response['detected']:
                        all_responses.append({
                            'time': response['time'],
                            'status': response['status'],
                            'confidence': response.get('confidence', 0),
                            'timestamp': current_time
                        })
                    
                    # Only set reaction_time if we haven't found one yet (first valid response)
                    if reaction_time == 0.0 and response['detected']:
                        reaction_time = response['time']
                        rtn_status = response['status']
                        rtn_confidence = response.get('confidence', 0)
                
                frame_count += 1
            
            cap.release()
            
            # If no response detected in first pass, check collected responses
            if reaction_time == 0.0 and len(all_responses) > 0:
                # Use the first detected response (with highest confidence if available)
                best_response = max(all_responses, key=lambda x: x.get('confidence', 0))
                reaction_time = best_response['time']
                rtn_status = best_response['status']
                rtn_confidence = best_response.get('confidence', 0)
            elif reaction_time == 0.0:
                # No responses detected at all
                rtn_status = 'noResponse'
            
            # Calculate confidence score
            confidence = self._calculate_confidence(behaviors, reaction_time, duration, rtn_confidence)
            
            # Format behaviors
            unique_behaviors = self._format_behaviors(behaviors)
            
            # Expanded behavioral markers (facial expression, body language, attention maintenance)
            expanded_summary = self.behavior_tracker.get_expanded_summary(duration)
            
            # Analyze audio from video
            audio_analysis = None
            try:
                audio_analysis = self.audio_detector.analyze_audio(video_path, child_name)
            except Exception as e:
                print(f"Error analyzing audio: {e}")
                audio_analysis = {
                    'audio_detected': False,
                    'error': str(e)
                }
            
            # Get ML model prediction (if available)
            autism_prediction = None
            if self.autism_predictor.is_model_available():
                try:
                    autism_prediction = self.autism_predictor.predict(video_path)
                except Exception as e:
                    print(f"Error getting ML prediction: {e}")
            
            # Reaction_Time: prefer time from name call to response when audio is good.
            # If no reliable name call is detected but we still detected a visual response,
            # fall back to using the response timestamp in the video so the UI can show a value.
            name_calls = audio_analysis.get('name_calls', []) if audio_analysis else []
            if name_calls and reaction_time > 0:
                first_name_call = name_calls[0]
                name_call_time = first_name_call['start_time']
                response_time_from_call = reaction_time - name_call_time
                # Clamp to sensible range (0.1s–30s); use 0 if negative or unreasonably long
                actual_reaction_time = round(
                    max(0.0, min(30.0, response_time_from_call)) if response_time_from_call > 0 else 0.0, 2
                )
            else:
                # Fallback: if we saw a response but no clean name call in audio,
                # use the response timestamp in the video (0–60s) so we don't show "Not detected".
                if reaction_time > 0:
                    actual_reaction_time = round(min(60.0, reaction_time), 2)
                else:
                    actual_reaction_time = 0.0

            result = {
                'RTN_Status': rtn_status,
                'Reaction_Time': actual_reaction_time,
                'Confidence_Score': confidence,
                'Detected_Behaviors': unique_behaviors,
                'Video_Duration': round(duration, 2),
                'Analysis_Type': analysis_type,
                'Child_Name': child_name,
                'Timestamp': datetime.now().isoformat(),
                'Expanded_Behavioral_Markers': expanded_summary,
            }
            if not name_calls and reaction_time > 0:
                result['Response_At_Seconds'] = round(reaction_time, 2)  # when in video response was detected

            # Add audio analysis results
            if audio_analysis:
                result['Audio_Analysis'] = {
                    'audio_detected': audio_analysis.get('audio_detected', False),
                    'name_calls_detected': len(audio_analysis.get('name_calls', [])),
                    'name_calls': audio_analysis.get('name_calls', []),
                    'child_vocalizations_detected': len(audio_analysis.get('child_vocalizations', [])),
                    'child_vocalizations': audio_analysis.get('child_vocalizations', []),
                    'sound_events_detected': len(audio_analysis.get('sound_events', [])),
                    'audio_duration': audio_analysis.get('audio_duration', 0.0),
                    'error': audio_analysis.get('error'),
                    # Expanded vocalization markers
                    'child_verbally_responded': audio_analysis.get('child_verbally_responded', False),
                    'verbal_responses': audio_analysis.get('verbal_responses', []),
                    'babbling_or_sound_as_response': audio_analysis.get('babbling_or_sound_as_response', []),
                    'echolalia_patterns': audio_analysis.get('echolalia_patterns', {}),
                }
                if name_calls and reaction_time > 0:
                    result['Response_Time_From_Name_Call'] = round(response_time_from_call, 2)
            
            # Add ML prediction if available
            if autism_prediction and autism_prediction.get('model_available'):
                result['ML_Prediction'] = {
                    'prediction': autism_prediction.get('prediction', 'unknown'),
                    'autism_probability': round(autism_prediction.get('autism_probability', 0.5), 3),
                    'typical_probability': round(autism_prediction.get('typical_probability', 0.5), 3),
                    'confidence': round(autism_prediction.get('confidence', 0.0), 3)
                }
            
            return result
            
        except Exception as e:
            # Return default response on error
            return {
                'error': str(e),
                'RTN_Status': 'noResponse',
                'Reaction_Time': 0.0,
                'Confidence_Score': 0,
                'Detected_Behaviors': []
            }
    
    def _calculate_confidence(self, behaviors, reaction_time, duration, rtn_confidence=0):
        """
        Calculate confidence score based on detected behaviors and reaction time
        
        Note: High confidence means the system is confident in its analysis,
        NOT that the child responded well. Delayed/no response can still have
        high confidence if the system is sure about detecting autism indicators.
        """
        # Start with RTN confidence (from improved calculator)
        confidence = rtn_confidence * 0.6  # 60% weight on RTN detection confidence
        
        # Behavior detection score (30% weight)
        if behaviors:
            behavior_score = min(30, len(behaviors) * 5)
            confidence += behavior_score
        
        # Reaction time score (10% weight - faster = higher confidence for responses)
        if reaction_time > 0:
            if reaction_time < 1.0:
                time_score = 10
            elif reaction_time < 3.0:
                time_score = 7
            else:
                time_score = 4
            confidence += time_score
        
        # Duration score (longer videos = more reliable, but less weight)
        if duration > 0:
            duration_score = min(5, duration / 10)
            confidence += duration_score
        
        # Adjust confidence for delayed/no response cases
        # This better reflects uncertainty in autism diagnosis
        if reaction_time == 0.0:
            # No response: Lower confidence to reflect diagnostic uncertainty
            # Even if system is sure there was no response, diagnosis confidence should be moderate
            confidence = max(30, min(60, confidence * 0.75))  # Reduce by 25%, cap at 30-60
        elif reaction_time > 3.0:
            # Delayed response (>3s): Moderate confidence
            # Delayed response is autism indicator, but we should show some uncertainty
            confidence = max(50, min(75, confidence * 0.85))  # Reduce by 15%, cap at 50-75
        # For immediate responses (<1s) or moderate delays (1-3s), keep confidence as calculated
        
        return min(100, int(confidence))
    
    def _format_behaviors(self, behaviors):
        """Format and deduplicate behaviors"""
        if not behaviors:
            return []
        
        # Group by type and get unique behaviors
        behavior_dict = {}
        for behavior in behaviors:
            b_type = behavior.get('type', 'unknown')
            if b_type not in behavior_dict:
                behavior_dict[b_type] = {
                    'type': b_type,
                    'count': 0,
                    'first_detected': behavior.get('time', 0),
                    'confidence': behavior.get('confidence', 0)
                }
            behavior_dict[b_type]['count'] += 1
        
        return list(behavior_dict.values())
