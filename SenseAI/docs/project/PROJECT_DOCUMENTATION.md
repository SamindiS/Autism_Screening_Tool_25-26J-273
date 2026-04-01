# SenseAI - Complete Project Documentation

## 📋 Project Overview

**SenseAI** is a comprehensive, multilingual Autism Spectrum Disorder (ASD) screening tool designed for clinical use on tablets. The application provides age-appropriate assessments for children aged 2-6.9 years, combining parental questionnaires, interactive games, and clinician reflections to identify autism risk levels.

---

## 🏗️ Architecture

### **Technology Stack**

#### **Frontend (Flutter)**
- **Framework**: Flutter 2.10.5 (Dart 2.16.2)
- **State Management**: Provider pattern
- **Local Database**: SQLite (sqflite)
- **HTTP Client**: http package (v0.13.5)
- **Localization**: Flutter's ARB-based localization system
- **Games**: HTML5 games embedded via WebView

#### **Backend (Node.js)**
- **Runtime**: Node.js (v14+)
- **Framework**: Express.js
- **Database**: SQLite3
- **Authentication**: bcrypt for PIN hashing
- **Validation**: Joi schema validation
- **API**: RESTful API design

### **Architecture Pattern**
```
Flutter App (Tablet)
     ↓ (HTTP REST API)
Node.js + Express (Local Server)
     ↓ (SQLite DB)
Local Storage (offline-first)
     ↓ (Future: Firebase Sync)
Cloud Storage (when online)
```

---

## 📱 Application Features

### **1. Multilingual Support**
- **Languages**: English, Sinhala (සිංහල), Tamil (தமிழ்)
- **Implementation**: Flutter ARB localization system
- **Auto-detection**: Device language auto-detection
- **Font Support**: 
  - Sinhala: IskoolaPota
  - Tamil: Bamini
  - English: System default

### **2. Age-Based Assessment System**

The application routes children to different assessment types based on their age:

| Age Range | Assessment Type | Components |
|-----------|----------------|------------|
| **2.0 ≤ age < 3.5** | Parental Questionnaire | AI Doctor Bot (10 questions) + Clinician Reflection (manual tasks) |
| **3.5 ≤ age < 5.5** | Interactive Game | Frog Jump Game + Clinician Reflection (behavioral observations) |
| **5.5 ≤ age < 6.9** | Interactive Game | Color-Shape Game + Clinician Reflection (behavioral observations) |

### **3. Assessment Components**

#### **A. AI Doctor Bot (Ages 2-3.5)**
- **Type**: Parental questionnaire
- **Questions**: 10 behavioral questions
- **Format**: Multiple choice with 4-5 options
- **Topics**: Social interaction, communication, repetitive behaviors, sensory responses
- **Flow**: Parent answers → Clinician Reflection → Results

#### **B. Frog Jump Game (Ages 3.5-5.5)**
- **Type**: Interactive HTML5 game
- **Objective**: Cognitive flexibility and rule-switching assessment
- **Features**: 
  - Rule changes during gameplay
  - Reaction time tracking
  - Accuracy measurement
  - Trial-by-trial data collection
- **Flow**: Game → Clinician Reflection → Results

#### **C. Color-Shape Game (Ages 5.5-6.9)**
- **Type**: Interactive HTML5 game
- **Objective**: Advanced cognitive flexibility assessment
- **Features**:
  - 5-minute timer
  - Streak counter
  - Rule change animations
  - Advanced metrics tracking
- **Flow**: Game → Clinician Reflection → Results

#### **D. Clinician Reflections**
- **Ages 2-3.5**: Manual task observations (cognitive flexibility, rule-switching)
- **Ages 3.5-6.9**: Behavioral observation questions (5-point Likert scale)
- **Metrics**: Risk score calculation based on observations

### **4. Risk Assessment**
- **Risk Levels**: Low, Moderate, High
- **Calculation**: Based on game metrics, questionnaire responses, and clinician observations
- **Display**: Comprehensive results screen with recommendations

---

## 📂 Project Structure

### **Frontend Structure**

