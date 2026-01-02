# Test Login Right Now - Quick Steps

## 🚀 Immediate Actions

### 1. Start Backend (Terminal 1)

```bash
cd senseai_backend
npm start
```

**Wait for this message:**
```
==================================================
SenseAI Backend + Firebase running
==================================================
→ Listening on http://0.0.0.0:3000
```

**Keep this terminal open!**

---

### 2. Test Backend (Terminal 2 - New Terminal)

```bash
curl http://localhost:3000/health
```

**Should show:**
```json
{"status":"OK","timestamp":"2025-..."}
```

**If this fails** → Backend not running properly

---

### 3. Find Your IP

**Windows**:
```bash
ipconfig | findstr IPv4
```

**Copy the IP address** (e.g., `192.168.1.100`)

---

### 4. Test from Computer

**In Terminal 2**:
```bash
cd senseai_backend
node test_connection.js YOUR_IP
```

**Replace YOUR_IP** with your actual IP.

**Example:**
```bash
node test_connection.js 192.168.1.100
```

**Should show**: `✅ SUCCESS!`

---

### 5. Test Login Directly (Terminal 2)

**Test admin login:**
```bash
curl -X POST http://localhost:3000/api/clinicians/login -H "Content-Type: application/json" -d "{\"pin\":\"admin123\"}"
```

**Should return:**
```json
{
  "success": true,
  "message": "Admin login successful",
  "role": "admin",
  ...
}
```

**If this works** → Backend is fine, issue is with app connection

**If this fails** → Backend has a problem

---

### 6. Configure App

**In mobile app:**
1. Try to login → Backend config dialog appears
2. Enter: `http://YOUR_IP:3000` (no trailing slash!)
3. Click **"Test Connection"**
4. **What happens?**
   - ✅ "Connection successful!" → Good!
   - ❌ Error message → Tell me what it says

---

### 7. Try Login Again

**After Test Connection succeeds:**
1. Enter PIN: `admin123`
2. Click Login
3. **Watch Terminal 1** (backend) - what appears?

**Should see:**
```
🔐 LOGIN REQUEST RECEIVED
📌 PIN received: ad***
✅ Admin login detected
```

**If you see errors** → Copy and paste them here

---

## 🔍 What to Check

### Backend Terminal (Terminal 1):
- Is it running? (Should show "Listening on...")
- Any error messages?
- When you login, what appears?

### App Error Message:
- What exact error do you see?
- Does backend config dialog appear?
- What does "Test Connection" say?

### Network:
- Both devices on same Wi-Fi?
- Can you ping your computer from tablet?
- Can you open `http://YOUR_IP:3000/health` in tablet browser?

---

## 📋 Tell Me:

1. **Backend running?** (Yes/No - what do you see?)
2. **Health endpoint works?** (Yes/No - what response?)
3. **Your IP address?** (From `ipconfig`)
4. **Test Connection result?** (Success/Failed - what message?)
5. **Login error?** (What exact error message?)
6. **Backend terminal logs?** (What appears when you login?)

---

## 🎯 Most Common Fix

**90% of the time, it's one of these:**

1. **Backend not running** → `cd senseai_backend && npm start`
2. **Wrong IP** → Check with `ipconfig`, update in app
3. **Firewall** → Allow port 3000
4. **Different Wi-Fi** → Connect both to same network

**Try these first!**

