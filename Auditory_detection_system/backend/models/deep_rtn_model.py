"""
Optional Deep Learning model for RTN screening:
- CNN for frame-level features (direct frame processing)
- LSTM for temporal pattern recognition (response timing)

Compare with Random Forest / Ensemble via train_and_compare().
Requires: tensorflow (pip install tensorflow)
"""
from pathlib import Path
import json
import numpy as np

try:
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras import layers
    TF_AVAILABLE = True
except ImportError:
    TF_AVAILABLE = False

# Default paths
MODEL_DIR = Path(__file__).resolve().parent.parent / 'models'
FRAME_HEIGHT, FRAME_WIDTH = 64, 64
SEQ_LENGTH = 30  # number of frames per video (temporal window)
NUM_CLASSES = 2  # typical=0, autism=1


def build_cnn_lstm_model(input_shape=(SEQ_LENGTH, FRAME_HEIGHT, FRAME_WIDTH, 1), num_classes=2):
    """
    Build CNN + LSTM: CNN per frame -> LSTM over time -> dense classifier.
    input_shape: (time_steps, H, W, channels)
    """
    if not TF_AVAILABLE:
        raise RuntimeError("TensorFlow is required. pip install tensorflow")
    
    inp = keras.Input(shape=input_shape)
    # TimeDistributed CNN for each frame
    x = layers.TimeDistributed(
        layers.Conv2D(32, (3, 3), activation='relu', padding='same'),
        name='td_conv1'
    )(inp)
    x = layers.TimeDistributed(layers.MaxPooling2D((2, 2)), name='td_pool1')(x)
    x = layers.TimeDistributed(layers.Conv2D(64, (3, 3), activation='relu', padding='same'), name='td_conv2')(x)
    x = layers.TimeDistributed(layers.MaxPooling2D((2, 2)), name='td_pool2')(x)
    x = layers.TimeDistributed(layers.Flatten(), name='td_flat')(x)
    x = layers.TimeDistributed(layers.Dense(64, activation='relu'), name='td_dense')(x)
    # LSTM for temporal patterns
    x = layers.LSTM(32, return_sequences=False, dropout=0.2, name='lstm')(x)
    x = layers.Dense(16, activation='relu', name='dense1')(x)
    x = layers.Dropout(0.3)(x)
    out = layers.Dense(num_classes, activation='softmax', name='output')(x)
    
    model = keras.Model(inp, out)
    model.compile(
        optimizer=keras.optimizers.Adam(1e-3),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    return model


def extract_frame_sequence(video_path, max_frames=SEQ_LENGTH, height=FRAME_HEIGHT, width=FRAME_WIDTH):
    """
    Extract a fixed-length sequence of grayscale frames from video.
    Returns array of shape (max_frames, height, width, 1) or None.
    """
    try:
        import cv2
    except ImportError:
        return None
    cap = cv2.VideoCapture(str(video_path))
    if not cap.isOpened():
        return None
    fps = cap.get(cv2.CAP_PROP_FPS) or 1
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total == 0:
        cap.release()
        return None
    step = max(1, total // max_frames)
    frames = []
    for i in range(0, total, step):
        if len(frames) >= max_frames:
            break
        cap.set(cv2.CAP_PROP_POS_FRAMES, i)
        ret, frame = cap.read()
        if not ret:
            continue
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        resized = cv2.resize(gray, (width, height))
        frames.append(resized)
    cap.release()
    if len(frames) < max_frames:
        # Pad with last frame
        while len(frames) < max_frames:
            frames.append(frames[-1] if frames else np.zeros((height, width), dtype=np.uint8))
    frames = np.array(frames[:max_frames], dtype=np.float32) / 255.0
    return np.expand_dims(frames, axis=-1)  # (T, H, W, 1)


def train_deep_model(video_paths, labels, model_dir=MODEL_DIR, epochs=20, batch_size=4):
    """
    Train CNN+LSTM on frame sequences.
    video_paths: list of paths to videos
    labels: list of 0/1 (typical/autism)
    """
    if not TF_AVAILABLE:
        print("TensorFlow not installed. Skipping deep model training.")
        return None
    X = []
    for p in video_paths:
        seq = extract_frame_sequence(p)
        if seq is not None:
            X.append(seq)
        else:
            X.append(np.zeros((SEQ_LENGTH, FRAME_HEIGHT, FRAME_WIDTH, 1), dtype=np.float32))
    X = np.array(X)
    y = np.array(labels, dtype=np.int32)
    if len(y) != len(X):
        y = y[:len(X)]
    
    model = build_cnn_lstm_model()
    model_dir = Path(model_dir)
    model_dir.mkdir(parents=True, exist_ok=True)
    callbacks = [
        keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True),
        keras.callbacks.ModelCheckpoint(
            str(model_dir / 'deep_rtn_best.keras'),
            save_best_only=True,
            monitor='val_accuracy'
        ),
    ]
    history = model.fit(
        X, y,
        validation_split=0.2,
        epochs=epochs,
        batch_size=batch_size,
        callbacks=callbacks,
        verbose=1
    )
    model.save(model_dir / 'deep_rtn_model.keras')
    meta = {
        'input_shape': [SEQ_LENGTH, FRAME_HEIGHT, FRAME_WIDTH, 1],
        'num_classes': NUM_CLASSES,
        'final_accuracy': float(history.history.get('val_accuracy', [0])[-1]),
    }
    with open(model_dir / 'deep_rtn_metadata.json', 'w') as f:
        json.dump(meta, f, indent=2)
    print(f"Deep model saved to {model_dir}. Val accuracy: {meta['final_accuracy']:.2%}")
    return model


def load_deep_model(model_dir=MODEL_DIR):
    """Load saved CNN+LSTM model."""
    if not TF_AVAILABLE:
        return None
    path = Path(model_dir) / 'deep_rtn_model.keras'
    if not path.exists():
        return None
    return keras.models.load_model(path)


def predict_deep(model, video_path):
    """Predict using deep model. Returns dict with prediction, autism_probability, typical_probability."""
    if model is None:
        return None
    seq = extract_frame_sequence(video_path)
    if seq is None:
        return None
    X = np.expand_dims(seq, axis=0)
    proba = model.predict(X, verbose=0)[0]
    return {
        'prediction': 'autism' if np.argmax(proba) == 1 else 'typical',
        'autism_probability': float(proba[1]),
        'typical_probability': float(proba[0]),
        'confidence': float(max(proba)),
        'model_type': 'deep_cnn_lstm',
    }


def train_and_compare_with_rf(labels_csv='training_data/labels.csv'):
    """
    Train both ensemble (RF+GB+SVM) and optional deep model; compare accuracy.
    Run from backend/: python -m models.deep_rtn_model
    """
    import pandas as pd
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
    from train_model import AutismDetectionTrainer
    
    df = pd.read_csv(labels_csv)
    video_paths = df['video_path'].tolist()
    labels = [1 if str(row['label']).lower() == 'autism' else 0 for _, row in df.iterrows()]
    
    # Ensure paths exist
    valid = []
    valid_labels = []
    for p, l in zip(video_paths, labels):
        if Path(p).exists():
            valid.append(p)
            valid_labels.append(l)
    
    if len(valid) < 10:
        print("Need at least 10 valid videos to train and compare. Skipping.")
        return
    
    # 1. Train sklearn ensemble (with feature engineering)
    trainer = AutismDetectionTrainer()
    features_df, labels_df = trainer.load_training_data(labels_csv)
    if features_df is not None:
        acc_ensemble = trainer.train_model(features_df, labels_df, model_type='ensemble')
        trainer.save_model('autism_detection_model')
        print(f"\nEnsemble accuracy: {acc_ensemble:.2%}")
    
    # 2. Train deep model (optional)
    if TF_AVAILABLE:
        train_deep_model(valid, valid_labels, epochs=15, batch_size=4)
    else:
        print("TensorFlow not installed. Install with: pip install tensorflow")
    
    print("\nComparison: Use ensemble for production; deep model available if TensorFlow installed.")
