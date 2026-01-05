# 🧠 SenseAI - Autism Spectrum Disorder Screening System

**Project ID:** 25-26J-273  
**Version:** 1.0.0  
**Platform:** Cross-platform (Android/iOS Tablet, Web Admin Portal)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Technology Stack](#technology-stack)
- [Installation & Setup](#installation--setup)
- [Running the Project](#running-the-project)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Assessment Games](#assessment-games)
- [Machine Learning Engine](#machine-learning-engine)
- [Multilingual Support](#multilingual-support)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Project Overview

**SenseAI** is a comprehensive, tablet-based autism spectrum disorder (ASD) screening system designed for early detection in children aged 2-6 years. The system combines evidence-based cognitive assessments, parent questionnaires, and machine learning to provide automated risk scoring for clinical use in Sri Lankan healthcare settings.

### Problem Statement

- **Late Diagnosis**: Most ASD cases are diagnosed after age 4, missing critical early intervention windows
- **Limited Access**: Shortage of trained clinicians and long waiting times
- **Subjective Methods**: Traditional screening relies heavily on clinician observation with inconsistent results
- **Language Barriers**: Most screening tools available only in English, limiting accessibility
- **Lack of Age-Appropriate Tools**: Existing tools not designed for young children (2-6 years)

### Our Solution

- ✅ **Age-Stratified Cognitive Games**: Age-appropriate tasks ensure valid measurements
- ✅ **Machine Learning Risk Scoring**: Automated, objective risk assessment with confidence levels
- ✅ **Multilingual Support**: Full support for English, Sinhala (සිංහල), and Tamil (தமிழ்)
- ✅ **Offline-First Architecture**: Works in remote clinics without reliable internet
- ✅ **Professional ML Engine**: Production-ready FastAPI microservice for ML predictions

---

## ✨ Key Features

### 🎮 Interactive Assessment Games

1. **AI Doctor Bot (Ages 2-3.5)**
   - 10 critical screening questions
   - M-CHAT-R/F framework alignment
   - Parent-reported responses
   - Domain scoring (social, communication, behavior)

2. **Frog Jump Game (Ages 3.5-5.5)**
   - Go/No-Go inhibitory control task
   - Measures commission errors, RT variability
   - 30-40 trials with practice rounds
   - Real-time performance tracking

3. **Color-Shape Game (Ages 5.5-6.9)**
   - DCCS cognitive flexibility assessment
   - Rule-switching (color → shape)
   - Measures switch cost, perseverative errors
   - 5-minute timed assessment

### 📊 Core Capabilities

- **Child Profile Management**: Create/manage child profiles with automatic ID generation
- **Clinician Reflection**: Behavioral observation forms with 5-point Likert scale ratings
- **ML-Enhanced Risk Assessment**: Automated feature extraction with age-normalized scoring
- **Results Display**: User-friendly session summaries with charts and visualizations
- **Admin Web Portal**: Dashboard with analytics, data export, and clinician management
- **Offline-First**: Complete functionality without internet, automatic sync when available

---

## 🏗️ System Architecture

### Three-Tier Architecture

```
┌─────────────────────────────────┐
│   Flutter Mobile App (Tablet)   │
│   • Offline SQLite Storage      │
│   • Assessment Games            │
│   • Multilingual UI             │
└──────────────┬──────────────────┘
               │ HTTP/REST API
┌──────────────▼──────────────────┐
│   Node.js Backend (Port 3000)   │
│   • Data Validation             │
│   • ML Prediction API           │
│   • Firebase Sync               │
└──────────────┬──────────────────┘
               │ HTTP
┌──────────────▼──────────────────┐
│   FastAPI ML Engine (Port 8001) │
│   • Model Loading               │
│   • Feature Preprocessing       │
│   • Age Normalization           │
│   • Risk Prediction             │
└─────────────────────────────────┘
```

### Data Flow

1. **Mobile App** collects assessment data locally (SQLite)
2. **Backend Server** validates and processes data
3. **ML Engine** generates risk predictions
4. **Firebase** syncs data when online (optional)

---

## 💻 Technology Stack

### Frontend (Flutter Mobile App)
- **Framework**: Flutter 3.38+ (Dart 3.0+)
- **State Management**: Provider pattern
- **Local Storage**: SQLite (sqflite)
- **Charts**: fl_chart for data visualization
- **Localization**: ARB-based i18n system
- **Games**: HTML5 embedded via WebView
- **PDF Generation**: pdf package for reports

### Backend (Node.js)
- **Runtime**: Node.js with Express.js
- **Validation**: Joi schema validation
- **Authentication**: bcrypt PIN hashing
- **Database**: SQLite (local) + Firebase Firestore (cloud)
- **CORS**: Enabled for cross-origin requests

### ML Engine (FastAPI)
- **Framework**: FastAPI with Pydantic schemas
- **ML Libraries**: scikit-learn, joblib
- **Features**: Age normalization, feature scaling, calibration
- **API Docs**: Auto-generated Swagger UI

### Web Admin Portal
- **Framework**: React 18+ with TypeScript
- **UI Library**: Material-UI (MUI)
- **Build Tool**: Vite
- **Charts**: Recharts, MUI X Charts
- **i18n**: i18next for translations

---

## 🚀 Installation & Setup

### Prerequisites

- **Flutter**: 3.38+ (Dart 3.0+)
- **Node.js**: 18+ and npm
- **Python**: 3.8+ (for ML Engine)
- **Firebase Account**: (optional, for cloud sync)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Autism_Screening_Tool_25-26J-273
```

### 2. Setup Flutter Mobile App

```bash
# Install Flutter dependencies
flutter pub get

# Generate localization files
flutter gen-l10n
```

### 3. Setup Backend Server

```bash
cd senseai_backend
npm install
```

### 4. Setup ML Engine

```bash
cd senseai_backend/ml_engine

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Place model files in models/ directory:
# - asd_detection_model.pkl (or asd_screening_model_calibrated.pkl)
# - feature_scaler.pkl
# - feature_names.json
# - age_norms.json (optional)
```

### 5. Setup Web Admin Portal

```bash
cd web_application
npm install
```

---

## 🏃 Running the Project

### Quick Start (All Services)

We've created PowerShell scripts to start all services:

**Windows PowerShell:**
```powershell
# Start all services in separate windows
.\start_all.ps1
```

Or start individually:
```powershell
# Backend Server
.\start_backend.ps1

# Web Application
.\start_webapp.ps1

# Python ML Engine
.\start_python_engine.ps1
```

### Manual Start

#### 1. Start Backend Server

```bash
cd senseai_backend
npm start
```

Backend runs on: **http://localhost:3000**

#### 2. Start ML Engine

```bash
cd senseai_backend/ml_engine
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

ML Engine runs on: **http://localhost:8001**
- Swagger UI: http://localhost:8001/docs
- Health Check: http://localhost:8001/health

#### 3. Start Web Admin Portal

```bash
cd web_application
npm run dev
```

Web app runs on: **http://localhost:5173**

#### 4. Run Flutter Mobile App

```bash
# Check available devices
flutter devices

# Run on emulator/device
flutter run

# Or specify device
flutter run -d <device-id>
```

**Note**: For Android emulator, backend URL should be `http://10.0.2.2:3000`

---

## 📁 Project Structure

```
Autism_Screening_Tool_25-26J-273/
├── lib/                          # Flutter mobile app source
│   ├── core/                     # Core services & utilities
│   ├── data/                     # Data models & repositories
│   ├── features/                 # Feature modules
│   │   ├── assessment/           # Assessment games
│   │   ├── auth/                 # Authentication
│   │   ├── dashboard/            # Dashboard
│   │   └── settings/             # Settings
│   └── main.dart                 # App entry point
├── senseai_backend/              # Node.js backend
│   ├── routes/                   # API routes
│   ├── services/                 # Business logic
│   ├── ml_engine/                # FastAPI ML service
│   │   ├── app/                  # FastAPI application
│   │   │   ├── api/              # API endpoints
│   │   │   ├── ml/               # ML logic
│   │   │   └── schemas/          # Request/response schemas
│   │   └── models/               # ML model files
│   └── server.js                 # Backend entry point
├── web_application/              # React admin portal
│   ├── src/
│   │   ├── components/           # React components
│   │   ├── services/             # API services
│   │   └── locales/              # Translation files
│   └── package.json
├── assets/                       # App assets
│   ├── audio/                    # Audio files
│   ├── fonts/                    # Custom fonts
│   ├── games/                    # HTML5 game files
│   ├── images/                   # Images
│   └── translations/              # Translation JSON files
├── docs/                         # Documentation
├── ML_TRAINING/                  # ML training notebooks
└── README.md                     # This file
```

---

## 📡 API Documentation

### Backend API (Port 3000)

#### Health Check
- `GET /health` - Server health status

#### Clinicians
- `POST /api/clinicians/register` - Register/update clinician
- `POST /api/clinicians/login` - Login with PIN
- `GET /api/clinicians/me` - Get current clinician info

#### Children
- `POST /api/children` - Create new child
- `GET /api/children` - Get all children
- `GET /api/children/:id` - Get child by ID
- `PUT /api/children/:id` - Update child
- `DELETE /api/children/:id` - Delete child

#### Sessions (Assessments)
- `POST /api/sessions` - Create new assessment session
- `GET /api/sessions` - Get all sessions
- `GET /api/sessions/:id` - Get session by ID
- `GET /api/sessions/child/:childId` - Get sessions by child

### ML Engine API (Port 8001)

#### Health Check
- `GET /health` - Service status and model availability

#### Prediction
- `POST /predict` - Predict ASD risk from ML features

**Request Example:**
```json
{
  "age_months": 48,
  "features": {
    "post_switch_accuracy": 65,
    "switch_cost_ms": 450,
    "perseverative_error_rate_post_switch": 35
  },
  "age_group": "4-5",
  "session_type": "color_shape"
}
```

**Response Example:**
```json
{
  "prediction": 1,
  "probability": [0.21, 0.79],
  "confidence": 0.79,
  "risk_level": "high",
  "risk_score": 78.9,
  "asd_probability": 0.789
}
```

**Interactive API Docs**: http://localhost:8001/docs

---

## 🎮 Assessment Games

### Age-Based Routing

| Age Range | Assessment Type | Components |
|-----------|----------------|------------|
| **2.0 ≤ age < 3.5** | Parental Questionnaire | AI Doctor Bot (10 questions) + Clinician Reflection (manual tasks) |
| **3.5 ≤ age < 5.5** | Interactive Game | Frog Jump Game + Clinician Reflection (behavioral observations) |
| **5.5 ≤ age < 6.9** | Interactive Game | Color-Shape Game + Clinician Reflection (behavioral observations) |

### Game Details

#### 1. AI Doctor Bot (Ages 2-3.5)
- **Type**: Parent-reported questionnaire
- **Questions**: 10 critical screening questions
- **Framework**: M-CHAT-R/F inspired
- **Domains**: Social, Communication, Behavior
- **Output**: Domain scores and risk indicators

#### 2. Frog Jump Game (Ages 3.5-5.5)
- **Type**: Go/No-Go inhibitory control task
- **Trials**: 30-40 trials with practice rounds
- **Measures**: 
  - Commission errors
  - Reaction time variability
  - Response accuracy
- **Duration**: ~5-7 minutes

#### 3. Color-Shape Game (Ages 5.5-6.9)
- **Type**: DCCS (Dimensional Change Card Sort) cognitive flexibility
- **Mechanism**: Rule-switching (color → shape)
- **Measures**:
  - Switch cost (ms)
  - Perseverative errors
  - Post-switch accuracy
  - Pre-switch vs post-switch performance
- **Duration**: ~5 minutes

---

## 🤖 Machine Learning Engine

### Features

- **Professional Structure**: Modular, scalable, maintainable
- **Auto-Generated API Docs**: Swagger UI at `/docs`
- **Structured Logging**: Audit trail for clinical use
- **Age Normalization**: Z-score calculation from control norms
- **Feature Validation**: Safe error handling
- **Child ID Tracking**: Ethics compliance

### Model Requirements

Place these files in `senseai_backend/ml_engine/models/`:
- `asd_detection_model.pkl` (or `asd_screening_model_calibrated.pkl`)
- `feature_scaler.pkl`
- `feature_names.json`
- `age_norms.json` (optional, for age normalization)

### ML Features Extracted

The system extracts 18+ features including:
- Post-switch accuracy
- Switch cost (ms)
- Perseverative error rate
- Commission error rate
- Reaction time variability
- Average reaction times
- And more...

### Risk Levels

- **High Risk**: ≥70% ASD probability
- **Moderate Risk**: 40-69% ASD probability
- **Low Risk**: <40% ASD probability

---

## 🌍 Multilingual Support

### Supported Languages

- **English** (en) - Default
- **Sinhala** (සිංහල) - si
- **Tamil** (தமிழ்) - ta

### Implementation

- **Flutter App**: ARB-based localization system
- **Web Portal**: i18next with JSON translation files
- **Fonts**: 
  - Sinhala: IskoolaPota
  - Tamil: Bamini
  - English: System default

### Language Switching

Users can switch languages in the Settings screen. All UI elements, instructions, and voice prompts are localized.

---

## 🔐 Security & Privacy

- **PIN-Based Authentication**: Secure clinician login with bcrypt hashing
- **Offline-First**: Data stored locally, reducing security risks
- **Data Validation**: Comprehensive input validation and sanitization
- **Child ID Anonymization**: Sequential IDs (LRH-001, LRH-002...) for privacy
- **Firebase Security**: Firestore security rules for cloud data

---

## 📊 Data Export

### CSV Export

The admin portal supports CSV export for:
- Child profiles
- Assessment sessions
- Game trials
- ML features

Perfect for:
- ML model training
- Research analysis
- Data backup

### PDF Reports

The mobile app can generate PDF reports for:
- Session summaries
- Assessment results
- Risk scores

---

## 🧪 Testing

### Flutter Tests

```bash
flutter test
```

### Backend Tests

```bash
cd senseai_backend
npm test
```

### ML Engine Tests

```bash
cd senseai_backend/ml_engine
python -m pytest
```

---

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **Project Documentation**: `docs/project/`
- **API Guides**: `docs/api/`
- **Setup Guides**: Various setup and troubleshooting guides
- **ML Training**: `ML_TRAINING/` directory

---

## 🛠️ Development

### Code Structure

- **Flutter**: Provider pattern for state management
- **Backend**: RESTful API with Express.js
- **ML Engine**: FastAPI with Pydantic schemas
- **Web Portal**: React with TypeScript

### Best Practices

- ✅ Offline-first architecture
- ✅ Comprehensive error handling
- ✅ Input validation at all layers
- ✅ Structured logging
- ✅ Type safety (TypeScript, Pydantic)
- ✅ Modular code structure

---

## 🐛 Troubleshooting

### Port Already in Use

If you get "EADDRINUSE" errors:

**Windows:**
```powershell
# Find process using port
netstat -ano | findstr :3000

# Kill process
taskkill /PID <PID> /F
```

**Linux/Mac:**
```bash
lsof -ti:3000 | xargs kill -9
```

### ML Engine Not Starting

1. Check virtual environment is activated
2. Verify model files are in `models/` directory
3. Check `logs/ml_engine.log` for errors

### Flutter Build Issues

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📝 License

This project is for research and clinical use. See LICENSE file for details.

---

## 👥 Contributing

This is a research project (Project ID: 25-26J-273). For contributions, please contact the project maintainers.

---

## 📞 Support

For issues, questions, or contributions:
- Check the `docs/` directory for detailed guides
- Review troubleshooting sections in documentation
- Contact project maintainers

---

## 🎉 Acknowledgments

- **Research Team**: Project 25-26J-273
- **Clinical Partners**: Healthcare institutions in Sri Lanka
- **Open Source Libraries**: Flutter, React, FastAPI, and all contributors

---

**Built with ❤️ for early ASD detection and intervention**

---

*Last Updated: 2025*
