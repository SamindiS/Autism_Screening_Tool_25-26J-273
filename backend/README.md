# SenseAI Backend API

Backend API server for the SenseAI Autism Screening Tool. Built with Node.js, Express, TypeScript, and Firebase.

---

## 📋 Table of Contents

1. [Features](#features)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Prerequisites](#prerequisites)
5. [Installation](#installation)
6. [Configuration](#configuration)
7. [Running the Server](#running-the-server)
8. [API Endpoints](#api-endpoints)
9. [Testing](#testing)
10. [Deployment](#deployment)

---

## 🎯 Features

- ✅ **RESTful API** for session, child, and ML data
- ✅ **Firebase Firestore** for data storage
- ✅ **Firebase Storage** for large files (compressed trials)
- ✅ **ML Integration** with external prediction API
- ✅ **Data Compression** (gzip for trial data)
- ✅ **Input Validation** with Joi
- ✅ **Logging** with Winston
- ✅ **TypeScript** for type safety
- ✅ **Error Handling** middleware
- ✅ **CORS** support
- ✅ **Environment-based** configuration

---

## 🛠️ Tech Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Language:** TypeScript
- **Database:** Firebase Firestore
- **Storage:** Firebase Storage
- **Validation:** Joi
- **Logging:** Winston
- **Compression:** Pako (gzip)
- **HTTP Client:** Axios

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   └── firebase.ts          # Firebase initialization
│   ├── routes/
│   │   ├── sessions.ts          # Session endpoints
│   │   ├── children.ts          # Child endpoints
│   │   └── ml.ts                # ML prediction endpoints
│   ├── services/
│   │   └── mlService.ts         # ML service logic
│   ├── utils/
│   │   ├── logger.ts            # Winston logger
│   │   └── validation.ts        # Joi schemas
│   └── index.ts                 # Main server file
├── logs/                        # Log files (auto-generated)
├── dist/                        # Compiled JavaScript (auto-generated)
├── package.json
├── tsconfig.json
├── .env                         # Environment variables (create from .env.example)
└── README.md
```

---

## 📝 Prerequisites

Before you begin, ensure you have:

- ✅ **Node.js 18+** installed
- ✅ **npm** or **yarn** installed
- ✅ **Firebase project** created
- ✅ **Firebase service account** key (JSON file)

---

## 🚀 Installation

### Step 1: Clone and Navigate

```bash
cd backend
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Set Up Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Enable **Firestore** and **Storage**
4. Go to **Project Settings → Service Accounts**
5. Click **Generate New Private Key**
6. Download the JSON file

---

## ⚙️ Configuration

### Step 1: Create Environment File

Create a `.env` file in the `backend/` directory:

```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"

# Server Configuration
PORT=3000
NODE_ENV=development

# ML API Configuration
ML_API_URL=http://localhost:5000/predict
ML_API_KEY=your-ml-api-key-here

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:19006

# Storage Configuration
STORAGE_BUCKET=your-project-id.appspot.com
```

### Step 2: Update Firebase Credentials

Copy the values from your downloaded Firebase service account JSON:

- `FIREBASE_PROJECT_ID` → `project_id`
- `FIREBASE_CLIENT_EMAIL` → `client_email`
- `FIREBASE_PRIVATE_KEY` → `private_key` (keep the \n characters)

---

## 🏃 Running the Server

### Development Mode (with auto-reload)

```bash
npm run dev
```

### Production Build

```bash
npm run build
npm start
```

### Expected Output

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║    🚀 SenseAI Backend API Server                         ║
║                                                           ║
║    📍 Server running on http://localhost:3000            ║
║    🌍 Environment: development                           ║
║    🔥 Firebase initialized                               ║
║    📚 Documentation: /docs                               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 📚 API Endpoints

### Health Check

```
GET /health

Response:
{
  "status": "ok",
  "message": "SenseAI Backend API is running",
  "timestamp": "2024-10-28T10:30:00.000Z",
  "version": "1.0.0"
}
```

### Sessions

#### Create Session

```
POST /api/sessions

Body:
{
  "session_id": "S-2024-10-28-001",
  "clinic_id": "hospital_a",
  "clinician_id": "doctor_001",
  "child": {
    "child_id": "child_001",
    "name": "Test Child",
    "age_years": 5.5,
    "gender": "male",
    "language": "en"
  },
  "assessment_type": "color_shape",
  "timestamp_start": "2024-10-28T10:30:00Z",
  "game_data": {
    "total_trials": 20,
    "accuracy_percent": 85,
    "mean_rt_ms": 915,
    "trials": [ /* array of trial objects */ ]
  }
}

Response:
{
  "success": true,
  "message": "Session data saved successfully",
  "data": {
    "session_id": "S-2024-10-28-001",
    "storage_refs": {
      "trials": "sessions/S-2024-10-28-001/trials.ndjson.gz"
    },
    "firestore_path": "clinics/hospital_a/children/child_001/assessments/S-2024-10-28-001"
  }
}
```

#### Get Session

```
GET /api/sessions/:sessionId?clinicId=hospital_a&childId=child_001

Response:
{
  "success": true,
  "data": { /* session data */ }
}
```

#### Get Session Trials (from Storage)

```
GET /api/sessions/:sessionId/trials

Response:
{
  "success": true,
  "data": {
    "trials": [ /* array of trial objects */ ],
    "count": 20
  }
}
```

### Children

#### Create Child

```
POST /api/children

Body:
{
  "name": "Test Child",
  "dateOfBirth": "2019-03-15",
  "age": 5,
  "gender": "male",
  "language": "en",
  "hospitalId": "hospital_a",
  "hospitalName": "Hospital A"
}

Response:
{
  "success": true,
  "message": "Child profile created successfully",
  "data": {
    "childId": "child_xxx",
    /* child data */
  }
}
```

#### Get All Children

```
GET /api/children?clinicId=hospital_a

Response:
{
  "success": true,
  "data": {
    "children": [ /* array of children */ ],
    "count": 15
  }
}
```

### ML Predictions

#### Trigger ML Prediction

```
POST /api/ml/predict

Body:
{
  "sessionId": "S-2024-10-28-001",
  "clinicId": "hospital_a",
  "childId": "child_001",
  "useHeuristic": false
}

Response:
{
  "success": true,
  "message": "ML prediction completed",
  "data": {
    "sessionId": "S-2024-10-28-001",
    "prediction": {
      "riskLevel": "moderate",
      "confidence": 0.78,
      "drivers": ["switch_cost", "perseveration"],
      "modelVersion": "v1.0.0",
      "predictedAt": "2024-10-28T10:35:00Z"
    },
    "features": { /* extracted features */ }
  }
}
```

#### Get ML Statistics

```
GET /api/ml/stats?clinicId=hospital_a

Response:
{
  "success": true,
  "data": {
    "totalAssessments": 45,
    "riskDistribution": {
      "low": 20,
      "moderate": 18,
      "high": 7
    },
    "avgConfidence": 0.76,
    "totalChildren": 15
  }
}
```

---

## 🧪 Testing

### Test with cURL

```bash
# Health check
curl http://localhost:3000/health

# Create a session
curl -X POST http://localhost:3000/api/sessions \
  -H "Content-Type: application/json" \
  -d @sample-session.json

# Get children
curl http://localhost:3000/api/children?clinicId=hospital_a
```

### Test with Postman

1. Import the provided Postman collection (if available)
2. Set environment variables
3. Run the requests

---

## 🚢 Deployment

### Deploy to Firebase Functions

1. **Install Firebase CLI:**

```bash
npm install -g firebase-tools
firebase login
```

2. **Initialize Firebase:**

```bash
firebase init functions
```

3. **Deploy:**

```bash
npm run build
firebase deploy --only functions
```

### Deploy to Cloud Run (Docker)

1. **Create Dockerfile:**

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

2. **Build and Deploy:**

```bash
gcloud run deploy senseai-api \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Deploy to Heroku

```bash
heroku create senseai-backend
heroku config:set FIREBASE_PROJECT_ID=your-project-id
heroku config:set FIREBASE_CLIENT_EMAIL=your-email
heroku config:set FIREBASE_PRIVATE_KEY="your-private-key"
git push heroku main
```

---

## 📝 Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `FIREBASE_PROJECT_ID` | Firebase project ID | `senseai-12345` |
| `FIREBASE_CLIENT_EMAIL` | Service account email | `firebase-adminsdk-xxxxx@...` |
| `FIREBASE_PRIVATE_KEY` | Service account private key | `-----BEGIN PRIVATE KEY-----\n...` |
| `PORT` | Server port | `3000` |
| `NODE_ENV` | Environment | `development` or `production` |
| `ML_API_URL` | ML service URL | `http://localhost:5000/predict` |
| `ML_API_KEY` | ML API key | `your-api-key` |
| `ALLOWED_ORIGINS` | CORS origins (comma-separated) | `http://localhost:3000` |
| `STORAGE_BUCKET` | Firebase storage bucket | `senseai-12345.appspot.com` |

---

## 🔒 Security

- ✅ Environment variables for sensitive data
- ✅ CORS configuration
- ✅ Input validation with Joi
- ✅ Firebase security rules (set separately)
- ✅ HTTPS only in production
- ✅ Rate limiting (add if needed)

---

## 📊 Monitoring

- **Logs:** Check `logs/` directory
- **Firebase Console:** Monitor Firestore and Storage usage
- **Performance:** Use Firebase Performance Monitoring
- **Errors:** Use Firebase Crashlytics or Sentry

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

MIT License - See LICENSE file for details

---

## 📞 Support

For issues or questions:
- 📧 Email: support@senseai.com
- 📚 Documentation: [docs/](../docs/)
- 🐛 Issues: GitHub Issues

---

**Backend Status:** ✅ Ready for Development  
**Last Updated:** October 28, 2024  
**Version:** 1.0.0






