# API Service Setup Guide

## ✅ What's Done

1. ✅ Added `http` package to `pubspec.yaml`
2. ✅ Created `ApiService` class with all CRUD operations
3. ✅ Updated `StorageService` to use `ApiService` instead of local SQLite
4. ✅ All data now goes through backend API

## 🚀 Next Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Base URL

Edit `lib/core/services/api_service.dart`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

**For Real Device:**
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` (look for inet)
   
2. Update the base URL:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000'; // Your IP
   ```

### 3. Start Backend Server

```bash
cd senseai_backend
npm start
```

Server should be running on `http://localhost:3000`

### 4. Test the Connection

Run your Flutter app and try adding a child. Check Postman to see if it appears:

```bash
GET http://localhost:3000/api/children
```

## 📱 Testing Flow

1. **Start Backend**: `npm start` in `senseai_backend`
2. **Run Flutter App**: `flutter run`
3. **Add Child in App** → Should save to backend
4. **Check Postman**: `GET /api/children` → Should see the child
5. **Add Child in Postman** → Should save to backend
6. **Refresh App** → Should see child from Postman

## ⚠️ Important Notes

### Network Configuration

- **Emulator**: Uses `10.0.2.2` to access host machine
- **Real Device**: Must be on same WiFi network as your computer
- **Backend**: Must be running before using the app

### Error Handling

The API service includes error handling. If backend is not available:
- App will show errors
- Check console logs for details
- Make sure backend is running

### Data Format

The `StorageService` now converts between:
- **App format**: What your Flutter screens expect
- **API format**: What the backend expects

This ensures compatibility with existing code.

## 🔧 Troubleshooting

### "Connection refused" Error
- ✅ Check backend is running: `npm start`
- ✅ Check base URL is correct
- ✅ For real device: Check IP address and WiFi connection

### "404 Not Found" Error
- ✅ Check backend routes are correct
- ✅ Verify endpoint paths match

### Data Not Appearing
- ✅ Check backend console for errors
- ✅ Verify data format matches API expectations
- ✅ Check Postman to see if data is in backend

## 📝 What Changed

### Before:
- Flutter app → Local SQLite → Only visible in app
- Postman → Backend SQLite → Only visible in Postman
- **No connection between them**

### After:
- Flutter app → API Service → Backend API → Backend SQLite
- Postman → Backend API → Backend SQLite
- **Both use same database!**

## 🎉 Result

Now when you:
- ✅ Add data in Flutter app → Visible in Postman
- ✅ Add data in Postman → Visible in Flutter app
- ✅ Edit data in either → Changes visible in both
- ✅ Delete data in either → Deleted in both

**Single source of truth: Backend Database!**

