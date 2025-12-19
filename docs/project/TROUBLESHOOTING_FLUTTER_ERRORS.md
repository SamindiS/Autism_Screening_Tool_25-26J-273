# Troubleshooting Flutter Build Errors

## 🔴 Current Issues

### Issue 1: Backend - ML Models Warning (Non-Critical)
**Status**: ⚠️ Warning only, backend is working fine

**Message**:
```
⚠️  ML models not found. ML predictions will use fallback.
```

**Solution**: This is just a warning. Your backend is running correctly. ML models are optional - the app will work without them, just predictions will use fallback logic.

**To fix (optional)**:
1. Train your ML models (see `ML_TRAINING/Complete_ASD_ML_Training.ipynb`)
2. Place trained models in `senseai_backend/models/`:
   - `asd_detection_model.pkl`
   - `feature_scaler.pkl`
   - `feature_names.json`

---

### Issue 2: Flutter - Localization Generation Error (Critical)
**Status**: ❌ Blocking app build

**Error**:
```
Target gen_localizations failed: ProcessException: `dart format` failed with exit code -1073740791
Could not start thread DartWorker: 22 (The device does not recognize the command.)
```

**Cause**: Windows-specific Dart tooling issue, often caused by:
- Antivirus blocking Dart processes
- Corrupted Flutter/Dart installation
- Thread creation failure
- Permission issues

---

## ✅ Solutions (Try in Order)

### Solution 1: Clean Flutter Build (Recommended)

```powershell
# Clean Flutter build cache
flutter clean

# Get dependencies again
flutter pub get

# Try running again
flutter run
```

---

### Solution 2: Delete Generated Files and Regenerate

```powershell
# Delete generated localization files
Remove-Item -Recurse -Force lib\l10n\app_localizations*.dart

# Regenerate
flutter pub get
flutter run
```

---

### Solution 3: Disable Antivirus Temporarily

1. **Temporarily disable Windows Defender** or your antivirus
2. Try `flutter clean` and `flutter run` again
3. Re-enable antivirus after build succeeds

**Or add Flutter to exclusions**:
- Windows Defender → Virus & threat protection → Manage settings
- Add exclusions for:
  - `C:\Program Files\flutter\`
  - `C:\Users\<YourUser>\AppData\Local\Pub\Cache\`
  - Your project directory

---

### Solution 4: Fix Dart SDK

```powershell
# Update Flutter (this will also update Dart)
flutter upgrade

# Verify Dart installation
dart --version

# Try again
flutter clean
flutter pub get
flutter run
```

---

### Solution 5: Skip Localization Generation (Temporary Workaround)

If you need to run the app immediately, you can temporarily skip localization:

**Option A: Comment out localization in `main.dart`**:

```dart
// Temporarily comment these lines:
// locale: languageProvider.locale,
// supportedLocales: AppLocalizations.supportedLocales,
// localizationsDelegates: AppLocalizations.localizationsDelegates,
```

**Option B: Disable generation in `pubspec.yaml`**:

```yaml
flutter:
  generate: false  # Temporarily disable
```

**Note**: This will disable multi-language support temporarily. Re-enable after fixing the issue.

---

### Solution 6: Manual Localization Generation

```powershell
# Generate localizations manually
flutter gen-l10n

# Then try running
flutter run
```

---

### Solution 7: Reinstall Flutter (Last Resort)

If nothing works:

```powershell
# 1. Uninstall Flutter (delete folder)
# 2. Download fresh Flutter from https://flutter.dev
# 3. Extract to C:\Program Files\flutter
# 4. Add to PATH
# 5. Run: flutter doctor
# 6. Run: flutter pub get
# 7. Run: flutter run
```

---

## 🔍 Additional Debugging

### Check Flutter Doctor

```powershell
flutter doctor -v
```

Look for any issues with:
- Dart SDK
- Flutter tools
- Windows toolchain

### Check Dart Version

```powershell
dart --version
```

Should be compatible with Flutter version.

### Check for Corrupted Files

```powershell
# Verify Flutter installation
flutter doctor

# Check for corrupted cache
flutter pub cache repair
```

---

## 📝 Translation Warnings (Non-Critical)

**Warning**:
```
"si": 78 untranslated message(s).
"ta": 78 untranslated message(s).
```

**Status**: ⚠️ Warning only, app will still work

**Solution**: These are just warnings about missing translations. The app will use English as fallback. You can fix later by:
1. Adding missing translations to `lib/l10n/app_si.arb` and `lib/l10n/app_ta.arb`
2. Or ignore for now (app works fine with English fallback)

---

## 🎯 Quick Fix Checklist

1. [ ] Run `flutter clean`
2. [ ] Run `flutter pub get`
3. [ ] Try `flutter run` again
4. [ ] If still fails, delete generated files in `lib/l10n/`
5. [ ] Check antivirus settings
6. [ ] Try `flutter upgrade`
7. [ ] Check `flutter doctor -v` for issues

---

## 💡 Prevention

To avoid this issue in the future:

1. **Add Flutter to antivirus exclusions**
2. **Keep Flutter updated**: `flutter upgrade` regularly
3. **Clean build regularly**: `flutter clean` before major changes
4. **Use stable Flutter channel**: `flutter channel stable`

---

## 🆘 Still Not Working?

If none of the above solutions work:

1. **Check Windows Event Viewer** for system errors
2. **Check Flutter logs**: `flutter run -v` (verbose mode)
3. **Try on different machine** to isolate hardware/OS issues
4. **Check Flutter GitHub issues** for similar problems
5. **Consider using WSL2** (Windows Subsystem for Linux) for Flutter development

---

*Last Updated: 2024*

