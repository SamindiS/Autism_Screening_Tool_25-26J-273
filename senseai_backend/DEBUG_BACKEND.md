# Backend Debugging Guide

## Quick Backend Health Check

### 1. Start Backend with Verbose Logging

```bash
cd senseai_backend
npm start
```

**Look for these messages:**
```
==================================================
SenseAI Backend + Firebase running
==================================================
→ Listening on http://0.0.0.0:3000
→ Health check: http://YOUR_LAPTOP_IP:3000/health
==================================================
```

**If you see Firebase errors:**
- Check `serviceAccountKey.json` exists
- Verify Firebase project is active
- Check Firebase quota (may be exceeded)

### 2. Test Health Endpoint

**In browser or new terminal:**
```bash
curl http://localhost:3000/health
```

**Should return:**
```json
{"status":"OK","timestamp":"2025-..."}
```

### 3. Test Login Endpoint Directly

**Test admin login:**
```bash
curl -X POST http://localhost:3000/api/clinicians/login \
  -H "Content-Type: application/json" \
  -d "{\"pin\":\"admin123\"}"
```

**Should return:**
```json
{
  "success": true,
  "message": "Admin login successful",
  "role": "admin",
  "user": {...}
}
```

**Test clinician login:**
```bash
curl -X POST http://localhost:3000/api/clinicians/login \
  -H "Content-Type: application/json" \
  -d "{\"pin\":\"1234\"}"
```

(Replace `1234` with your clinician PIN)

### 4. Check Backend Logs When Login Attempted

**When you try to login from app, backend terminal should show:**

**For admin:**
```
✅ Admin login detected
```

**For clinician:**
```
🔍 Attempting login with PIN (length: 4)
✅ PIN match found for clinician: ...
✅ Login successful for clinician: ...
```

**If you see errors:**
```
❌ Login failed: Invalid PIN
⚠️  Clinician ... has no pin_hash
```

### 5. Common Backend Issues

#### Issue: Firebase Authentication Error
```
Error: 16 UNAUTHENTICATED: Request had invalid authentication credentials.
```

**Fix:**
1. Download new `serviceAccountKey.json` from Firebase Console
2. Replace file in `senseai_backend/`
3. Restart backend

#### Issue: Port Already in Use
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Fix:**
1. Find process using port 3000:
   ```bash
   # Windows
   netstat -ano | findstr :3000
   
   # Kill the process (replace PID)
   taskkill /PID <PID> /F
   ```
2. Restart backend

#### Issue: No Clinicians in Database
```
⚠️  No clinicians found in database
```

**Fix:**
1. Register a clinician first
2. Or use admin PIN: `admin123`

---

## Backend Connection Test Script

Run this to test your backend:

```bash
cd senseai_backend
node test_connection.js localhost
node test_connection.js YOUR_IP
```

This will tell you if:
- Backend is running
- Health endpoint works
- Connection is accessible from network

---

## Enable More Debugging

Add this to `server.js` to see all requests:

```javascript
// Add after app.use(express.json())
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  console.log('Body:', JSON.stringify(req.body, null, 2));
  next();
});
```

This will log every request to help debug.

