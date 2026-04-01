# 🚀 Quick Fix for Kotlin Cache Error

## ✅ Solution 1: Run Cleanup Script (Recommended)

**From project root directory:**

```powershell
# Run the cleanup script
.\clean_build.ps1

# Then rebuild
flutter run -d emulator-5554
```

---

## ✅ Solution 2: Manual Cleanup (If script doesn't work)

**Run these commands one by one:**

```powershell
# 1. Delete build directories
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force android\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue

# 2. Flutter clean
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Run app
flutter run -d emulator-5554
```

---

## ✅ Solution 3: Disable Incremental Compilation (Already Applied)

I've already updated `android/app/build.gradle` to disable Kotlin incremental compilation as a workaround. This prevents the cache issue from happening again.

**After cleanup, the build should work!**

---

## 🔍 What Was Fixed

1. ✅ Added `incremental = false` to Kotlin compilation tasks
2. ✅ Created `clean_build.ps1` script for easy cleanup
3. ✅ Provided manual cleanup steps

**The error was caused by corrupted Kotlin incremental compilation caches with files from different drive roots (C: vs D:).**


