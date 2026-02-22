# 🎥 Run App for Online Meeting - Simple Steps

## ✅ Your Emulator is Ready!
- **Device**: Pixel Tablet (emulator-5554)
- **Android**: API 35
- **Status**: Connected ✅

---

## 🚀 Quick Start (2 Terminals)

### Terminal 1: Start Backend
```powershell
cd senseai_backend
npm start
```
**Wait for**: `Server running on http://0.0.0.0:3000`

---

### Terminal 2: Run Flutter App
```powershell
flutter run -d emulator-5554
```

**First time**: Takes 2-3 minutes to build  
**After that**: Much faster!

---

## 📱 What You'll See

1. **App builds** (shows progress)
2. **App installs** on emulator
3. **App launches** automatically
4. **Emulator window** shows your app!

---

## 🎬 For the Meeting

### Share Your Screen
- Share the **emulator window** (not full screen)
- Or share **entire screen** if needed

### Demo Flow (5 minutes)
1. **Login Screen** → Show registration/login
2. **Add Child** → Create a test child
3. **Run Assessment** → Show one game (Color-Shape or Frog Jump)
4. **View Results** → Show assessment results
5. **Admin Portal** (optional) → Open browser, show dashboard

---

## ⚡ Quick Commands

```powershell
# Run app (debug mode - with hot reload)
flutter run -d emulator-5554

# Run app (release mode - faster, no debug)
flutter run -d emulator-5554 --release

# Hot reload while running (press 'r')
# Hot restart while running (press 'R')
# Quit (press 'q')
```

---

## 🔧 If Issues

### Backend Not Starting?
```powershell
cd senseai_backend
npm install
npm start
```

### App Won't Build?
```powershell
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### Emulator Too Slow?
- Close other apps
- Use release mode: `flutter run -d emulator-5554 --release`

---

## ✅ Pre-Meeting Checklist

- [ ] Backend running (Terminal 1)
- [ ] App running on emulator (Terminal 2)
- [ ] Test login works
- [ ] Test adding child works
- [ ] Screen sharing ready
- [ ] Microphone ready

---

**Ready to go! Just run the two commands above! 🚀**



