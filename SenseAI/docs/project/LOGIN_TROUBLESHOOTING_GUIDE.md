# Login Troubleshooting Guide

## 🔴 Problem: Cannot Login Even with Correct IP and Backend Running

This guide helps you diagnose and fix login issues.

---

## 🔍 Step 1: Verify Backend is Running

### Check Backend Server Status

1. **Open terminal/command prompt**
2. **Navigate to backend folder**:
   ```bash
   cd senseai_backend
   ```
3. **Start backend**:
   ```bash
   npm start
   ```

4. **Look for this message**:
   ```
   ==================================================
   SenseAI Backend + Firebase running
   ==================================================
   → Listening on http://0.0.0.0:3000
   → Health check: http://YOUR_LAPTOP_IP:3000/health
   ==================================================
   ```

5. **Test health endpoint** (in browser or new terminal):
   ```bash
   curl http://localhost:3000/health
   ```
   Should return: `{"status":"OK","timestamp":"..."}`

### If Backend Won't Start:

**Check for errors**:
- Firebase authentication error? → Check `serviceAccountKey.json`
- Port 3000 already in use? → Close other apps using port 3000
- Missing dependencies? → Run `npm install`

---

## 🔍 Step 2: Verify IP Address

### Find Your Computer's IP Address

**Windows**:
```bash
ipconfig
```
Look for **IPv4 Address** under your active network adapter (usually Wi-Fi or Ethernet).

Example: `192.168.1.100`

**Mac/Linux**:
```bash
ifconfig
```
Look for `inet` address (usually starts with `192.168.` or `10.`)

