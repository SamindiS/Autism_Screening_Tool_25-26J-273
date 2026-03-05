# Postman Testing Guide for SenseAI Backend

## What's Included in the Backend

### 1. **Database Schema**
- **clinicians** - Clinician authentication (name, hospital, PIN hash)
- **children** - Child profiles (name, DOB, gender, language, age)
- **sessions** - Assessment sessions (game results, questionnaires, reflections, risk scores)
- **trials** - Individual trial data for games

### 2. **API Endpoints**

#### Clinicians (Authentication)
- `POST /api/clinicians/register` - Register/update clinician
- `POST /api/clinicians/login` - Login with PIN
- `GET /api/clinicians/me` - Get current clinician info

#### Children (CRUD)
- `POST /api/children` - Create new child
- `GET /api/children` - Get all children
- `GET /api/children/:id` - Get child by ID
- `PUT /api/children/:id` - Update child
- `DELETE /api/children/:id` - Delete child
- `GET /api/children/clinician/:clinicianId` - Get children by clinician

#### Sessions (Assessments)
- `POST /api/sessions` - Create new assessment session
- `GET /api/sessions` - Get all sessions
- `GET /api/sessions/:id` - Get session by ID
- `GET /api/sessions/child/:childId` - Get sessions by child
- `PUT /api/sessions/:id` - Update session
- `DELETE /api/sessions/:id` - Delete session

#### Trials
- `POST /api/trials` - Create new trial
- `POST /api/trials/batch` - Create multiple trials
- `GET /api/trials/session/:sessionId` - Get trials by session
- `GET /api/trials/:id` - Get trial by ID
- `DELETE /api/trials/:id` - Delete trial

### 3. **Features**
- ✅ Secure PIN authentication with bcrypt
- ✅ Data validation with Joi
- ✅ Error handling
- ✅ JSON storage for complex objects
- ✅ Foreign key relationships
- ✅ Database indexes for performance

---

## Setting Up Postman

### Step 1: Start the Backend Server

```bash
cd senseai_backend
npm install
npm start
```

Server will run on: `http://localhost:3000`

### Step 2: Create Postman Collection

1. Open Postman
2. Click **New** → **Collection**
3. Name it: **SenseAI Backend API**
4. Set base URL variable:
   - Click on collection → **Variables** tab
   - Add variable: `base_url` = `http://localhost:3000`

---

## Testing Endpoints in Postman

### 1. Health Check

**Request:**
- Method: `GET`
- URL: `http://localhost:3000/health`

**Expected Response:**
```json
{
  "status": "OK",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "database": "connected"
}
```

---

### 2. Register Clinician

**Request:**
- Method: `POST`
- URL: `http://localhost:3000/api/clinicians/register`
- Headers:
  - `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "name": "Dr. Sarah Johnson",
  "hospital": "General Hospital",
  "pin": "1234"
}
```

**Expected Response (201):**
```json
{
  "message": "Clinician registered successfully",
  "clinician": {
    "id": 1,
    "name": "Dr. Sarah Johnson",
    "hospital": "General Hospital"
  }
}
```

**Error Response (400 - Invalid PIN):**
```json
{
  "error": "Validation error",
  "details": "PIN must be exactly 4 digits"
}
```

---

### 3. Login

**Request:**
- Method: `POST`
- URL: `http://localhost:3000/api/clinicians/login`
- Headers:
  - `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "pin": "1234"
}
```

**Expected Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "clinician": {
    "id": 1,
    "name": "Dr. Sarah Johnson",
    "hospital": "General Hospital"
  }
}
```

**Error Response (401 - Wrong PIN):**
```json
{
  "error": "Invalid PIN"
}
```

---

### 4. Get Current Clinician

**Request:**
- Method: `GET`
- URL: `http://localhost:3000/api/clinicians/me`

**Expected Response:**
```json
{
  "clinician": {
    "id": 1,
    "name": "Dr. Sarah Johnson",
    "hospital": "General Hospital",
    "created_at": "2024-01-01 12:00:00"
  }
}
```

---

### 5. Create Child

**Request:**
- Method: `POST`
- URL: `http://localhost:3000/api/children`
- Headers:
  - `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "name": "Alice Smith",
  "date_of_birth": 946684800000,
  "gender": "female",
  "language": "en",
  "hospital_id": "H001"
}
```

