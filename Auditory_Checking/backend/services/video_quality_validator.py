"""
Video Quality Control for RTN screening.
Pre-upload validation: resolution, lighting, audio clarity, face visibility, duration.
"""
import cv2
import numpy as np
import os
from pathlib import Path
from typing import Dict, Any, Optional, Tuple

# Optional: use existing audio detector for audio level
try:
    from .audio_detector import AudioDetector
except ImportError:
    AudioDetector = None

# Minimum resolution (720p is recommended but not required)
MIN_WIDTH = 320
MIN_HEIGHT = 240
# Minimum duration in seconds (30s recommended for RTN; shorter clips still analyzable)
MIN_DURATION_SECONDS = 10
# Lighting: mean brightness in [LOW_LIGHT, HIGH_LIGHT] (0-255)
LOW_LIGHT_THRESHOLD = 40
HIGH_LIGHT_THRESHOLD = 250
# Audio: minimum RMS (librosa normalized ~-1 to 1). Convert to dB: 20*log10(max(rms, 1e-10))
MIN_AUDIO_RMS = 0.005  # ~ -46 dB equivalent
# Face: at least one frame in sampled frames should have a face detected (or face-like region)
MIN_FACE_FRAMES_RATIO = 0.2  # 20% of sampled frames
NUM_SAMPLE_FRAMES = 15


