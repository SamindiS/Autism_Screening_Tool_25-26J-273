# Flutter App ↔ Backend Integration Guide

## Current Situation

**❌ Data is NOT automatically shared** between your Flutter app and the backend.

### Why?

- **Flutter App**: Uses local SQLite database (`sqflite`) stored in app's documents directory
- **Backend**: Uses separate SQLite database in `senseai_backend` folder
- **They are completely separate** - no connection between them

---

## Solution Options

### Option 1: Connect Flutter App to Backend API (Recommended)

Make your Flutter app use the backend API instead of local SQLite directly.

#### Steps:

1. **Add HTTP package to Flutter**
   ```yaml
   # pubspec.yaml
   dependencies:
     http: ^0.13.5  # Add this
   ```

2. **Create API Service**
   Create `lib/core/services/api_service.dart`:
   ```dart
   import 'package:http/http.dart' as http;
   import 'dart:convert';
   
   class ApiService {
     static const String baseUrl = 'http://localhost:3000'; // For emulator
     // For real device: 'http://<your-computer-ip>:3000'
     
     // Example: Create child
     static Future<Map<String, dynamic>> createChild({
       required String name,
       required DateTime dateOfBirth,
       required String gender,
       required String language,
     }) async {
       final response = await http.post(
         Uri.parse('$baseUrl/api/children'),
         headers: {'Content-Type': 'application/json'},
         body: jsonEncode({
           'name': name,
           'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
           'gender': gender,
           'language': language,
         }),
       );
       
       if (response.statusCode == 201) {
         return jsonDecode(response.body);
       } else {
         throw Exception('Failed to create child');
       }
     }
     
     // Add more methods for other endpoints...
   }
   ```

3. **Update StorageService to use API**
   Modify `StorageService` to call the API instead of local SQLite.

#### Pros:
- ✅ Single source of truth (backend database)
- ✅ Data accessible from both Flutter app and Postman
- ✅ Easy to sync to cloud later
- ✅ Centralized data management

#### Cons:
- ❌ Requires backend server running
- ❌ Needs network connection
- ❌ More complex error handling

---

### Option 2: Hybrid Approach (Offline-First + Sync)

Keep local SQLite for offline use, sync to backend when online.

#### Steps:

1. **Keep using local SQLite** in Flutter app
2. **Add sync service** that:
   - Saves to local DB first (offline support)
   - Syncs to backend API when online
   - Handles conflicts

#### Pros:
- ✅ Works offline
- ✅ Fast local access
- ✅ Can sync when online
- ✅ Data accessible from Postman after sync

#### Cons:
- ❌ More complex to implement
- ❌ Need conflict resolution
- ❌ Two databases to maintain

---

### Option 3: Use Backend Database Directly (Advanced)

Point both Flutter and backend to the same SQLite file.

#### Steps:

1. **Share database file** between Flutter app and backend
2. **Use file path** that both can access
3. **Handle concurrent access** carefully

#### Pros:
- ✅ Single database file
- ✅ Immediate data sharing
- ✅ No API needed

#### Cons:
- ❌ Complex file path management
- ❌ Concurrent access issues
- ❌ Platform-specific paths
- ❌ Not recommended for production

---

## Recommended: Option 1 (API-Based)

### Implementation Steps

#### 1. Add HTTP Package

```bash
flutter pub add http
```

#### 2. Create API Service

Create `lib/core/services/api_service.dart` with all CRUD operations.

#### 3. Update Your Screens

Replace `StorageService` calls with `ApiService` calls:

**Before:**
```dart
await StorageService.saveChild(...);
```

**After:**
```dart
await ApiService.createChild(...);
```

#### 4. Handle Errors

Add try-catch blocks and show user-friendly error messages.

#### 5. Add Loading States

Show loading indicators while API calls are in progress.

---

## Quick Test Setup

### For Android Emulator:
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### For Real Device:
1. Find your computer's IP address:
   ```bash
   # Windows
   ipconfig
   
   # Mac/Linux
   ifconfig
   ```

2. Use that IP:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000'; // Your IP
   ```

3. Make sure Flutter app and backend are on same network

---

## Testing Flow

1. **Start Backend:**
   ```bash
   cd senseai_backend
   npm start
   ```

2. **Run Flutter App:**
   ```bash
   flutter run
   ```

3. **Add data in Flutter app** → Saves to backend via API

4. **Check in Postman:**
   - GET `/api/children` → Should show the child you added

5. **Add data in Postman** → Saves to backend database

6. **Check in Flutter app** → Refresh → Should show data from Postman

---

## Example: Complete API Service

See `lib/core/services/api_service_example.dart` (create this file):

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // For real device, use your computer's IP:
  // static const String baseUrl = 'http://192.168.1.100:3000';
  
  // Children
  static Future<Map<String, dynamic>> createChild({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String language,
    String? hospitalId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/children'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
        'gender': gender,
        'language': language,
        'hospital_id': hospitalId,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create child: ${response.body}');
    }
  }
  
  static Future<List<Map<String, dynamic>>> getAllChildren() async {
    final response = await http.get(Uri.parse('$baseUrl/api/children'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['children']);
    } else {
      throw Exception('Failed to load children');
    }
  }
  
  // Add more methods for sessions, trials, etc.
}
```

---

## Summary

**Current State:**
- ❌ Flutter app and backend use separate databases
- ❌ Data added in Flutter is NOT visible in Postman
- ❌ Data added in Postman is NOT visible in Flutter

**After Integration:**
- ✅ Flutter app calls backend API
- ✅ All data stored in backend database
- ✅ Data accessible from both Flutter and Postman
- ✅ Single source of truth

---

## Next Steps

1. Choose an integration approach (Option 1 recommended)
2. Add `http` package to Flutter
3. Create `ApiService` class
4. Update your screens to use API instead of local SQLite
5. Test data flow between Flutter and Postman

---

## Need Help?

- Check `POSTMAN_GUIDE.md` for API endpoint details
- Check `BACKEND_FEATURES.md` for available features
- Test endpoints in Postman first before integrating

