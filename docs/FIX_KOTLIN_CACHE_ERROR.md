# 🔧 Fix Kotlin Incremental Compilation Cache Error

## ❌ Problem

Kotlin compiler cache has files from different drive roots:
- `C:\Users\DELL\AppData\Local\Pub\Cache\...` (pub cache)
- `D:\Desktop\FLUTTERAUTISM\...` (project)

This causes: `IllegalArgumentException: this and base files have different roots`

---

## ✅ Solution: Clean All Caches

### **Step 1: Stop Gradle Daemons**

```powershell
# In main project directory
cd D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273
.\android\gradlew --stop
```

### **Step 2: Delete Build Directory**

```powershell
# Delete entire build folder
Remove-Item -Recurse -Force build
```

### **Step 3: Clean Flutter**

```powershell
flutter clean
```

### **Step 4: Clean Gradle**

```powershell
cd android
.\gradlew clean
cd ..
```

### **Step 5: Get Dependencies**

```powershell
flutter pub get
```

### **Step 6: Rebuild**

```powershell
flutter run -d emulator-5554
```

---

## 🚀 Quick Fix (All in One)

Run these commands **from main project directory**:

```powershell
# 1. Stop Gradle daemons
cd android
.\gradlew --stop
cd ..

# 2. Delete build folder
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

# 3. Flutter clean
flutter clean

# 4. Get dependencies
flutter pub get

# 5. Run app
flutter run -d emulator-5554
```

---

## 🔍 Alternative: Manual Cache Cleanup

If the above doesn't work:

```powershell
# Delete all build-related folders
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue

# Then rebuild
flutter clean
flutter pub get
flutter run -d emulator-5554
```

---

**The issue is corrupted Kotlin incremental caches. Cleaning everything should fix it!**


