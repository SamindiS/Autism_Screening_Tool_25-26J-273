# SenseAI – Clinical Auditory Response to Name (RTN) Screening Module

**SenseAI** is a research-grade early autism screening system.  
This repository contains the **Auditory Response to Name (RTN)** module — an objective, non-invasive tool that analyzes a child's behavioral response when their name is called, using synchronized audio-visual processing.

The system is designed to support early detection of potential autism indicators through natural, home-based video recordings.

## ✨ Key Features

- Parent-friendly mobile application (Android & iOS)
- Simple video recording & upload interface
- Automatic name-call detection in audio
- Computer vision analysis of child's response:
  - Head turning
  - Eye movement/gaze shift
  - Face orientation change
  - Response latency
  - Response consistency
- Machine learning-based risk classification
- Professional PDF screening report generation
- Completely **non-invasive** — no wearables or clinical setting required

## 🏗️ Technology Stack

| Layer               | Technology              |
|---------------------|-------------------------|
| Mobile App          | Flutter (Android + iOS) |
| Backend API         | FastAPI (Python)        |
| Audio Processing    | Python (librosa, etc.)  |
| Computer Vision     | OpenCV / MediaPipe      |
| Machine Learning    | Scikit-learn            |
| Model File          | rtn_model.pkl           |
| Report Generation   | ReportLab / FPDF        |
| License             | Research Use Only       |

## ⚠️ Important Clinical & Legal Notes

> This tool is a **screening module only** — **NOT** a diagnostic instrument.  
> Results should **never** be used as a standalone diagnosis.  
> Always refer to qualified clinical professionals for autism assessment and diagnosis.

## Risk Classification (Output)

| Score Range | Risk Category     | Interpretation                     |
|-------------|-------------------|------------------------------------|
| 0–30        | Low Risk          | Typical response patterns          |
| 31–60       | Moderate Risk     | Some atypical indicators           |
| 61–100      | Elevated Risk     | Multiple atypical response markers |

## Project Structure
Auditory_RTN/
├── README.md
│
├── backend/
│   ├── main.py                 # FastAPI application
│   ├── audio_detector.py       # Name-call detection logic
│   ├── response_analyzer.py    # Head/eye/face analysis
│   ├── model/
│   │   └── rtn_model.pkl       # Trained ML model
│   ├── requirements.txt
│   └── reports/                # Generated PDF reports (output)
│
└── frontend/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── instruction_screen.dart
│   │   ├── upload_video_screen.dart
│   │   └── result_screen.dart
│   └── widgets/
└── pubspec.yaml


## 🚀 Quick Start (for Researchers)

1. Clone the repository
```bash
git clone https://github.com/YOUR-USERNAME/Auditory_RTN.git

##Backend setup
cd backend
python -m venv venv
source venv/bin/activate    # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload

##Frontend setup
cd frontend
flutter pub get
flutter run

