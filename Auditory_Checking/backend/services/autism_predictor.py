"""
Autism Predictor Service
Uses trained ML model to predict autism vs typical responses
"""
import os
from pathlib import Path
import sys

# Add parent directory to path to import train_model
sys.path.append(str(Path(__file__).parent.parent))

try:
    from train_model import AutismDetectionTrainer
    ML_AVAILABLE = True
except ImportError:
    ML_AVAILABLE = False
    print("Warning: ML model not available. Install scikit-learn, pandas, joblib")


class AutismPredictor:
    """Predict autism vs typical responses using trained model"""
    
    def __init__(self, model_name='autism_detection_model'):
        self.trainer = None
        self.model_loaded = False
        self.model_name = model_name
        
        if ML_AVAILABLE:
            self.trainer = AutismDetectionTrainer(model_dir='models')
            self._load_model()
    
    def _load_model(self):
        """Load trained model if available"""
        if not ML_AVAILABLE or not self.trainer:
            return False
        
        model_path = Path('models') / f"{self.model_name}.pkl"
        if model_path.exists():
            try:
                self.model_loaded = self.trainer.load_model(self.model_name)
                if self.model_loaded:
                    print(f"Autism detection model loaded: {self.model_name}")
            except Exception as e:
                print(f"Error loading model: {e}")
                self.model_loaded = False
        else:
            print(f"Model not found: {model_path}")
            print("Train model first using: python train_model.py")
            self.model_loaded = False
        
        return self.model_loaded
    
    def predict(self, video_path):
        """
        Predict autism vs typical for a video
        
        Args:
            video_path: Path to video file
            
        Returns:
            dict: Prediction results with probabilities
        """
        if not self.model_loaded or not self.trainer:
            return {
                'prediction': 'unknown',
                'autism_probability': 0.5,
                'typical_probability': 0.5,
                'confidence': 0.0,
                'model_available': False,
                'message': 'Model not trained or loaded'
            }
        
        try:
            result = self.trainer.predict(video_path)
            if result:
                result['model_available'] = True
                return result
            else:
                return {
                    'prediction': 'unknown',
                    'autism_probability': 0.5,
                    'typical_probability': 0.5,
                    'confidence': 0.0,
                    'model_available': True,
                    'message': 'Feature extraction failed'
                }
        except Exception as e:
            return {
                'prediction': 'unknown',
                'autism_probability': 0.5,
                'typical_probability': 0.5,
                'confidence': 0.0,
                'model_available': True,
                'error': str(e)
            }
    
    def is_model_available(self):
        """Check if trained model is available"""
        return self.model_loaded




























