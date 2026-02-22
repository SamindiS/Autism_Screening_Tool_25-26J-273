@echo off
echo ========================================
echo Starting RRB Detection Backend Server
echo ========================================
echo.

REM Check if node_modules exists
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    echo.
)

echo Starting server on port 3000...
echo.
node server.js

pause

