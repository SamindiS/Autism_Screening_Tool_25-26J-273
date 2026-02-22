"""
Gaze Pattern Analyzer for Autism Screening
==========================================

This module analyzes gaze patterns from children's eye tracking data
to identify potential markers associated with Autism Spectrum Disorder (ASD).

Clinical Features Analyzed:
---------------------------
1. FIXATION PATTERNS
   - Fixation duration (ASD: often longer or shorter than typical)
   - Fixation count (ASD: may show reduced exploration)
   - Fixation stability (ASD: may show more variability)

2. SACCADE PATTERNS
   - Saccade frequency (rapid eye movements between fixations)
   - Saccade amplitude (distance of eye jumps)
   - Saccade velocity (speed of eye movements)

3. ATTENTION PATTERNS
   - Time on target vs off target
   - Response latency to new stimuli
   - Attention switching frequency
   - Perseveration (getting "stuck" on areas)

4. SMOOTH PURSUIT
   - Ability to follow moving objects smoothly
   - Catch-up saccades (corrections when falling behind)

References:
- Klin et al. (2002) - Visual fixation patterns in autism
- Jones & Klin (2013) - Attention to eyes in autism
- Falck-Ytter et al. (2013) - Gaze patterns in autism
"""

import numpy as np
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
import json
import pickle
from pathlib import Path
import joblib

# Try to load trained ML classifier
ML_CLASSIFIER = None
ML_SCALER = None
ML_MODEL_TYPE = None  # 'synthetic' or 'real_data'

def _load_ml_classifier():
    """Load trained autism screening classifier if available.
    Prefers real-data model over synthetic model.
    """
    global ML_CLASSIFIER, ML_SCALER, ML_MODEL_TYPE
    
    # First try the real-data model (trained on actual toddler ASD data)
    models_dir = Path(__file__).parent / 'models'
    real_classifier_path = models_dir / 'autism_classifier_real_data.pkl'
    real_scaler_path = models_dir / 'scaler_real_data.pkl'
    
    if real_classifier_path.exists() and real_scaler_path.exists():
        try:
            ML_CLASSIFIER = joblib.load(real_classifier_path)
            ML_SCALER = joblib.load(real_scaler_path)
            ML_MODEL_TYPE = 'real_data'
            print("✅ Loaded REAL DATA model (trained on Toddler ASD dataset)")
            return True
        except Exception as e:
            print(f"Warning: Could not load real-data model: {e}")
    
    # Fallback to synthetic model
    classifier_path = Path(__file__).parent / 'autism_classifier.pkl'
    scaler_path = Path(__file__).parent / 'autism_classifier_scaler.pkl'
    
    if classifier_path.exists() and scaler_path.exists():
        try:
            with open(classifier_path, 'rb') as f:
                ML_CLASSIFIER = pickle.load(f)
            with open(scaler_path, 'rb') as f:
                ML_SCALER = pickle.load(f)
            ML_MODEL_TYPE = 'synthetic'
            print("⚠️ Loaded SYNTHETIC model (fallback)")
            return True
        except Exception as e:
            print(f"Warning: Could not load ML classifier: {e}")
    
    print("❌ No ML model available - using rule-based analysis only")
    return False

# Attempt to load on module import
_load_ml_classifier()


@dataclass
class FixationData:
    """Represents a single fixation (stable gaze period)"""
    x: float  # Normalized x position (0-1)
    y: float  # Normalized y position (0-1)
    start_time: float  # Start timestamp
    duration: float  # Duration in seconds
    events_count: int  # Number of raw events in this fixation


@dataclass 
class SaccadeData:
    """Represents a saccade (rapid eye movement)"""
    start_x: float
    start_y: float
    end_x: float
    end_y: float
    amplitude: float  # Distance traveled
    duration: float
    velocity: float  # Amplitude / duration


@dataclass
class GazeMetrics:
    """Comprehensive gaze analysis metrics"""
    # Basic statistics
    total_duration: float
    total_events: int
    valid_events: int
    
    # Fixation metrics
    fixation_count: int
    mean_fixation_duration: float
    std_fixation_duration: float
    total_fixation_time: float
    fixation_rate: float  # Fixations per second
    
    # Saccade metrics
    saccade_count: int
    mean_saccade_amplitude: float
    mean_saccade_velocity: float
    saccade_rate: float  # Saccades per second
    
    # Attention metrics
    time_on_target: float  # Percentage
    time_in_center: float  # Percentage in center region
    time_in_periphery: float  # Percentage in edges
    attention_switches: int  # Transitions between regions
    
    # Spatial distribution
    gaze_dispersion: float  # How spread out gaze is
    preferred_region: str  # Where child looks most
    
    # Pursuit metrics (for moving targets)
    smooth_pursuit_ratio: float  # Smooth vs saccadic following
    lag_behind_target: float  # Average lag in following


