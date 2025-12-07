# Building APK for Android Device

## Quick Build Commands

### Debug APK (For Testing)
```bash
flutter build apk --debug
```
**Output**: `build/app/outputs/flutter-apk/app-debug.apk`
- ✅ Fast build
- ✅ Includes debugging symbols
- ⚠️ Larger file size
- ⚠️ Not optimized

### Release APK (For Distribution)
```bash
flutter build apk --release
```
**Output**: `build/app/outputs/flutter-apk/app-release.apk`
- ✅ Optimized and smaller
- ✅ Production-ready
- ✅ Best performance
- ⚠️ Takes longer to build

### Split APKs by ABI (Smaller Size)
```bash
flutter build apk --split-per-abi
```
**Output**: 
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit)
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (x86_64)

**Benefits**: Each APK is smaller (only includes one architecture)

---

## Step-by-Step Guide

### Step 1: Prepare Your Environment

1. **Check Flutter Setup**:
   ```bash
   flutter doctor
   ```
   Ensure Android toolchain is properly configured.

2. **Navigate to Project**:
   ```bash
   cd D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273
   ```

### Step 2: Configure Signing (For Release APK)

#### Option A: Debug Signing (Quick - For Testing)
No configuration needed! Debug builds are automatically signed.

#### Option B: Release Signing (For Distribution)

1. **Create Keystore** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore C:\Users\YourName\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   - Remember the password and alias!
   - Store keystore file securely

2. **Create `android/key.properties`**:
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=C:/Users/YourName/upload-keystore.jks
   ```

3. **Update `android/app/build.gradle`**:
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

### Step 3: Build APK

#### For Testing (Debug):
```bash
flutter build apk --debug
```

#### For Production (Release):
```bash
flutter build apk --release
```

#### For Smaller Size (Split by Architecture):
```bash
flutter build apk --release --split-per-abi
```

### Step 4: Find Your APK

After building, the APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Or for debug:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### Step 5: Install on Device

#### Method 1: Direct Transfer
1. Copy APK to your device (USB, email, cloud storage)
2. On device: Settings → Security → Enable "Unknown Sources"
3. Open APK file on device
4. Tap "Install"

#### Method 2: ADB Install
```bash
# Connect device via USB
adb devices  # Verify device is connected

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### Method 3: USB Transfer
1. Connect device via USB
2. Enable USB file transfer on device
3. Copy APK to device
4. Open file manager on device
5. Tap APK to install

---

## Build Options

### Full Commands

```bash
# Debug APK (testing)
flutter build apk --debug

# Release APK (production)
flutter build apk --release

# Release with split APKs (smaller)
flutter build apk --release --split-per-abi

# Release with specific target
flutter build apk --release --target-platform android-arm64

# Build with verbose output (see what's happening)
flutter build apk --release --verbose
```

---

## Troubleshooting

### Issue: "Gradle build failed"
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### Issue: "Keystore file not found"
**Solution**:
- Check `key.properties` path is correct
- Use forward slashes `/` in path (even on Windows)
- Ensure keystore file exists

### Issue: "SDK version mismatch"
**Solution**:
- Check `android/app/build.gradle` has correct `compileSdkVersion`
- Should be 36 (already updated in your project)

### Issue: "Out of memory"
**Solution**:
```bash
# Increase Gradle memory
# Edit android/gradle.properties:
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
```

### Issue: "Build takes too long"
**Solution**:
- First build always takes longer (downloads dependencies)
- Subsequent builds are faster
- Use `--debug` for faster builds during development

---

## APK File Sizes

### Typical Sizes:
- **Debug APK**: ~50-80 MB
- **Release APK**: ~25-40 MB
- **Split APK (arm64)**: ~15-25 MB

### To Reduce Size:
1. Use `--split-per-abi` (builds separate APKs per architecture)
2. Enable ProGuard/R8 (code shrinking)
3. Remove unused assets
4. Use App Bundle instead of APK

---

## App Bundle (Alternative - For Play Store)

If you plan to publish on Google Play Store, use App Bundle instead:

```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

**Benefits**:
- Smaller download size for users
- Google Play optimizes for each device
- Required for Play Store submission

---

## Quick Reference

### Most Common Commands:

```bash
# 1. Clean previous builds
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build release APK
flutter build apk --release

# 4. Find APK
# Location: build/app/outputs/flutter-apk/app-release.apk
```

### For Your Project:

```bash
# Navigate to project
cd D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273

# Build release APK
flutter build apk --release

# APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Installation on Device

### Enable Unknown Sources:
1. Go to **Settings** → **Security**
2. Enable **"Unknown Sources"** or **"Install Unknown Apps"**
3. Select your file manager app
4. Enable **"Allow from this source"**

### Install APK:
1. Transfer APK to device
2. Open file manager
3. Navigate to APK location
4. Tap APK file
5. Tap **"Install"**
6. Wait for installation
7. Tap **"Open"** or find app in app drawer

---

## Testing the APK

### Before Distribution:
1. ✅ Test on real device
2. ✅ Test all features
3. ✅ Test offline functionality
4. ✅ Test backend connection
5. ✅ Test data saving
6. ✅ Test login/logout
7. ✅ Test all assessment games

### Checklist:
- [ ] App launches correctly
- [ ] Login works
- [ ] Can create children
- [ ] Can run assessments
- [ ] Data saves correctly
- [ ] Profile screen works
- [ ] All languages work
- [ ] Games function properly

---

## Advanced: Build Configuration

### Update Version (in `pubspec.yaml`):
```yaml
version: 1.0.0+1
# Format: version_name+build_number
```

### Update App Name (in `android/app/src/main/AndroidManifest.xml`):
```xml
<application
    android:label="SenseAI"  <!-- Your app name -->
    ...
```

### Update Package Name (in `android/app/build.gradle`):
```gradle
applicationId "com.example.my_autism_app"
```

---

## Common Build Times

- **First Build**: 5-15 minutes (downloads dependencies)
- **Subsequent Builds**: 2-5 minutes
- **Clean Build**: 3-8 minutes

---

## Next Steps After Building

1. **Test APK** on your device
2. **Share with testers** (if needed)
3. **Upload to Play Store** (if publishing)
4. **Keep keystore safe** (for updates)

---

## Notes

- **Debug APK**: Use for testing, includes debugging info
- **Release APK**: Use for distribution, optimized
- **Keystore**: Keep it safe! Needed for all future updates
- **Version**: Update version number before each release
- **Permissions**: App needs internet permission for backend connection

---

*Last Updated: 2024*
*Flutter Version: 3.38+*


