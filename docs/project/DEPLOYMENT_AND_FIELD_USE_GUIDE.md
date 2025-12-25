# Deployment and Field Use Guide

## 🎯 Overview

This guide covers how to deploy and use the mobile app for field data collection, including recommendations for running the backend, network requirements, and offline functionality.

---

## 📱 Mobile App Deployment Options

### Option 1: Local Backend (Development/Testing)
**Best for**: Testing, development, small-scale data collection

**Requirements**:
- Laptop/PC with backend running
- Same WiFi network for mobile app and backend
- Backend must be running on laptop

**Setup**:
```bash
# On your laptop
cd senseai_backend
npm install
node server.js
# Backend runs on http://localhost:3000
```

**Mobile App Configuration**:
- App automatically detects backend on same network
- Uses IP address of laptop (e.g., `http://192.168.1.100:3000`)

**Limitations**:
- ❌ Laptop must be running
- ❌ Must be on same WiFi network
- ❌ Cannot use from different location
- ❌ Laptop must stay on during data collection

---

### Option 2: Cloud Backend (Production/Field Use) ⭐ RECOMMENDED
**Best for**: Field data collection, multiple locations, production use

**Deployment Options**:

#### A. Firebase Functions + Firestore (Easiest)
- Deploy backend as Firebase Cloud Functions
- No server management needed
- Automatic scaling
- Pay-as-you-go pricing

#### B. Heroku (Simple)
- Free tier available
- Easy deployment
- Automatic HTTPS
- Can sleep after inactivity (free tier)

#### C. AWS EC2 / Google Cloud / Azure
- Full control
- More configuration needed
- Better for production scale

#### D. Railway / Render / Fly.io
- Modern platforms
- Easy deployment
- Good free tiers

**Benefits**:
- ✅ Works from anywhere (internet connection required)
- ✅ No laptop needed during data collection
- ✅ Multiple tablets can use simultaneously
- ✅ Data stored in cloud automatically
- ✅ Can access from admin website anywhere

---

### Option 3: Hybrid Approach (Best for Your Case)
**Best for**: Field data collection with offline capability

**Setup**:
1. **Deploy backend to cloud** (for production)
2. **Mobile app works offline** (stores data locally)
3. **Syncs when online** (uploads to cloud backend)

**How It Works**:
- App stores all data locally (SQLite)
- When online: Syncs with cloud backend
- When offline: Continues working, stores locally
- When back online: Automatically syncs

---

## 🌐 Network Requirements

### Scenario 1: Same WiFi Network (Local Backend)
**When**: Testing, development, small-scale collection

**Requirements**:
- ✅ Laptop and tablet on same WiFi
- ✅ Backend running on laptop
- ✅ Laptop IP address configured in app

**Configuration**:
```dart
// App automatically detects backend on same network
// Or manually set in app settings:
Backend URL: http://192.168.1.100:3000
```

**Limitations**:
- ❌ Must be on same network
- ❌ Cannot use from different location
- ❌ Laptop must stay on

---

### Scenario 2: Internet Connection (Cloud Backend) ⭐ RECOMMENDED
**When**: Field data collection, production use

**Requirements**:
- ✅ Internet connection (WiFi or mobile data)
- ✅ Backend deployed to cloud
- ✅ Backend URL configured in app

**Configuration**:
```dart
// Set cloud backend URL in app:
Backend URL: https://your-backend.herokuapp.com
// or
Backend URL: https://your-backend.firebaseapp.com
```

**Benefits**:
- ✅ Works from anywhere with internet
- ✅ No laptop needed
- ✅ Multiple devices can use simultaneously
- ✅ Data stored in cloud automatically

---

### Scenario 3: Offline Mode (No Internet)
**When**: Remote locations, no internet access

**How It Works**:
- ✅ App stores all data locally (SQLite database)
- ✅ All features work offline
- ✅ Data syncs when internet available
- ✅ No data loss

**Setup**:
- App automatically works offline
- No configuration needed
- Data stored in device storage

**Sync Process**:
1. Collect data offline
2. When internet available, app automatically syncs
3. All data uploaded to backend
4. Can sync manually from app settings

---

## 📋 Recommendations for Field Data Collection

### ⭐ RECOMMENDED SETUP

