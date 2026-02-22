# 📱 Building APK for SenseAI App

## Quick Guide

### **Build Release APK (Recommended for Distribution)**

```powershell
flutter build apk --release
```

**Output Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

---

### **Build Debug APK (For Testing)**

```powershell
flutter build apk --debug
```

**Output Location:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

## 📋 Step-by-Step Instructions

### **Step 1: Ensure Dependencies are Installed**

```powershell
flutter pub get
```

### **Step 2: Check Build Configuration**

Make sure your `android/app/build.gradle` has:
- ✅ `ndkVersion "28.2.13676358"` (already fixed)
- ✅ Proper signing config (for release)

### **Step 3: Build Release APK**

```powershell
flutter build apk --release
```

**This will:**
- Compile the app in release mode
- Optimize the code
- Generate a signed APK (if signing config is set)
- Output: `app-release.apk`

### **Step 4: Find Your APK**

After build completes, the APK will be at:
```
D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273\build\app\outputs\flutter-apk\app-release.apk
```

---

## 🔧 Build Options

### **1. Build Split APKs (by ABI)**

For smaller file sizes (separate APKs for different architectures):

```powershell
flutter build apk --split-per-abi
```

**Output:**
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### **2. Build Specific Architecture**

```powershell
# 64-bit ARM (most common)
flutter build apk --target-platform android-arm64

# 32-bit ARM
flutter build apk --target-platform android-arm

# x86_64 (for emulators)
flutter build apk --target-platform android-x64
```

### **3. Build with Specific Build Number**

```powershell
flutter build apk --release --build-number=2
```

### **4. Build with Specific Build Name**

```powershell
flutter build apk --release --build-name=1.0.1
```

---

## 📦 Build App Bundle (for Google Play Store)

If you plan to publish on Google Play Store, use App Bundle instead:

```powershell
flutter build appbundle --release
```

**Output Location:**
```
build/app/outputs/bundle/release/app-release.aab
```

**Note:** App Bundle is smaller and optimized for Play Store distribution.

---

## 🔐 Signing Configuration (For Release)

### **Current Status**

Your `build.gradle` currently uses debug signing:
```gradle
signingConfig signingConfigs.debug
```

### **For Production Release**

You need to create a keystore and configure signing:

#### **Step 1: Generate Keystore**

```powershell
keytool -genkey -v -keystore senseai-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias senseai
```

**You'll be asked for:**
- Password (remember this!)
- Name, Organization, etc.

#### **Step 2: Create `key.properties`**

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=senseai
storeFile=../senseai-release-key.jks
```

#### **Step 3: Update `build.gradle`**

Add to `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 🚀 Quick Build Commands

### **For Testing (Debug)**
```powershell
flutter build apk --debug
```

### **For Distribution (Release)**
```powershell
flutter build apk --release
```

### **For Play Store (App Bundle)**
```powershell
flutter build appbundle --release
```

### **For Multiple Architectures**
```powershell
flutter build apk --split-per-abi --release
```

---

## 📊 APK Size Optimization

### **Check APK Size**

After building, check size:
```powershell
# Windows PowerShell
(Get-Item build\app\outputs\flutter-apk\app-release.apk).Length / 1MB
```

### **Reduce APK Size**

1. **Remove unused assets:**
   - Check `assets/` folder
   - Remove unused images/audio

2. **Use split APKs:**
   ```powershell
   flutter build apk --split-per-abi --release
   ```

3. **Enable ProGuard (minification):**
   - Add to `android/app/build.gradle`:
   ```gradle
   buildTypes {
       release {
           minifyEnabled true
           shrinkResources true
           proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
       }
   }
   ```

---

## ✅ Build Checklist

Before building release APK:

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Fix all linter errors
- [ ] Test app on device/emulator
- [ ] Update version in `pubspec.yaml`
- [ ] Configure signing (for release)
- [ ] Build APK: `flutter build apk --release`
- [ ] Test the generated APK

---

## 🐛 Troubleshooting

### **Error: "Gradle build failed"**
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### **Error: "NDK version mismatch"**
- Already fixed in `build.gradle` with `ndkVersion "28.2.13676358"`

### **Error: "Signing config not found"**
- For debug: Uses default debug signing (OK)
- For release: Need to configure signing (see above)

### **APK too large**
- Use `--split-per-abi` to create separate APKs
- Remove unused assets
- Enable ProGuard

---

## 📱 Installing APK

### **Via ADB (Android Debug Bridge)**

```powershell
adb install build\app\outputs\flutter-apk\app-release.apk
```

### **Via File Transfer**

1. Copy APK to device
2. Open file manager on device
3. Tap APK file
4. Allow installation from unknown sources (if needed)
5. Install

---

## 🎯 Recommended Build Command

**For your current setup (testing/distribution):**

```powershell
flutter build apk --release
```

**This will create:**
- `build/app/outputs/flutter-apk/app-release.apk`
- Ready to install and test
- ~50-100 MB (depending on assets)

---

**Ready to build!** Run the command above to generate your APK. 🚀


