@echo off
echo ================================================================================
echo RRB Detection ML Service - Starting Server
echo ================================================================================
echo.

REM Set environment variables for TensorFlow/Keras compatibility
set TF_USE_LEGACY_KERAS=1
set TF_CPP_MIN_LOG_LEVEL=2

REM Activate virtual environment if it exists
if exist venv\Scripts\activate.bat (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
)

REM Start Flask server
echo Starting Flask server...
python app.py

pause

