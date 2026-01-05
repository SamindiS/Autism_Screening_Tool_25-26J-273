# SenseAI – Clinical Auditory Response to Name (RTN) Screening Module

SenseAI is a **research-grade autism screening system** designed to support early identification of autism-related behavioral markers.
This repository contains the **Auditory Response to Name (RTN) Screening Module**, which evaluates how a child responds when their name is called using **audio–visual analysis**.

Auditory Response to Name is one of the **earliest and most reliable behavioral indicators** associated with Autism Spectrum Disorder (ASD).
This module enables **non-invasive, home-based screening** using a short parent-recorded video.


---

## Platforms & Technologies

* **Platforms:** Android | iOS
* **Frontend:** Flutter
* **Backend:** FastAPI (Python)
* **Machine Learning:** Scikit-learn
* **License:** Research Use Only

---

## Key Components

### 📱 Flutter Mobile Application

* Parent-friendly video recording & upload interface
* Clear instructions for recording name-calling videos
* Result visualization and report download

### ⚙️ FastAPI Backend

* Audio event detection (name-calling timing)
* Video frame analysis
* Audio–video synchronization
* Feature extraction and preprocessing

### 🤖 Machine Learning Model

* Classifies auditory response patterns
* Outputs a quantitative risk score
* Designed for early autism screening research

### 📄 PDF Report Generator

* Clinically styled screening summary
* Risk level with confidence score
* Suitable for sharing with healthcare professionals

---

## Features

### 🔊 Auditory-Based Screening

* Parent records a short video calling the child’s name
* Automatic detection of the name-calling audio event
* Analysis of child’s behavioral response:

  * Head turning
  * Eye movement
  * Face orientation change
  * Response delay

### 🧠 Clinical Analysis

* Precise audio–video synchronization
* Response time measurement
* Response consistency analysis
* Risk assessment with confidence score

### 👶 Child-Friendly Design

* Natural home environment
* No wearable sensors
* Non-invasive and stress-free
* Suitable for toddlers and young children

---

## System Architecture

```
+-------------------------------------------------------------+
|                  Flutter Mobile Application                  |
|                                                             |
|  Child Info Screen → Parent Info Screen → Video Upload       |
|                                                             |
|        (Parent calls the child’s name in the video)          |
|                                                             |
+----------------------------|--------------------------------+
                             |
                       Video & Audio Data
                             |
                             v
+-------------------------------------------------------------+
|                    FastAPI Backend                           |
|                                                             |
|  Audio Event Detector  →  Response Feature Analyzer          |
|                                                             |
|   (Name call timing)      (Head turn, eye movement, delay)  |
|                                                             |
|              Machine Learning Classifier                    |
+----------------------------|--------------------------------+
                             |
                             v
+-------------------------------------------------------------+
|              Risk Assessment & PDF Report                   |
+-------------------------------------------------------------+
```

---

## Machine Learning Model
### Features Used
- response_time
- head_turn_detected
- eye_movement_detected
- face_orientation_change
- response_consistency
- missed_responses

### Risk Levels
| Score Range | Risk Category |
|------------|--------------|
| 0–30       | Low Risk     |
| 31–60      | Moderate Risk|
| 61–100     | Elevated Risk|

### Auditory & Behavioral Features Used

* `response_time`
* `head_turn_detected`
* `eye_movement_detected`
* `face_orientation_change`
* `response_consistency`
* `missed_responses`

### Risk Level Interpretation

| Score Range | Risk Category |
| ----------- | ------------- |
| 0 – 30      | Low Risk      |
| 31 – 60     | Moderate Risk |
| 61 – 100    | Elevated Risk |

> These scores indicate **screening risk only** and must not be used for diagnosis.

---

## Project Structure

```
Auditory_RTN/
├── README.md
├── backend/
│   ├── main.py                # FastAPI entry point
│   ├── audio_detector.py      # Name-calling audio detection
│   ├── response_analyzer.py   # Visual response analysis
│   ├── rtn_model.pkl          # Trained ML model
│   ├── requirements.txt
│   └── reports/               # Generated PDF reports
│
└── frontend/
    ├── lib/
    │   ├── upload_video_screen.dart
    │   ├── instruction_screen.dart
    │   └── result_screen.dart
    └── pubspec.yaml
```

---


## Usage Guide

1. Parent records a short video calling the child’s name
2. Video is uploaded via the mobile application
3. Audio event (name call) is automatically detected
4. Child’s visual and auditory response is analyzed
5. Machine learning model evaluates risk level
6. PDF screening report is generated

---

## Research Significance

Auditory Response to Name (RTN) is a well-established early behavioral marker in autism research.
This module contributes to:

* Early autism screening research
* Objective behavioral analysis
* Home-based and scalable assessments
* Multimodal (audio–visual) autism research

---

## Ethical Considerations

* Explicit parent/guardian consent required
* No invasive procedures
* No wearable devices
* Data confidentiality and secure handling
* Intended strictly for **research and screening purposes**

---

## License

**Research Use Only**

This software is intended for academic, clinical research, and non-commercial use only.
It is **not approved for diagnostic or clinical decision-making**.

---

