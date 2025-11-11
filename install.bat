@echo off
REM Autism Screening App Installation Script for Windows
echo 🧠 Installing Autism Screening App...

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js v20+ first.
    pause
    exit /b 1
)

REM Check if React Native CLI is installed
react-native --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 📦 Installing React Native CLI...
    npm install -g react-native-cli
)

REM Install frontend dependencies
echo 📱 Installing frontend dependencies...
npm install

REM Create backend virtual environment
echo 🐍 Setting up Python backend...
cd backend
python -m venv venv

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install Python dependencies
pip install -r requirements.txt

REM Create .env file for backend
echo ⚙️ Creating backend configuration...
(
echo DATABASE_URL=postgresql://user:password@localhost/autism_screening
echo SECRET_KEY=your-secret-key-change-in-production
echo DEBUG=True
) > .env

cd ..

echo ✅ Installation complete!
echo.
echo 🚀 To start the app:
echo    Frontend: npm run android
echo    Backend:  cd backend ^&^& python app/main.py
echo.
echo 📚 See README.md for detailed setup instructions.
pause









