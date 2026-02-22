@echo off
echo ================================================================================
echo RRB Detection Model Training
echo ================================================================================
echo.

REM Activate virtual environment if it exists
if exist venv\Scripts\activate.bat (
    echo Activating virtual environment...
    call venv\Scripts\activate.bat
)

REM Run training with default parameters
echo Starting training...
python train.py --epochs 50 --batch_size 8 --use_pretrained --save_preprocessed

echo.
echo ================================================================================
echo Training completed!
echo ================================================================================
pause