#### 1. Deploy Backend to Cloud
**Why**: 
- Works from anywhere
- No laptop needed
- Multiple tablets can use
- Data automatically stored

**Options**:
- **Heroku** (easiest, free tier)
- **Firebase Functions** (if using Firebase)
- **Railway** (modern, easy)
- **Render** (simple deployment)

#### 2. Use Offline-First Architecture
**Why**:
- Works without internet
- No data loss
- Syncs when online

**How**:
- App already supports this! ✅
- All data stored locally first
- Syncs to backend when online

#### 3. Configure Mobile Data as Backup
**Why**:
- WiFi may not be available
- Mobile data can sync data

**Setup**:
- Enable mobile data on tablet
- App will use mobile data if WiFi unavailable
- Can sync data using mobile data

---

## 🚀 Step-by-Step Deployment Guide

### Step 1: Deploy Backend to Cloud

#### Option A: Heroku (Recommended for Quick Start)

```bash
# 1. Install Heroku CLI
# Download from: https://devcenter.heroku.com/articles/heroku-cli

# 2. Login to Heroku
heroku login

# 3. Create new app
cd senseai_backend
heroku create your-app-name

# 4. Set environment variables
heroku config:set GOOGLE_APPLICATION_CREDENTIALS=your-firebase-key.json
heroku config:set NODE_ENV=production

# 5. Deploy
git init
git add .
git commit -m "Initial commit"
git push heroku main

# 6. Get your backend URL
heroku info
# Your backend will be at: https://your-app-name.herokuapp.com
```

#### Option B: Firebase Functions

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login
firebase login

# 3. Initialize Firebase
cd senseai_backend
firebase init functions

# 4. Deploy
firebase deploy --only functions
```

#### Option C: Railway

```bash
# 1. Sign up at railway.app
# 2. Create new project
# 3. Connect GitHub repository
# 4. Railway auto-deploys
# 5. Get your backend URL from Railway dashboard
```

---

### Step 2: Update Mobile App Configuration

#### Option A: Hardcode Backend URL (Quick)

Edit `lib/core/services/api_service.dart`:

```dart
static const String _defaultRealDeviceUrl = 'https://your-backend.herokuapp.com';
```

#### Option B: App Settings (Better)

Add backend URL configuration in app settings:
- User can change backend URL
- Works for different environments
- Can switch between local and cloud

---

### Step 3: Test Connection

1. **Install APK on tablet**
2. **Open app**
3. **Check connection**:
   - App should connect to cloud backend
   - Test login/registration
   - Test data saving

---

## 📱 Field Data Collection Workflow

### Before Going to Field:

1. ✅ **Deploy backend to cloud**
2. ✅ **Update app with cloud backend URL**
3. ✅ **Install APK on tablet**
4. ✅ **Test connection** (login, create child, save data)
5. ✅ **Charge tablet fully**
6. ✅ **Enable mobile data** (as backup)

### During Data Collection:

1. **Connect to WiFi** (if available)
   - App automatically uses WiFi
   - Faster data sync

2. **If no WiFi**:
   - App works offline ✅
   - All data stored locally
   - Can use mobile data for sync (if enabled)

3. **Collect data**:
   - Create children
   - Run assessments
   - All data saved locally

4. **Sync data**:
   - Automatic: When internet available
   - Manual: From app settings → "Sync Now"

### After Data Collection:

1. **Ensure internet connection**
2. **Open app** → Settings → "Sync Now"
3. **Verify data** in admin website
4. **Backup tablet** (optional)

---

## 🔧 Configuration Options

### Backend URL Configuration

#### Method 1: Environment-Based (Recommended)

```dart
// lib/core/services/api_service.dart
static Future<String> get baseUrl async {
  const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  
  if (isProduction) {
    return 'https://your-backend.herokuapp.com';
  } else {
    // Development: Auto-detect or use local
    return await _getLocalUrl();
  }
}
```

Build with:
```bash
flutter build apk --release --dart-define=PRODUCTION=true
```

#### Method 2: App Settings

Add a settings screen where user can configure backend URL:
- Default: Cloud backend
- Option to change for testing
- Saves to SharedPreferences

---

## 🌍 Network Scenarios

### Scenario A: Same Location, Same WiFi
**Setup**: Local backend on laptop
- ✅ Fast connection
- ✅ No internet needed
- ❌ Laptop must stay on
- ❌ Limited to same network

### Scenario B: Different Location, Internet Available
**Setup**: Cloud backend
- ✅ Works from anywhere
- ✅ No laptop needed
- ✅ Multiple devices
- ✅ Data in cloud

### Scenario C: Remote Location, No Internet
**Setup**: Offline mode
- ✅ App works fully offline
- ✅ Data stored locally
- ✅ Syncs when internet available
- ✅ No data loss

### Scenario D: Intermittent Internet
**Setup**: Offline-first with auto-sync
- ✅ Works offline
- ✅ Auto-syncs when online
- ✅ No manual intervention needed

---

## 📊 Data Flow

### Online Mode:
```
Tablet → Cloud Backend → Firebase
         ↓
    Admin Website
