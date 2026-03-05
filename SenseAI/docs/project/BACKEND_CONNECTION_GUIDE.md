# Backend Connection Troubleshooting Guide

## Problem: Cannot Login or Register

If you're experiencing issues with login or registration, it's likely because the **backend server is not running** or **not accessible**.

## Quick Fix

### Step 1: Start the Backend Server

1. Open a terminal/command prompt
2. Navigate to the backend directory:
   ```bash
   cd senseai_backend
   ```
3. Install dependencies (if not already done):
   ```bash
   npm install
   ```
4. Start the server:
   ```bash
   npm start
   ```
5. You should see: `Server running on port 3000`

### Step 2: Verify Backend is Running

Open your browser and go to:
- `http://localhost:3000/health`

You should see a response indicating the server is running.

### Step 3: Configure API URL in App

The app needs to know where the backend server is located:

#### For Android Emulator:
- The default URL `http://10.0.2.2:3000` should work
- This is already configured in `lib/core/services/api_service.dart`

#### For Real Device (Physical Phone/Tablet):
1. Find your computer's IP address:
   - **Windows**: Open Command Prompt and type `ipconfig`
   - **Mac/Linux**: Open Terminal and type `ifconfig` or `ip addr`
   - Look for your local network IP (usually starts with `192.168.x.x`)

2. Update `lib/core/services/api_service.dart`:
   ```dart
   // Change this line:
   static const String baseUrl = 'http://10.0.2.2:3000';
   
   // To your computer's IP:
   static const String baseUrl = 'http://192.168.1.100:3000'; // Replace with your IP
   ```

3. Make sure your phone and computer are on the **same Wi-Fi network**

#### For iOS Simulator:
- Use `http://localhost:3000` (should work by default)

## Error Messages Explained

### "Backend server is not available"
- **Cause**: Backend server is not running
- **Fix**: Start the backend server (see Step 1 above)

### "Cannot connect to server"
- **Cause**: Network connectivity issue or wrong IP address
- **Fix**: 
  1. Check backend is running
  2. Verify IP address is correct
  3. Ensure device and computer are on same network
  4. Check firewall settings (may be blocking port 3000)

### "Invalid PIN"
- **Cause**: PIN doesn't match any registered clinician
- **Fix**: Register first, or use the correct PIN

### "Clinician not found"
- **Cause**: No clinician registered with that PIN
- **Fix**: Register a new account first

## Testing the Connection

### Method 1: Use the App
- Try to login or register
- The app will now show detailed error messages if connection fails

### Method 2: Test API Directly
You can test the backend API using:

**Using curl (Command Line):**
```bash
# Health check
curl http://localhost:3000/health

# Register (example)
curl -X POST http://localhost:3000/api/clinicians/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","hospital":"Test Hospital","pin":"1234"}'
```

**Using Postman:**
- Import the collection from `senseai_backend/SenseAI_Backend.postman_collection.json`
- Test the endpoints directly

## Common Issues

### Issue: "Connection refused"
**Solution**: 
- Backend server is not running
- Start it with `npm start` in the `senseai_backend` directory

### Issue: "Failed host lookup"
**Solution**:
- Wrong IP address configured
- Check your computer's IP and update `api_service.dart`

### Issue: Works on emulator but not on real device
**Solution**:
- Emulator uses `10.0.2.2` which maps to host machine
- Real device needs your computer's actual IP address
- Update the `baseUrl` in `api_service.dart` to your computer's IP

### Issue: Firewall blocking connection
**Solution**:
- Allow port 3000 through your firewall
- Windows: Windows Defender Firewall → Allow an app → Node.js
- Mac: System Preferences → Security & Privacy → Firewall

## Backend Setup (If Not Already Done)

If you haven't set up the backend yet:

1. **Navigate to backend directory:**
   ```bash
   cd senseai_backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Initialize database (if needed):**
   - The database should be created automatically
   - Check `senseai_backend/senseai.db` exists

4. **Start server:**
   ```bash
   npm start
   ```

5. **Verify it's running:**
   - Check terminal for "Server running on port 3000"
   - Visit `http://localhost:3000/health` in browser

## Need More Help?

1. Check backend logs in the terminal where you ran `npm start`
2. Check app logs in Flutter console (run `flutter run` with verbose logging)
3. Verify network connectivity between device and computer
4. Check that port 3000 is not being used by another application

## Summary

**Most common issue**: Backend server is not running.

**Quick fix**: 
```bash
cd senseai_backend
npm start
```

**For real devices**: Update the IP address in `lib/core/services/api_service.dart` to your computer's IP address.

---

**Last Updated**: After improving error handling in authentication system




