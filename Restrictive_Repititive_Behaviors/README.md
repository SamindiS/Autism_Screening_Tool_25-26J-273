# 🎯 RRB Detection System

**Repetitive and Restrictive Behavior Detection System using Deep Learning**

[![Status](https://img.shields.io/badge/Status-Operational-success)]()
[![ML Model](https://img.shields.io/badge/Model-Trained-blue)]()
[![Backend](https://img.shields.io/badge/Backend-Ready-green)]()
[![Flutter](https://img.shields.io/badge/Flutter-Ready-cyan)]()

---

## 📋 Overview

The RRB Detection System is a comprehensive solution for detecting Repetitive and Restrictive Behaviors (RRBs) in video recordings using deep learning. The system consists of three main components:

1. **ML Service** - Python Flask API with trained CNN-LSTM model
2. **Backend API** - Node.js Express server for authentication and video management
3. **Flutter App** - Cross-platform mobile application for video recording and analysis

---

## 🚀 Quick Start

### Option 1: One-Click Start (Recommended)
```cmd
START_ALL_SERVICES.bat
```

### Option 2: Read Documentation First
1. **START_HERE.md** - Begin here for quick setup
2. **QUICK_START_GUIDE.md** - Detailed manual instructions
3. **SYSTEM_STATUS_REPORT.md** - System status and test results

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
│              (Web / Windows / Android)                       │
│                      Port: 8080                              │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP/REST API
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  Node.js Backend API                         │
│                   (Express.js)                               │
│                    Port: 3000                                │
└────────────────────┬────────────────────────────────────────┘
                     │ Forward Videos
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   ML Service (Flask)                         │
│              TensorFlow + CNN-LSTM Model                     │
│                    Port: 5000                                │
│                                                              │
│  ┌──────────────────┐      ┌─────────────────┐             │
│  │ rrb_classifier.h5│      │label_encoder.pkl│             │
│  │    (22.3 MB)     │      │   (6 classes)   │             │
│  └──────────────────┘      └─────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Components

### 1. ML Service (Port 5000)
- **Framework**: Python Flask
- **ML Framework**: TensorFlow 2.15.0 + tf-keras
- **Model**: CNN-LSTM architecture
- **Input**: Video sequences (30 frames)
- **Output**: RRB classification with confidence scores
- **Categories**: 6 RRB types
  - Hand Flapping
  - Head Banging
  - Head Nodding
  - Spinning
  - Atypical Hand Movements
  - Normal

### 2. Backend API (Port 3000)
- **Framework**: Node.js Express
- **Features**:
  - User authentication (JWT)
  - Video upload and management
  - ML service integration
  - RESTful API
- **Dependencies**: 146 npm packages

### 3. Flutter App
- **Framework**: Flutter 3.38.5
- **Platforms**: Web, Windows, Android
- **Features**:
  - User registration and login
  - Video recording
  - Video upload
  - Real-time detection results
  - History tracking

---

## 🛠️ Installation

### Prerequisites
- Python 3.10
- Node.js 16+
- Flutter SDK
- 4GB RAM minimum
- 2GB disk space

### Setup Steps

1. **Clone/Navigate to Repository**
   ```cmd
   cd E:\RRB
   ```

2. **Install ML Service Dependencies**
   ```cmd
   cd ml_service
   pip install -r requirements.txt
   ```

3. **Install Backend Dependencies**
   ```cmd
   cd backend
   npm install
   ```

4. **Install Flutter Dependencies**
   ```cmd
   cd rrb_detection_app
   flutter pub get
   ```

5. **Start All Services**
   ```cmd
   cd E:\RRB
   START_ALL_SERVICES.bat
   ```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [START_HERE.md](START_HERE.md) | Quick start guide (3 simple steps) |
| [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) | Detailed manual startup instructions |
| [SYSTEM_STATUS_REPORT.md](SYSTEM_STATUS_REPORT.md) | Complete system status and test results |
| [FINAL_SUMMARY.md](FINAL_SUMMARY.md) | Project summary and achievements |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | Deployment verification checklist |

---

## ✅ System Status

| Component | Status | Port | Health Check |
|-----------|--------|------|--------------|
| ML Service | ✅ Running | 5000 | http://localhost:5000/health |
| Backend API | ✅ Running | 3000 | http://localhost:3000/health |
| Flutter App | ✅ Ready | 8080 | Launch via `flutter run` |
| ML Model | ✅ Trained | - | 22.3 MB, 6 classes |

---

## 🧪 Testing

### Health Checks
```cmd
# ML Service
curl http://localhost:5000/health

# Backend
curl http://localhost:3000/health
```

### End-to-End Test
1. Start all services
2. Open Flutter app
3. Register new account
4. Login
5. Record/upload video
6. View detection results

---

## 🔧 Configuration

### For Physical Devices
Update `rrb_detection_app/lib/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'http://YOUR_IP:3000/api';
static const String mlServiceUrl = 'http://YOUR_IP:5000/api/v1';
```

Replace `YOUR_IP` with your computer's IP address (find using `ipconfig`).

---

## 📊 Model Information

- **Architecture**: CNN-LSTM
- **Training Date**: January 3, 2026
- **Model Size**: 22.3 MB
- **Input**: Video sequences (30 frames, 224x224 pixels)
- **Output**: 6-class classification with confidence scores
- **Accuracy**: Trained on custom RRB dataset

---

## 🐛 Troubleshooting

### ML Service Won't Start
```cmd
set TF_USE_LEGACY_KERAS=1
set TF_CPP_MIN_LOG_LEVEL=2
python app.py
```

### Backend Won't Start
```cmd
cd backend
npm install
node server.js
```

### Flutter Build Errors
```cmd
flutter clean
flutter pub get
flutter run
```

See [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) for detailed troubleshooting.

---

## 📁 Project Structure

```
E:\RRB\
├── ml_service/              # ML Service (Port 5000)
│   ├── models/
│   │   ├── rrb_classifier.h5
│   │   └── label_encoder.pkl
│   ├── app.py
│   └── requirements.txt
├── backend/                 # Backend API (Port 3000)
│   ├── routes/
│   ├── server.js
│   └── package.json
├── rrb_detection_app/       # Flutter App
│   ├── lib/
│   └── pubspec.yaml
├── START_ALL_SERVICES.bat   # One-click start
└── Documentation files
```

---

## 🤝 Contributing

This is a research project for RRB detection. For issues or improvements:
1. Check existing documentation
2. Review error logs
3. Test each component individually

---

## 📄 License

This project is for educational and research purposes.

---

## 🎉 Acknowledgments

- TensorFlow team for the ML framework
- Flutter team for the cross-platform framework
- MediaPipe for pose estimation

---

## 📞 Support

For issues:
1. Check [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)
2. Review [SYSTEM_STATUS_REPORT.md](SYSTEM_STATUS_REPORT.md)
3. Check service logs in terminal windows

---

**Status**: 🟢 Fully Operational | **Version**: 1.0.0 | **Last Updated**: January 4, 2026

# Autism_Screening_Tool_25-26J-273
Final year Research project to create Autism screening tool for age 2-6 children
