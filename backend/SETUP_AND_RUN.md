# 🚀 Quick Setup & Run Guide

## Your Firebase Project
- **Project ID:** `senseai-cognitive`
- **Storage:** `senseai-cognitive.firebasestorage.app`

---

## ⚡ Quick Setup (5 Minutes)

### Step 1: Get Firebase Admin SDK Key ⏱️ 2 minutes

1. **Open this link:**
   ```
   https://console.firebase.google.com/project/senseai-cognitive/settings/serviceaccounts/adminsdk
   ```

2. **Click "Generate new private key"**

3. **Click "Generate key" in popup**

4. **A JSON file downloads** → Open it

### Step 2: Create `.env` File ⏱️ 1 minute

Create file: `backend/.env`

```bash
FIREBASE_PROJECT_ID=senseai-cognitive
FIREBASE_CLIENT_EMAIL=PASTE_HERE
FIREBASE_PRIVATE_KEY="PASTE_HERE"

PORT=3000
NODE_ENV=development
ML_API_URL=http://localhost:5000/predict
ML_API_KEY=optional
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8081,http://localhost:19006,http://10.0.2.2:3000
STORAGE_BUCKET=senseai-cognitive.firebasestorage.app
```

**Copy from JSON file:**
- `client_email` → `FIREBASE_CLIENT_EMAIL`
- `private_key` → `FIREBASE_PRIVATE_KEY` (keep the `\n` and quotes!)

### Step 3: Enable Firestore ⏱️ 1 minute

**Open this link:**
```
https://console.firebase.google.com/project/senseai-cognitive/firestore
```

**Click:** "Create database" → "Test mode" → Choose location → "Enable"

### Step 4: Enable Storage ⏱️ 1 minute

**Open this link:**
```
https://console.firebase.google.com/project/senseai-cognitive/storage
```

**Click:** "Get started" → "Done"

---

## 🚀 Run the Backend

```bash
# Go to backend folder
cd backend

# Install dependencies (first time only)
npm install

# Run the server
npm run dev
```

**✅ Success Output:**
```
✅ Firebase Admin SDK initialized successfully
╔═══════════════════════════════════════════════════════════╗
║    🚀 SenseAI Backend API Server                         ║
║    📍 Server running on http://localhost:3000            ║
║    🔥 Firebase initialized                               ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 🧪 Test the API

**Open new terminal and run:**

```bash
# Test 1: Health check
curl http://localhost:3000/health

# Expected: {"status":"ok","message":"SenseAI Backend API is running"}

# Test 2: API info
curl http://localhost:3000/

# Expected: JSON with all endpoint info
```

**✅ If you see JSON responses, it's working!**

---

## 📝 Complete Example .env File

```bash
FIREBASE_PROJECT_ID=senseai-cognitive
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-a1b2c@senseai-cognitive.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"

PORT=3000
NODE_ENV=development

ML_API_URL=http://localhost:5000/predict
ML_API_KEY=optional

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8081,http://localhost:19006,http://10.0.2.2:3000

STORAGE_BUCKET=senseai-cognitive.firebasestorage.app
```

---

## 🎯 What You Need to Do

1. ✅ Create `.env` file in `backend/` folder
2. ✅ Copy credentials from downloaded JSON
3. ✅ Enable Firestore in Firebase Console
4. ✅ Enable Storage in Firebase Console
5. ✅ Run `npm install` (first time only)
6. ✅ Run `npm run dev`
7. ✅ Test with `curl http://localhost:3000/health`

---

## 🐛 Still Having Issues?

### Error: "Cannot find module"
```bash
cd backend
npm install
```

### Error: "Firebase initialization failed"
1. Check `.env` file exists in `backend/` folder
2. Verify you copied the full private key with `\n`
3. Make sure Firestore is enabled
4. Make sure Storage is enabled

### Error: "Port 3000 in use"
Change port in `.env`:
```bash
PORT=3001
```

---

## 📚 More Help

- See: [backend/ENV_SETUP_INSTRUCTIONS.md](ENV_SETUP_INSTRUCTIONS.md)
- See: [docs/BACKEND_QUICK_START.md](../docs/BACKEND_QUICK_START.md)
- See: [backend/README.md](README.md)

---

**Ready to test in 5 minutes!** 🎉




