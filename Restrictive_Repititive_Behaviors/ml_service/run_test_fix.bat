@echo off
echo ================================================================================
echo ML Server Crash Fix - Test Script
echo ================================================================================
echo.

REM Set environment variables
set TF_USE_LEGACY_KERAS=1
set TF_CPP_MIN_LOG_LEVEL=2
set CUDA_VISIBLE_DEVICES=-1

echo Running tests...
echo.

python test_fix.py

echo.
echo ================================================================================
echo Test completed. Check the output above for results.
echo ================================================================================
echo.
pause

