"""
Gaze Model Training Script
===========================

This script trains a neural network to predict screen gaze coordinates
from eye landmark features extracted by ML Kit Face Detection.

Usage:
------
1. Collect training data using the Flutter app's Data Collection screen
2. Copy the JSON file to this directory
3. Run: python train_gaze_model.py --data gaze_training_*.json
4. The script outputs: gaze_model.tflite (for the Flutter app)

Model Architecture:
------------------
Input: 32 floats (eye landmarks, head pose, face position)
Hidden: 64 -> 32 neurons with ReLU activation
Output: 2 floats (x, y screen coordinates, normalized 0-1)

Requirements:
------------
pip install tensorflow numpy
"""

import argparse
import json
import os
import numpy as np

def load_training_data(json_path):
    """Load training data from JSON file exported by Flutter app."""
    print(f"Loading data from: {json_path}")
    
    with open(json_path, 'r') as f:
        data = json.load(f)
    
    # Handle both formats: list of samples or {'samples': [...]}
    if isinstance(data, list):
        samples = data
    else:
        samples = data.get('samples', [])
    
    print(f"Found {len(samples)} samples")
    
    X = []  # Input features (eye landmarks)
    y = []  # Target outputs (screen coordinates)
    
    for sample in samples:
        # Get model input (32 floats from eye landmarks)
        model_input = sample.get('modelInput', sample.get('landmarks', {}).get('modelInput', []))
        
        if len(model_input) != 32:
            print(f"Warning: Sample has {len(model_input)} features, expected 32. Skipping.")
            continue
        
        target_x = sample.get('targetX', 0.5)
        target_y = sample.get('targetY', 0.5)
        
        X.append(model_input)
        y.append([target_x, target_y])
    
    X = np.array(X, dtype=np.float32)
    y = np.array(y, dtype=np.float32)
    
    print(f"Loaded {len(X)} valid samples")
    print(f"Input shape: {X.shape}")
    print(f"Output shape: {y.shape}")
    
    return X, y


def create_model():
    """Create the gaze prediction neural network."""
    import tensorflow as tf
    
    model = tf.keras.Sequential([
        # Input layer: 32 features from eye landmarks
        tf.keras.layers.Input(shape=(32,), name='eye_landmarks'),
        
        # Batch normalization for input
        tf.keras.layers.BatchNormalization(),
        
        # Hidden layer 1: 64 neurons
        tf.keras.layers.Dense(64, activation='relu', name='hidden1'),
        tf.keras.layers.Dropout(0.2),
        
        # Hidden layer 2: 32 neurons
        tf.keras.layers.Dense(32, activation='relu', name='hidden2'),
        tf.keras.layers.Dropout(0.2),
        
        # Output layer: 2 neurons (x, y coordinates)
        # Using sigmoid to constrain output to 0-1 range
        tf.keras.layers.Dense(2, activation='sigmoid', name='gaze_output'),
    ])
    
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='mse',  # Mean squared error for regression
        metrics=['mae']  # Mean absolute error for interpretability
    )
    
    return model


def train_model(X, y, epochs=100, validation_split=0.2):
    """Train the gaze prediction model."""
    import tensorflow as tf
    
    print("\n" + "="*50)
    print("TRAINING GAZE MODEL")
    print("="*50)
    
    model = create_model()
    model.summary()
    
    # Callbacks for training
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=0.0001
        )
    ]
    
    # Train
    history = model.fit(
        X, y,
        epochs=epochs,
        validation_split=validation_split,
        batch_size=32,
        callbacks=callbacks,
        verbose=1
    )
    
    # Evaluate
    val_loss, val_mae = model.evaluate(X, y, verbose=0)
    print(f"\nFinal Loss: {val_loss:.4f}")
    print(f"Final MAE: {val_mae:.4f}")
    print(f"(MAE represents average error in normalized coordinates)")
    print(f"(e.g., MAE=0.05 means ~5% of screen width/height error)")
    
    return model, history


def convert_to_tflite(model, output_path='gaze_model.tflite'):
    """Convert trained model to TFLite format for mobile deployment."""
    import tensorflow as tf
    
    print(f"\nConverting model to TFLite: {output_path}")
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Optimize for mobile
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    file_size = os.path.getsize(output_path)
    print(f"TFLite model saved: {output_path} ({file_size / 1024:.1f} KB)")
    
    return output_path


def test_tflite_model(tflite_path, X_test):
    """Test the TFLite model with sample data."""
    import tensorflow as tf
    
    print(f"\nTesting TFLite model...")
    
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    
    # Get input/output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"Input shape: {input_details[0]['shape']}")
    print(f"Output shape: {output_details[0]['shape']}")
    
    # Test with first sample
    test_input = np.array([X_test[0]], dtype=np.float32)
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"Test prediction: x={output[0][0]:.3f}, y={output[0][1]:.3f}")
    
    return True


def generate_sample_data(n_samples=100):
    """Generate synthetic training data for testing the pipeline."""
    print(f"Generating {n_samples} synthetic samples for testing...")
    
    X = []
    y = []
    
    for _ in range(n_samples):
        # Generate random target position
        target_x = np.random.uniform(0.1, 0.9)
        target_y = np.random.uniform(0.1, 0.9)
        
        # Generate fake eye landmarks that correlate with target
        # In real data, eye position would correlate with where person is looking
        base_features = np.random.randn(32) * 0.1
        
        # Add correlation: eye position shifts towards target
        base_features[0] = target_x + np.random.randn() * 0.1  # left eye x
        base_features[1] = target_y + np.random.randn() * 0.1  # left eye y
        base_features[2] = target_x + np.random.randn() * 0.1  # right eye x
        base_features[3] = target_y + np.random.randn() * 0.1  # right eye y
        
        X.append(base_features.astype(np.float32))
        y.append([target_x, target_y])
    
    return np.array(X), np.array(y)


def main():
    parser = argparse.ArgumentParser(description='Train gaze prediction model')
    parser.add_argument('--data', type=str, help='Path to training data JSON file')
    parser.add_argument('--output', type=str, default='gaze_model.tflite', help='Output TFLite model path')
    parser.add_argument('--epochs', type=int, default=100, help='Training epochs')
    parser.add_argument('--synthetic', action='store_true', help='Use synthetic data for testing')
    parser.add_argument('--samples', type=int, default=500, help='Number of synthetic samples')
    
    args = parser.parse_args()
    
    # Load or generate data
    if args.synthetic or args.data is None:
        print("\n⚠️  Using synthetic data for testing the pipeline")
        print("   For real training, use --data <path_to_json>")
        X, y = generate_sample_data(args.samples)
    else:
        X, y = load_training_data(args.data)
    
    if len(X) < 10:
        print("Error: Not enough training samples. Need at least 10.")
        return
    
    # Train model
    model, history = train_model(X, y, epochs=args.epochs)
    
    # Convert to TFLite
    tflite_path = convert_to_tflite(model, args.output)
    
    # Test TFLite model
    test_tflite_model(tflite_path, X)
    
    print("\n" + "="*50)
    print("TRAINING COMPLETE!")
    print("="*50)
    print(f"\nNext steps:")
    print(f"1. Copy {tflite_path} to Flutter app assets")
    print(f"2. Update frontend/pubspec.yaml to include the asset")
    print(f"3. Load and use in the app for real-time gaze prediction")


if __name__ == '__main__':
    main()