```
lib/
├── main.dart                          # App entry point
├── l10n/                              # Localization files (ARB format)
│   ├── app_en.arb                     # English translations
│   ├── app_si.arb                     # Sinhala translations
│   ├── app_ta.arb                     # Tamil translations
│   └── app_localizations.dart         # Auto-generated localization class
│
├── core/                              # Core functionality
│   ├── providers/
│   │   └── language_provider.dart     # Language state management
│   ├── services/
│   │   ├── api_service.dart           # Backend API integration
│   │   ├── auth_service.dart          # Authentication service
│   │   ├── storage_service.dart       # Local database operations
│   │   ├── language_preference_service.dart  # Language persistence
│   │   └── translation_helper.dart    # Translation utilities
│   └── utils/
│       └── age_calculator.dart        # Age calculation utilities
│
├── data/
│   └── models/
│       ├── child.dart                 # Child data model
│       ├── session.dart               # Assessment session model
│       └── game_results.dart          # Game results model
│
├── features/                          # Feature modules
│   ├── auth/
│   │   ├── login_screen.dart          # Clinician login/registration
│   │   └── clinician_profile_screen.dart  # Profile management
│   │
│   ├── dashboard/
│   │   ├── dashboard_screen.dart     # Main dashboard
│   │   └── widgets/                  # Dashboard components
│   │
│   ├── cognitive/
│   │   ├── cognitive_dashboard_screen.dart  # Cognitive assessment dashboard
│   │   ├── add_child_screen.dart     # Add new child
│   │   ├── age_select_screen.dart    # Age-based routing
│   │   ├── child_list_screen.dart    # List of children
│   │   ├── reflection_screen.dart    # Reflection (ages 3.5-6.9)
│   │   └── reflection_screen_2_3.dart  # Reflection (ages 2-3.5)
│   │
│   ├── assessment/
│   │   ├── ai_doctor_bot_screen.dart # AI Bot questionnaire
│   │   ├── game_screen.dart          # Game wrapper (WebView)
│   │   └── result_screen.dart       # Assessment results
│   │
│   ├── settings/
│   │   └── settings_screen.dart      # App settings (language)
│   │
│   └── common/
│       └── splash_screen.dart        # App splash screen
│
└── widgets/
    └── language_selector.dart        # Language switcher widget
```

### **Backend Structure**

```
senseai_backend/
├── server.js                          # Express server entry point
├── db.js                              # Database initialization
├── package.json                       # Node.js dependencies
│
├── models/
│   └── schema.sql                    # Database schema
│
└── routes/
    ├── clinicians.js                 # Clinician CRUD operations
    ├── children.js                   # Child CRUD operations
    ├── sessions.js                    # Session CRUD operations
    └── trials.js                      # Trial data operations
```

---

## 🗄️ Database Schema

### **Tables**

#### **1. clinicians**
- `id` (INTEGER, PRIMARY KEY)
- `name` (TEXT, NOT NULL)
- `hospital` (TEXT, NOT NULL)
- `pin_hash` (TEXT, NOT NULL) - bcrypt hashed PIN
- `created_at` (DATETIME)
- `updated_at` (DATETIME)

#### **2. children**
- `id` (TEXT, PRIMARY KEY) - UUID
- `clinician_id` (INTEGER, FOREIGN KEY)
- `name` (TEXT, NOT NULL)
- `date_of_birth` (INTEGER, NOT NULL) - Unix timestamp
- `gender` (TEXT, CHECK: 'male', 'female', 'other')
- `language` (TEXT, NOT NULL)
- `age` (REAL, NOT NULL)
- `hospital_id` (TEXT)
- `created_at` (INTEGER, NOT NULL)

#### **3. sessions**
- `id` (TEXT, PRIMARY KEY) - UUID
- `child_id` (TEXT, FOREIGN KEY)
- `session_type` (TEXT) - 'ai_doctor_bot', 'frog_jump', 'color_shape'
- `age_group` (TEXT)
- `start_time` (INTEGER, NOT NULL)
- `end_time` (INTEGER)
- `metrics` (TEXT) - JSON string
- `game_results` (TEXT) - JSON string
- `questionnaire_results` (TEXT) - JSON string
- `reflection_results` (TEXT) - JSON string
- `risk_score` (REAL)
- `risk_level` (TEXT, CHECK: 'low', 'moderate', 'high')
- `created_at` (INTEGER, NOT NULL)

#### **4. trials**
- `id` (TEXT, PRIMARY KEY) - UUID
- `session_id` (TEXT, FOREIGN KEY)
- `trial_number` (INTEGER, NOT NULL)
- `stimulus` (TEXT)
- `rule` (TEXT)
- `response` (TEXT)
- `correct` (INTEGER, CHECK: 0 or 1)
- `reaction_time` (INTEGER)
- `timestamp` (INTEGER, NOT NULL)
- `is_post_switch` (INTEGER, CHECK: 0 or 1)
- `is_perseverative_error` (INTEGER, CHECK: 0 or 1)
- `additional_data` (TEXT) - JSON string

---

## 🔌 API Endpoints