**Note:** `date_of_birth` is in milliseconds (Unix timestamp)

**Expected Response (201):**
```json
{
  "message": "Child created successfully",
  "child": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Alice Smith",
    "date_of_birth": 946684800000,
    "gender": "female",
    "language": "en",
    "age": 5.2,
    "hospital_id": "H001",
    "created_at": 1704110400000
  }
}
```

**Error Response (400 - Validation):**
```json
{
  "error": "Validation error",
  "details": "\"gender\" must be one of [male, female, other]"
}
```

---

### 6. Get All Children

**Request:**
- Method: `GET`
- URL: `http://localhost:3000/api/children`

**Expected Response:**
```json
{
  "count": 2,
  "children": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Alice Smith",
      "date_of_birth": 946684800000,
      "gender": "female",
      "language": "en",
      "age": 5.2,
      "hospital_id": "H001",
      "created_at": 1704110400000
    }
  ]
}
```

---

### 7. Get Child by ID

**Request:**
- Method: `GET`
- URL: `http://localhost:3000/api/children/550e8400-e29b-41d4-a716-446655440000`

**Expected Response:**
```json
{
  "child": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Alice Smith",
    "date_of_birth": 946684800000,
    "gender": "female",
    "language": "en",
    "age": 5.2,
    "hospital_id": "H001",
    "created_at": 1704110400000
  }
}
```

---

### 8. Create Assessment Session

**Request:**
- Method: `POST`
- URL: `http://localhost:3000/api/sessions`
- Headers:
  - `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "child_id": "550e8400-e29b-41d4-a716-446655440000",
  "session_type": "color_shape",
  "age_group": "3.5-6",
  "start_time": 1704110400000,
  "end_time": 1704110700000,
  "metrics": {
    "total_trials": 30,
    "correct_trials": 25,
    "accuracy": 0.83
  },
  "game_results": {
    "game_type": "color_shape",
    "total_trials": 30,
    "correct_trials": 25,
    "accuracy": 0.83,
    "average_reaction_time": 1200,
    "switch_cost": 150,
    "perseverative_errors": 2
  },
  "questionnaire_results": null,
  "reflection_results": {
    "attention": 4,
    "engagement": 5,
    "frustration": 3,
    "instructions": 4,
    "overall": 4
  },
  "risk_score": 65.5,
  "risk_level": "moderate"
}
```

**Expected Response (201):**
```json
{
  "message": "Session created successfully",
  "session": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "child_id": "550e8400-e29b-41d4-a716-446655440000",
    "session_type": "color_shape",
    "age_group": "3.5-6",
    "start_time": 1704110400000,
    "end_time": 1704110700000,
    "risk_score": 65.5,
    "risk_level": "moderate",
    "created_at": 1704110800000
  }
}
```

---

### 9. Get Sessions by Child

**Request:**
- Method: `GET`
- URL: `http://localhost:3000/api/sessions/child/550e8400-e29b-41d4-a716-446655440000`

**Expected Response:**
```json
{
  "count": 1,
  "sessions": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "child_id": "550e8400-e29b-41d4-a716-446655440000",
      "session_type": "color_shape",
      "age_group": "3.5-6",
      "start_time": 1704110400000,
      "end_time": 1704110700000,
      "metrics": {
        "total_trials": 30,
        "correct_trials": 25,
        "accuracy": 0.83
      },
      "game_results": {
        "game_type": "color_shape",
        "total_trials": 30,
        "correct_trials": 25,
        "accuracy": 0.83
      },
      "questionnaire_results": null,
      "reflection_results": {
        "attention": 4,
        "engagement": 5,
        "frustration": 3,
        "instructions": 4,
        "overall": 4
      },
      "risk_score": 65.5,
      "risk_level": "moderate",
      "created_at": 1704110800000
    }
  ]
}
```

---

### 10. Create Trial

**Request:**
- Method: `POST`
- URL: `http://localhost:3000/api/trials`
- Headers:
  - `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "session_id": "660e8400-e29b-41d4-a716-446655440001",
  "trial_number": 1,
  "stimulus": "red_circle",
  "rule": "color",
  "response": "red",
  "correct": true,
  "reaction_time": 1200,
  "timestamp": 1704110401000,
  "is_post_switch": false,
  "is_perseverative_error": false,
  "additional_data": {
    "rule_switched": false,
    "previous_rule": null
  }
}
```

