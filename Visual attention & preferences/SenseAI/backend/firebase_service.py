"""
Firebase Firestore Service for SenseAI
======================================

Saves child test reports to Firebase Firestore (dual storage with SQLite).
Works gracefully when Firebase is not configured - skips writes without failing.
"""

import json
import os
from copy import deepcopy
from pathlib import Path
from typing import Optional, Dict, Any

# Firestore maximum document size is 1 MiB; stay under with margin for protobuf overhead.
_FIRESTORE_DOC_SIZE_LIMIT = 1_048_576 - 40_960

# Firebase is optional - only import when needed
_firestore_db = None
_initialized = False
_init_failed = False


def _get_credentials_path() -> Optional[str]:
    """Get path to Firebase credentials JSON file."""
    path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
    if path and os.path.isfile(path):
        return path
    # Default: backend/firebase-credentials.json
    default_path = Path(__file__).parent / "firebase-credentials.json"
    if default_path.exists():
        return str(default_path)
    return None


def _init_firebase() -> bool:
    """Initialize Firebase Admin SDK. Returns True if successful."""
    global _firestore_db, _initialized, _init_failed

    if _initialized:
        return _firestore_db is not None
    if _init_failed:
        return False

    creds_path = _get_credentials_path()
    if not creds_path:
        print("Firebase: No credentials file found - skipping Firestore (using SQLite only)")
        _init_failed = True
        return False

    try:
        import firebase_admin
        from firebase_admin import credentials, firestore

        # Check if already initialized (e.g. from another import)
        if not firebase_admin._apps:
            cred = credentials.Certificate(creds_path)
            firebase_admin.initialize_app(cred)

        _firestore_db = firestore.client()
        _initialized = True
        print("Firebase: Firestore initialized successfully")
        return True
    except Exception as e:
        print(f"Firebase: Initialization failed - {e}")
        _init_failed = True
        return False


def _estimate_payload_bytes(payload: Dict[str, Any]) -> int:
    """Rough UTF-8 size of JSON serialization (good proxy for Firestore document bulk)."""
    try:
        return len(json.dumps(payload, default=str, ensure_ascii=False).encode("utf-8"))
    except (TypeError, ValueError):
        return _FIRESTORE_DOC_SIZE_LIMIT + 1


def _shrink_payload_for_firestore(payload: Dict[str, Any]) -> Dict[str, Any]:
    """Ensure payload fits Firestore limits; omit raw gaze data first if needed."""
    out = deepcopy(payload)
    size = _estimate_payload_bytes(out)
    if size <= _FIRESTORE_DOC_SIZE_LIMIT:
        out["raw_events_synced"] = "raw_events" in out
        return out

    out.pop("raw_events", None)
    out["raw_events_synced"] = False
    out["raw_events_omitted_reason"] = "firestore_document_size_limit"
    size = _estimate_payload_bytes(out)
    if size <= _FIRESTORE_DOC_SIZE_LIMIT:
        print(
            f"Firebase: raw_events omitted (approx payload too large); "
            f"estimated doc ~{size} bytes without raw gaze data"
        )
        return out

    print(f"Firebase: Document still oversized (~{_estimate_payload_bytes(out)} bytes), cannot save summary")
    return {}


def save_report_to_firestore(test_id: str, record_dict: Dict[str, Any]) -> bool:
    """
    Save a test report to Firebase Firestore.

    Args:
        test_id: Unique test identifier (document ID)
        record_dict: Full test snapshot aligned with SQLite: childName, childAge,
                     testDateTime, score, scores, metrics, interpretation,
                     parent fields, created_at, testId, and optional raw_events (list).

    Returns:
        True if saved successfully, False otherwise.
        Does NOT raise - logs errors and returns False.
    """
    if not _init_firebase():
        return False

    try:
        payload = _shrink_payload_for_firestore(record_dict)
        if not payload:
            return False
        doc_ref = _firestore_db.collection("reports").document(test_id)
        doc_ref.set(payload)
        raw_ok = payload.get("raw_events_synced", False)
        print(
            f"Firebase: Report {test_id} saved to Firestore"
            + (" (with raw_events)" if raw_ok else " (without raw_events or summary-only)")
        )
        return True
    except Exception as e:
        print(f"Firebase: Failed to save report {test_id} - {e}")
        return False


def is_firebase_available() -> bool:
    """Check if Firebase is configured and ready for writes."""
    return _init_firebase()