### **Base URL**: `http://localhost:3000` (or `http://10.0.2.2:3000` for Android emulator)

### **Clinicians**
- `POST /api/clinicians/register` - Register new clinician
- `POST /api/clinicians/login` - Login with PIN
- `GET /api/clinicians/me` - Get current clinician info
- `PUT /api/clinicians/:id` - Update clinician
- `DELETE /api/clinicians/:id` - Delete clinician

### **Children**
- `POST /api/children` - Create new child
- `GET /api/children` - Get all children
- `GET /api/children/:id` - Get child by ID
- `PUT /api/children/:id` - Update child
- `DELETE /api/children/:id` - Delete child
- `GET /api/children/clinician/:clinicianId` - Get children by clinician

### **Sessions**
- `POST /api/sessions` - Create new assessment session
- `GET /api/sessions` - Get all sessions
- `GET /api/sessions/:id` - Get session by ID
- `GET /api/sessions/child/:childId` - Get sessions by child
- `PUT /api/sessions/:id` - Update session
- `DELETE /api/sessions/:id` - Delete session

### **Trials**
- `POST /api/trials` - Create new trial
- `POST /api/trials/batch` - Create multiple trials (batch)
- `GET /api/trials/session/:sessionId` - Get trials by session
- `GET /api/trials/:id` - Get trial by ID
- `DELETE /api/trials/:id` - Delete trial

---

## 🎮 Game Integration

### **HTML5 Games**
- **Location**: `assets/games/`
- **Integration**: WebView with JavaScript channels
- **Communication**: Flutter ↔ JavaScript bidirectional communication
- **Games**:
  1. `frog-jump.html` - For ages 3.5-5.5
  2. `color-shape.html` - For ages 5.5-6.9

### **Game Data Flow**
1. Flutter opens WebView with game HTML
2. Game sends trial data via JavaScript channel
3. Flutter receives data and saves to database
4. Game completion triggers navigation to reflection screen

---

## 🌐 Localization System

### **Implementation**
- **Format**: ARB (Application Resource Bundle) files
- **Generation**: `flutter gen-l10n` command
- **Files**: 
  - `lib/l10n/app_en.arb` (English)
  - `lib/l10n/app_si.arb` (Sinhala)
  - `lib/l10n/app_ta.arb` (Tamil)

### **Usage**
```dart
// In any widget:
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcomeBack);
```

### **Language Switching**
- **Settings Screen**: Manual language selection
- **Auto-detection**: Device language detection on first launch
- **Persistence**: Language preference saved in SharedPreferences

---

## 🔐 Authentication

### **Clinician Authentication**
- **Method**: 4-digit PIN
- **Security**: bcrypt hashing
- **Storage**: Backend database + local SharedPreferences
- **Flow**:
  1. First launch → Registration screen
  2. Enter name, hospital, create PIN
  3. Subsequent launches → Login with PIN
  4. PIN verified against backend

---

## 📊 Assessment Flow

### **Complete Assessment Journey**

```
1. Login/Registration
   ↓
2. Main Dashboard
   ↓
3. Cognitive Dashboard
   ↓
4. Add Child (Name, DOB, Gender, Language)
   ↓
5. Age Selection Screen
   ↓
   ├─ Age 2-3.5:
   │   ├─ AI Doctor Bot (10 questions)
   │   └─ Clinician Reflection (Manual tasks)
   │
   ├─ Age 3.5-5.5:
   │   ├─ Frog Jump Game
   │   └─ Clinician Reflection (5 behavioral questions)
   │
   └─ Age 5.5-6.9:
       ├─ Color-Shape Game
       └─ Clinician Reflection (5 behavioral questions)
   ↓
6. Results Screen
   - Risk Level (Low/Moderate/High)
   - Detailed Metrics
   - Recommendations
```

---

## 🎨 UI/UX Features

### **Dashboard**
- **Welcome Card**: Clinician name and hospital
- **Statistics**: Total children, completed assessments, pending, today's count
- **Quick Actions**: Add child, view all children
- **Component Tiles**: Compact buttons for assessment components
- **Pull-to-Refresh**: Refresh data functionality
- **Animations**: Smooth transitions and loading states

### **Color Scheme**
- **Primary**: Teal/Blue tones
- **Cognitive Dashboard**: Blue theme (light, dark, sea blue)
- **Games**: Orange theme
- **Reflections**: Orange/Blue theme (age-dependent)

---

## 🔧 Development Setup

### **Prerequisites**
- Flutter 2.10.5
- Dart 2.16.2
- Node.js v14+
- Android Studio / Xcode

