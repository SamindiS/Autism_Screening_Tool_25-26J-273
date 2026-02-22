import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Configuration class for ML service"""
    
    # Flask Configuration
    FLASK_APP = os.getenv('FLASK_APP', 'app.py')
    FLASK_ENV = os.getenv('FLASK_ENV', 'development')
    DEBUG = os.getenv('FLASK_DEBUG', '1') == '1'
    PORT = int(os.getenv('PORT', 5000))
    
    # Model Configuration
    MODEL_PATH = os.getenv('MODEL_PATH', 'models/rrb_classifier.h5')
    SCALER_PATH = os.getenv('SCALER_PATH', 'models/scaler.pkl')
    LABEL_ENCODER_PATH = os.getenv('LABEL_ENCODER_PATH', 'models/label_encoder.pkl')
    
    # Detection Configuration
    CONFIDENCE_THRESHOLD = float(os.getenv('CONFIDENCE_THRESHOLD', 0.70))
    MIN_DETECTION_DURATION = float(os.getenv('MIN_DETECTION_DURATION', 3.0))
    
    # File Upload Configuration
    UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', 'uploads')
    PROCESSED_FOLDER = os.getenv('PROCESSED_FOLDER', 'processed')
    MAX_CONTENT_LENGTH = int(os.getenv('MAX_CONTENT_LENGTH', 104857600))  # 100MB
    ALLOWED_EXTENSIONS = {'mp4', 'avi', 'mov', 'mkv'}
    
    # Video Processing Configuration
    TARGET_FPS = 30
    SEQUENCE_LENGTH = 30  # Number of frames per sequence
    IMG_SIZE = (224, 224)
    
    # Pose Estimation Configuration
    POSE_CONFIDENCE = 0.5
    POSE_TRACKING_CONFIDENCE = 0.5
    
    # RRB Categories
    RRB_CATEGORIES = [
        'hand_flapping',
        'head_banging',
        'head_nodding',
        'spinning',
        'atypical_hand_movements',
        'normal'
    ]
    
    # Feature Configuration
    FEATURE_NAMES = [
        'velocity', 'acceleration', 'frequency',
        'displacement', 'jerk', 'angular_velocity'
    ]
    
    @staticmethod
    def init_app(app):
        """Initialize application with configuration"""
        os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)
        os.makedirs(Config.PROCESSED_FOLDER, exist_ok=True)
        os.makedirs('models', exist_ok=True)
        os.makedirs('logs', exist_ok=True)

