# Quick Deployment Checklist

## 🎯 For Field Data Collection

### ✅ MUST DO (Before Field Work)

1. **Deploy Backend to Cloud**
   - [ ] Choose platform (Heroku/Railway/Firebase)
   - [ ] Deploy backend code
   - [ ] Get backend URL (e.g., `https://your-app.herokuapp.com`)
   - [ ] Test backend is working

2. **Update Mobile App**
   - [ ] Update backend URL in app code
   - [ ] Build new APK
   - [ ] Install APK on tablet
   - [ ] Test connection to cloud backend

3. **Test Everything**
   - [ ] Test login/registration
   - [ ] Test child creation
   - [ ] Test assessment completion
   - [ ] Test data saving
   - [ ] Test offline mode
   - [ ] Test sync functionality

4. **Prepare Tablet**
   - [ ] Install APK
   - [ ] Charge fully
   - [ ] Enable mobile data (backup)
   - [ ] Test app works

---

## 🚀 Quick Deployment (Heroku - 10 minutes)

```bash
# 1. Install Heroku CLI
# Download: https://devcenter.heroku.com/articles/heroku-cli

# 2. Login
heroku login

# 3. Deploy
cd senseai_backend
heroku create your-app-name
git init
git add .
git commit -m "Deploy"
git push heroku main

# 4. Set Firebase credentials
heroku config:set GOOGLE_APPLICATION_CREDENTIALS="your-key.json"

# 5. Get URL
heroku info
# Your backend: https://your-app-name.herokuapp.com
```

---

## 📱 Update App Backend URL

Edit `lib/core/services/api_service.dart`:

```dart
static const String _defaultRealDeviceUrl = 'https://your-app-name.herokuapp.com';
```

Then rebuild APK:
```bash
flutter build apk --release
```

---

## ✅ Network Requirements

### Option 1: WiFi Available
- ✅ Connect tablet to WiFi
- ✅ App connects to cloud backend
- ✅ Data syncs automatically

### Option 2: No WiFi (Mobile Data)
- ✅ Enable mobile data on tablet
- ✅ App uses mobile data
- ✅ Data syncs (small data usage)

### Option 3: No Internet (Offline)
- ✅ App works fully offline
- ✅ Data stored locally
- ✅ Syncs when internet available

---

## 🎯 Recommended Setup

1. **Backend**: Deploy to Heroku/Railway (cloud)
2. **App**: Configure with cloud backend URL
3. **Tablet**: Install APK, enable mobile data
4. **Network**: WiFi preferred, mobile data backup
5. **Mode**: Offline-first (works without internet)

---

## ⚠️ Important Notes

- ❌ **Don't use local backend** for field work
- ✅ **Use cloud backend** (works from anywhere)
- ✅ **App works offline** (stores data locally)
- ✅ **Syncs when online** (automatic)
- ✅ **Mobile data works** (as backup)

---

*Quick Reference for Field Deployment*