**Expected Response (201):**
```json
{
  "message": "Trial created successfully",
  "trial": {
    "id": "770e8400-e29b-41d4-a716-446655440002",
    "session_id": "660e8400-e29b-41d4-a716-446655440001",
    "trial_number": 1,
    "stimulus": "red_circle",
    "rule": "color",
    "response": "red",
    "correct": true,
    "reaction_time": 1200,
    "timestamp": 1704110401000,
    "is_post_switch": false,
    "is_perseverative_error": false,
    "additional_data": {
      "rule_switched": false,
      "previous_rule": null
    }
  }
}
```

---

### 11. Create Multiple Trials (Batch)

**Request:**
- Method: `POST`
- URL: `http://localhost:3000/api/trials/batch`
- Headers:
  - `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "trials": [
    {
      "session_id": "660e8400-e29b-41d4-a716-446655440001",
      "trial_number": 1,
      "stimulus": "red_circle",
      "rule": "color",
      "response": "red",
      "correct": true,
      "reaction_time": 1200,
      "timestamp": 1704110401000,
      "is_post_switch": false,
      "is_perseverative_error": false
    },
    {
      "session_id": "660e8400-e29b-41d4-a716-446655440001",
      "trial_number": 2,
      "stimulus": "blue_square",
      "rule": "color",
      "response": "blue",
      "correct": true,
      "reaction_time": 1100,
      "timestamp": 1704110402000,
      "is_post_switch": false,
      "is_perseverative_error": false
    }
  ]
}
```

**Expected Response (201):**
```json
{
  "message": "2 trials created successfully",
  "count": 2,
  "trials": [...]
}
```

---

### 12. Get Trials by Session

**Request:**
- Method: `GET`
- URL: `http://localhost:3000/api/trials/session/660e8400-e29b-41d4-a716-446655440001`

**Expected Response:**
```json
{
  "count": 2,
  "trials": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440002",
      "session_id": "660e8400-e29b-41d4-a716-446655440001",
      "trial_number": 1,
      "stimulus": "red_circle",
      "rule": "color",
      "response": "red",
      "correct": true,
      "reaction_time": 1200,
      "timestamp": 1704110401000,
      "is_post_switch": false,
      "is_perseverative_error": false
    }
  ]
}
```

---

## Common Error Responses

### 400 Bad Request (Validation Error)
```json
{
  "error": "Validation error",
  "details": "Error message here"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid PIN"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

---

## Postman Collection JSON

Save this as `SenseAI_Backend.postman_collection.json` and import into Postman:

```json
{
  "info": {
    "name": "SenseAI Backend API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:3000"
    }
  ],
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "{{base_url}}/health"
      }
    },
    {
      "name": "Clinicians",
      "item": [
        {
          "name": "Register Clinician",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"name\": \"Dr. Sarah Johnson\",\n  \"hospital\": \"General Hospital\",\n  \"pin\": \"1234\"\n}"
            },
            "url": "{{base_url}}/api/clinicians/register"
          }
        },
        {
          "name": "Login",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"pin\": \"1234\"\n}"
            },
            "url": "{{base_url}}/api/clinicians/login"
          }
        },
        {
          "name": "Get Current Clinician",
          "request": {
            "method": "GET",
            "url": "{{base_url}}/api/clinicians/me"
          }
        }
      ]
    }
  ]
}
```

---

## Testing Workflow

1. **Start Backend**: `npm start` in `senseai_backend`
2. **Health Check**: Test `GET /health`
3. **Register**: Create a clinician
4. **Login**: Test authentication
5. **Create Child**: Add a test child
6. **Create Session**: Create an assessment session
7. **Create Trials**: Add trial data
8. **Query Data**: Test GET endpoints

---

## Tips

- Use **Environment Variables** in Postman for different environments (dev, prod)
- Save **child_id** and **session_id** from responses to use in subsequent requests
- Use **Tests** tab in Postman to automatically save IDs to variables
- Use **Pre-request Scripts** to generate timestamps dynamically

