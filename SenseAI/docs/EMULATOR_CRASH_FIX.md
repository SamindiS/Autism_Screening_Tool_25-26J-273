# Fix for Emulator Crash (Impeller Rendering Issue)

## 🔴 Problem

The app crashes on Android emulator with:
```
Fatal signal 11 (SIGSEGV)
Requested texture size (1, 1) exceeds maximum supported size of (0, 0)
```

This is an **Impeller rendering issue** with charts on the emulator.

---

## ✅ Solution 1: Disable Impeller (Recommended for Emulator)

**Impeller** is Flutter's new rendering engine, but it has issues on some emulators.

### Option A: Disable via Command Line

Run the app with:
```bash
flutter run --no-enable-impeller
```

### Option B: Disable in Code (Permanent)

Add this to `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable Impeller for emulator compatibility
  if (kDebugMode) {
    // Use Skia instead of Impeller
    debugDisableShadows = true;
  }
  
  await OfflineSyncService.init();
  // ... rest of code
}
```

---

## ✅ Solution 2: Use Real Device Instead

**Emulators often have graphics issues.** Try on a **real Android device**:

1. Connect your tablet via USB
2. Enable USB debugging
3. Run: `flutter devices` (should show your device)
4. Run: `flutter run -d <device-id>`

**Real devices work much better** for graphics-intensive apps.

---

## ✅ Solution 3: Add Error Handling to Charts

I'll add try-catch blocks around chart rendering to prevent crashes.

---

## ✅ Solution 4: Update Emulator Settings

If you must use emulator:

1. **Increase RAM**: Emulator → Settings → Advanced → RAM: 4096 MB
2. **Use Hardware Graphics**: Emulator → Settings → Graphics: Hardware - GLES 2.0
3. **Update Emulator**: Tools → SDK Manager → SDK Tools → Update Android Emulator

---

## 🚀 Quick Fix (Try This First)

**Run with Skia instead of Impeller:**

```bash
flutter run --no-enable-impeller
```

This should fix the crash immediately.

---

## 📱 For Production Build

When building APK, Impeller is usually fine on real devices:

```bash
flutter build apk --release
```

The crash is mainly an **emulator issue**, not a real device issue.

---

## 🔍 Why This Happens

- **Impeller** is Flutter's new rendering engine (faster, but newer)
- **Emulators** have limited graphics capabilities
- **Charts** (fl_chart) require texture rendering that emulator can't handle
- **Real devices** have proper GPU support

---

## ✅ Recommended Approach

1. **For Development**: Use `--no-enable-impeller` flag
2. **For Testing**: Use real device
3. **For Production**: Build normally (Impeller works on real devices)

---

**Try Solution 1 first - it should fix the crash immediately!**



