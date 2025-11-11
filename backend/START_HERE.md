# 🚀 START HERE - Backend Setup in 5 Minutes!

Welcome! Let's get your backend API running. Follow these steps:

---

## ✅ Step 1: Dependencies Installed ✓

Already done! All packages are installed.

---

## ⚠️ Step 2: Create .env File (YOU NEED TO DO THIS)

**This is the MOST IMPORTANT step!**

### Quick Instructions:

1. **Open:** `CREATE_ENV_FILE.md` (read it first!)

2. **Download Firebase Key:**
   - Go to: https://console.firebase.google.com/project/senseai-cognitive/settings/serviceaccounts/adminsdk
   - Click "Generate new private key"
   - Download the JSON file

3. **Create .env file** in `backend/` folder

4. **Copy credentials** from downloaded JSON

---

### Run Test to Check:

```bash
cd backend
node QUICK_TEST.js
```

This will tell you if your .env file is ready!

---

## 🔥 Step 3: Enable Firebase Services

### Enable Firestore:
1. Go to: https://console.firebase.google.com/project/senseai-cognitive/firestore
2. Click "Create database" → "Test mode" → Location → "Enable"

### Enable Storage:
1. Go to: https://console.firebase.google.com/project/senseai-cognitive/storage
2. Click "Get started" → "Done"

---

## 🚀 Step 4: Run the Server

```bash
cd backend
npm run dev
```

**✅ Success looks like:**

```
✅ Firebase Admin SDK initialized successfully
╔═══════════════════════════════════════════════════════════╗
║    🚀 SenseAI Backend API Server                         ║
║    📍 Server running on http://localhost:3000            ║
║    🔥 Firebase initialized                               ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 🧪 Step 5: Test the API

**Open a NEW terminal** (keep server running):

```bash
# Test health
curl http://localhost:3000/health

# Test API info
curl http://localhost:3000/
```

**✅ Expected:**
```json
{
  "status": "ok",
  "message": "SenseAI Backend API is running"
}
```

---

## 📚 Need Help?

### Read These Guides:
- 📖 `CREATE_ENV_FILE.md` - How to create .env
- 📖 `SETUP_AND_RUN.md` - Complete setup guide
- 📖 `README.md` - Full API documentation
- 📖 `../docs/BACKEND_QUICK_START.md` - Super quick guide

### Quick Tests:
- `node QUICK_TEST.js` - Check your setup
- `curl http://localhost:3000/health` - Test API

### Common Errors:
- **".env not found"** → Read `CREATE_ENV_FILE.md`
- **"Firebase init failed"** → Check .env has correct credentials
- **"Port 3000 in use"** → Change PORT in .env to 3001

---

## ✅ Checklist

Before running server:

- [ ] Read `CREATE_ENV_FILE.md`
- [ ] Downloaded Firebase service account key
- [ ] Created `.env` file in `backend/` folder
- [ ] Copied credentials to `.env`
- [ ] Enabled Firestore in Firebase Console
- [ ] Enabled Storage in Firebase Console
- [ ] Ran `node QUICK_TEST.js` - all checks passed

---

## 🎯 Next Steps After Backend is Running:

1. **Keep backend running** (don't close that terminal!)

2. **Connect React Native app:**
   - Backend is already set up in `src/services/backendApi.ts`
   - Just run your React Native app
   - Data will sync automatically!

3. **Test from app:**
   - Register a new child
   - Play a game
   - Complete an assessment
   - Check Firebase Console to see data arriving!

---

## 🎉 That's It!

Once you see the server running, your backend is ready to use!

**Common Commands:**
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm start            # Run production build
node QUICK_TEST.js   # Test your setup
```

---

**Questions?** Read the guides or check Firebase Console!

**Ready to start?** → Read `CREATE_ENV_FILE.md` first! 🚀




