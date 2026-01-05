# 🧠 SenseAI – Early Autism Spectrum Disorder (ASD) Screening System

**Project ID:** 25-26J-273
**Version:** 1.0.0
**Target Age Group:** 2–6 years
**Platforms:** Android / iOS Tablet · Web Admin Portal
**Context:** Research & Clinical Screening (Sri Lanka)


## 📌 Overview

**SenseAI** is a tablet-based, AI-powered early screening system for **Autism Spectrum Disorder (ASD)** designed for children aged **2–6 years**.
The system combines **gamified cognitive assessments**, **clinician input**, and **machine learning–based risk scoring** to provide an **objective, scalable, and child-friendly screening solution**, particularly suited for **low-resource healthcare settings**.

⚠️ **Important:** SenseAI is a **screening tool**, not a diagnostic system. All results must be reviewed by qualified healthcare professionals.


## 🚨 Problem Statement

Current ASD screening approaches face several challenges:

* Late diagnosis (often after age 4)
* Heavy reliance on subjective clinician observations
* Long waiting times and limited specialist availability
* Lack of culturally adapted tools
* Poor suitability for very young children
* English-only screening instruments

These limitations delay early intervention and reduce access to timely support.


## ✅ Solution Summary

SenseAI addresses these challenges through:

* 🎮 **Age-appropriate cognitive games**
* 📊 **Objective, automated behavioral metrics**
* 🤖 **Machine learning–based risk prediction**
* 🌍 **Multilingual support (English, Sinhala, Tamil)**
* 🔌 **Offline-first design for remote clinics**
* 📱 **Tablet-optimized, child-friendly UI**


## ✨ Key Features

### 🎮 Interactive Assessment Modules

| Age Range | Assessment Type | Module                            |
| --------- | --------------- | --------------------------------- |
| 2.0 – 3.5 | Parent-reported | AI Doctor Bot (M-CHAT-R inspired) |
| 3.5 – 5.5 | Game-based      | Frog Jump (Go/No-Go task)         |
| 5.5 – 6.9 | Game-based      | Color–Shape (DCCS rule-switching) |

---

### 🧠 Cognitive & Behavioral Measures

* Reaction time (RT)
* Switch cost (pre vs post rule-change)
* Perseverative errors
* Commission / omission errors
* Accuracy drop after rule switching
* Response variability

---

### 📊 Core System Capabilities

* Child profile management with anonymized IDs
* Clinician reflection & behavioral observation forms
* ML-based ASD risk scoring (Low / Moderate / High)
* Visual dashboards & charts
* Offline data capture with automatic sync
* CSV & PDF report export

---

## 🏗️ System Architecture

### High-Level Architecture

```
Flutter Tablet App
  └─ SQLite (Offline Storage)
        ↓
Node.js Backend (REST API)
  └─ Validation & Sync
        ↓
FastAPI ML Engine
  └─ Feature Processing & Risk Prediction
```

---

## 🧰 Technology Stack

### 📱 Mobile App

* Flutter 3.38+
* Dart 3.0+
* SQLite (sqflite)
* fl_chart
* ARB-based localization
* HTML5 games via WebView

### 🖥 Backend

* Node.js + Express
* Joi validation
* SQLite (local) + Firebase Firestore (optional)
* CORS enabled

### 🤖 ML Engine

* FastAPI
* scikit-learn
* joblib
* Pydantic schemas
* Swagger UI documentation

### 🌐 Web Admin Portal

* React 18 + TypeScript
* Vite
* Material-UI (MUI)
* Recharts
* i18next

---

## 🚀 Installation & Setup

### Prerequisites

* Flutter 3.38+
* Node.js 18+
* Python 3.8+
* Git
* (Optional) Firebase account

---

### Clone Repository

```bash
git clone <repository-url>
cd Autism_Screening_Tool_25-26J-273
```

---

### Flutter App Setup

```bash
flutter pub get
flutter gen-l10n
```

---

### Backend Setup

```bash
cd senseai_backend
npm install
npm start
```

Runs on: `http://localhost:3000`

---

### ML Engine Setup

```bash
cd senseai_backend/ml_engine
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

Swagger Docs: `http://localhost:8001/docs`

---

### Web Admin Portal

```bash
cd web_application
npm install
npm run dev
```

Runs on: `http://localhost:5173`

---

## 📁 Project Structure

```
Autism_Screening_Tool_25-26J-273/
│
├── lib/                    # Flutter app
├── senseai_backend/        # Node.js backend
│   └── ml_engine/          # FastAPI ML service
├── web_application/        # React admin dashboard
├── assets/                 # Images, games, translations
├── docs/                   # Documentation
├── ML_TRAINING/            # ML notebooks
└── README.md
```

---

## 🤖 Machine Learning Engine

### Models Used

* Logistic Regression
* Random Forest
* Support Vector Machine (SVM)
* Gradient Boosted Trees (XGBoost, LightGBM, CatBoost)
* Ordinal Regression

### Risk Levels

| ASD Probability | Risk     |
| --------------- | -------- |
| ≥ 70%           | High     |
| 40–69%          | Moderate |
| < 40%           | Low      |

---

## 🌍 Multilingual Support

* English (en)
* Sinhala (සිංහල)
* Tamil (தமிழ்)

Implemented using:

* Flutter ARB localization
* i18next for web
* Localized audio instructions

---

## 🔐 Security & Privacy

* PIN-based clinician authentication
* Child ID anonymization
* Offline-first data storage
* Encrypted backups
* Secure Firestore rules (optional)

---

## 📊 Reporting & Export

* CSV export (sessions, trials, ML features)
* PDF reports for caregivers & clinicians
* Longitudinal progress tracking

---

## 🧪 Testing

```bash
flutter test
npm test
pytest
```

---

## 👥 Research Team

* **Sankalpani M.H.S (IT22128904)** – Cognitive Flexibility & Rule Switching
* **Karunathilaka S.M** – Visual Attention & Preference
* **Ilanganthilake I.M.H** – Response to Name (RTN)
* **Senavirathna K.G.G.K** – Restricted & Repetitive Behaviors (RRBs)

---

## 📄 License

For **research and clinical screening purposes only**.
See `LICENSE` for details.

---

## 🙌 Acknowledgments

* Sri Lanka Institute of Information Technology (SLIIT)
* Lady Ridgeway Hospital (LRH)
* Healthcare professionals & caregivers
* Open-source community

---

**Built with ❤️ to support early autism screening and intervention**

*Last Updated: 2025*


