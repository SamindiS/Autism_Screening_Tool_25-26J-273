"""
Simple script to check model accuracy
Run this directly to see your model's accuracy
"""
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from train_model import AutismDetectionTrainer

def main():
    print("=" * 60)
    print("Checking Model Accuracy")
    print("=" * 60)
    
    # Initialize trainer
    trainer = AutismDetectionTrainer()
    
    # Load saved model
    print("\n1. Loading saved model...")
    if not trainer.load_model('autism_detection_model'):
        print("\n[ERROR] Model not found!")
        print("Please train a model first by running: python train_model.py")
        return
    
    print("[OK] Model loaded successfully")
    
    # Load training data
    print("\n2. Loading training data...")
    features_df, labels_df = trainer.load_training_data('training_data/labels.csv')
    
    if features_df is None:
        print("\n[ERROR] Training data not found!")
        return
    
    print(f"[OK] Loaded {len(features_df)} samples")
    
    # Evaluate model
    print("\n3. Evaluating model accuracy...")
    print("-" * 60)
    
    metrics = trainer.evaluate_model(features_df, labels_df)
    
    if metrics:
        print("\n" + "=" * 60)
        print("[OK] Accuracy Check Complete!")
        print("=" * 60)
        print(f"\nFinal Accuracy: {metrics['accuracy']:.2%}")
    else:
        print("\n[ERROR] Evaluation failed!")

if __name__ == '__main__':
    main()

