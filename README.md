SenseAI – Auditory Response to Name (RTN) Module for Autism Screening

SenseAI – Auditory RTN Module is a research-based autism screening component that analyzes a child’s auditory response when their name is called.
The system uses parent-recorded videos, combining audio event detection and visual response analysis, to identify early auditory attention patterns associated with Autism Spectrum Disorder (ASD).








Key Components

Flutter Mobile App – Parent video upload & instructions

FastAPI Backend – Audio-video processing and feature extraction

ML Classifier – Auditory response classification model

Report Generator – Screening result & PDF report generation

Features
Auditory-Based Screening

Parent uploads a short video calling the child’s name

Automatic detection of name-calling audio event

Analysis of child’s reaction:

Head turning

Eye movement

Face orientation

Response delay

Clinical Analysis

Audio–visual synchronization

Response time measurement

Consistency analysis across calls

Risk assessment with confidence score

Professional PDF report generation

Child-Friendly & Non-Invasive

Natural home environment

No sensors or wearable devices

Minimal child cooperation required

Stress-free screening process

Architecture
+-------------------------------------------------------------+
|                  Flutter Mobile Application                  |
|                                                             |
|  +-------------------+                                      |
|  | Parent Video      |                                      |
|  | Upload Screen     |                                      |
|  | (Name Calling)    |                                      |
|  +-------------------+                                      |
|            |                                                |
|     Video & Audio Data                                      |
+------------|------------------------------------------------+
             |
             v
+-------------------------------------------------------------+
|                    FastAPI Backend                           |
|                                                             |
|  +-------------------+   +-------------------------------+ |
|  | Audio Event       |-> | Response Feature Analyzer     | |
|  | Detector          |   | (Head turn, eye movement,     | |
|  | (Name Call)       |   |  response delay)              | |
|  +-------------------+   +-------------------------------+ |
|                 |                      |                    |
|        Name Call Timestamp     Auditory Response Features   |
|                 +----------+--------------------------------+
|                            v                                 |
|                 Machine Learning Classifier                  |
|            (Auditory Response to Name Model)                 |
+----------------------------+--------------------------------+
                             |
                             v
+-------------------------------------------------------------+
|                Risk Assessment & PDF Report                  |
+-------------------------------------------------------------+

Machine Learning Model
Auditory Features Used

Response Timing

response_time – Delay after name call

reaction_latency_variance

Visual Response Indicators

head_turn_detected

eye_movement_detected

face_orientation_change

Attention Consistency

response_frequency

missed_responses

response_stability

Model Output
Score Range	Risk Category
0–30	Low Risk
31–60	Moderate Risk
61–100	Elevated Risk

Note: This is a screening tool, not a diagnostic system.

Project Structure
Auditory_RTN/
├── README.md
├── backend/
│   ├── main.py                    # FastAPI endpoints
│   ├── audio_detector.py          # Name-call detection
│   ├── video_response_analyzer.py # Head & eye movement analysis
│   ├── rtn_model.pkl              # Trained ML model
│   ├── requirements.txt
│   └── reports/                   # Generated PDF reports
│
└── frontend/
    ├── lib/
    │   ├── upload_video_screen.dart
    │   ├── instruction_screen.dart
    │   └── result_screen.dart
    └── pubspec.yaml

Usage Guide
Running an Auditory RTN Session

Parent records a short video calling the child’s name

Video is uploaded via the mobile app

Backend detects the name call in audio

Child’s response is analyzed using video frames

Auditory response features are extracted

ML model evaluates risk level

PDF report is generated

Clinical Importance

Auditory Response to Name (RTN) is one of the earliest behavioral indicators of autism.
Children with ASD may show:

Delayed or absent response

Reduced head turning

Limited eye contact

Inconsistent reactions

This module enables objective, early, and accessible screening.

Ethical & Research Considerations

Parent consent required

Data used strictly for research

No invasive procedures

Privacy and confidentiality ensured
