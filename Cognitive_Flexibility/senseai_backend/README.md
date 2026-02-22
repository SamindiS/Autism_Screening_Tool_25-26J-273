# SenseAI Local Backend

Professional, offline-first local backend for the SenseAI Autism Screening Tool using **Node.js + Express + SQLite**.

## Architecture

```
Flutter App (Tablet)
     ↓ (HTTP REST API)
Node.js + Express (Local Server)
     ↓ (SQLite DB)
Local Storage (offline CRUD)
     ↓ (Future Sync)
Firebase Firestore (when online)
```

## Features

- ✅ **Offline-first** - Works completely offline on tablet
- ✅ **SQLite Database** - Lightweight, embedded database
- ✅ **RESTful API** - Clean, standard REST endpoints
- ✅ **Secure Authentication** - PIN-based login with bcrypt hashing
- ✅ **Data Validation** - Joi schema validation
- ✅ **Error Handling** - Comprehensive error handling
- ✅ **Future-ready** - Designed for Firebase sync integration

## Installation

1. **Install Node.js** (v14 or higher)

2. **Navigate to backend directory:**
   ```bash
   cd senseai_backend
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Start the server:**
   ```bash
   npm start
   ```

   Or for development with auto-reload:
   ```bash
   npm run dev
   ```

## Running on Tablet

### Option A: Using Termux (Android)

1. Install **Termux** from Google Play Store
2. Open Termux and run:
   ```bash
   pkg update
   pkg install nodejs
   cd /storage/emulated/0/senseai_backend
   npm install
   node server.js
   ```

### Option B: Development Server

For development, run on your computer and connect Flutter app to:
- **Android Emulator**: `http://10.0.2.2:3000`
- **Real Device**: `http://<your-computer-ip>:3000`

## API Endpoints

### Health Check
- `GET /health` - Server health status

### Clinicians
- `POST /api/clinicians/register` - Register/update clinician
- `POST /api/clinicians/login` - Login with PIN
- `GET /api/clinicians/me` - Get current clinician info

### Children
- `POST /api/children` - Create new child
- `GET /api/children` - Get all children
- `GET /api/children/:id` - Get child by ID
- `PUT /api/children/:id` - Update child
- `DELETE /api/children/:id` - Delete child
- `GET /api/children/clinician/:clinicianId` - Get children by clinician

### Sessions (Assessments)
- `POST /api/sessions` - Create new assessment session
- `GET /api/sessions` - Get all sessions
- `GET /api/sessions/:id` - Get session by ID
- `GET /api/sessions/child/:childId` - Get sessions by child
- `PUT /api/sessions/:id` - Update session
- `DELETE /api/sessions/:id` - Delete session

### Trials
- `POST /api/trials` - Create new trial
- `POST /api/trials/batch` - Create multiple trials
- `GET /api/trials/session/:sessionId` - Get trials by session
- `GET /api/trials/:id` - Get trial by ID
- `DELETE /api/trials/:id` - Delete trial

## Database Schema

The database automatically initializes with the following tables:

- **clinicians** - Clinician authentication and info
- **children** - Child profiles
- **sessions** - Assessment sessions (game results, questionnaires, reflections)
- **trials** - Individual trial data for games

See `models/schema.sql` for full schema details.

## Example API Calls

### Register Clinician
```bash
curl -X POST http://localhost:3000/api/clinicians/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Dr. John Doe",
    "hospital": "General Hospital",
    "pin": "1234"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/clinicians/login \
  -H "Content-Type: application/json" \
  -d '{
    "pin": "1234"
  }'
```

### Create Child
```bash
curl -X POST http://localhost:3000/api/children \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice",
    "date_of_birth": 946684800000,
    "gender": "female",
    "language": "en",
    "hospital_id": "H001"
  }'
```

## Flutter Integration

In your Flutter app, use the `http` package to make API calls:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

final baseUrl = 'http://10.0.2.2:3000'; // Emulator
// final baseUrl = 'http://127.0.0.1:3000'; // Real device

Future<void> registerClinician(String name, String hospital, String pin) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/clinicians/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'hospital': hospital,
      'pin': pin
    }),
  );
  
  if (response.statusCode == 201) {
    print('Clinician registered');
  }
}
```

## Future: Firebase Sync

The backend is designed to easily sync to Firebase Firestore when online. Add a sync service that:

1. Monitors for network connectivity
2. Syncs local SQLite data to Firestore
3. Handles conflicts and merge strategies
4. Maintains offline-first architecture

## License

ISC

