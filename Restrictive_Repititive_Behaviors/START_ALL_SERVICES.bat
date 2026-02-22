@echo off
echo ========================================
echo RRB Detection System - Starting All Services
echo ========================================
echo.

REM Get local IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set LOCAL_IP=%%a
    goto :found_ip
)
:found_ip
set LOCAL_IP=%LOCAL_IP:~1%
echo Your Local IP Address: %LOCAL_IP%
echo.
echo IMPORTANT: Update Flutter app config with this IP!
echo File: rrb_detection_app\lib\config\app_config.dart
echo Replace 'localhost' with '%LOCAL_IP%'
echo.
pause

echo.
echo Starting services in separate windows...
echo.

REM Start ML Service
echo [1/3] Starting ML Service (Python Flask - Port 5000)...
start "ML Service - Port 5000" cmd /k "cd ml_service && set TF_USE_LEGACY_KERAS=1 && set TF_CPP_MIN_LOG_LEVEL=2 && python app.py"
timeout /t 5 /nobreak >nul

REM Start Backend
echo [2/3] Starting Backend (Node.js - Port 3000)...
start "Backend - Port 3000" cmd /k "cd backend && node server.js"
timeout /t 5 /nobreak >nul

REM Start Flutter App
echo [3/3] Starting Flutter App...
start "Flutter App" cmd /k "cd rrb_detection_app && C:\flutter\bin\flutter.bat run"

echo.
echo ========================================
echo All services are starting!
echo ========================================
echo.
echo Service Status:
echo - ML Service:  http://localhost:5000 (or http://%LOCAL_IP%:5000)
echo - Backend:     http://localhost:3000 (or http://%LOCAL_IP%:3000)
echo - Flutter App: Running on connected device
echo.
echo Check each window for service status.
echo.
echo To stop all services:
echo - Close each command window
echo - Or press Ctrl+C in each window
echo.
pause