```

### Offline Mode:
```
Tablet → Local SQLite
         ↓
    (When online)
         ↓
    Cloud Backend → Firebase
```

---

## ✅ Best Practices

### 1. Always Use Cloud Backend for Production
- Don't rely on local backend for field work
- Deploy to Heroku/Firebase/Railway
- Test before going to field

### 2. Enable Offline Mode
- App already supports this
- Test offline functionality
- Verify data syncs when online

### 3. Test Before Field Work
- Test login/registration
- Test child creation
- Test assessment completion
- Test data saving
- Test sync functionality

### 4. Have Backup Plan
- Enable mobile data as backup
- Charge tablet fully
- Bring power bank
- Test in similar conditions first

### 5. Monitor Data Collection
- Check admin website regularly
- Verify data is syncing
- Check for errors
- Backup important data

---

## 🚨 Troubleshooting

### Issue: App can't connect to backend
**Solutions**:
1. Check internet connection
2. Verify backend URL is correct
3. Check backend is running (if local)
4. Check firewall settings
5. Try mobile data instead of WiFi

### Issue: Data not syncing
**Solutions**:
1. Check internet connection
2. Open app → Settings → "Sync Now"
3. Check backend logs
4. Verify Firebase connection
5. Check app logs for errors

### Issue: App works but data not saving
**Solutions**:
1. Check backend connection
2. Verify Firebase credentials
3. Check backend logs
4. Test with simple data first
5. Verify database permissions

---

## 📝 Quick Checklist

### Before Field Work:
- [ ] Backend deployed to cloud
- [ ] App configured with cloud backend URL
- [ ] APK installed on tablet
- [ ] Tested login/registration
- [ ] Tested child creation
- [ ] Tested assessment completion
- [ ] Tested data saving
- [ ] Tested offline mode
- [ ] Tested sync functionality
- [ ] Tablet fully charged
- [ ] Mobile data enabled (backup)
- [ ] Admin website accessible

### During Field Work:
- [ ] Connect to WiFi (if available)
- [ ] Verify app connects to backend
- [ ] Collect data normally
- [ ] Check sync status periodically
- [ ] Monitor battery level

### After Field Work:
- [ ] Ensure internet connection
- [ ] Sync all data
- [ ] Verify data in admin website
- [ ] Backup tablet data (optional)
- [ ] Review collected data

---

## 🎯 Final Recommendations

### For Your Use Case (Field Data Collection):

1. **⭐ Deploy Backend to Cloud** (Heroku/Railway/Firebase)
   - Works from anywhere
   - No laptop needed
   - Multiple tablets can use

2. **⭐ Use Offline-First Mode**
   - App already supports this
   - Works without internet
   - Syncs when available

3. **⭐ Enable Mobile Data as Backup**
   - WiFi may not be available
   - Mobile data can sync data
   - Small data usage

4. **⭐ Test Before Field Work**
   - Test all features
   - Test offline mode
   - Test sync functionality
   - Verify data saves correctly

5. **⭐ Monitor Data Collection**
   - Check admin website
   - Verify data syncing
   - Check for errors

---

## 📞 Support

If you encounter issues:
1. Check app logs
2. Check backend logs
3. Verify network connection
4. Test with simple data first
5. Check Firebase connection

---

*Last Updated: 2024*
*Status: Ready for Field Deployment*






