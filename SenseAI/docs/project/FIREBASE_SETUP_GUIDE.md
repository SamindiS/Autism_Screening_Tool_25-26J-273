# Firebase Realtime Database Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name: `SenseAI` (or your preferred name)
   - Enable/disable Google Analytics (optional)
   - Click "Create project"

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the Android icon (or "Add app")
2. Enter package name: `com.example.my_autism_app`
   - This must match your `applicationId` in `android/app/build.gradle`
3. Enter app nickname (optional): `SenseAI Android`
4. Enter SHA-1 (optional for now, needed for Auth later)
5. Click "Register app"

## Step 3: Download google-services.json

1. Download the `google-services.json` file
2. Place it in: `android/app/google-services.json`
   - **Important:** The file must be in `android/app/` directory, NOT `android/`

## Step 4: Enable Realtime Database

1. In Firebase Console, go to "Build" → "Realtime Database"
2. Click "Create Database"
3. Choose location (select closest to your users)
4. Choose security rules:
   - **For development:** Start in test mode (allows read/write for 30 days)
   - **For production:** Start in locked mode (you'll configure rules later)
5. Click "Enable"

## Step 5: Configure Database Rules (Important!)

1. Go to "Realtime Database" → "Rules" tab
2. For development/testing, you can use:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

3. For production, configure proper rules based on your data structure

## Step 6: Install Dependencies

Run in your project directory:
```bash
flutter pub get
```

## Step 7: Initialize Firebase in Your App

The Firebase initialization code will be added to `lib/main.dart` automatically.

## Step 8: Test Connection

After setup, you can test the connection by running:
```bash
flutter run
```

## Troubleshooting

### If google-services.json is not found:
- Make sure the file is in `android/app/google-services.json`
- Check file name spelling (must be exactly `google-services.json`)
- Re-download from Firebase Console if needed

### If build fails:
- Run `flutter clean`
- Run `flutter pub get`
- Delete `.dart_tool` folder and try again

### If database connection fails:
- Check internet permission in `AndroidManifest.xml`
- Verify Firebase project is active
- Check database rules allow your operations

## Next Steps

After setup, you can:
1. Create a Firebase service class to handle database operations
2. Replace local storage with Firebase Realtime Database
3. Implement real-time synchronization
4. Add authentication for secure access

