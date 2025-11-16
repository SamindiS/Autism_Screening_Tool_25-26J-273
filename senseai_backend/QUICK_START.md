# Quick Start - Testing with Postman

## 🚀 Start the Backend

```bash
cd senseai_backend
npm install
npm start
```

Server runs on: `http://localhost:3000`

---

## ✅ Quick Test Checklist

### 1. Health Check
```
GET http://localhost:3000/health
```
Should return: `{"status": "OK", ...}`

### 2. Register Clinician
```
POST http://localhost:3000/api/clinicians/register
Body: {
  "name": "Dr. Test",
  "hospital": "Test Hospital",
  "pin": "1234"
}
```

### 3. Login
```
POST http://localhost:3000/api/clinicians/login
Body: {
  "pin": "1234"
}
```

### 4. Create Child
```
POST http://localhost:3000/api/children
Body: {
  "name": "Alice",
  "date_of_birth": 946684800000,
  "gender": "female",
  "language": "en"
}
```

### 5. Get All Children
```
GET http://localhost:3000/api/children
```

---

## 📋 Complete Endpoint List

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/api/clinicians/register` | Register clinician |
| POST | `/api/clinicians/login` | Login |
| GET | `/api/clinicians/me` | Get clinician info |
| POST | `/api/children` | Create child |
| GET | `/api/children` | Get all children |
| GET | `/api/children/:id` | Get child by ID |
| PUT | `/api/children/:id` | Update child |
| DELETE | `/api/children/:id` | Delete child |
| POST | `/api/sessions` | Create session |
| GET | `/api/sessions` | Get all sessions |
| GET | `/api/sessions/:id` | Get session by ID |
| GET | `/api/sessions/child/:childId` | Get sessions by child |
| PUT | `/api/sessions/:id` | Update session |
| DELETE | `/api/sessions/:id` | Delete session |
| POST | `/api/trials` | Create trial |
| POST | `/api/trials/batch` | Create multiple trials |
| GET | `/api/trials/session/:sessionId` | Get trials by session |
| GET | `/api/trials/:id` | Get trial by ID |
| DELETE | `/api/trials/:id` | Delete trial |

---

## 📖 Full Documentation

- **POSTMAN_GUIDE.md** - Complete Postman testing guide with examples
- **BACKEND_FEATURES.md** - Detailed feature list
- **README.md** - Setup and usage guide
- **SETUP.md** - Installation instructions

