"""
Minimal tests for Social vs Object metrics.
Run from backend/: python -m tests.test_social_object_metrics
Or: python tests/test_social_object_metrics.py
"""
import sys
import os
import unittest
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from analysis.social_object_metrics import compute_metrics


class TestSocialObjectMetrics(unittest.TestCase):
    def test_ratios_sum_close_to_one(self):
        # Synthetic events: 1s face, 1s object, 1s center => total 3s, no "none" so ratios sum to 1
        base = 1000
        events = [
            {"timestamp_ms": base, "x": 0.2, "y": 0.5, "aoi": "face"},
            {"timestamp_ms": base + 1000, "x": 0.8, "y": 0.5, "aoi": "object"},
            {"timestamp_ms": base + 2000, "x": 0.5, "y": 0.5, "aoi": "center"},
            {"timestamp_ms": base + 3000, "x": 0.5, "y": 0.5, "aoi": "center"},
        ]
        m = compute_metrics(events)
        total = m["face_time_ratio"] + m["object_time_ratio"] + m["center_time_ratio"]
        self.assertAlmostEqual(total, 1.0, places=2, msg=f"Ratios should sum to ~1, got {total}")

    def test_switch_count(self):
        events = [
            {"timestamp_ms": 1000, "x": 0.2, "y": 0.5, "aoi": "face"},
            {"timestamp_ms": 1100, "x": 0.8, "y": 0.5, "aoi": "object"},
            {"timestamp_ms": 1200, "x": 0.2, "y": 0.5, "aoi": "face"},
            {"timestamp_ms": 1300, "x": 0.8, "y": 0.5, "aoi": "object"},
        ]
        m = compute_metrics(events)
        self.assertEqual(m["switch_count"], 3, f"Expected 3 face<->object switches, got {m['switch_count']}")

    def test_first_fixation(self):
        events = [
            {"timestamp_ms": 1000, "x": 0.5, "y": 0.5, "aoi": "center"},
            {"timestamp_ms": 1100, "x": 0.2, "y": 0.5, "aoi": "face"},
            {"timestamp_ms": 1200, "x": 0.8, "y": 0.5, "aoi": "object"},
        ]
        m = compute_metrics(events)
        self.assertEqual(m["first_fixation"], "center", f"Expected first_fixation=center, got {m['first_fixation']}")

        events2 = [
            {"timestamp_ms": 1000, "x": 0.2, "y": 0.5, "aoi": "face"},
            {"timestamp_ms": 1100, "x": 0.8, "y": 0.5, "aoi": "object"},
        ]
        m2 = compute_metrics(events2)
        self.assertEqual(m2["first_fixation"], "face", f"Expected first_fixation=face, got {m2['first_fixation']}")

    def test_empty_events(self):
        m = compute_metrics([])
        self.assertEqual(m["duration_ms"], 0)
        self.assertEqual(m["face_time_ratio"], 0.0)
        self.assertEqual(m["switch_count"], 0)
        self.assertEqual(m["first_fixation"], "none")


if __name__ == "__main__":
    unittest.main()