class GazePatternAnalyzer:
    """
    Analyzes gaze patterns to compute clinical metrics for autism screening.
    """
    
    # Thresholds based on research literature
    FIXATION_VELOCITY_THRESHOLD = 0.05  # Max velocity (norm units/sec) for fixation
    FIXATION_MIN_DURATION = 0.1  # Minimum fixation duration (100ms)
    SACCADE_MIN_AMPLITUDE = 0.03  # Minimum distance for saccade
    
    # Screen regions
    CENTER_REGION = (0.25, 0.75, 0.25, 0.75)  # (x_min, x_max, y_min, y_max)
    
    def __init__(self):
        self.raw_events: List[Dict] = []
        self.fixations: List[FixationData] = []
        self.saccades: List[SaccadeData] = []
        
    def analyze(self, events: List[Dict]) -> Dict:
        """
        Main analysis function. Takes raw gaze events and returns
        comprehensive metrics and autism screening scores.
        
        Args:
            events: List of gaze event dicts with keys:
                    - x, y: normalized coordinates (0-1)
                    - timestamp: time in seconds
                    - target_x, target_y: where stimulus was (optional)
                    - game: which game/task ("butterfly", "bubbles")
        
        Returns:
            Dict with metrics, scores, and clinical interpretation
        """
        if not events:
            return self._empty_result()
        
        self.raw_events = events
        
        # Step 1: Extract fixations and saccades
        self._identify_fixations_and_saccades()
        
        # Step 2: Compute metrics
        metrics = self._compute_metrics()
        
        # Step 3: Compute autism screening scores
        scores = self._compute_autism_scores(metrics)
        
        # Step 4: Generate clinical interpretation
        interpretation = self._interpret_results(metrics, scores)
        
        # Step 5: Annotate events with analysis
        annotated_events = self._annotate_events()
        
        return {
            'metrics': metrics.__dict__,
            'scores': scores,
            'interpretation': interpretation,
            'events': annotated_events,
            'score': scores['overall_score'],  # Main score for compatibility
        }
    
    def _empty_result(self) -> Dict:
        """Return empty result when no events"""
        return {
            'metrics': {},
            'scores': {'overall_score': 0.0},
            'interpretation': {'summary': 'Insufficient data for analysis'},
            'events': [],
            'score': 0.0,
        }
    
    def _identify_fixations_and_saccades(self):
        """
        Parse raw events into fixations and saccades using
        velocity-based classification.
        """
        self.fixations = []
        self.saccades = []
        
        if len(self.raw_events) < 2:
            return
        
        # Sort by timestamp
        events = sorted(self.raw_events, key=lambda e: e.get('timestamp', 0))
        
        # Calculate velocities
        velocities = []
        for i in range(1, len(events)):
            prev = events[i-1]
            curr = events[i]
            
            dx = curr.get('x', 0) - prev.get('x', 0)
            dy = curr.get('y', 0) - prev.get('y', 0)
            dt = curr.get('timestamp', 0) - prev.get('timestamp', 0)
            
            if dt > 0:
                velocity = np.sqrt(dx**2 + dy**2) / dt
            else:
                velocity = 0
            velocities.append(velocity)
        
        # Classify events: fixation if velocity below threshold
        is_fixation = [v < self.FIXATION_VELOCITY_THRESHOLD for v in velocities]
        is_fixation.insert(0, is_fixation[0] if is_fixation else True)  # First event
        
        # Group consecutive fixation events
        fixation_start = None
        fixation_events = []
        
        for i, (event, is_fix) in enumerate(zip(events, is_fixation)):
            if is_fix:
                if fixation_start is None:
                    fixation_start = i
                fixation_events.append(event)
            else:
                # End of fixation - save if long enough
                if fixation_events and len(fixation_events) >= 2:
                    duration = (fixation_events[-1].get('timestamp', 0) - 
                               fixation_events[0].get('timestamp', 0))
                    if duration >= self.FIXATION_MIN_DURATION:
                        avg_x = np.mean([e.get('x', 0) for e in fixation_events])
                        avg_y = np.mean([e.get('y', 0) for e in fixation_events])
                        self.fixations.append(FixationData(
                            x=avg_x,
                            y=avg_y,
                            start_time=fixation_events[0].get('timestamp', 0),
                            duration=duration,
                            events_count=len(fixation_events)
                        ))
                
                # Check for saccade
                if fixation_start is not None and i > 0:
                    prev_fix_end = events[fixation_start]
                    curr = event
                    amplitude = np.sqrt(
                        (curr.get('x', 0) - prev_fix_end.get('x', 0))**2 +
                        (curr.get('y', 0) - prev_fix_end.get('y', 0))**2
                    )
                    if amplitude >= self.SACCADE_MIN_AMPLITUDE:
                        dt = curr.get('timestamp', 0) - prev_fix_end.get('timestamp', 0)
                        self.saccades.append(SaccadeData(
                            start_x=prev_fix_end.get('x', 0),
                            start_y=prev_fix_end.get('y', 0),
                            end_x=curr.get('x', 0),
                            end_y=curr.get('y', 0),
                            amplitude=amplitude,
                            duration=dt if dt > 0 else 0.01,
                            velocity=amplitude / dt if dt > 0 else 0
                        ))
                
                fixation_start = None
                fixation_events = []
        
        # Handle last fixation
        if fixation_events and len(fixation_events) >= 2:
            duration = (fixation_events[-1].get('timestamp', 0) - 
                       fixation_events[0].get('timestamp', 0))
            if duration >= self.FIXATION_MIN_DURATION:
                avg_x = np.mean([e.get('x', 0) for e in fixation_events])
                avg_y = np.mean([e.get('y', 0) for e in fixation_events])
                self.fixations.append(FixationData(
                    x=avg_x,
                    y=avg_y,
                    start_time=fixation_events[0].get('timestamp', 0),
                    duration=duration,
                    events_count=len(fixation_events)
                ))
    
    def _compute_metrics(self) -> GazeMetrics:
        """Compute comprehensive gaze metrics"""
        events = self.raw_events
        
        # Basic stats
        timestamps = [e.get('timestamp', 0) for e in events]
        total_duration = max(timestamps) - min(timestamps) if timestamps else 0
        
        # Filter valid events (with proper coordinates)
        valid_events = [e for e in events if 0 <= e.get('x', -1) <= 1 and 0 <= e.get('y', -1) <= 1]
        
        # Fixation metrics
        fix_durations = [f.duration for f in self.fixations]
        
        # Saccade metrics
        saccade_amps = [s.amplitude for s in self.saccades]
        saccade_vels = [s.velocity for s in self.saccades]
        
        # Attention metrics
        on_target_events = [e for e in valid_events if self._is_on_target(e)]
        center_events = [e for e in valid_events if self._is_in_center(e)]
        
        # Count attention switches (center <-> periphery)
        attention_switches = 0
        last_in_center = None
        for e in valid_events:
            in_center = self._is_in_center(e)
            if last_in_center is not None and in_center != last_in_center:
                attention_switches += 1
            last_in_center = in_center
        
        # Gaze dispersion (standard deviation of positions)
        if valid_events:
            xs = [e.get('x', 0.5) for e in valid_events]
            ys = [e.get('y', 0.5) for e in valid_events]
            dispersion = np.sqrt(np.std(xs)**2 + np.std(ys)**2)
        else:
            dispersion = 0
        
        # Preferred region
        region_counts = {'center': 0, 'top': 0, 'bottom': 0, 'left': 0, 'right': 0}
        for e in valid_events:
            x, y = e.get('x', 0.5), e.get('y', 0.5)
            if self._is_in_center(e):
                region_counts['center'] += 1
            elif y < 0.33:
                region_counts['top'] += 1
            elif y > 0.67:
                region_counts['bottom'] += 1
            elif x < 0.33:
                region_counts['left'] += 1
            else:
                region_counts['right'] += 1
        preferred = max(region_counts, key=region_counts.get) if region_counts else 'center'
        
        # Smooth pursuit ratio (for moving targets)
        # More forgiving thresholds for real-world gaze tracking accuracy
        # Filter for events with valid (non-None) target coordinates
        pursuit_events = [
            e for e in valid_events 
            if e.get('target_x') is not None and e.get('target_y') is not None
        ]
        
        if pursuit_events:
            distances = []
            for e in pursuit_events:
                try:
                    x = e.get('x', 0) or 0
                    y = e.get('y', 0) or 0
                    tx = e.get('target_x', 0.5) or 0.5
                    ty = e.get('target_y', 0.5) or 0.5
                    d = np.sqrt((x - tx)**2 + (y - ty)**2)
                    distances.append(d)
                except (TypeError, ValueError):
                    continue
            
            if distances:
                # Multi-tier scoring for smooth pursuit
                # Tight tracking (< 20% distance) - ideal
                tight_tracking = sum(1 for d in distances if d < 0.20)
                # Moderate tracking (< 35% distance) - acceptable
                moderate_tracking = sum(1 for d in distances if d < 0.35)
                # Loose tracking (< 50% distance) - minimal following
                loose_tracking = sum(1 for d in distances if d < 0.50)
                
                # Weighted pursuit score
                smooth_pursuit = (
                    (tight_tracking * 1.0 + 
                     (moderate_tracking - tight_tracking) * 0.7 + 
                     (loose_tracking - moderate_tracking) * 0.4) 
                    / len(distances)
                )
                
                avg_lag = np.mean(distances)
                
                print(f"   Smooth pursuit breakdown: tight={tight_tracking}/{len(distances)}, moderate={moderate_tracking}/{len(distances)}, loose={loose_tracking}/{len(distances)}")
            else:
                smooth_pursuit = 0
                avg_lag = 0
        else:
            smooth_pursuit = 0
            avg_lag = 0
        
        return GazeMetrics(
            total_duration=total_duration,
            total_events=len(events),
            valid_events=len(valid_events),
            
            fixation_count=len(self.fixations),
            mean_fixation_duration=np.mean(fix_durations) if fix_durations else 0,
            std_fixation_duration=np.std(fix_durations) if fix_durations else 0,
            total_fixation_time=sum(fix_durations),
            fixation_rate=len(self.fixations) / total_duration if total_duration > 0 else 0,
            
            saccade_count=len(self.saccades),
            mean_saccade_amplitude=np.mean(saccade_amps) if saccade_amps else 0,
            mean_saccade_velocity=np.mean(saccade_vels) if saccade_vels else 0,
            saccade_rate=len(self.saccades) / total_duration if total_duration > 0 else 0,
            
            time_on_target=100 * len(on_target_events) / len(valid_events) if valid_events else 0,
            time_in_center=100 * len(center_events) / len(valid_events) if valid_events else 0,
            time_in_periphery=100 * (len(valid_events) - len(center_events)) / len(valid_events) if valid_events else 0,
            attention_switches=attention_switches,
            
            gaze_dispersion=dispersion,
            preferred_region=preferred,
            
            smooth_pursuit_ratio=smooth_pursuit * 100,
            lag_behind_target=avg_lag,
        )
    
    def _is_on_target(self, event: Dict) -> bool:
        """Check if gaze is on the target stimulus"""
        # Check if target coordinates exist AND are not None
        tx = event.get('target_x')
        ty = event.get('target_y')
        
        if tx is None or ty is None:
            # If no valid target specified, check if in center
            return self._is_in_center(event)
        
        x = event.get('x', 0) or 0  # Handle None values
        y = event.get('y', 0) or 0
        
        try:
            distance = np.sqrt((x - tx)**2 + (y - ty)**2)
            return distance < 0.35  # Within 35% of screen distance (very forgiving for phone gaze tracking)
        except (TypeError, ValueError):
            return self._is_in_center(event)
    
    def _is_in_center(self, event: Dict) -> bool:
        """Check if gaze is in center region"""
        x = event.get('x', 0.5)
        y = event.get('y', 0.5)
        # Handle None values
        if x is None:
            x = 0.5
        if y is None:
            y = 0.5
        x_min, x_max, y_min, y_max = self.CENTER_REGION
        return x_min <= x <= x_max and y_min <= y <= y_max
    
    def _compute_autism_scores(self, metrics: GazeMetrics) -> Dict:
        """
        Compute autism screening scores based on gaze metrics.
        
        Uses trained ML classifier if available, otherwise falls back to
        rule-based scoring based on research findings.
        
        Returns dict with individual domain scores and overall score.
        """
        scores = {}
        
        # Try ML-based scoring first
        if ML_CLASSIFIER is not None and ML_SCALER is not None:
            try:
                ml_scores = self._compute_ml_scores(metrics)
                scores.update(ml_scores)
                scores['scoring_method'] = 'ml_classifier'
                return scores
            except Exception as e:
                print(f"ML scoring failed, falling back to rule-based: {e}")
        
        # Fallback: Rule-based scoring
        scores['scoring_method'] = 'rule_based'
        
        # 1. ATTENTION SCORE (0-100)
        # Higher score = better attention to targets
        # ASD often shows reduced attention to social stimuli
        attention_score = min(100, metrics.time_on_target * 1.2)
        scores['attention_score'] = round(attention_score, 1)
        
        # 2. FIXATION SCORE (0-100)
        # Typical fixation duration: 200-400ms
        # ASD may show atypical (too short or too long) fixations
        if metrics.mean_fixation_duration > 0:
            # Optimal is around 0.3 seconds
            fix_deviation = abs(metrics.mean_fixation_duration - 0.3)
            fixation_score = max(0, 100 - fix_deviation * 200)
        else:
            fixation_score = 50
        scores['fixation_score'] = round(fixation_score, 1)
        
        # 3. EXPLORATION SCORE (0-100)
        # Measures visual exploration of the screen
        # ASD may show reduced exploration or perseveration
        if metrics.gaze_dispersion > 0:
            # Optimal dispersion around 0.2-0.3
            if metrics.gaze_dispersion < 0.1:
                exploration_score = metrics.gaze_dispersion * 500  # Too focused
            elif metrics.gaze_dispersion > 0.4:
                exploration_score = max(0, 100 - (metrics.gaze_dispersion - 0.4) * 200)  # Too scattered
            else:
                exploration_score = 80 + (0.3 - abs(metrics.gaze_dispersion - 0.25)) * 100
        else:
            exploration_score = 50
        scores['exploration_score'] = round(min(100, exploration_score), 1)
        
        # 4. TRACKING SCORE (0-100)
        # Smooth pursuit ability - following moving objects
        # ASD may show impaired smooth pursuit
        tracking_score = metrics.smooth_pursuit_ratio
        scores['tracking_score'] = round(tracking_score, 1)
        
        # 5. FLEXIBILITY SCORE (0-100)
        # Ability to shift attention appropriately
        # ASD may show reduced flexibility (perseveration)
        if metrics.total_duration > 0:
            # Expected ~2-4 attention switches per 10 seconds
            expected_switches = (metrics.total_duration / 10) * 3
            if expected_switches > 0:
                switch_ratio = metrics.attention_switches / expected_switches
                flexibility_score = min(100, switch_ratio * 80)
            else:
                flexibility_score = 50
        else:
            flexibility_score = 50
        scores['flexibility_score'] = round(flexibility_score, 1)
        
        # 6. OVERALL SCORE (weighted average)
        weights = {
            'attention_score': 0.30,
            'fixation_score': 0.15,
            'exploration_score': 0.20,
            'tracking_score': 0.25,
            'flexibility_score': 0.10,
        }
        
        overall = sum(scores[k] * weights[k] for k in weights)
        
        # DATA QUALITY CHECK - adjust scores if gaze data quality is poor
        # Poor gaze tracking shouldn't result in "High Risk" autism classification
        data_quality_issues = []
        
        # Check if gaze is stuck near center (calibration issue)
        if metrics.gaze_dispersion < 0.05:
            data_quality_issues.append('very_low_dispersion')
        
        # Check if there's almost no tracking data
        if metrics.smooth_pursuit_ratio == 0 and metrics.total_duration > 5:
            data_quality_issues.append('no_pursuit_data')
        
        # Check for insufficient events
        if metrics.total_events < 50:
            data_quality_issues.append('insufficient_events')
        
        # Check if there are few/no fixations detected
        if metrics.fixation_count < 3 and metrics.total_duration > 10:
            data_quality_issues.append('few_fixations')
        
        if data_quality_issues:
            scores['data_quality_warning'] = True
            scores['data_quality_issues'] = data_quality_issues
            # Don't classify as high risk when data quality is questionable
            # Instead, bump up the minimum overall score
            overall = max(overall, 50)  # At least "moderate" when data is poor
            print(f"⚠️ Data quality issues detected: {data_quality_issues}")
            print(f"   Adjusted overall score from potential low value to minimum 50")
        
        scores['overall_score'] = round(overall, 1)
        
        # Risk category
        if overall >= 80:
            scores['risk_category'] = 'Low Risk'
        elif overall >= 60:
            scores['risk_category'] = 'Moderate - Further Evaluation Recommended'
        elif overall >= 40:
            scores['risk_category'] = 'Elevated Risk - Professional Consultation Advised'
        else:
            scores['risk_category'] = 'High Risk - Immediate Professional Evaluation Recommended'
        
        # Add note about data quality if issues detected
        if data_quality_issues:
            scores['risk_category'] += ' (Note: Data quality issues detected - retest recommended)'
        
        return scores
    
    def _compute_ml_scores(self, metrics: GazeMetrics) -> Dict:
        """Compute scores using trained ML classifier"""
        
        # ==================================================================
        # DATA QUALITY CHECK - Critical for preventing false positives!
        # ==================================================================
        data_quality_issues = []
        
        print(f"\n📊 ML Scoring - Input metrics:")
        print(f"   total_events: {metrics.total_events}")
        print(f"   total_duration: {metrics.total_duration:.1f}s")
        print(f"   gaze_dispersion: {metrics.gaze_dispersion:.3f}")
        print(f"   smooth_pursuit_ratio: {metrics.smooth_pursuit_ratio:.1f}%")
        print(f"   fixation_count: {metrics.fixation_count}")
        print(f"   time_on_target: {metrics.time_on_target:.1f}%")
        
        # Check for insufficient data
        if metrics.total_events < 30:
            data_quality_issues.append('insufficient_events')
            print(f"⚠️ ML Scoring: Only {metrics.total_events} events (need 30+)")
        
        # Check for very short session
        if metrics.total_duration < 5:
            data_quality_issues.append('session_too_short')
            print(f"⚠️ ML Scoring: Session only {metrics.total_duration:.1f}s (need 5s+)")
        
        # Check for stuck/no-movement gaze (calibration issue)
        if metrics.gaze_dispersion < 0.05:
            data_quality_issues.append('gaze_stuck')
            print(f"⚠️ ML Scoring: Gaze dispersion {metrics.gaze_dispersion:.3f} (too low, likely stuck)")
        
        # Check for very low smooth pursuit (likely gaze tracking calibration issue)
        # Even ASD typically has 30-50% pursuit ratio, if it's < 15%, tracking is broken
        if metrics.smooth_pursuit_ratio < 15 and metrics.total_duration > 5:
            data_quality_issues.append('poor_gaze_calibration')
            print(f"⚠️ ML Scoring: Smooth pursuit only {metrics.smooth_pursuit_ratio:.1f}% - likely calibration issue")
        
        # Check for no fixations
        if metrics.fixation_count < 3 and metrics.total_duration > 5:
            data_quality_issues.append('no_fixations')
            print(f"⚠️ ML Scoring: Only {metrics.fixation_count} fixations detected")
        
        # Check for very low time on target with decent pursuit - indicates calibration offset
        # This is common with phone-based gaze tracking - gaze follows but with offset
        if metrics.time_on_target < 10 and metrics.smooth_pursuit_ratio > 30:
            data_quality_issues.append('gaze_offset_likely')
            print(f"⚠️ ML Scoring: Low on-target ({metrics.time_on_target:.1f}%) but decent pursuit ({metrics.smooth_pursuit_ratio:.1f}%) - likely calibration offset")
        
        # If data quality is poor, return safe default scores
        if data_quality_issues:
            print(f"❌ ML Scoring ABORTED due to data quality issues: {data_quality_issues}")
            print("   Returning 'Inconclusive' result to avoid false positive")
        
        # If data quality is poor, return safe default scores
        if data_quality_issues:
            print(f"❌ ML Scoring ABORTED due to data quality issues: {data_quality_issues}")
            print("   Returning 'Inconclusive' result to avoid false positive")
            
            return {
                'overall_score': 50.0,  # Neutral score
                'attention_score': 50.0,
                'fixation_score': 50.0,
                'exploration_score': 50.0,
                'tracking_score': 50.0,
                'flexibility_score': 50.0,
                'risk_probability': 0.0,  # Don't show risk when data is bad
                'confidence': 0.0,
                'risk_category': 'Inconclusive - Data Quality Issues (Please Retest)',
                'data_quality_warning': True,
                'data_quality_issues': data_quality_issues,
                'scoring_method': 'ml_classifier_aborted',
            }
        
        # ==================================================================
        # ML PREDICTION - Only if data quality is good
        # ==================================================================
        
        # Feature extraction depends on which model is loaded
        if ML_MODEL_TYPE == 'real_data':
            # Real-data model trained on toddler ASD dataset
            # Map our app's metrics to the dataset features
            # The model expects features like: FD_F, FD_O, freq, DS, trans, etc.
            
            # Convert our metrics to match dataset structure
            # Age in months (estimate child's age, default to 30 months)
            age_months = 30  # Default age for toddler screening
            
            # Fixation Duration features (normalized to dataset scale ~0-100)
            fd_face = metrics.time_in_center * 1.0  # Center = social/face area
            fd_object = metrics.time_in_periphery * 1.0  # Periphery = objects
            fd_target = metrics.time_on_target * 1.0  # Target tracking
            
            # Frequency features (gaze shifts per second * 10 to match dataset scale)
            freq = metrics.saccade_rate * 10
            freq_norm = min(freq / 5.0, 1.0)  # Normalized 0-1
            
            # Dwell time / scan path
            ds = metrics.mean_fixation_duration * 100  # Convert to dataset scale
            ds_norm = min(ds / 50.0, 1.0)  # Normalized
            
            # Transition features (attention switches normalized)
            trans_face = metrics.attention_switches * 0.5
            trans_obj = metrics.attention_switches * 0.3
            
            # Joint attention response (transitions to face)
            joint_attention = (trans_face * 0.5 + trans_face * 0.4) / 2  # Average of transOF and transTOF
            
            # Build feature vector matching the real-data model's expected input
            # 31 features to match training (26 base + 5 derived)
            features = np.array([
                # Age
                age_months,
                # RJA features (Responding to Joint Attention)
                trans_face * 0.8,  # TransFTO_RJA
                trans_obj * 0.6,   # transFO_RJA
                freq,              # freq_RJA
                freq_norm,         # freq_norm_RJA
                ds,                # DS_RJA
                ds_norm,           # DS_norm_RJA
                fd_face,           # FD_F_RJA
                fd_target,         # FD_TO_RJA
                fd_object,         # FD_O_RJA
                # IJA1 features (Initiating Joint Attention 1)
                trans_face * 0.5,  # transTOF_IJA1
                trans_face * 0.4,  # transOF_IJA1
                trans_face * 0.6,  # transFTO_IJA1
                trans_obj * 0.3,   # transFO_IJA1
                trans_obj * 0.2,   # transTOO_IJA1
                freq * 0.9,        # freq_IJA1
                freq_norm * 0.9,   # freq_norm_IJA1
                ds * 0.95,         # DS_IJA1
                ds_norm * 0.95,    # DS_norm_IJA1
                fd_face * 0.9,     # FD_F_IJA1
                fd_target * 0.85,  # FD_TO_IJA1
                fd_object * 1.1,   # FD_O_IJA1
                # IJA2 features
                trans_face * 0.3,  # transTOF_IJA2
                trans_face * 0.4,  # transFTO_IJA2
                fd_face * 0.8,     # FD_F_IJA2
                fd_target * 0.7,   # FD_TO_IJA2
                # Derived features (5 total)
                fd_face / max(fd_face + fd_object, 0.001),  # face_object_ratio
                (fd_face + fd_face * 0.9 + fd_face * 0.8) / 3,  # social_attention_index
                metrics.std_fixation_duration * 10,  # gaze_shift_variability
                (fd_target + fd_target * 0.85 + fd_target * 0.7) / 3,  # target_tracking
                joint_attention,  # joint_attention_response
            ]).reshape(1, -1)
            
            print(f"\n📊 ML Scoring (Real Data Model) - Mapped features:")
            print(f"   Age: {age_months} months")
            print(f"   Face fixation (FD_F): {fd_face:.1f}")
            print(f"   Object fixation (FD_O): {fd_object:.1f}")
            print(f"   Target fixation (FD_TO): {fd_target:.1f}")
            print(f"   Gaze shift frequency: {freq:.2f}")
            print(f"   Model type: REAL DATA (Toddler ASD)")
            
        else:
            # Synthetic model - use original features
            features = np.array([
                metrics.fixation_count,
                metrics.mean_fixation_duration,
                metrics.std_fixation_duration,
                metrics.fixation_rate,
                metrics.saccade_count,
                metrics.mean_saccade_amplitude,
                metrics.mean_saccade_velocity,
                metrics.saccade_rate,
                metrics.time_on_target,
                metrics.time_in_center,
                metrics.time_in_periphery,
                metrics.attention_switches,
                metrics.gaze_dispersion,
                metrics.smooth_pursuit_ratio,
                metrics.lag_behind_target,
                metrics.total_duration,
                metrics.total_events,
            ]).reshape(1, -1)
            
            print(f"\n📊 ML Scoring (Synthetic Model) - Input features:")
            print(f"   fixation_count: {metrics.fixation_count}")
            print(f"   mean_fixation_duration: {metrics.mean_fixation_duration:.3f}")
            print(f"   smooth_pursuit_ratio: {metrics.smooth_pursuit_ratio:.1f}")
            print(f"   time_on_target: {metrics.time_on_target:.1f}%")
            print(f"   gaze_dispersion: {metrics.gaze_dispersion:.3f}")
            print(f"   total_events: {metrics.total_events}")
            print(f"   Model type: SYNTHETIC")
        
        # Scale features
        features_scaled = ML_SCALER.transform(features)
        
        # Get prediction probabilities
        prob = ML_CLASSIFIER.predict_proba(features_scaled)[0]
        asd_prob = prob[1]  # Probability of ASD indicators
        
        print(f"\n🤖 ML Prediction:")
        print(f"   Typical probability: {prob[0]:.3f}")
        print(f"   ASD probability: {prob[1]:.3f}")
        
        # Convert to scores
        scores = {}
        
        # Overall score inversely related to ASD probability
        # High ASD probability = Lower score
        overall = 100 * (1 - asd_prob)
        scores['overall_score'] = round(max(0, min(100, overall)), 1)
        
        # Individual domain scores (estimated from overall)
        # These are approximations since ML gives single prediction
        base = scores['overall_score']
        scores['attention_score'] = round(base * (0.9 + 0.2 * (1 - asd_prob)), 1)
        scores['fixation_score'] = round(base * (0.85 + 0.3 * (1 - asd_prob)), 1)
        scores['exploration_score'] = round(base * (0.8 + 0.4 * (1 - asd_prob)), 1)
        scores['tracking_score'] = round(base * (0.9 + 0.2 * (1 - asd_prob)), 1)
        scores['flexibility_score'] = round(base * (0.85 + 0.3 * (1 - asd_prob)), 1)
        
        # Clamp all scores
        for k in ['attention_score', 'fixation_score', 'exploration_score', 
                  'tracking_score', 'flexibility_score']:
            scores[k] = max(0, min(100, scores[k]))
        
        # Risk category
        scores['risk_probability'] = round(asd_prob * 100, 1)
        scores['confidence'] = round(max(prob) * 100, 1)
        
        if asd_prob < 0.25:
            scores['risk_category'] = 'Low Risk'
        elif asd_prob < 0.50:
            scores['risk_category'] = 'Moderate - Further Evaluation Recommended'
        elif asd_prob < 0.75:
            scores['risk_category'] = 'Elevated Risk - Professional Consultation Advised'
        else:
            scores['risk_category'] = 'High Risk - Immediate Professional Evaluation Recommended'
        
        print(f"\n✅ ML Result: {scores['risk_category']} (score: {scores['overall_score']})")
        
        return scores
    
    def _interpret_results(self, metrics: GazeMetrics, scores: Dict) -> Dict:
        """Generate human-readable clinical interpretation"""
        interpretation = {}
        
        # Summary
        interpretation['summary'] = self._generate_summary(scores)
        
        # Domain-specific findings
        findings = []
        
        # Attention findings
        if scores['attention_score'] < 60:
            findings.append("Reduced attention to target stimuli observed. "
                          "Child may benefit from attention-focused interventions.")
        elif scores['attention_score'] >= 80:
            findings.append("Good attention to visual targets demonstrated.")
        
        # Fixation findings
        if metrics.mean_fixation_duration < 0.15:
            findings.append("Fixations appear shorter than typical, suggesting rapid scanning behavior.")
        elif metrics.mean_fixation_duration > 0.5:
            findings.append("Prolonged fixations observed, which may indicate perseverative tendencies.")
        
        # Exploration findings
        if scores['exploration_score'] < 50:
            findings.append("Limited visual exploration of the screen noted. "
                          "May indicate restricted interests or attention patterns.")
        
        # Tracking findings
        if scores['tracking_score'] < 60:
            findings.append("Difficulty with smooth visual tracking of moving objects. "
                          "May benefit from visual-motor coordination activities.")
        
        interpretation['findings'] = findings
        
        # Recommendations
        recommendations = []
        if scores['overall_score'] < 70:
            recommendations.append("Consider comprehensive developmental evaluation by a specialist.")
            recommendations.append("Re-screening in 3-6 months recommended to track developmental progress.")
        if scores['attention_score'] < 60:
            recommendations.append("Attention training activities may be beneficial.")
        if scores['tracking_score'] < 60:
            recommendations.append("Visual tracking exercises recommended.")
        
        interpretation['recommendations'] = recommendations
        
        # Clinical notes
        interpretation['clinical_notes'] = {
            'total_test_duration': f"{metrics.total_duration:.1f} seconds",
            'data_quality': 'Good' if metrics.valid_events > 100 else 'Limited',
            'fixations_detected': metrics.fixation_count,
            'saccades_detected': metrics.saccade_count,
        }
        
        return interpretation
    
    def _generate_summary(self, scores: Dict) -> str:
        """Generate a summary paragraph"""
        overall = scores['overall_score']
        risk = scores['risk_category']
        
        if overall >= 80:
            return (f"Overall gaze pattern score: {overall:.1f}% ({risk}). "
                   "The child demonstrated age-appropriate visual attention patterns "
                   "with good target tracking and visual exploration. "
                   "No significant concerns identified in this screening.")
        elif overall >= 60:
            return (f"Overall gaze pattern score: {overall:.1f}% ({risk}). "
                   "Some atypical gaze patterns were observed. "
                   "While not diagnostic, these findings suggest that additional "
                   "developmental screening may be beneficial.")
        elif overall >= 40:
            return (f"Overall gaze pattern score: {overall:.1f}% ({risk}). "
                   "The gaze patterns observed show notable differences from typical development. "
                   "A comprehensive evaluation by a developmental specialist is recommended "
                   "to further assess these findings.")
        else:
            return (f"Overall gaze pattern score: {overall:.1f}% ({risk}). "
                   "Significant atypical gaze patterns were observed across multiple domains. "
                   "Immediate referral for comprehensive developmental evaluation is strongly recommended.")
    
    def _annotate_events(self) -> List[Dict]:
        """Add analysis annotations to events"""
        annotated = []
        
        for event in self.raw_events:
            e = dict(event)
            e['on_target'] = self._is_on_target(event)
            e['in_center'] = self._is_in_center(event)
            annotated.append(e)
        
        return annotated


