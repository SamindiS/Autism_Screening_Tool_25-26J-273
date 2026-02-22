@echo off
echo ========================================
echo Flutter Verification Script
echo ========================================
echo.

set FLUTTER_BIN=C:\flutter\bin

echo [1/3] Checking Flutter installation...
if not exist "%FLUTTER_BIN%\flutter.bat" (
    echo ERROR: Flutter not found at %FLUTTER_BIN%
    pause
    exit /b 1
)
echo OK: Flutter found
echo.

echo [2/3] Checking Flutter version...
"%FLUTTER_BIN%\flutter.bat" --version
echo.

echo [3/3] Running Flutter doctor...
echo This will check for any missing dependencies...
echo.
"%FLUTTER_BIN%\flutter.bat" doctor -v
echo.

echo ========================================
echo Verification Complete!
echo ========================================
echo.
echo If you see any issues above, please address them.
echo Common issues:
echo   - Android SDK not installed
echo   - Visual Studio not installed (for Windows development)
echo   - Chrome not installed (for web development)
echo.
pause

