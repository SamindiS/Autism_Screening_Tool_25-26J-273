"""
Audio Detector Service
Detects audio patterns including name calling and child vocalizations.

Expanded vocalization markers:
- Verbal response: does child verbally respond? ("What?", "Yes?", etc.)
- Babbling or sound-making as response (after name call)
- Echolalia patterns (repetitive/repeated vocalizations)
"""
import numpy as np
import os
import subprocess
import tempfile
import librosa
import soundfile as sf
from scipy import signal
from typing import Dict, List, Optional, Tuple


class AudioDetector:
    """Detects audio patterns and responses from video files"""
    
    def __init__(self):
        self.sample_rate = 44100
        self.speech_threshold = 0.02  # Threshold for detecting speech/sounds
        self.vocalization_threshold = 0.015  # Threshold for child vocalizations
        self.name_call_duration_range = (0.5, 3.0)  # Expected duration of name call (seconds)
        self.verbal_response_window_after_name_call = 5.0  # seconds to look for verbal response after name call
        self.echolalia_similarity_threshold = 0.7  # similarity for repeated segments (0-1)
        
    def extract_audio_from_video(self, video_path: str) -> Optional[Tuple[np.ndarray, int]]:
        """
        Extract audio track from video file
        
        Args:
            video_path: Path to video file
            
        Returns:
            tuple: (audio_data, sample_rate) or None if extraction fails
        """
        try:
            # Try using librosa directly (works for many video formats)
            try:
                audio_data, sr = librosa.load(video_path, sr=self.sample_rate, mono=True)
                return audio_data, sr
            except Exception:
                # Fallback: Use ffmpeg to extract audio first, then load with librosa
                return self._extract_audio_with_ffmpeg(video_path)
                
        except Exception as e:
            print(f"Error extracting audio: {e}")
            return None
    
    def _extract_audio_with_ffmpeg(self, video_path: str) -> Optional[Tuple[np.ndarray, int]]:
        """Extract audio using ffmpeg as fallback"""
        try:
            # Create temporary audio file
            with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_audio:
                temp_path = temp_audio.name
            
            try:
                # Use ffmpeg to extract audio
                cmd = [
                    'ffmpeg', '-i', video_path,
                    '-vn', '-acodec', 'pcm_s16le',
                    '-ar', str(self.sample_rate),
                    '-ac', '1', '-y', temp_path
                ]
                
                result = subprocess.run(
                    cmd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    timeout=30
                )
                
                if result.returncode == 0 and os.path.exists(temp_path):
                    # Load extracted audio
                    audio_data, sr = librosa.load(temp_path, sr=self.sample_rate, mono=True)
                    return audio_data, sr
                else:
                    print(f"FFmpeg extraction failed: {result.stderr.decode()}")
                    return None
                    
            finally:
                # Clean up temporary file
                if os.path.exists(temp_path):
                    os.unlink(temp_path)
                    
        except FileNotFoundError:
            print("FFmpeg not found. Please install ffmpeg for audio extraction.")
            return None
        except Exception as e:
            print(f"Error in FFmpeg extraction: {e}")
            return None
    
    def detect_sound_events(self, audio_data: np.ndarray, sample_rate: int) -> List[Dict]:
        """
        Detect all sound/speech events in audio
        
        Args:
            audio_data: Audio signal data
            sample_rate: Sample rate of audio
            
        Returns:
            list: List of detected sound events with timestamps
        """
        events = []
        
        try:
            # Calculate envelope (amplitude over time)
            frame_length = 2048
            hop_length = 512
            
            # Use RMS energy for more robust detection
            rms = librosa.feature.rms(y=audio_data, frame_length=frame_length, hop_length=hop_length)[0]
            times = librosa.frames_to_time(np.arange(len(rms)), sr=sample_rate, hop_length=hop_length)
            
            # Detect segments above threshold
            active_segments = rms > self.speech_threshold
            
            if not np.any(active_segments):
                return events
            
            # Find continuous segments
            segments = self._find_continuous_segments(active_segments, times)
            
            for start_time, end_time in segments:
                duration = end_time - start_time
                # Filter very short segments (likely noise) and very long (background noise)
                if 0.1 <= duration <= 10.0:
                    start_idx = int(start_time * sample_rate)
                    end_idx = int(end_time * sample_rate)
                    segment_audio = audio_data[start_idx:end_idx]
                    
                    # Calculate intensity
                    intensity = np.max(np.abs(segment_audio))
                    
                    events.append({
                        'start_time': float(start_time),
                        'end_time': float(end_time),
                        'duration': float(duration),
                        'intensity': float(intensity),
                        'type': 'sound_event'
                    })
            
            return events
            
        except Exception as e:
            print(f"Error detecting sound events: {e}")
            return events
    
    def detect_name_calling(self, audio_data: np.ndarray, sample_rate: int, child_name: str = None) -> List[Dict]:
        """
        Detect when someone calls the child's name
        
        Args:
            audio_data: Audio signal data
            sample_rate: Sample rate of audio
            child_name: Name of the child (for keyword detection, optional)
            
        Returns:
            list: List of detected name call events
        """
        name_calls = []
        
        try:
            # Get all sound events
            sound_events = self.detect_sound_events(audio_data, sample_rate)
            
            for event in sound_events:
                duration = event['duration']
                # Name calling typically lasts 0.5-3 seconds
                if self.name_call_duration_range[0] <= duration <= self.name_call_duration_range[1]:
                    start_time = event['start_time']
                    end_time = event['end_time']
                    start_idx = int(start_time * sample_rate)
                    end_idx = int(end_time * sample_rate)
                    segment_audio = audio_data[start_idx:end_idx]
                    
                    # Analyze audio characteristics of name call
                    # Name calling usually has:
                    # - Clear speech patterns (not just noise)
                    # - Moderate to high intensity
                    # - Speech-like spectral characteristics
                    
                    is_speech_like = self._is_speech_like(segment_audio, sample_rate)
                    intensity = event['intensity']
                    
                    # High confidence if it's speech-like and has good intensity
                    confidence = 0
                    if is_speech_like and intensity > 0.03:
                        confidence = min(90, int(50 + (intensity * 500)))
                    elif is_speech_like:
                        confidence = 60
                    elif intensity > 0.03:
                        confidence = 50
                    
                    if confidence > 40:  # Minimum threshold
                        name_calls.append({
                            'start_time': float(start_time),
                            'end_time': float(end_time),
                            'duration': float(duration),
                            'confidence': confidence,
                            'intensity': float(intensity),
                            'type': 'name_call'
                        })
            
            return name_calls
            
        except Exception as e:
            print(f"Error detecting name calling: {e}")
            return name_calls
    
    def detect_child_vocalizations(self, audio_data: np.ndarray, sample_rate: int) -> List[Dict]:
        """
        Detect child vocalizations (sounds made by the child)
        
        Args:
            audio_data: Audio signal data
            sample_rate: Sample rate of audio
            
        Returns:
            list: List of detected vocalization events
        """
        vocalizations = []
        
        try:
            # Get all sound events
            sound_events = self.detect_sound_events(audio_data, sample_rate)
            
            for event in sound_events:
                start_time = event['start_time']
                end_time = event['end_time']
                duration = event['duration']
                
                # Child vocalizations can be shorter and higher pitched
                # Typical duration: 0.2 to 4 seconds
                if 0.2 <= duration <= 4.0:
                    start_idx = int(start_time * sample_rate)
                    end_idx = int(end_time * sample_rate)
                    segment_audio = audio_data[start_idx:end_idx]
                    
                    # Analyze frequency characteristics
                    # Children's voices are often higher pitched
                    dominant_freq = self._get_dominant_frequency(segment_audio, sample_rate)
                    
                    # Vocalizations typically have:
                    # - Higher pitch (300-3000 Hz for children)
                    # - Clear harmonic structure
                    # - Moderate intensity
                    
                    is_vocalization = False
                    confidence = 0
                    
                    if dominant_freq and 200 <= dominant_freq <= 4000:
                        # Check if it has vocal-like characteristics
                        intensity = event['intensity']
                        has_harmonics = self._has_harmonic_structure(segment_audio, sample_rate)
                        
                        if has_harmonics and intensity > self.vocalization_threshold:
                            is_vocalization = True
                            confidence = min(85, int(50 + (intensity * 400)))
                        elif intensity > self.vocalization_threshold:
                            confidence = 50
                    
                    if is_vocalization or (confidence > 40 and duration < 2.0):
                        vocalizations.append({
                            'start_time': float(start_time),
                            'end_time': float(end_time),
                            'duration': float(duration),
                            'confidence': confidence,
                            'dominant_frequency': float(dominant_freq) if dominant_freq else None,
                            'intensity': float(event['intensity']),
                            'type': 'child_vocalization'
                        })
            
            return vocalizations
            
        except Exception as e:
            print(f"Error detecting child vocalizations: {e}")
            return vocalizations
    
    def analyze_audio(self, video_path: str, child_name: str = None) -> Dict:
        """
        Comprehensive audio analysis of video file
        
        Args:
            video_path: Path to video file
            child_name: Name of the child (optional)
        
        Returns:
            dict: Complete audio analysis results
        """
        result = {
            'audio_detected': False,
            'name_calls': [],
            'child_vocalizations': [],
            'sound_events': [],
            'audio_duration': 0.0,
            'error': None
        }
        
        try:
            # Extract audio from video
            audio_data, sample_rate = self.extract_audio_from_video(video_path)
            
            if audio_data is None or len(audio_data) == 0:
                result['error'] = 'No audio track found in video'
                return result
            
            audio_duration = len(audio_data) / sample_rate
            result['audio_detected'] = True
            result['audio_duration'] = float(audio_duration)
            
            # Detect name calling
            name_calls = self.detect_name_calling(audio_data, sample_rate, child_name)
            result['name_calls'] = name_calls
            
            # Detect child vocalizations
            vocalizations = self.detect_child_vocalizations(audio_data, sample_rate)
            result['child_vocalizations'] = vocalizations
            
            # Get all sound events
            sound_events = self.detect_sound_events(audio_data, sample_rate)
            result['sound_events'] = sound_events
            
            # --- Expanded: Vocalization detection ---
            verbal_responses = self.detect_verbal_responses(audio_data, sample_rate, result['name_calls'])
            result['verbal_responses'] = verbal_responses
            result['child_verbally_responded'] = len(verbal_responses) > 0
            
            babbling_as_response = self.detect_babbling_as_response(
                audio_data, sample_rate,
                result['name_calls'],
                result['child_vocalizations']
            )
            result['babbling_or_sound_as_response'] = babbling_as_response
            
            echolalia_result = self.detect_echolalia_patterns(audio_data, sample_rate, result['child_vocalizations'])
            result['echolalia_patterns'] = echolalia_result
            
            return result
            
        except Exception as e:
            result['error'] = str(e)
            return result
    
    def detect_verbal_responses(
        self,
        audio_data: np.ndarray,
        sample_rate: int,
        name_calls: List[Dict],
    ) -> List[Dict]:
        """
        Detect if child verbally responds after name is called (e.g. "What?", "Yes?").
        Looks for short speech-like segments in a window after each name call.
        """
        verbal = []
        try:
            speech_events = self.detect_sound_events(audio_data, sample_rate)
            for call in name_calls:
                start_after = call['end_time']
                end_before = min(
                    start_after + self.verbal_response_window_after_name_call,
                    len(audio_data) / sample_rate
                )
                for ev in speech_events:
                    if ev['start_time'] < start_after:
                        continue
                    if ev['start_time'] > end_before:
                        break
                    # Short speech-like segment (0.2–2 s) = possible verbal response
                    if 0.2 <= ev['duration'] <= 2.0:
                        start_idx = int(ev['start_time'] * sample_rate)
                        end_idx = int(ev['end_time'] * sample_rate)
                        segment = audio_data[start_idx:end_idx]
                        if self._is_speech_like(segment, sample_rate):
                            verbal.append({
                                'start_time': ev['start_time'],
                                'end_time': ev['end_time'],
                                'duration': ev['duration'],
                                'seconds_after_name_call': round(ev['start_time'] - call['end_time'], 2),
                                'type': 'verbal_response',
                                'confidence': 70,
                            })
            return verbal
        except Exception as e:
            print(f"Error detecting verbal responses: {e}")
            return []
    
    def detect_babbling_as_response(
        self,
        audio_data: np.ndarray,
        sample_rate: int,
        name_calls: List[Dict],
        child_vocalizations: List[Dict],
    ) -> List[Dict]:
        """Babbling or sound-making as response: child vocalizations shortly after name call."""
        babbling = []
        try:
            for call in name_calls:
                start_after = call['end_time']
                end_before = start_after + self.verbal_response_window_after_name_call
                for v in child_vocalizations:
                    if v['start_time'] < start_after or v['start_time'] > end_before:
                        continue
                    babbling.append({
                        **v,
                        'seconds_after_name_call': round(v['start_time'] - call['end_time'], 2),
                        'as_response': True,
                    })
            return babbling
        except Exception as e:
            print(f"Error detecting babbling as response: {e}")
            return []
    
    def detect_echolalia_patterns(
        self,
        audio_data: np.ndarray,
        sample_rate: int,
        child_vocalizations: List[Dict],
    ) -> Dict:
        """
        Echolalia patterns: repeated or similar vocalizations (repetitive speech/sounds).
        Returns summary with detected flag and count of similar pairs.
        """
        result = {'detected': False, 'similar_pair_count': 0, 'segments_compared': 0}
        try:
            if len(child_vocalizations) < 2:
                return result
            similar_count = 0
            for i in range(len(child_vocalizations)):
                for j in range(i + 1, len(child_vocalizations)):
                    v1, v2 = child_vocalizations[i], child_vocalizations[j]
                    s1 = audio_data[
                        int(v1['start_time'] * sample_rate):int(v1['end_time'] * sample_rate)
                    ]
                    s2 = audio_data[
                        int(v2['start_time'] * sample_rate):int(v2['end_time'] * sample_rate)
                    ]
                    if len(s1) < 100 or len(s2) < 100:
                        continue
                    # Resample to same length for comparison
                    min_len = min(len(s1), len(s2))
                    s1 = s1[:min_len]
                    s2 = s2[:min_len]
                    sim = self._segment_similarity(s1, s2)
                    result['segments_compared'] += 1
                    if sim >= self.echolalia_similarity_threshold:
                        similar_count += 1
            result['similar_pair_count'] = similar_count
            result['detected'] = similar_count >= 1
            return result
        except Exception as e:
            print(f"Error detecting echolalia: {e}")
            return result
    
    def _segment_similarity(self, a: np.ndarray, b: np.ndarray) -> float:
        """Correlation-based similarity between two segments (0-1)."""
        try:
            if len(a) != len(b) or len(a) < 10:
                return 0.0
            corr = np.corrcoef(a, b)[0, 1]
            if np.isnan(corr):
                return 0.0
            return float((corr + 1) / 2)  # map [-1,1] to [0,1]
        except Exception:
            return 0.0
    
    def _find_continuous_segments(self, active_mask: np.ndarray, times: np.ndarray) -> List[Tuple[float, float]]:
        """Find continuous segments where mask is True"""
        segments = []
        in_segment = False
        start_time = None
        
        for i, active in enumerate(active_mask):
            if active and not in_segment:
                # Start of segment
                start_time = times[i]
                in_segment = True
            elif not active and in_segment:
                # End of segment
                segments.append((start_time, times[i]))
                in_segment = False
        
        # Handle segment that extends to end
        if in_segment:
            segments.append((start_time, times[-1]))
        
        return segments
    
    def _is_speech_like(self, audio_segment: np.ndarray, sample_rate: int) -> bool:
        """Determine if audio segment sounds like speech"""
        try:
            # Speech typically has:
            # 1. Clear spectral structure (not just noise)
            # 2. Energy concentrated in speech frequency range (300-3400 Hz)
            # 3. Modulated amplitude (not constant)
            
            # Calculate spectral centroid (average frequency weighted by magnitude)
            stft = librosa.stft(audio_segment, hop_length=512)
            magnitude = np.abs(stft)
            frequencies = librosa.fft_frequencies(sr=sample_rate)
            
            # Focus on speech frequency range
            speech_range_mask = (frequencies >= 300) & (frequencies <= 3400)
            if np.any(speech_range_mask):
                speech_energy = np.sum(magnitude[speech_range_mask, :])
                total_energy = np.sum(magnitude)
                speech_ratio = speech_energy / (total_energy + 1e-10)
                
                # Speech-like if >30% energy in speech range
                return speech_ratio > 0.3
            
            return False
            
        except Exception:
            return False
    
    def _get_dominant_frequency(self, audio_segment: np.ndarray, sample_rate: int) -> Optional[float]:
        """Get the dominant frequency in the audio segment"""
        try:
            # Try using librosa.pyin (fundamental frequency detection)
            # This is available in librosa >= 0.9.0
            try:
                fmin = 80  # Minimum frequency (Hz)
                fmax = 4000  # Maximum frequency (Hz)
                
                f0, voiced_flag, voiced_probs = librosa.pyin(
                    audio_segment,
                    fmin=fmin,
                    fmax=fmax,
                    sr=sample_rate
                )
                
                # Get the first valid (non-NaN) fundamental frequency
                valid_f0 = f0[~np.isnan(f0)]
                if len(valid_f0) > 0:
                    # Return median frequency (more robust than mean)
                    return float(np.median(valid_f0))
            except (AttributeError, Exception):
                # Fallback if pyin is not available
                pass
            
            # Fallback: use spectral centroid (average frequency weighted by magnitude)
            stft = librosa.stft(audio_segment, hop_length=512)
            magnitude = np.abs(stft)
            frequencies = librosa.fft_frequencies(sr=sample_rate)
            
            # Calculate centroid for each frame
            centroid_per_frame = np.sum(frequencies[:, np.newaxis] * magnitude, axis=0) / (np.sum(magnitude, axis=0) + 1e-10)
            
            # Return median centroid (more robust than mean)
            if len(centroid_per_frame) > 0:
                return float(np.median(centroid_per_frame))
            
            return None
            
        except Exception:
            return None
    
    def _has_harmonic_structure(self, audio_segment: np.ndarray, sample_rate: int) -> bool:
        """Check if audio has harmonic structure (indicative of voice/sound)"""
        try:
            # Use harmonic-percussive separation
            # Harmonic sounds (like voice) have clear harmonic structure
            y_harmonic, y_percussive = librosa.effects.hpss(audio_segment)
            
            # Calculate energy ratio
            harmonic_energy = np.sum(np.abs(y_harmonic) ** 2)
            total_energy = np.sum(np.abs(audio_segment) ** 2)
            
            if total_energy > 0:
                harmonic_ratio = harmonic_energy / total_energy
                # Voice typically has >40% harmonic content
                return harmonic_ratio > 0.4
            
            return False
            
        except Exception:
            return False