# Create singleton analyzer
analyzer = GazePatternAnalyzer()


def analyze_gaze_patterns(events: List[Dict]) -> Dict:
    """
    Main entry point for gaze pattern analysis.
    
    Args:
        events: List of gaze event dictionaries
        
    Returns:
        Complete analysis results including metrics, scores, and interpretation
    """
    # Add detailed logging for debugging
    print("\n" + "=" * 60)
    print("GAZE ANALYSIS DEBUG INFO")
    print("=" * 60)
    print(f"Total events received: {len(events)}")
    
    if events:
        # Log sample of events
        print(f"\nFirst event sample: {events[0]}")
        if len(events) > 1:
            print(f"Last event sample: {events[-1]}")
        
        # Calculate basic stats
        xs = [e.get('x', 0.5) for e in events]
        ys = [e.get('y', 0.5) for e in events]
        has_target = sum(1 for e in events if 'target_x' in e)
        
        print(f"\nGaze X range: {min(xs):.3f} to {max(xs):.3f}")
        print(f"Gaze Y range: {min(ys):.3f} to {max(ys):.3f}")
        print(f"Events with target info: {has_target}/{len(events)}")
        
        # Check for potential issues
        x_range = max(xs) - min(xs)
        y_range = max(ys) - min(ys)
        
        if x_range < 0.1 or y_range < 0.1:
            print("\n⚠️ WARNING: Very limited gaze movement detected!")
            print("   This may indicate calibration issues or the child isn't following targets.")
            print(f"   X movement: {x_range:.3f} (expected > 0.3)")
            print(f"   Y movement: {y_range:.3f} (expected > 0.3)")
        
        # Check for center bias
        center_xs = [x for x in xs if 0.4 <= x <= 0.6]
        center_ys = [y for y in ys if 0.4 <= y <= 0.6]
        center_pct = len(center_xs) / len(xs) * 100 if xs else 0
        
        if center_pct > 80:
            print(f"\n⚠️ WARNING: {center_pct:.1f}% of gaze points are near center!")
            print("   This suggests the gaze tracking may not be working properly.")
    
    result = analyzer.analyze(events)
    
    # Log the computed metrics
    print(f"\nCOMPUTED METRICS:")
    metrics = result.get('metrics', {})
    for key, value in metrics.items():
        if isinstance(value, (int, float)):
            print(f"  {key}: {value:.3f}" if isinstance(value, float) else f"  {key}: {value}")
    
    print(f"\nSCORES:")
    scores = result.get('scores', {})
    for key, value in scores.items():
        print(f"  {key}: {value}")
    
    print("=" * 60 + "\n")
    
    return result


