# Troubleshooting: Data Not Saving to Firebase

## Quick Checks

### 1. **Backend Server Running?**
```bash
# Check if backend is running
cd senseai_backend
npm start
```

You should see:
```
SenseAI Backend + Firebase running
→ Listening on http://0.0.0.0:3000
```

### 2. **Test Backend Health**
Open browser or Postman:
```
GET http://localhost:3000/health
```

Should return:
```json
{
  "status": "OK",
  "timestamp": "..."
}
```

### 3. **Check Mobile App Backend URL**

In the mobile app:
1. Go to **Settings**
2. Check **Backend URL**
3. Should be:
   - **Emulator**: `http://10.0.2.2:3000`
   - **Real Device**: `http://YOUR_LAPTOP_IP:3000` (e.g., `http://192.168.1.100:3000`)

### 4. **Test API Endpoints**

#### Test Child Creation (Postman):
```
POST http://localhost:3000/api/children
Content-Type: application/json

{
  "name": "Test Child",
  "date_of_birth": 946684800000,
  "gender": "male",
  "language": "en",
  "group": "typically_developing"
}
```

#### Test Session Creation (Postman):
```
POST http://localhost:3000/api/sessions
Content-Type: application/json

{
  "child_id": "CHILD_ID_HERE",
  "session_type": "color_shape",
  "start_time": 1704067200000
}
```

### 5. **Check Firebase Configuration**

Verify `senseai_backend/serviceAccountKey.json` exists and is valid.

### 6. **Check Backend Logs**

When you add a child in mobile app, check backend terminal for:
- `📥 Received child creation request:`
- `✅ Child created in Firebase:`
- Or error messages

### 7. **Check Mobile App Logs**

In Flutter/Dart console, look for:
- `✅ Child saved to backend:` (success)
- `❌ Error saving child to backend:` (failure)
- `⚠️ Saving locally and queuing for sync...` (offline mode)

## Common Issues

### Issue 1: Backend Not Running
**Solution**: Start backend server
```bash
cd senseai_backend
npm start
```

### Issue 2: Wrong Backend URL
**Solution**: Update in mobile app Settings
- For tablet/real device: Use your laptop's IP address
- Find IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Use Wi-Fi adapter IP (not Ethernet)

### Issue 3: Network/Firewall
**Solution**: 
- Ensure mobile device and laptop on same network
- Disable firewall or allow port 3000
- Check antivirus isn't blocking

### Issue 4: Firebase Service Account Missing
**Solution**: 
- Ensure `senseai_backend/serviceAccountKey.json` exists
- Verify it's valid Firebase service account key

### Issue 5: Data Saving Locally Only
**Symptom**: Data appears in mobile app but not in Firebase/Postman

**Cause**: Backend connection failed, app saved locally

**Solution**:
1. Check backend is running
2. Check backend URL in app settings
3. Check network connectivity
4. Restart mobile app
5. Data should sync when backend is available

## Debug Steps

1. **Check Backend Health**
   ```bash
   curl http://localhost:3000/health
   ```

2. **Check Backend Logs**
   - Look for incoming requests
   - Look for Firebase connection messages
   - Look for errors

3. **Check Mobile App Logs**
   - Look for API calls
   - Look for errors
   - Check backend URL being used

4. **Test with Postman**
   - Try creating child via Postman
   - If works: Issue is in mobile app
   - If fails: Issue is in backend

5. **Verify Firebase**
   - Check Firebase console
   - Verify collections exist
   - Check permissions

## Expected Behavior

### When Backend is Connected:
- ✅ Child saved → Backend logs: `✅ Child created in Firebase`
- ✅ Session saved → Backend logs: `✅ Session created in Firebase`
- ✅ Data visible in Postman/Firebase console

### When Backend is Offline:
- ⚠️ Child saved locally
- ⚠️ Queued for sync
- ⚠️ Will sync when backend available

## Still Not Working?

1. Check backend terminal for errors
2. Check mobile app console for errors
3. Verify Firebase service account key
4. Test with Postman to isolate issue
5. Check network connectivity between devices

