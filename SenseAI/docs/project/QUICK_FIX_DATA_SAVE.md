# Quick Fix: Data Not Saving to Firebase

## Step-by-Step Diagnosis

### Step 1: Check Backend is Running

Open terminal and run:
```bash
cd senseai_backend
npm start
```

**Expected Output:**
```
==================================================
SenseAI Backend + Firebase running
==================================================
→ Listening on http://0.0.0.0:3000
→ Health check: http://YOUR_LAPTOP_IP:3000/health
==================================================
Firebase Firestore connected successfully!
```

**If you see errors:**
- Check if `serviceAccountKey.json` exists in `senseai_backend/` folder
- Check if Firebase is properly configured

### Step 2: Test Backend Health

Open browser or Postman:
```
GET http://localhost:3000/health
```

**Should return:**
```json
{
  "status": "OK",
  "timestamp": "2024-..."
}
```

### Step 3: Check Mobile App Backend URL

1. Open mobile app
2. Go to **Settings**
3. Check **Backend URL** field
4. Should be:
   - **For Emulator**: `http://10.0.2.2:3000`
   - **For Real Device/Tablet**: `http://YOUR_LAPTOP_IP:3000`

**To find your laptop IP:**
- Windows: Open Command Prompt → `ipconfig` → Look for "IPv4 Address" under Wi-Fi adapter
- Mac/Linux: Open Terminal → `ifconfig` → Look for "inet" under Wi-Fi adapter

### Step 4: Test with Postman

#### Test Child Creation:
```
POST http://localhost:3000/api/children
Content-Type: application/json

{
  "name": "Test Child",
  "date_of_birth": 946684800000,
  "gender": "male",
  "language": "en"
}
```

**Expected Response:**
```json
{
  "child": {
    "id": "...",
    "name": "Test Child",
    ...
  }
}
```

**If this works:** Backend is fine, issue is in mobile app connection
**If this fails:** Backend has an issue

### Step 5: Check Logs

#### Backend Logs (Terminal):
When you add a child in mobile app, you should see:
```
📥 Received child creation request: {...}
✅ Child created in Firebase: abc123 (Test Child, Group: typically_developing)
```

**If you don't see this:** Mobile app isn't reaching backend

#### Mobile App Logs (Flutter Console):
Look for:
```
🌐 Creating child via API: http://...
📤 Request body: {...}
📥 Response status: 201
✅ Child created successfully: abc123
```

**Or errors:**
```
❌ Error creating child: ...
❌ Error type: ...
⚠️ Saving locally and queuing for sync...
```

### Step 6: Common Issues & Fixes

#### Issue: "Connection refused" or "Failed host lookup"
**Fix:**
1. Check backend is running
2. Check backend URL in mobile app settings
3. For real device: Use laptop IP, not localhost
4. Ensure same Wi-Fi network

#### Issue: "404 Not Found"
**Fix:**
1. Check backend URL doesn't have trailing slash
2. Should be: `http://192.168.1.100:3000` (not `http://192.168.1.100:3000/`)

#### Issue: "400 Bad Request"
**Fix:**
1. Check backend logs for validation errors
2. Verify data format matches backend schema
3. Check required fields are provided

#### Issue: Data saves locally but not to Firebase
**Fix:**
1. Backend connection failed
2. Check backend is running
3. Check backend URL
4. Data will sync when backend is available

### Step 7: Verify Firebase

1. Go to Firebase Console
2. Check Firestore Database
3. Look for `children` and `sessions` collections
4. Verify data appears there

## Quick Test Checklist

- [ ] Backend server is running (`npm start` in `senseai_backend`)
- [ ] Health check works (`GET http://localhost:3000/health`)
- [ ] Mobile app backend URL is correct
- [ ] Mobile device and laptop on same network
- [ ] Postman test works (child creation)
- [ ] Backend logs show incoming requests
- [ ] Firebase service account key exists
- [ ] No firewall blocking port 3000

## Still Not Working?

1. **Check backend terminal** - Look for errors
2. **Check mobile app console** - Look for API errors
3. **Test with Postman** - Isolate if it's mobile app or backend
4. **Check network** - Ping between devices
5. **Restart everything** - Backend, mobile app, network

## What I Added

1. ✅ Better error logging in mobile app
2. ✅ Better request/response logging
3. ✅ Backend logging for incoming requests
4. ✅ Clear success/error messages

Now when you add a child, check:
- **Backend terminal** - Should see request and success message
- **Mobile app console** - Should see API call and response

This will help identify where the issue is!

