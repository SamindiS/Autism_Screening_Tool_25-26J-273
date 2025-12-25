# Firebase Authentication Error Fix

## 🔴 Problem

```
⚠️  WARNING: Firebase connection test failed: 16 UNAUTHENTICATED: 
Request had invalid authentication credentials.
```

## 🔍 Root Cause

The Firebase service account key exists and loads, but the **connection test fails** with an authentication error. This usually means:

1. **Service account key is expired or revoked**
2. **Service account was deleted from Firebase Console**
3. **Service account lacks Firestore permissions**
4. **Private key is corrupted or incomplete**
5. **Wrong Firebase project**

## ✅ Solution

### Step 1: Verify Service Account Key

Check if your `serviceAccountKey.json` is valid:

```bash
# In senseai_backend directory
node -e "const key = require('./serviceAccountKey.json'); console.log('Project:', key.project_id); console.log('Email:', key.client_email);"
```

### Step 2: Download New Service Account Key

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project: `senseai-cognitive`

2. **Navigate to Service Accounts**
   - Click the gear icon ⚙️ (Project Settings)
   - Go to "Service Accounts" tab

3. **Generate New Private Key**
   - Click "Generate new private key"
   - Confirm the dialog
   - A JSON file will download

4. **Replace the Old Key**
   ```bash
   # Backup old key (just in case)
   cp senseai_backend/serviceAccountKey.json senseai_backend/serviceAccountKey.json.backup
   
   # Replace with new downloaded file
   # Copy the downloaded file to: senseai_backend/serviceAccountKey.json
   ```

### Step 3: Verify Firestore Permissions

1. **Check IAM Permissions**
   - Go to Google Cloud Console: https://console.cloud.google.com/
   - Select project: `senseai-cognitive`
   - Go to "IAM & Admin" > "IAM"
   - Find your service account email: `firebase-adminsdk-xxxxx@senseai-cognitive.iam.gserviceaccount.com`
   - Ensure it has these roles:
     - ✅ **Firebase Admin SDK Administrator Service Agent**
     - ✅ **Cloud Datastore User** (or **Cloud Firestore User**)

2. **Enable Firestore API**
   - Go to "APIs & Services" > "Enabled APIs"
   - Ensure "Cloud Firestore API" is enabled
   - If not, click "Enable API"

### Step 4: Test the Connection

```bash
# Restart the backend
cd senseai_backend
npm start
```

You should see:
```
✅ Firebase Firestore connected successfully!
   Project ID: senseai-cognitive
✅ Firebase connection test successful!
```

## 🔧 Alternative: Check Service Account Status

If the above doesn't work, check if the service account is active:

1. **Google Cloud Console** > **IAM & Admin** > **Service Accounts**
2. Find: `firebase-adminsdk-xxxxx@senseai-cognitive.iam.gserviceaccount.com`
3. Check status - should be "Enabled"
4. If disabled, click "Enable"

## 🚨 Important Notes

1. **Never commit `serviceAccountKey.json` to Git**
   - It's already in `.gitignore`
   - Contains sensitive credentials

2. **The app may still work** even with this warning
   - The warning is from a connection test
   - Actual operations might still succeed
   - But it's better to fix it

3. **If you see this error, some operations might fail:**
   - Saving data to Firestore
   - Reading data from Firestore
   - Exporting CSV from Firebase

## 📝 Quick Fix Checklist

- [ ] Download new service account key from Firebase Console
- [ ] Replace `senseai_backend/serviceAccountKey.json`
- [ ] Verify service account has Firestore permissions
- [ ] Enable Cloud Firestore API
- [ ] Restart backend: `npm start`
- [ ] Verify no authentication errors

## 🎯 Expected Output After Fix

```
✅ Firebase Firestore connected successfully!
   Project ID: senseai-cognitive
✅ Firebase connection test successful!
==================================================
SenseAI Backend + Firebase running
==================================================
→ Listening on http://0.0.0.0:3000
```

---

*Last Updated: 2024*


