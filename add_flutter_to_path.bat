@echo off
echo ========================================
echo Flutter PATH Setup Script
echo ========================================
echo.

set FLUTTER_PATH=C:\flutter\bin

echo Checking Flutter installation...
if not exist "%FLUTTER_PATH%\flutter.bat" (
    echo ERROR: Flutter not found at %FLUTTER_PATH%
    echo Please verify Flutter installation location.
    pause
    exit /b 1
)

echo Flutter found at: %FLUTTER_PATH%
echo.

echo Adding Flutter to User PATH...
setx PATH "%PATH%;%FLUTTER_PATH%"

echo.
echo ========================================
echo Flutter added to PATH successfully!
echo ========================================
echo.
echo IMPORTANT: You need to:
echo   1. Close and reopen VS Code
echo   2. Close and reopen any terminal windows
echo   3. Then run: flutter --version
echo.

echo Testing Flutter with full path...
echo.
"%FLUTTER_PATH%\flutter.bat" --version

echo.
echo ========================================
echo Setup Complete!
echo ========================================
pause

