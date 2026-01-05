@echo off
echo ========================================
echo RRB Detection Flutter App - Setup and Test
echo ========================================
echo.

set FLUTTER_BIN=C:\flutter\bin

cd rrb_detection_app

echo [1/5] Installing dependencies...
echo This may take a few minutes...
"%FLUTTER_BIN%\flutter.bat" pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo OK: Dependencies installed
echo.

echo [2/5] Analyzing code for errors...
"%FLUTTER_BIN%\flutter.bat" analyze
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Code analysis found issues
    echo Please review the issues above
) else (
    echo OK: No analysis issues found
)
echo.

echo [3/5] Checking Flutter doctor...
"%FLUTTER_BIN%\flutter.bat" doctor
echo.

echo [4/5] Listing available devices...
"%FLUTTER_BIN%\flutter.bat" devices
echo.

echo [5/5] Setup complete!
echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo 1. Update API URLs in lib\config\app_config.dart:
echo    - apiBaseUrl: Your Node.js backend URL
echo    - mlServiceUrl: Your Python ML service URL
echo.
echo 2. Connect a device or start an emulator
echo.
echo 3. Run the app:
echo    %FLUTTER_BIN%\flutter.bat run
echo.
echo 4. Build APK for Android:
echo    %FLUTTER_BIN%\flutter.bat build apk
echo.
echo ========================================
pause

