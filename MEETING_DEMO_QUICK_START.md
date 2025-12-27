# 🎥 Quick Start: Run App for Online Meeting

## ✅ Your Setup is Ready!

- ✅ Flutter installed and working
- ✅ Android emulator connected: `emulator-5554`
- ✅ Everything configured correctly

---

## 🚀 Run the App (3 Steps)

### Step 1: Start Backend Server (Terminal 1)

Open a **new terminal** and run:

```powershell
cd senseai_backend
npm start
```

**Wait for**: `Server running on http://0.0.0.0:3000`

---

### Step 2: Run Flutter App (Terminal 2)

In your **current terminal**, run:

```powershell
flutter run -d emulator-5554
```

**What happens**:
- Builds the app (first time takes 2-3 minutes)
- Installs on emulator
- Launches automatically
- Shows your app!

---

### Step 3: Share Your Screen

Once the app is running:
1. **Share your screen** in the meeting
2. **Show the emulator** window
3. **Demo the app features**:
   - Login/Registration
   - Add child
   - Run assessments
   - View data

---

## 📱 What to Show in Meeting

### 1. **Login Screen**
- Show clinician registration
- Show login with PIN

### 2. **Child Management**
- Add new child
- View child list
- Show child details

### 3. **Assessment Games**
- Color-Shape Game (DCCS)
- Frog Jump Game (Go/No-Go)
- AI Doctor Bot Questionnaire

### 4. **Data Export**
- Show CSV export
- Show data in cognitive dashboard

### 5. **Admin Portal** (Optional)
- Open web browser
- Show admin dashboard
- Show data visualization

---

## ⚡ Quick Commands

```powershell
# Check emulator is connected
adb devices

# Run app on emulator
flutter run -d emulator-5554

# Run in release mode (faster, no debug)
flutter run -d emulator-5554 --release

# Hot reload (press 'r' while app is running)
# Hot restart (press 'R' while app is running)
```

---

## 🎯 For Best Performance

### Option 1: Release Mode (Recommended for Demo)
```powershell
flutter run -d emulator-5554 --release
```
- Faster performance
- No debug overhead
- Better for screen sharing

### Option 2: Debug Mode (For Development)
```powershell
flutter run -d emulator-5554
```
- Hot reload available
- Debug tools enabled
- Slower but more flexible

---

## 🔧 If Something Goes Wrong

### App Won't Build?
```powershell
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### Backend Not Connecting?
1. Check backend is running: `http://localhost:3000/health`
2. Check emulator can reach backend (use `10.0.2.2:3000` for emulator)
3. Check API service base URL in code

### Emulator Too Slow?
- Close other applications
- Increase emulator RAM in AVD Manager
- Use release mode: `--release`

---

## 📋 Pre-Meeting Checklist

- [ ] Backend server running (`npm start` in `senseai_backend`)
- [ ] Emulator running and visible
- [ ] Flutter app built and running
- [ ] Test login works
- [ ] Test adding a child works
- [ ] Screen sharing ready
- [ ] Microphone ready for explanation

---

## 🎬 Demo Script (5 Minutes)

1. **Introduction** (30 sec)
   - "This is our Autism Screening Tool"
   - "Built with Flutter for mobile, React for admin portal"

2. **Mobile App** (2 min)
   - Show login/registration
   - Add a child
   - Run one assessment game
   - Show results

3. **Admin Portal** (1.5 min)
   - Open web browser
   - Show dashboard with statistics
   - Show data visualization
   - Show export functionality

4. **Technical Highlights** (1 min)
   - Offline-first architecture
   - Multi-language support
   - ML model integration
   - Data validation & integrity

---

## 💡 Pro Tips

1. **Practice First**: Run through the demo once before the meeting
2. **Have Backup**: Keep Postman ready to show API if app has issues
3. **Show Code**: If asked, you can show code structure
4. **Be Ready**: Have documentation ready to share if needed

---

## 🚨 Emergency Backup Plan

If app won't run:
1. **Show Screenshots**: Have screenshots ready
2. **Show Code**: Walk through code structure
3. **Show Admin Portal**: Web app should still work
4. **Show Documentation**: Share your comprehensive docs

---

**You're all set! Good luck with your meeting! 🎉**

