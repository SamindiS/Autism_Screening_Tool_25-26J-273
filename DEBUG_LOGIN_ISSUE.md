# Debug Login Issue - Step by Step

## 🔍 Let's Debug This Together

Follow these steps and tell me what you see at each step:

---

## Step 1: Check if Backend is Running

**Open a terminal/command prompt** and run:

```bash
cd senseai_backend
npm start
```

**What to look for:**
- Should see: `SenseAI Backend + Firebase running`
- Should see: `Listening on http://0.0.0.0:3000`
- **If you see errors**, copy and paste them here

**Question**: Do you see the backend starting successfully? (Yes/No)

---

## Step 2: Test Backend Health Endpoint

**While backend is running**, open a **new terminal** and run:

```bash
curl http://localhost:3000/health
```

**OR** open a browser and go to: `http://localhost:3000/health`

**What you should see:**
```json
{"status":"OK","timestamp":"2025-..."}
```

**Question**: What do you see? (Paste the response or error)

---

## Step 3: Find Your Computer's IP Address

**Windows** (PowerShell or Command Prompt):
```bash
ipconfig
```

**Look for**: `IPv4 Address` under your active network (Wi-Fi or Ethernet)

**Example**: `192.168.1.100` or `192.168.0.105`

**Question**: What is your IP address? (Paste it here)

---

## Step 4: Test Connection from Computer

**In a new terminal**, run:

```bash
cd senseai_backend
node test_connection.js YOUR_IP
```

**Replace YOUR_IP** with the IP from Step 3.

**Example**:
```bash
node test_connection.js 192.168.1.100
```

**Question**: What does it say? (✅ SUCCESS or ❌ FAILED?)

---

## Step 5: Check What Error You're Getting

**In the mobile app**, when you try to login:

1. **What PIN are you using?**
   - Admin: `admin123`
   - Clinician: Your 4-digit PIN

2. **What error message do you see?**
   - "Backend server is not available"
   - "Invalid PIN"
   - "Connection timeout"
   - Something else?

3. **Does the backend config dialog appear?**
   - Yes/No

**Question**: What exact error message do you see?

---

## Step 6: Check Backend Terminal Logs

**When you try to login**, look at the **backend terminal** (where `npm start` is running).

**What do you see?**
- `✅ Admin login detected`
- `❌ Login failed: Invalid PIN`
- `🔍 Attempting login with PIN`
- Any error messages?

**Question**: What appears in the backend terminal when you try to login?

---

## Step 7: Test Health Endpoint from Tablet Browser

**On your tablet**:
1. Open a web browser
2. Go to: `http://YOUR_IP:3000/health`
   (Replace YOUR_IP with your computer's IP)

**What happens?**
- ✅ Shows: `{"status":"OK",...}`
- ❌ Shows error or can't connect
- ❌ Page doesn't load

**Question**: What happens when you open this URL in tablet browser?

---

## Step 8: Check Network Connection

**Both devices must be on same Wi-Fi:**

1. **Computer Wi-Fi name**: _______________
2. **Tablet Wi-Fi name**: _______________
3. **Are they the same?** Yes/No

**Question**: Are both devices on the same Wi-Fi network?

---

## Step 9: Check Windows Firewall

**Windows Firewall may be blocking port 3000.**

**Quick test**: Temporarily disable Windows Firewall and try again.

**OR** run this in PowerShell (as Administrator):

```powershell
New-NetFirewallRule -DisplayName "Node.js Backend" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

**Question**: Have you allowed port 3000 in Windows Firewall?

---

## Step 10: Check Backend URL in App

**In the mobile app**:
1. Go to Settings (gear icon)
2. Check "Backend URL" field
3. What does it say?

**Should be**: `http://YOUR_IP:3000` (no trailing slash!)

**Common mistakes**:
- ❌ `http://192.168.1.100:3000/` (has trailing slash)
- ❌ `192.168.1.100:3000` (missing http://)
- ✅ `http://192.168.1.100:3000` (correct)

**Question**: What is the Backend URL shown in Settings?

---

## 🔧 Quick Diagnostic Commands

**Run these and paste the results:**

### 1. Check if backend is running:
```bash
netstat -ano | findstr :3000
```
(Windows) - Should show Node.js process

### 2. Test localhost:
```bash
curl http://localhost:3000/health
```

### 3. Find your IP:
```bash
ipconfig | findstr IPv4
```
(Windows)

---

## 📋 Information I Need

Please provide:

1. **Backend running?** (Yes/No) - What do you see when you run `npm start`?
2. **Health endpoint works?** (Yes/No) - What response do you get?
3. **Your IP address?** - From `ipconfig`
4. **Tablet IP address?** - Check Wi-Fi settings on tablet
5. **Same Wi-Fi?** (Yes/No)
6. **Error message in app?** - Exact text
7. **Backend terminal logs?** - What appears when you try to login?
8. **PIN you're using?** - `admin123` or your clinician PIN?

---

## 🚀 Most Likely Issues

Based on common problems:

1. **Backend not running** → Start it: `cd senseai_backend && npm start`
2. **Wrong IP address** → Check with `ipconfig`, update in app
3. **Firewall blocking** → Allow port 3000
4. **Different Wi-Fi** → Connect both to same network
5. **Wrong PIN** → Try `admin123` for admin
6. **Backend URL has trailing slash** → Remove it: `http://IP:3000` not `http://IP:3000/`

---

**Please run through these steps and tell me what you find at each step!**


