"""
Firebase Firestore service for the backend.
Uses the Admin SDK with a service account key to write/read from Firestore.
"""
import os
import firebase_admin
from firebase_admin import credentials, firestore

# Path to the service account JSON (env var override supported)
_FIREBASE_CRED_PATH = os.environ.get(
    'FIREBASE_CREDENTIALS_PATH',
    os.path.join(os.path.dirname(__file__), '..', 'firebase-service-account.json')
)

_db = None


def get_firestore():
    """Get Firestore client. Initializes Firebase app once."""
    global _db
    if _db is None:
        if not firebase_admin._apps:
            cred = credentials.Certificate(_FIREBASE_CRED_PATH)
            firebase_admin.initialize_app(cred)
        _db = firestore.client()
    return _db


def save_analysis_result(data):
    """
    Save a video analysis result to Firestore.

    Args:
        data: dict with keys such as childName, childAge, reactionTime,
              confidenceLevel, rtnStatus, behaviorClassification, detectedActions,
              mlPrediction, autismProbability, typicalProbability, mlConfidence, etc.

    Returns:
        str: The ID of the created document.
    """
    db = get_firestore()
    data = dict(data)  # copy so we don't mutate caller's dict
    data['createdAt'] = firestore.SERVER_TIMESTAMP
    ref, _ = db.collection('video_analysis_results').add(data)
    return ref.id