### **Frontend Setup**
```bash
# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

### **Backend Setup**
```bash
cd senseai_backend
npm install
npm start
```

### **Backend Configuration**
- **Port**: 3000 (default)
- **Database**: SQLite (`senseai.db`)
- **Auto-initialization**: Database and tables created automatically

---

## 📦 Dependencies

### **Frontend (pubspec.yaml)**
- `provider: ^6.0.5` - State management
- `sqflite: ^2.0.0+3` - Local database
- `http: ^0.13.5` - HTTP client
- `webview_flutter: ^2.8.0` - WebView for games
- `flutter_localizations` - Localization support
- `intl: ^0.17.0` - Internationalization
- `shared_preferences: ^2.0.11` - Local storage
- `pull_to_refresh: ^2.0.0` - Pull-to-refresh

### **Backend (package.json)**
- `express: ^4.18.2` - Web framework
- `sqlite3: ^5.1.6` - Database
- `bcrypt: ^5.1.0` - Password hashing
- `joi: ^17.9.2` - Validation
- `cors: ^2.8.5` - CORS support
- `body-parser: ^1.20.2` - Request parsing

---

## 🚀 Key Features Summary

✅ **Multilingual Support** (English, Sinhala, Tamil)  
✅ **Age-Based Assessment Routing** (2-6.9 years)  
✅ **Interactive HTML5 Games** (Frog Jump, Color-Shape)  
✅ **Parental Questionnaire** (AI Doctor Bot)  
✅ **Clinician Reflections** (Age-appropriate observations)  
✅ **Risk Assessment** (Low/Moderate/High)  
✅ **Offline-First Architecture** (Local SQLite + Backend sync)  
✅ **Secure Authentication** (PIN-based with bcrypt)  
✅ **Comprehensive Data Collection** (Trials, sessions, metrics)  
✅ **Professional UI/UX** (Modern, animated, responsive)  
✅ **Settings Management** (Language, profile)  
✅ **Data Synchronization** (Frontend ↔ Backend)  

---

## 📝 Current Status

### **✅ Completed**
- Frontend Flutter app with all screens
- Backend Node.js API with full CRUD operations
- Database schema and initialization
- Multilingual localization system (ARB-based)
- Age-based assessment routing
- HTML5 game integration
- Clinician authentication
- Data synchronization (Frontend ↔ Backend)
- Settings and profile management
- Risk assessment calculation
- Results display

### **🔄 In Progress**
- Language change propagation across all screens (some screens may need Consumer wrapper)

### **📋 Future Enhancements**
- Firebase sync integration
- PDF report generation
- Data export functionality
- Advanced analytics dashboard
- Multi-clinician support enhancements
- Cloud backup functionality

---

## 📞 API Integration

### **Frontend → Backend**
All data operations go through `ApiService`:
- Children CRUD
- Sessions CRUD
- Trials CRUD
- Clinician operations

### **Backend → Frontend**
- RESTful API responses
- JSON data format
- Error handling with status codes
- UUID generation for new records

---

## 🔍 Testing

### **Postman Collection**
- Complete Postman collection available: `senseai_backend/SenseAI_Backend.postman_collection.json`
- Import to test all API endpoints
- Documentation: `POSTMAN_GUIDE.md`

### **Manual Testing**
1. Register clinician via app
2. Add child
3. Complete assessment flow
4. Verify data in Postman
5. Test language switching
6. Test settings and profile management

---

## 📚 Documentation Files

- `PROJECT_DOCUMENTATION.md` - This file
- `LOCALIZATION_MIGRATION_GUIDE.md` - Localization system guide
- `QUICK_START_LOCALIZATION.md` - Quick reference for localization
- `senseai_backend/README.md` - Backend documentation
- `senseai_backend/POSTMAN_GUIDE.md` - API testing guide
- `senseai_backend/FLUTTER_BACKEND_INTEGRATION.md` - Integration guide

---

## 🎯 Project Goals

1. **Clinical Use**: Provide reliable ASD screening tool for clinicians
2. **Multilingual**: Support for English, Sinhala, and Tamil
3. **Age-Appropriate**: Different assessments for different age groups
4. **Data-Driven**: Comprehensive data collection and analysis
5. **Offline-First**: Work without internet connection
6. **User-Friendly**: Intuitive UI for clinicians and parents
7. **Scalable**: Ready for cloud sync and multi-device support

---

## 📄 License

ISC License

---

**Last Updated**: 2024  
**Version**: 1.0.0+1  
**Flutter Version**: 2.10.5  
**Dart Version**: 2.16.2






