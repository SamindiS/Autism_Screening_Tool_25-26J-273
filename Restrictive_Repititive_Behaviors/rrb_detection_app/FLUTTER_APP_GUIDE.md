# RRB Detection Flutter App - Implementation Guide

## ✅ Current Status

### Completed:
1. ✅ Flutter PATH fixed in VS Code
2. ✅ Flutter app created (`rrb_detection_app`)
3. ✅ Dependencies added to `pubspec.yaml`
4. ✅ App structure created:
   - `lib/config/` - Configuration files
   - `lib/models/` - Data models
   - `lib/services/` - API services
   - `lib/providers/` - State management
   - `lib/screens/` - UI screens
   - `lib/widgets/` - Reusable widgets
   - `lib/utils/` - Utility functions

### Files Created:
- ✅ `lib/config/app_config.dart` - App configuration
- ✅ `lib/models/user_model.dart` - User data model
- ✅ `lib/models/detection_result_model.dart` - Detection result model
- ✅ `lib/services/auth_service.dart` - Authentication service
- ✅ `lib/services/video_service.dart` - Video upload/detection service
- ✅ `lib/providers/auth_provider.dart` - Auth state management
- ✅ `lib/main.dart` - Main app entry point

## 📋 Next Steps

### 1. Install Dependencies

```bash
cd rrb_detection_app
C:\flutter\bin\flutter.bat pub get
```

### 2. Create Remaining Screen Files

The following screen files need to be created. I'll provide the code for each:

#### A. Splash Screen (`lib/screens/splash_screen.dart`)
#### B. Login Screen (`lib/screens/login_screen.dart`)
#### C. Home Screen (`lib/screens/home_screen.dart`)
#### D. Video Recording Screen (`lib/screens/video_recording_screen.dart`)
#### E. Results Screen (`lib/screens/results_screen.dart`)

### 3. Update Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 4. Update iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to record clinical observation videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record videos with audio</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save recorded videos</string>
```

## 🏗️ App Architecture

### State Management: Provider Pattern
- `AuthProvider` - Manages authentication state
- Future: `VideoProvider` - Manages video recording/upload state

### Services Layer
- `AuthService` - Handles API calls for authentication
- `VideoService` - Handles video upload and RRB detection

### Models
- `User` - User data model
- `DetectionResult` - RRB detection results
- `BehaviorDetection` - Individual behavior detection
- `VideoMetadata` - Video metadata

## 🔌 API Integration

### Backend APIs (Node.js)
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/videos/upload` - Upload video
- `GET /api/results/:videoId` - Get detection results

### ML Service APIs (Python Flask)
- `POST /api/v1/detect` - Detect RRB in video
- `GET /health` - Health check

## 📱 App Flow

1. **Splash Screen** → Check authentication
2. **Login Screen** → Authenticate user
3. **Home Screen** → Main dashboard
4. **Video Recording** → Record clinical observation
5. **Processing** → Upload & detect RRB
6. **Results Screen** → Display detection results

## 🎨 UI/UX Features

- Material Design 3
- Responsive layouts
- Loading indicators
- Error handling
- Toast notifications
- Progress indicators
- Charts for visualization

## 🔒 Security

- JWT token authentication
- Secure storage for tokens
- HTTPS communication (production)
- Input validation
- Error handling

## 📊 Detection Display

Results screen shows:
- Primary detected behavior
- Confidence score
- All detected behaviors with:
  - Behavior name
  - Confidence percentage
  - Number of occurrences
  - Total duration
- Video metadata
- Visual charts

## 🧪 Testing

```bash
# Run tests
C:\flutter\bin\flutter.bat test

# Run app in debug mode
C:\flutter\bin\flutter.bat run

# Build APK
C:\flutter\bin\flutter.bat build apk

# Build iOS
C:\flutter\bin\flutter.bat build ios
```

## 📝 Configuration

Update `lib/config/app_config.dart` with your backend URLs:
- `apiBaseUrl` - Node.js backend URL
- `mlServiceUrl` - Python ML service URL

## 🚀 Deployment

### Android
1. Update `android/app/build.gradle` with signing config
2. Run: `flutter build apk --release`
3. APK location: `build/app/outputs/flutter-apk/app-release.apk`

### iOS
1. Configure signing in Xcode
2. Run: `flutter build ios --release`
3. Archive and upload to App Store

## 📚 Resources

- Flutter Documentation: https://docs.flutter.dev/
- Provider Package: https://pub.dev/packages/provider
- Camera Package: https://pub.dev/packages/camera
- HTTP Package: https://pub.dev/packages/http

