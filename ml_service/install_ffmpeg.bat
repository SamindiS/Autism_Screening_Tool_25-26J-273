@echo off
echo ========================================
echo FFmpeg Installation Helper
echo ========================================
echo.
echo FFmpeg is required for video repair functionality.
echo.
echo Installation Options:
echo 1. Using Chocolatey (Recommended for Windows)
echo 2. Manual Download
echo.
echo ========================================
echo.

REM Check if FFmpeg is already installed
where ffmpeg >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo FFmpeg is already installed!
    ffmpeg -version | findstr "ffmpeg version"
    echo.
    pause
    exit /b 0
)

echo FFmpeg is not installed.
echo.
echo Option 1: Install using Chocolatey
echo -----------------------------------------
echo If you have Chocolatey installed, run:
echo   choco install ffmpeg
echo.
echo Option 2: Manual Installation
echo -----------------------------------------
echo 1. Download FFmpeg from: https://www.gyan.dev/ffmpeg/builds/
echo 2. Extract the archive
echo 3. Add the 'bin' folder to your system PATH
echo.
echo For detailed instructions, visit:
echo https://www.wikihow.com/Install-FFmpeg-on-Windows
echo.
echo ========================================
echo.
echo Would you like to install FFmpeg using Chocolatey? (Y/N)
set /p choice=

if /i "%choice%"=="Y" (
    echo.
    echo Checking for Chocolatey...
    where choco >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo Chocolatey is not installed.
        echo Please install Chocolatey first from: https://chocolatey.org/install
        echo.
        pause
        exit /b 1
    )
    
    echo Installing FFmpeg via Chocolatey...
    choco install ffmpeg -y
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo FFmpeg installed successfully!
        echo Please restart your terminal/command prompt.
    ) else (
        echo.
        echo Installation failed. Please try manual installation.
    )
) else (
    echo.
    echo Please install FFmpeg manually.
    echo Opening download page...
    start https://www.gyan.dev/ffmpeg/builds/
)

echo.
pause

