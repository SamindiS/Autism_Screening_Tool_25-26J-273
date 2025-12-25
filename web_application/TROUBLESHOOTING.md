# Troubleshooting Guide

## Common Issues and Solutions

### 1. Firebase Data Not Showing

**Symptoms:**
- Dashboard shows 0 children/sessions
- Tables are empty
- No data appears in the web app

**Possible Causes & Solutions:**

#### A. Backend Not Running
- **Check**: Open browser console (F12) and look for network errors
- **Solution**: Make sure backend is running on port 3000
  ```bash
  cd senseai_backend
  npm start
  ```

#### B. Backend Not Connected to Firebase
- **Check**: Look at backend terminal output for Firebase connection messages
- **Solution**: Verify `serviceAccountKey.json` exists in `senseai_backend` folder
- **Solution**: Check Firebase initialization messages in backend console

#### C. CORS Issues
- **Check**: Browser console shows CORS errors
- **Solution**: Backend should have CORS enabled (check `server.js`)

#### D. API Response Format
- **Check**: Open browser DevTools → Network tab → Check API responses
- **Expected Format**:
  ```json
  {
    "count": 10,
    "children": [...]
  }
  ```
- **Solution**: Verify backend routes return data in correct format

#### E. Authentication Token Missing
- **Check**: Browser console for 401 errors
- **Solution**: Make sure you're logged in (check localStorage for 'authToken')

### 2. Clinician Login Not Working

**Symptoms:**
- Can't login with 4-digit PIN
- Login fails even with correct PIN
- Error message: "Invalid PIN"

**Possible Causes & Solutions:**

#### A. PIN Not Registered
- **Check**: Verify clinician is registered in Firebase
- **Solution**: Register clinician via mobile app first, or use admin PIN `admin123`

#### B. PIN Hash Mismatch
- **Check**: Backend console shows "Invalid PIN" even with correct PIN
- **Solution**: Re-register clinician with new PIN

#### C. Backend Response Format
- **Check**: Browser console Network tab → Check login response
- **Expected Response**:
  ```json
  {
    "success": true,
    "role": "clinician",
    "user": {
      "id": "...",
      "name": "...",
      "hospital": "...",
      "role": "clinician"
    }
  }
  ```
- **Solution**: Check backend `/api/clinicians/login` route

#### D. Frontend Not Handling Response
- **Check**: Browser console for login errors
- **Solution**: Check `src/services/auth.ts` login function

### 3. Logout Not Redirecting

**Symptoms:**
- Clicking logout doesn't redirect to login
- Stays on same page after logout
- Error in console

**Solution:**
- Fixed in latest update: Logout now uses `window.location.href` for full redirect
- Check `src/components/Layout/Layout.tsx` handleLogout function

### 4. Data Not Loading After Login

**Symptoms:**
- Login successful but dashboard shows no data
- Empty tables and charts

**Solutions:**

#### A. Check Browser Console
- Open DevTools (F12) → Console tab
- Look for errors or warnings
- Check Network tab for failed API calls

#### B. Verify API Endpoints
- Test backend directly: `http://localhost:3000/api/children`
- Should return JSON with `children` array
- If error, check backend logs

#### C. Check Authentication
- Verify `authToken` in localStorage
- Check if API requests include authentication
- Verify backend accepts requests

### 5. Network Errors

**Symptoms:**
- "Network Error" in console
- "Failed to fetch" messages
- API calls timing out

**Solutions:**

#### A. Backend Not Running
```bash
cd senseai_backend
npm start
```

#### B. Wrong API URL
- Check `src/services/api.ts` for `API_BASE_URL`
- Default: `http://localhost:3000`
- For production: Update environment variable

#### C. Firewall/Port Issues
- Check if port 3000 is accessible
- Try accessing `http://localhost:3000/health` in browser
- Should return: `{ "status": "ok" }`

### 6. Empty Dashboard

**Symptoms:**
- Dashboard loads but shows all zeros
- Charts are empty
- "No data" messages

**Solutions:**

#### A. No Data in Firebase
- Check Firebase Console: https://console.firebase.google.com
- Verify `children` and `sessions` collections have data
- Add test data via mobile app or backend

#### B. Data Filtering Issue
- Check if time range filter is too restrictive
- Try "All Time" option in dashboard
- Check if data exists in Firebase but not showing

#### C. API Response Empty
- Check Network tab in browser DevTools
- Verify API returns data: `{ "count": X, "children": [...] }`
- Check backend console for errors

## Debugging Steps

### Step 1: Check Backend
```bash
# Terminal 1: Start backend
cd senseai_backend
npm start

# Should see:
# ✅ Firebase Firestore connected successfully!
# Server running on port 3000
```

### Step 2: Check Frontend
```bash
# Terminal 2: Start frontend
cd web_application
npm run dev

# Should see:
# VITE ready in XXX ms
# ➜  Local:   http://localhost:5173/
```

### Step 3: Check Browser Console
1. Open `http://localhost:5173`
2. Press F12 to open DevTools
3. Go to Console tab
4. Look for errors or logs (we added console.log statements)
5. Go to Network tab
6. Try logging in and check API calls

### Step 4: Verify Data Flow
1. Login with `admin123`
2. Check Console for:
   - `🔐 Attempting login with PIN: ad***`
   - `📥 Login response: {...}`
   - `✅ Login successful`
   - `📊 Loading dashboard stats...`
   - `📡 Fetching all children from API...`
   - `✅ Children API response: {...}`

### Step 5: Test API Directly
Open in browser:
- `http://localhost:3000/api/children` (should return children)
- `http://localhost:3000/api/sessions` (should return sessions)
- `http://localhost:3000/api/clinicians` (should return clinicians)

## Console Logs Added

We've added detailed console logging to help debug:

- `🔐` - Login attempts
- `📥` - API responses
- `✅` - Success messages
- `❌` - Error messages
- `📡` - API requests
- `📊` - Data processing

Check browser console for these logs to trace the data flow.

## Still Having Issues?

1. **Check Backend Logs**: Look at terminal where backend is running
2. **Check Browser Console**: F12 → Console tab
3. **Check Network Tab**: F12 → Network tab → Look for failed requests
4. **Verify Firebase**: Check Firebase Console for data
5. **Test API Directly**: Use browser or Postman to test backend endpoints

## Quick Test

1. Start backend: `cd senseai_backend && npm start`
2. Start frontend: `cd web_application && npm run dev`
3. Open browser: `http://localhost:5173`
4. Login with: `admin123`
5. Check console for logs
6. Check Network tab for API calls
7. Verify data appears in dashboard

