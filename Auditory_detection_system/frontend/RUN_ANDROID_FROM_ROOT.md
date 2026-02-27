# Run the app on Android (avoid frontend build issues)

The **frontend** Android build hits Kotlin incremental cache errors when the project is on **D:** and the Pub cache is on **C:**. The same app runs correctly from the **project root**.

## Use this (recommended)

From the **project root** (not `frontend`):

```powershell
cd "d:\new flutter-app"
flutter clean
flutter pub get
flutter run -d emulator-5554
```

Use your emulator ID if different (e.g. from `flutter devices`).

## If you must run from frontend

1. Stop Gradle/Kotlin daemons and clean:
   ```powershell
   cd "d:\new flutter-app\frontend"
   cd android; .\gradlew --stop; cd ..
   Remove-Item -Path "android\build" -Recurse -Force -ErrorAction SilentlyContinue
   Remove-Item -Path "android\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
   flutter clean
   flutter pub get
   flutter run -d emulator-5554
   ```
2. If it still fails with "different roots" or "failed to produce .apk", run from root as above.