# For testing
if __name__ == '__main__':
    # Generate sample test data
    import random
    
    test_events = []
    t = 0
    for i in range(200):
        # Simulate gaze with some noise
        target_x = 0.3 + 0.4 * np.sin(t * 0.5)
        target_y = 0.3 + 0.4 * np.cos(t * 0.3)
        
        # Gaze follows target with some error
        gaze_x = target_x + random.gauss(0, 0.08)
        gaze_y = target_y + random.gauss(0, 0.08)
        
        test_events.append({
            'timestamp': t,
            'x': max(0, min(1, gaze_x)),
            'y': max(0, min(1, gaze_y)),
            'target_x': target_x,
            'target_y': target_y,
            'game': 'butterfly',
        })
        t += 0.05  # 20 Hz
    
    # Analyze
    result = analyze_gaze_patterns(test_events)
    
    print("=" * 60)
    print("GAZE PATTERN ANALYSIS RESULTS")
    print("=" * 60)
    print(f"\nOverall Score: {result['score']:.1f}%")
    print(f"Risk Category: {result['scores']['risk_category']}")
    print(f"\nDomain Scores:")
    for k, v in result['scores'].items():
        if k not in ['overall_score', 'risk_category']:
            print(f"  {k}: {v}")
    print(f"\nSummary:\n{result['interpretation']['summary']}")
    print(f"\nFindings:")
    for f in result['interpretation']['findings']:
        print(f"  - {f}")
    print(f"\nRecommendations:")
    for r in result['interpretation']['recommendations']:
        print(f"  - {r}")
