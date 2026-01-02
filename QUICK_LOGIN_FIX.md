# Quick Login Fix Guide

## 🔴 Problem: Cannot Login Even with Correct IP

Follow these steps in order:

---

## ✅ Step 1: Verify Backend is Running

**Open terminal in `senseai_backend` folder**:
```bash
cd senseai_backend
npm start
```

**Look for**:
```
==================================================
SenseAI Backend + Firebase running
==================================================
→ Listening on http://0.0.0.0:3000
```

**If you see errors**:
- Firebase auth error → Check `serviceAccountKey.json`
- Port in use → Close other apps using port 3000

---

## ✅ Step 2: Test Backend Locally

**In new terminal**:
```bash
curl http://localhost:3000/health
```

**Should return**: `{"status":"OK","timestamp":"..."}`

**If this fails** → Backend not running properly

---

## ✅ Step 3: Find Your IP Address

**Windows**:
```bash
ipconfig
```
Look for **IPv4 Address** (e.g., `192.168.1.100`)

**Mac/Linux**:
```bash
ifconfig
```
Look for `inet` address (e.g., `192.168.1.100`)

---

## ✅ Step 4: Test Connection from Computer

**Run test script**:
```bash
cd senseai_backend
node test_connection.js YOUR_IP
```

**Example**:
```bash
node test_connection.js 192.168.1.100
```

**Should show**: `✅ SUCCESS!`

**If fails** → Check Windows Firewall (Step 5)

---

## ✅ Step 5: Fix Windows Firewall

**PowerShell (Run as Administrator)**:
```powershell
New-NetFirewallRule -DisplayName "Node.js Backend" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

**Or manually**:
1. Windows Defender Firewall → Advanced settings
2. Inbound Rules → New Rule
3. Port → TCP → 3000
4. Allow connection
5. Apply to all profiles

---

## ✅ Step 6: Configure App

1. **Open app** on tablet
2. **Try to login** → Backend config dialog appears
3. **Enter**: `http://YOUR_IP:3000` (no trailing slash!)
4. **Click "Test Connection"**
5. **Should show**: "Connection successful!"

**Common mistakes**:
- ❌ `http://192.168.1.100:3000/` (trailing slash)
- ❌ `192.168.1.100:3000` (missing http://)
- ✅ `http://192.168.1.100:3000` (correct)

---

## ✅ Step 7: Test Login

**Admin PIN**: `admin123` (8 characters)

**Clinician PIN**: Your registered 4-digit PIN

---

## 🔍 Still Not Working?

### Check These:

1. **Same Wi-Fi?**
   - Computer and tablet must be on **same Wi-Fi network**
   - Check network names match

2. **Backend still running?**
   - Check terminal - should show "Listening on..."
   - If stopped, restart: `npm start`

3. **IP changed?**
   - IP addresses can change
   - Run `ipconfig` again
   - Update app with new IP

4. **Test in browser** (on tablet):
   - Open browser
   - Go to: `http://YOUR_IP:3000/health`
   - Should see: `{"status":"OK",...}`

---

## 🚀 Quick Commands

### Windows:
```powershell
# Find IP
ipconfig | findstr IPv4

# Allow firewall
New-NetFirewallRule -DisplayName "Node.js Backend" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow

# Test backend
curl http://localhost:3000/health
```

### Mac/Linux:
```bash
# Find IP
ifconfig | grep "inet "

# Test backend
curl http://localhost:3000/health
```

---

## 📋 Checklist

- [ ] Backend running (`npm start`)
- [ ] Health endpoint works (`curl http://localhost:3000/health`)
- [ ] IP address found (`ipconfig` / `ifconfig`)
- [ ] Windows Firewall allows port 3000
- [ ] Both devices on same Wi-Fi
- [ ] App configured with correct IP
- [ ] Test Connection shows success
- [ ] Using correct PIN

**If all checked and still not working**, check backend terminal for error messages!

