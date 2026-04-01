"""
Firebase Firestore Service for SenseAI
======================================

Saves child test reports to Firebase Firestore (dual storage with SQLite).
Works gracefully when Firebase is not configured - skips writes without failing.
"""

import os
from pathlib import Path
from typing import Optional, Dict, Any

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


def save_report_to_firestore(test_id: str, record_dict: Dict[str, Any]) -> bool:
    """
    Save a test report to Firebase Firestore.

    Args:
        test_id: Unique test identifier (document ID)
        record_dict: Report data with keys: childName, childAge, testDateTime,
                     score, scores, metrics, interpretation, parent_name,
                     parent_email, parent_phone, parent_relationship, created_at

    Returns:
        True if saved successfully, False otherwise.
        Does NOT raise - logs errors and returns False.
    """
    if not _init_firebase():
        return False

    try:
        doc_ref = _firestore_db.collection("reports").document(test_id)
        doc_ref.set(record_dict)
        print(f"Firebase: Report {test_id} saved to Firestore")
        return True
    except Exception as e:
        print(f"Firebase: Failed to save report {test_id} - {e}")
        return False


def is_firebase_available() -> bool:
    """Check if Firebase is configured and ready for writes."""
    return _init_firebase()
