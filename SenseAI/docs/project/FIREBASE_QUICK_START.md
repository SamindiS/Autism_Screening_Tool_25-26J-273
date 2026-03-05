# Firebase Realtime Database - Quick Start

## ✅ What's Already Done

1. ✅ Firebase dependencies added to `pubspec.yaml`
2. ✅ Google Services plugin added to Gradle files
3. ✅ Firebase initialization code added to `main.dart`
4. ✅ Firebase service class created (`lib/core/services/firebase_service.dart`)

## 📋 What You Need to Do

### 1. Create Firebase Project
- Go to https://console.firebase.google.com/
- Create a new project or use existing one

### 2. Add Android App
- Package name: `com.example.my_autism_app`
- Download `google-services.json`

### 3. Place Configuration File
```
Place google-services.json in: android/app/google-services.json
```

### 4. Enable Realtime Database
- In Firebase Console → Build → Realtime Database
- Click "Create Database"
- Choose location and start in test mode for development

### 5. Install Dependencies
```bash
flutter pub get
```

### 6. Test
```bash
flutter run
```

## 🔧 Using Firebase Service

### Example: Save Session
```dart
import 'package:senseai/core/services/firebase_service.dart';

// Save session
final sessionId = await FirebaseService.saveSession(
  childId: 'child123',
  sessionType: 'frog-jump',
  ageGroup: '3.5-5.5',
  startTime: DateTime.now(),
);
```

### Example: Update Session
```dart
await FirebaseService.updateSession(
  sessionId: sessionId,
  endTime: DateTime.now(),
  gameResults: results.toJson(),
);
```

### Example: Listen to Real-time Changes
```dart
FirebaseService.listenToData('sessions/$sessionId').listen((event) {
  final data = event.snapshot.value as Map<String, dynamic>;
  // Handle real-time updates
});
```

## ⚠️ Important Notes

1. **Security Rules**: Configure database rules in Firebase Console
2. **Offline Support**: Firebase Realtime Database works offline by default
3. **Data Structure**: Data is stored as JSON in Firebase
4. **Backup**: Consider implementing local backup alongside Firebase

## 🔐 Security Rules Example

For development (test mode - 30 days):
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

For production (authenticated users only):
```json
{
  "rules": {
    "sessions": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "trials": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

