# RRB Detection ML Service

AI-powered system for automatically identifying and classifying Restricted and Repetitive Behaviors (RRBs) in children aged 2-6 through clinical observation videos.

## 🎯 Features

- **Pose Estimation**: MediaPipe-based pose detection for accurate body landmark tracking
- **Kinematic Feature Extraction**: Velocity, acceleration, frequency, jerk, and angular velocity analysis
- **CNN+LSTM Model**: Deep learning architecture for temporal video classification
- **REST API**: Flask-based API for video upload and RRB detection
- **Confidence Filtering**: Only outputs detections with ≥70% confidence
- **Temporal Filtering**: Filters out detections lasting less than 3 seconds
- **Multi-class Classification**: Detects 6 RRB categories

## 📋 RRB Categories

1. **Hand Flapping**: Repetitive hand or arm movements
2. **Head Banging**: Repetitive head hitting or banging movements
3. **Head Nodding**: Repetitive head nodding movements (atypical)
4. **Spinning**: Repetitive spinning or rotating movements
5. **Atypical Hand Movements**: Other atypical hand movements
6. **Normal**: No restricted or repetitive behaviors detected

## 🏗️ Architecture

```
ml_service/
├── app.py                      # Flask API application
├── train.py                    # Model training script
├── test_inference.py           # Inference testing script
├── config.py                   # Configuration settings
├── requirements.txt            # Python dependencies
├── models/
│   ├── rrb_model.py           # CNN+LSTM model architecture
│   └── __init__.py
├── utils/
│   ├── pose_estimator.py      # MediaPipe pose estimation
│   ├── feature_extractor.py   # Kinematic feature extraction
│   ├── video_processor.py     # Video preprocessing
│   ├── data_loader.py         # Dataset loading and preparation
│   ├── inference.py           # Inference engine
│   └── __init__.py
└── outputs/                    # Training outputs and logs
```

## 🚀 Quick Start

### 1. Setup Environment

```bash
# Install dependencies
python setup.py

# Or manually:
pip install -r requirements.txt
```

### 2. Train the Model

```bash
# Basic training
python train.py --epochs 50 --batch_size 8

# Advanced training with custom parameters
python train.py \
    --dataset_path ../Dataset \
    --epochs 100 \
    --batch_size 16 \
    --learning_rate 0.0001 \
    --use_pretrained \
    --save_preprocessed
```

**Training Parameters:**
- `--dataset_path`: Path to dataset directory (default: ../Dataset)
- `--epochs`: Number of training epochs (default: 50)
- `--batch_size`: Batch size for training (default: 8)
- `--learning_rate`: Learning rate (default: 0.001)
- `--sequence_length`: Frames per sequence (default: 30)
- `--img_size`: Image dimensions (default: 224 224)
- `--use_pretrained`: Use pretrained CNN backbone (MobileNetV2)
- `--save_preprocessed`: Save preprocessed data for faster future training

### 3. Test Inference

```bash
# Test on single video
python test_inference.py \
    --mode single \
    --video_path path/to/video.mp4

# Test on folder of videos
python test_inference.py \
    --mode folder \
    --folder_path path/to/videos/ \
    --output_file results.json

# Test on entire dataset
python test_inference.py \
    --mode dataset \
    --dataset_path ../Dataset \
    --output_file dataset_results.json
```

### 4. Start API Server

```bash
# Start Flask server
python app.py

# Or use the batch script (Windows)
run_server.bat
```

The API will be available at `http://localhost:5000`

## 🔌 API Endpoints

### Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "RRB Detection ML Service",
  "timestamp": "2024-01-01T12:00:00"
}
```

### Detect RRB
```http
POST /api/v1/detect
Content-Type: multipart/form-data

video: <video_file>
```

**Response:**
```json
{
  "success": true,
  "timestamp": "2024-01-01T12:00:00",
  "filename": "video.mp4",
  "detection": {
    "detected": true,
    "primary_behavior": "hand_flapping",
    "confidence": 0.92,
    "behaviors": [
      {
        "behavior": "hand_flapping",
        "confidence": 0.92,
        "occurrences": 5,
        "total_duration": 12.5
      }
    ]
  },
  "metadata": {
    "video_duration": 15.0,
    "video_fps": 30,
    "sequences_analyzed": 10,
    "sequences_with_detections": 5
  }
}
```

### Enhanced Detection (with Pose Analysis)
```http
POST /api/v1/detect/enhanced
Content-Type: multipart/form-data

video: <video_file>
```

### Get Model Info
```http
GET /api/v1/model/info
```

### Get RRB Categories
```http
GET /api/v1/categories
```

## 📊 Model Performance

The model is trained on a dataset containing:
- **Hand Flapping**: 42 videos
- **Head Banging**: 20 videos
- **Head Nodding**: 26 videos (6 atypical + 20 normal)
- **Spinning**: 13 videos
- **Atypical Hand Movements**: 20 videos
- **Normal**: Multiple videos

**Expected Performance:**
- Accuracy: >85% on test set
- Precision: >80% per class
- Recall: >75% per class
- Confidence threshold: 70%
- Minimum detection duration: 3 seconds

## ⚙️ Configuration

Edit `.env` file to customize settings:

```env
# Flask Configuration
FLASK_ENV=development
PORT=5000

# Model Configuration
MODEL_PATH=models/rrb_classifier.h5
LABEL_ENCODER_PATH=preprocessed_data/label_encoder.pkl
CONFIDENCE_THRESHOLD=0.70
MIN_DETECTION_DURATION=3.0

# File Upload
UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=104857600  # 100MB
```

## 🧪 Testing

```bash
# Run unit tests (if implemented)
pytest tests/

# Test API endpoints
curl -X POST -F "video=@test_video.mp4" http://localhost:5000/api/v1/detect
```

## 📦 Dependencies

- **TensorFlow 2.15.0**: Deep learning framework
- **MediaPipe 0.10.8**: Pose estimation
- **OpenCV 4.8.1**: Video processing
- **Flask 3.0.0**: Web framework
- **NumPy, SciPy**: Numerical computing
- **scikit-learn**: Machine learning utilities

## 🔧 Troubleshooting

### Model not found error
```bash
# Ensure you've trained the model first
python train.py --epochs 50
```

### Out of memory during training
```bash
# Reduce batch size
python train.py --batch_size 4

# Or reduce sequence length
python train.py --sequence_length 20
```

### Low accuracy
- Increase training epochs
- Use data augmentation
- Adjust learning rate
- Ensure dataset quality

## 📝 Development Roadmap

- [ ] Implement data augmentation
- [ ] Add real-time video streaming support
- [ ] Optimize model for mobile deployment
- [ ] Add multi-person detection
- [ ] Implement attention mechanisms
- [ ] Create web-based visualization dashboard

## 🤝 Integration

This ML service is designed to integrate with:
- **Node.js Backend**: For authentication and data management
- **Flutter Mobile App**: For video recording and results display
- **Autism Screening Platform**: As part of comprehensive assessment

## 📄 License

Copyright © 2024 RRB Detection System

## 👥 Authors

Developed for autism screening and early intervention research.

## 📧 Support

For issues and questions, please refer to the project documentation.