### Common IP Address Formats:
- ✅ `192.168.1.100:3000`
- ✅ `192.168.0.105:3000`
- ✅ `10.0.2.2:3000` (Android emulator only)
- ❌ `localhost:3000` (won't work on real device)
- ❌ `127.0.0.1:3000` (won't work on real device)

---

## 🔍 Step 3: Test Connection from Tablet

### Method 1: Use "Test Connection" Button

1. **Open app** on tablet
2. **Try to login** → Backend config dialog appears
3. **Enter your IP**: `http://192.168.X.X:3000` (replace X.X with your IP)
4. **Click "Test Connection"**
5. **Check result**:
   - ✅ Success → "Connection successful!"
   - ❌ Failed → See error message

### Method 2: Test in Browser (if tablet has browser)

1. **Open browser** on tablet
2. **Navigate to**: `http://YOUR_IP:3000/health`
3. **Should see**: `{"status":"OK","timestamp":"..."}`

If this fails → Network/firewall issue (see Step 4)

---

## 🔍 Step 4: Check Network & Firewall

### 4.1 Same Wi-Fi Network

**CRITICAL**: Both computer and tablet must be on the **same Wi-Fi network**.

**Check**:
- Computer Wi-Fi: `MyNetwork`
- Tablet Wi-Fi: `MyNetwork` ✅ (must match!)

**If different networks**:
- Connect both to same Wi-Fi
- Or use mobile hotspot (connect both to hotspot)

### 4.2 Windows Firewall

**Windows Firewall may block port 3000**.

**Fix**:

1. **Open Windows Defender Firewall**
2. **Click "Advanced settings"**
3. **Click "Inbound Rules" → "New Rule"**
4. **Select "Port" → Next**
5. **Select "TCP" → Specific local ports: `3000`**
6. **Select "Allow the connection"**
7. **Check all profiles (Domain, Private, Public)**
8. **Name it**: "Node.js Backend Port 3000"
9. **Click "Finish"**

**Or use PowerShell (Run as Administrator)**:
```powershell
New-NetFirewallRule -DisplayName "Node.js Backend" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

### 4.3 Antivirus Software

Some antivirus software blocks network connections.

**Temporary fix** (for testing):
- Temporarily disable antivirus firewall
- Test connection
- If works → Add exception for Node.js/port 3000

---

## 🔍 Step 5: Check Backend URL in App

### Verify Saved URL

1. **Open app** on tablet
2. **Go to Settings** (gear icon)
3. **Check "Backend URL"** field
4. **Should match**: `http://YOUR_IP:3000`

### Common Mistakes:

- ❌ `http://192.168.1.100:3000/` (trailing slash - remove it)
- ❌ `192.168.1.100:3000` (missing http://)
- ❌ `http://192.168.1.100` (missing :3000)
- ✅ `http://192.168.1.100:3000` (correct)

### Reset and Reconfigure:

1. **In Settings**, click "Reset to Default"
2. **Enter correct IP**: `http://YOUR_IP:3000`
3. **Click "Test Connection"**
4. **If successful**, click "Save"
5. **Try login again**

---

## 🔍 Step 6: Check Login PIN

### Admin Login

**PIN**: `admin123` (8 characters, not 4)

**Test**:
1. Enter: `admin123`
2. Should login as Administrator

### Clinician Login

**PIN**: 4-digit PIN you registered with

**If forgot PIN**:
- Check Firebase Console → `clinicians` collection
- Or register new clinician

---

## 🔍 Step 7: Check Backend Logs

### Watch Backend Terminal

When you try to login, **check backend terminal** for:

**Good signs**:
```
✅ Admin login detected
✅ PIN match found for clinician: ...
✅ Login successful for clinician: ...
```

**Error signs**:
```
❌ Login failed: Invalid PIN
❌ Error logging in clinician: ...
❌ Health check failed: ...
```

### Common Backend Errors:

1. **"Invalid PIN"**:
   - PIN doesn't match any registered clinician
   - Check Firebase → clinicians collection → pin_hash

2. **"Firebase authentication error"**:
   - Check `serviceAccountKey.json`
   - Verify Firebase project is active

3. **"Request timeout"**:
   - Network issue
   - Firewall blocking
   - Wrong IP address

---

## 🔍 Step 8: Debug Health Check

### Test Health Endpoint Manually

**From computer**:
```bash
curl http://localhost:3000/health
```

**From tablet browser**:
```
http://YOUR_IP:3000/health
```

**Should return**:
```json
{"status":"OK","timestamp":"2025-01-XX..."}
```

**If this fails**:
- Backend not running
- Wrong IP address
- Firewall blocking
- Network issue

---

## 🔍 Step 9: Network Troubleshooting

### Ping Test

**From tablet** (if possible):
- Ping your computer's IP
- Should get responses

**From computer**:
```bash
# Windows
ping YOUR_TABLET_IP

# Mac/Linux
ping YOUR_TABLET_IP
```

### Check Network Connection

1. **Both devices connected to Wi-Fi?**
2. **Wi-Fi working?** (test internet on both)
3. **Same network?** (check network name)
4. **IP addresses in same range?**
   - Computer: `192.168.1.100`
   - Tablet: `192.168.1.105` ✅ (same subnet)
   - Tablet: `192.168.2.105` ❌ (different subnet)

---

## 🔍 Step 10: Common Issues & Solutions

### Issue 1: "Backend server is not available"

**Causes**:
- Backend not running
- Wrong IP address
- Firewall blocking
- Different Wi-Fi networks

**Solutions**:
1. Start backend: `cd senseai_backend && npm start`
2. Verify IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
3. Check firewall: Allow port 3000
4. Same Wi-Fi: Connect both to same network

### Issue 2: "Connection timed out"

**Causes**:
- Firewall blocking
- Network issue
- Backend crashed

**Solutions**:
1. Check Windows Firewall (see Step 4.2)
2. Restart backend server
3. Test health endpoint in browser

### Issue 3: "Invalid PIN"

**Causes**:
- Wrong PIN entered
- Clinician not registered
- PIN hash mismatch

**Solutions**:
1. Try admin PIN: `admin123`
2. Check Firebase → clinicians collection
3. Register new clinician if needed

### Issue 4: Login succeeds but app shows error

**Causes**:
- Response parsing error
- Missing data in response

**Solutions**:
1. Check backend logs for response
2. Verify backend returns correct format
3. Check app logs (Flutter debug console)

---

## ✅ Quick Checklist

Before asking for help, verify:

- [ ] Backend is running (`npm start` in `senseai_backend`)
- [ ] Health endpoint works: `curl http://localhost:3000/health`
- [ ] IP address is correct (from `ipconfig` or `ifconfig`)
- [ ] Both devices on same Wi-Fi network
- [ ] Windows Firewall allows port 3000
- [ ] Backend URL in app: `http://YOUR_IP:3000` (no trailing slash)
- [ ] Test connection button shows "Connection successful"
- [ ] Using correct PIN (`admin123` for admin, or registered clinician PIN)

---

## 🚀 Quick Fix Commands

### Windows (PowerShell as Administrator):

```powershell
# Allow port 3000 in firewall
New-NetFirewallRule -DisplayName "Node.js Backend" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow

# Find your IP
ipconfig | findstr IPv4

# Test backend
curl http://localhost:3000/health
```

### Mac/Linux:

```bash
# Find your IP
ifconfig | grep "inet "

# Test backend
curl http://localhost:3000/health
```

---

## 📞 Still Not Working?

### Collect Debug Information:

1. **Backend terminal output** (copy all logs)
2. **App error message** (screenshot)
3. **IP addresses**:
   - Computer IP: `ipconfig` / `ifconfig`
   - Tablet IP: Check Wi-Fi settings
4. **Network info**:
   - Wi-Fi network name (both devices)
   - Subnet mask
5. **Test results**:
   - Health endpoint test (browser)
   - Test Connection button result

### Common Final Fixes:

1. **Restart everything**:
   - Restart backend server
   - Restart app
   - Restart Wi-Fi on both devices

2. **Try different IP**:
   - Sometimes IP changes
   - Run `ipconfig` again
   - Update app with new IP

3. **Use mobile hotspot**:
   - Create hotspot on phone
   - Connect both computer and tablet
   - Use computer's hotspot IP

---

## 🎯 Most Common Solution

**90% of login issues are caused by**:

1. **Backend not running** → Start it: `cd senseai_backend && npm start`
2. **Wrong IP address** → Check with `ipconfig` / `ifconfig`
3. **Firewall blocking** → Allow port 3000 in Windows Firewall
4. **Different Wi-Fi networks** → Connect both to same network

**Fix these first!**



