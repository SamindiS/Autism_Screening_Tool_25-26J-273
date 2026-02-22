# 🔧 Fix Java Memory Error

## ❌ Problem

```
There is insufficient memory for the Java Runtime Environment to continue.
Native memory allocation (malloc) failed to allocate 32744 bytes.
```

Gradle is trying to use **2048MB** of heap memory, but your system doesn't have enough available.

---

## ✅ Solution: Reduce Gradle Memory

I've updated `android/gradle.properties` to use **1024MB** instead of 2048MB.

### **What Changed:**

```properties
# Before (too high):
org.gradle.jvmargs=-Xmx2048M -XX:MaxMetaspaceSize=512m

# After (reduced):
org.gradle.jvmargs=-Xmx1024M -XX:MaxMetaspaceSize=256m
```

---

## 🚀 Next Steps

1. **Run the fixed cleanup script:**
   ```powershell
   .\clean_build.ps1
   ```

2. **Or manually clean:**
   ```powershell
   Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
   Remove-Item -Recurse -Force android\app\build -ErrorAction SilentlyContinue
   Remove-Item -Recurse -Force android\.gradle -ErrorAction SilentlyContinue
   flutter clean
   flutter pub get
   ```

3. **Then run the app:**
   ```powershell
   flutter run -d emulator-5554
   ```

---

## 💡 If Still Getting Memory Errors

If 1024MB is still too much, reduce further:

Edit `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx512M -XX:MaxMetaspaceSize=128m
```

Or disable Gradle daemon temporarily:
```properties
org.gradle.daemon=false
```

---

**The memory settings have been reduced. Try building again!**


