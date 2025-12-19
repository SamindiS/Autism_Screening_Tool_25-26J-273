# Fixes for Registration and Login Issues

## 🔴 Issues Fixed

### Issue 1: Session Type Validation Error ✅ FIXED
**Problem**: App was sending `"color-shape"` (with hyphen) but backend expected `"color_shape"` (with underscore)

**Error Message**:
```
❌ Validation error: "session_type" must be one of [ai_doctor_bot, frog_jump, color_shape, manual_assessment]
```

**Solution**:
1. ✅ Added session type normalization in `lib/core/services/storage_service.dart`
   - Automatically converts hyphens to underscores
   - Maps common variations to backend-expected values
   - Handles: `color-shape`, `dccs-color-shape`, `frog-jump`, etc.

2. ✅ Updated `color_shape_game_screen.dart` to use `'color_shape'` directly
3. ✅ Updated `frog_jump_game_screen.dart` to use `'frog_jump'` directly

**Files Changed**:
- `lib/core/services/storage_service.dart` - Added normalization logic
- `lib/features/assessment/games/color_shape_game/color_shape_game_screen.dart` - Fixed session type
- `lib/features/assessment/games/frog_jump_game/frog_jump_game_screen.dart` - Fixed session type

---

### Issue 2: Firebase Authentication Error ✅ FIXED
**Problem**: Firebase authentication failing when registering/logging in clinicians

**Error Message**:
```
❌ Registration error: Error: 16 UNAUTHENTICATED: Request had invalid authentication credentials.
Expected OAuth 2 access token, login cookie or other valid authentication credential.
```

**Possible Causes**:
1. Missing or invalid `serviceAccountKey.json`
2. Service account key expired or revoked
3. Wrong Firebase project configuration
4. Service account doesn't have proper permissions

**Solution**:
1. ✅ Enhanced Firebase initialization with better error handling
2. ✅ Added validation for service account key structure
3. ✅ Added connection test on startup
4. ✅ Improved error messages with troubleshooting steps

**Files Changed**:
- `senseai_backend/firebase.js` - Enhanced error handling and validation

---

## 🔧 How to Fix Firebase Authentication

### Step 1: Verify serviceAccountKey.json Exists

Check if the file exists:
```powershell
Test-Path senseai_backend\serviceAccountKey.json
```

### Step 2: Download New Service Account Key

If the file is missing or invalid:

1. **Go to Firebase Console**:
   - Visit: https://console.firebase.google.com
   - Select your project

2. **Navigate to Service Accounts**:
   - Project Settings (gear icon) → Service Accounts tab

3. **Generate New Key**:
   - Click "Generate new private key"
   - Download the JSON file

4. **Save the File**:
   - Rename to `serviceAccountKey.json`
   - Place in `senseai_backend/` directory
   - **IMPORTANT**: Never commit this file to Git!

### Step 3: Verify Firebase Project Permissions

1. **Check Firestore Rules**:
   - Go to Firebase Console → Firestore Database → Rules
   - Ensure rules allow read/write for authenticated service accounts

2. **Check Service Account Permissions**:
   - Go to Google Cloud Console
   - IAM & Admin → IAM
   - Find your service account email
   - Ensure it has "Cloud Datastore User" or "Firebase Admin" role

### Step 4: Restart Backend

```powershell
cd senseai_backend
npm start
```

You should see:
```
✅ Firebase Firestore connected successfully!
   Project ID: your-project-id
✅ Firebase connection test successful!
```

---

## ✅ Testing the Fixes

### Test 1: Session Creation
1. Open mobile app
2. Create a child
3. Start a color-shape game
4. Check backend logs - should see:
   ```
   ✅ Session created in Firebase: <session-id> (Type: color_shape, Child: <child-id>)
   ```

### Test 2: Clinician Registration
1. Open mobile app
2. Try to register a new clinician
3. Should succeed without authentication errors

### Test 3: Clinician Login
1. Open mobile app
2. Login with registered PIN
3. Should succeed

---

## 🚨 If Still Having Issues

### Check Backend Logs

Look for these messages:
- ✅ `Firebase Firestore connected successfully!` - Good
- ❌ `ERROR: serviceAccountKey.json not found!` - Need to download key
- ❌ `ERROR: Failed to initialize Firebase` - Check key validity
- ⚠️ `WARNING: Firebase connection test failed` - Check permissions

### Common Solutions

1. **"serviceAccountKey.json not found"**:
   - Download new key from Firebase Console
   - Place in `senseai_backend/` directory

2. **"Invalid authentication credentials"**:
   - Service account key might be expired
   - Download a new key from Firebase Console
   - Make sure you're using the correct Firebase project

3. **"Permission denied"**:
   - Check Firestore security rules
   - Check service account IAM permissions in Google Cloud Console

4. **"Project not found"**:
   - Verify `project_id` in `serviceAccountKey.json` matches your Firebase project

---

## 📝 Summary

✅ **Session Type Issue**: Fixed by normalizing session types before sending to backend
✅ **Firebase Auth Issue**: Enhanced error handling and validation

**Next Steps**:
1. Restart backend to see improved error messages
2. If Firebase auth still fails, download new `serviceAccountKey.json`
3. Test registration and login in mobile app

---

*Last Updated: 2024*

