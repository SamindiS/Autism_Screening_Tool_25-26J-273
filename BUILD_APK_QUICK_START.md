# Quick Start: Build APK

## 🚀 Fastest Way to Build APK

### Step 1: Open Terminal in Project Folder
```bash
cd D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273
```

### Step 2: Build Release APK
```bash
flutter build apk --release
```

### Step 3: Find Your APK
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Install on Device
1. Copy APK to your Android device
2. Enable "Unknown Sources" in Settings → Security
3. Tap APK file to install
4. Done! ✅

---

## 📱 For Testing (Faster Build)

```bash
flutter build apk --debug
```
**Location**: `build/app/outputs/flutter-apk/app-debug.apk`

---

## 🔧 If Build Fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📦 Smaller APK Size

```bash
flutter build apk --release --split-per-abi
```
This creates separate APKs for different architectures (smaller files).

---

**That's it!** Your APK is ready to install on your device.

For detailed instructions, see: `docs/project/BUILD_APK_GUIDE.md`





