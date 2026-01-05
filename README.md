# SenseAI - Clinical Gaze Tracking for Autism Screening

SenseAI is a research-grade autism screening tool that uses front-facing camera eye-tracking to assess gaze patterns in young children. The app engages children with interactive games while collecting gaze data, which is analyzed using a machine learning model trained on real clinical data.

![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue)
![Python](https://img.shields.io/badge/Python-3.10+-green)
![License](https://img.shields.io/badge/License-Research%20Only-orange)

### Key Components

1. **Flutter Mobile App** - Cross-platform app with child-friendly games
2. **FastAPI Backend** - Gaze data analysis and PDF report generation
3. **ML Classifier** - GradientBoostingClassifier trained on real toddler ASD eye-tracking data

---

## Features

### Interactive Games

- **Butterfly Chase Game** - Tests smooth pursuit eye tracking (15 seconds)
- **Bubble Pop Game** - Tests visual attention and gaze-touch coordination (30 seconds)

### Clinical Analysis

- Real-time face detection and gaze tracking using Google ML Kit
- 9-point eye calibration system
- Comprehensive gaze pattern analysis
- Risk assessment with confidence scores
- Professional PDF report generation

### Child-Friendly Design

- Pastel color themes (soft greens, pinks, cyans)
- Engaging animations and sounds
- Clear visual instructions
- Non-invasive, game-based assessment

---

## Architecture

```
+-------------------------------------------------------------+
|                     Flutter Mobile App                       |
|  +-------------+  +-------------+  +---------------------+   |
|  | Child Info  |->| Calibration |->|  Games (Butterfly/  |   |
|  |   Screen    |  |   Screen    |  |     Bubbles)        |   |
|  +-------------+  +-------------+  +---------------------+   |
|                            |                                 |
|                   Gaze Data Collection                       |
|            (ML Kit Face Detection + Iris Tracking)           |
+----------------------------+---------------------------------+
                             | HTTP/REST API
                             v
+-------------------------------------------------------------+
|                    FastAPI Backend                           |
|  +--------------+  +--------------+  +-----------------+    |
|  | Gaze Pattern |->| ML Classifier |->|  PDF Report     |    |
|  |   Analyzer   |  | (95.2% acc)   |  |  Generator      |    |
|  +--------------+  +--------------+  +-----------------+    |
+-------------------------------------------------------------+
```

---

## Machine Learning Model

### Training Data

The classifier was trained on the **Toddler ASD Eye-Tracking Dataset** from Zenodo:

> "How Attention to Faces and Objects Changes Over Time in Toddlers with Autism Spectrum Disorders: Preliminary Evidence from An Eye Tracking Study"
>
> **Source:** https://zenodo.org/records/4062063

**Dataset Characteristics:**

- **Subjects:** 27 toddlers (18-33 months old)
- **Groups:** ASD (Group 1) vs Typically Developing (Group 0)
- **Metrics:** Fixation Duration, Transition patterns, Dwell time, Gaze shift frequency
- **Validation:** ADOS scores (Autism Diagnostic Observation Schedule)

### Model Details

| Property    | Value                                  |
| ----------- | -------------------------------------- |
| Algorithm   | GradientBoostingClassifier             |
| Features    | 31 eye-tracking metrics                |
| Accuracy    | 95.2% (Leave-One-Out Cross-Validation) |
| AUC-ROC     | 0.97                                   |
| Sensitivity | 93%                                    |
| Specificity | 97%                                    |

### Key Features Used

The model analyzes these gaze pattern metrics:

1. **Fixation Metrics**

   - `fixation_count` - Number of stable gaze points
   - `mean_fixation_duration` - Average fixation length
   - `std_fixation_duration` - Fixation variability
   - `total_fixation_time` - Total time in fixations

2. **Saccade Metrics**

   - `saccade_count` - Number of rapid eye movements
   - `mean_saccade_amplitude` - Average saccade distance
   - `mean_saccade_velocity` - Saccade speed

3. **Attention Metrics**

   - `time_on_target` - % time looking at target
   - `time_in_center` - % time in screen center
   - `attention_switches` - Gaze shift frequency

4. **Tracking Metrics**
   - `smooth_pursuit_ratio` - Smooth vs jerky tracking
   - `gaze_dispersion` - Spread of gaze points
   - `lag_behind_target` - Tracking delay

### Model Files

```
backend/
├── autism_classifier.pkl           # Trained classifier model
├── autism_classifier_scaler.pkl    # Feature scaler
├── autism_classifier_metrics.json  # Training metrics
└── datasets/
    └── toddler_asd_eye_tracking.xlsx  # Training dataset
```

---

## Setup Instructions

### Prerequisites

- **Python 3.10+**
- **Flutter 3.38+**
- **Android Studio** or **Xcode** (for mobile development)
- **Physical Android/iOS device** (camera required)

### Backend Setup

1. **Navigate to backend directory:**

   ```bash
   cd backend
   ```

2. **Create virtual environment:**

   ```bash
   python -m venv venv

   # Windows
   venv\Scripts\activate

   # macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies:**

   ```bash
   pip install -r requirements.txt
   ```

4. **Start the server:**

   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

   The API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory:**

   ```bash
   cd frontend
   ```

2. **Get Flutter dependencies:**

   ```bash
   flutter pub get
   ```

3. **Update server IP address:**

   Edit `lib/main.dart` and update the `baseUrl`:

   ```dart
   // Line ~30: Update to your server's IP address
   static const String baseUrl = 'http://YOUR_SERVER_IP:8000';
   ```

4. **Run on device:**

   ```bash
   # List available devices
   flutter devices

   # Run on specific device
   flutter run -d <device_id>
   ```

### Retraining the Model (Optional)

If you want to retrain with updated data:

```bash
cd backend
python train_with_real_data.py
```

This will:

- Load the dataset from `datasets/toddler_asd_eye_tracking.xlsx`
- Train a new GradientBoostingClassifier
- Save model files to the backend directory
- Output training metrics and cross-validation results

---

## Project Structure

```
SenseAI/
├── README.md                    # This file
├── backend/
│   ├── main.py                  # FastAPI server & endpoints
│   ├── model.py                 # ML model wrapper
│   ├── gaze_analyzer.py         # Gaze pattern analysis
│   ├── train_with_real_data.py  # Model training script
│   ├── requirements.txt         # Python dependencies
│   ├── autism_classifier.pkl    # Trained model
│   ├── autism_classifier_scaler.pkl
│   ├── datasets/
│   │   └── toddler_asd_eye_tracking.xlsx
│   └── reports/                 # Generated PDF reports
│
└── frontend/
    ├── lib/
    │   ├── main.dart            # App entry point & screens
    │   ├── gaze/
    │   │   ├── gaze_service.dart       # Gaze tracking service
    │   │   └── gaze_calibration_screen.dart
    │   └── widgets/
    │       ├── animated_butterfly.dart  # Butterfly game
    │       └── interactive_bubbles.dart # Bubble game
    ├── pubspec.yaml             # Flutter dependencies
    └── android/                 # Android configuration
```

---

## Usage Guide

### Running a Test Session

1. **Start the app** on a mobile device
2. **Enter child information** (name and age)
3. **Enter perant information** (name,email,contact number & relationship)
4. **Calibration** - Child follows animated characters with eyes
5. **Butterfly Game** (15 seconds) - Child follows butterfly with eyes
6. **Bubble Game** (30 seconds) - Child pops bubbles by looking or touching
7. **Results** - View risk assessment and download PDF report

### Interpreting Results

| Score Range | Risk Category | Interpretation                                                  |
| ----------- | ------------- | --------------------------------------------------------------- |
| 0-30        | Low Risk      | Typical gaze patterns observed                                  |
| 31-60       | Moderate Risk | Some atypical patterns; monitoring recommended                  |
| 61-100      | Elevated Risk | Atypical patterns detected; professional evaluation recommended |

**Important:** This is a screening tool only, not a diagnostic instrument. Always consult qualified healthcare professionals for diagnosis.

---

## Clinical Metrics

### Gaze Pattern Analysis

The app analyzes these clinical markers:

1. **Joint Attention**

   - Ability to follow gaze/pointing
   - Response to social cues

2. **Visual Tracking**

   - Smooth pursuit accuracy
   - Target following ability

3. **Attention Patterns**

   - Fixation stability
   - Attention switching frequency
   - Center bias (tendency to look at screen center)

4. **Motor Coordination**
   - Gaze-touch coordination (bubble game)
   - Response latency

### Red Flags for ASD

The classifier looks for these patterns:

- Reduced social attention (less time on faces/social stimuli)
- Decreased gaze following ability
- Atypical fixation patterns
- Reduced smooth pursuit
- Limited visual exploration

---

## API Documentation

### Endpoints

#### `POST /submit_info`

Submit child information to start a new test session.

```json
{
  "name": "Child Name",
  "age": 3,
  "test_datetime": "2024-12-07T10:30:00"
}
```

#### `POST /upload_gaze`

Upload gaze tracking data from games.

```json
{
  "test_id": "uuid-string",
  "events": [
    {
      "timestamp": 1234567890.123,
      "x": 0.5,
      "y": 0.5,
      "target_x": 0.6,
      "target_y": 0.4,
      "game": "butterfly",
      "on_target": true
    }
  ]
}
```

#### `GET /report/{test_id}`

Download the generated PDF report.

---

## Research References

1. **Training Dataset:**

   - Zenodo Dataset: "Toddler ASD Eye-Tracking Study" (https://zenodo.org/records/4062063)

2. **Key Research Papers:**
   - Jones, W., & Klin, A. (2013). Attention to eyes is present but in decline in 2-6-month-old infants later diagnosed with autism.
   - Klin, A., et al. (2009). Two-year-olds with autism orient to non-social contingencies rather than biological motion.
   - Chawarska, K., et al. (2013). Decreased spontaneous attention to social scenes in 6-month-old infants later diagnosed with ASD.