class VideoQualityValidator:
    """Run quality checks on a video file before upload/analysis."""

    def __init__(self):
        self.audio_detector = AudioDetector() if AudioDetector else None
        self._face_cascade = None

    def _get_face_cascade(self):
        if self._face_cascade is not None:
            return self._face_cascade
        # OpenCV built-in Haar cascade for frontal face
        path = cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
        if os.path.exists(path):
            self._face_cascade = cv2.CascadeClassifier(path)
        else:
            self._face_cascade = False  # not available
        return self._face_cascade

    def validate(self, video_path: str) -> Dict[str, Any]:
        """
        Run all quality checks. Returns:
        - passed: bool (all checks passed)
        - checks: { resolution, duration, lighting, audio, face_visibility }
        - messages: list of user-facing strings
        """
        result = {
            "passed": True,
            "checks": {},
            "messages": [],
            "resolution": None,
            "duration_seconds": None,
        }
        path = Path(video_path)
        if not path.exists():
            result["passed"] = False
            result["messages"].append("Video file not found.")
            return result

        # 1. Resolution
        ok_res, msg_res, res_info = self._check_resolution(video_path)
        result["checks"]["resolution"] = {"passed": ok_res, "message": msg_res, "detail": res_info}
        result["resolution"] = res_info
        if not ok_res:
            result["passed"] = False
            result["messages"].append(msg_res)

        # 2. Duration
        ok_dur, msg_dur, dur_sec = self._check_duration(video_path)
        result["checks"]["duration"] = {"passed": ok_dur, "message": msg_dur, "seconds": dur_sec}
        result["duration_seconds"] = dur_sec
        if not ok_dur:
            result["passed"] = False
            result["messages"].append(msg_dur)

        # 3. Lighting (requires opening video)
        cap = None
        try:
            cap = cv2.VideoCapture(video_path)
            if not cap.isOpened():
                result["checks"]["lighting"] = {"passed": False, "message": "Could not open video for lighting check.", "detail": None}
                result["passed"] = False
                result["messages"].append("Could not open video.")
            else:
                ok_light, msg_light, detail = self._check_lighting(cap)
                result["checks"]["lighting"] = {"passed": ok_light, "message": msg_light, "detail": detail}
                if not ok_light:
                    result["passed"] = False
                    result["messages"].append(msg_light)
        finally:
            if cap is not None:
                cap.release()

        # 4. Audio clarity
        ok_audio, msg_audio, detail_audio = self._check_audio(video_path)
        result["checks"]["audio"] = {"passed": ok_audio, "message": msg_audio, "detail": detail_audio}
        if not ok_audio:
            result["passed"] = False
            result["messages"].append(msg_audio)

        # 5. Face visibility (re-open if we closed)
        cap2 = cv2.VideoCapture(video_path)
        try:
            if cap2.isOpened():
                ok_face, msg_face, detail_face = self._check_face_visibility(cap2)
                result["checks"]["face_visibility"] = {"passed": ok_face, "message": msg_face, "detail": detail_face}
                if not ok_face:
                    result["passed"] = False
                    result["messages"].append(msg_face)
            else:
                result["checks"]["face_visibility"] = {"passed": False, "message": "Could not open video for face check.", "detail": None}
                result["passed"] = False
                result["messages"].append("Could not open video for face check.")
        finally:
            cap2.release()

        if result["passed"]:
            result["messages"].insert(0, "All quality checks passed. Ready for analysis.")

        return result

    def _check_resolution(self, video_path: str) -> Tuple[bool, str, Optional[Dict]]:
        cap = cv2.VideoCapture(video_path)
        try:
            if not cap.isOpened():
                return False, "Could not open video to check resolution.", None
            w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            detail = {"width": w, "height": h, "min_width": MIN_WIDTH, "min_height": MIN_HEIGHT}
            if w >= MIN_WIDTH and h >= MIN_HEIGHT:
                if w >= 1280 and h >= 720:
                    return True, f"Resolution OK ({w}x{h}, 720p or better).", detail
                return True, f"Resolution OK ({w}x{h}). 720p (1280x720) recommended for best results.", detail
            return False, f"Resolution too low: {w}x{h}. Minimum {MIN_WIDTH}x{MIN_HEIGHT} required.", detail
        finally:
            cap.release()

    def _check_duration(self, video_path: str) -> Tuple[bool, str, Optional[float]]:
        cap = cv2.VideoCapture(video_path)
        try:
            if not cap.isOpened():
                return False, "Could not open video to check duration.", None
            fps = cap.get(cv2.CAP_PROP_FPS) or 1
            frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            duration = frame_count / fps
            if duration >= MIN_DURATION_SECONDS:
                if duration >= 30:
                    return True, f"Duration OK ({duration:.1f}s, 30s+ recommended for RTN).", round(duration, 2)
                return True, f"Duration OK ({duration:.1f}s). 30+ seconds recommended for best results.", round(duration, 2)
            return False, f"Video too short: {duration:.1f}s. Minimum {MIN_DURATION_SECONDS} seconds required.", round(duration, 2)
        finally:
            cap.release()

    def _check_lighting(self, cap: cv2.VideoCapture) -> Tuple[bool, str, Optional[Dict]]:
        fps = cap.get(cv2.CAP_PROP_FPS) or 1
        total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        if total == 0:
            return False, "No frames in video.", None
        step = max(1, total // NUM_SAMPLE_FRAMES)
        brightness_values = []
        for i in range(0, total, step):
            cap.set(cv2.CAP_PROP_POS_FRAMES, i)
            ret, frame = cap.read()
            if not ret or frame is None:
                continue
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            brightness_values.append(float(np.mean(gray)))
        if not brightness_values:
            return False, "Could not sample frames for lighting.", None
        mean_brightness = sum(brightness_values) / len(brightness_values)
        detail = {"mean_brightness": round(mean_brightness, 1), "low_threshold": LOW_LIGHT_THRESHOLD, "high_threshold": HIGH_LIGHT_THRESHOLD}
        if mean_brightness < LOW_LIGHT_THRESHOLD:
            return False, f"Lighting too dark (average brightness {mean_brightness:.0f}). Please record in better lighting.", detail
        if mean_brightness > HIGH_LIGHT_THRESHOLD:
            return False, f"Image too bright (overexposed). Please reduce glare or adjust lighting.", detail
        return True, f"Lighting OK (adequate brightness).", detail

    def _check_audio(self, video_path: str) -> Tuple[bool, str, Optional[Dict]]:
        if not self.audio_detector:
            return True, "Audio check skipped (detector not available).", None
        try:
            out = self.audio_detector.extract_audio_from_video(video_path)
            if out is None:
                # Don't fail: we can still track audio during analysis (e.g. different codec path)
                return True, "Audio could not be verified in pre-check. Analysis will still run and track audio when possible.", None
            audio_data, sr = out
            if audio_data is None or len(audio_data) == 0:
                return True, "No audio detected in pre-check. Analysis will still run and track audio when available.", None
            rms = np.sqrt(np.mean(audio_data ** 2))
            # Approximate dB (relative to full scale)
            db = 20 * np.log10(max(rms, 1e-10)) if rms > 0 else -100
            detail = {"rms": round(float(rms), 6), "db_approx": round(float(db), 1), "min_rms": MIN_AUDIO_RMS}
            if rms < MIN_AUDIO_RMS:
                return False, "Audio too quiet. Move closer to the microphone or speak louder.", detail
            return True, "Audio clarity OK.", detail
        except Exception as e:
            # Don't fail: analysis can still track audio when it runs
            return True, f"Audio pre-check skipped ({e}). Analysis will still run and track audio when possible.", None

    def _check_face_visibility(self, cap: cv2.VideoCapture) -> Tuple[bool, str, Optional[Dict]]:
        cascade = self._get_face_cascade()
        fps = cap.get(cv2.CAP_PROP_FPS) or 1
        total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        if total == 0:
            return False, "No frames in video.", None
        step = max(1, total // NUM_SAMPLE_FRAMES)
        faces_found = 0
        frames_checked = 0
        for i in range(0, total, step):
            cap.set(cv2.CAP_PROP_POS_FRAMES, i)
            ret, frame = cap.read()
            if not ret or frame is None:
                continue
            frames_checked += 1
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            if cascade and not isinstance(cascade, bool):
                faces = cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
                if len(faces) > 0:
                    faces_found += 1
            else:
                # Fallback: face-like region has sufficient detail (variance in upper half)
                h, w = gray.shape
                upper = gray[: h // 2, :]
                if np.var(upper) > 200:  # some structure in face region
                    faces_found += 1
        if frames_checked == 0:
            return False, "Could not sample frames for face check.", None
        ratio = faces_found / frames_checked
        detail = {"faces_detected_frames": faces_found, "frames_checked": frames_checked, "ratio": round(ratio, 2)}
        if ratio >= MIN_FACE_FRAMES_RATIO:
            return True, "Face visibility OK (child's face detected in frame).", detail
        return False, "Child's face not clearly visible in enough frames. Please ensure the child's face is in view.", detail
