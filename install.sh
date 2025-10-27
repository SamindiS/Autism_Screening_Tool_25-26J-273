#!/bin/bash

# Autism Screening App Installation Script
echo "🧠 Installing Autism Screening App..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v20+ first."
    exit 1
fi

# Check if React Native CLI is installed
if ! command -v react-native &> /dev/null; then
    echo "📦 Installing React Native CLI..."
    npm install -g react-native-cli
fi

# Install frontend dependencies
echo "📱 Installing frontend dependencies..."
npm install

# Install iOS dependencies (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Installing iOS dependencies..."
    cd ios
    pod install
    cd ..
fi

# Create backend virtual environment
echo "🐍 Setting up Python backend..."
cd backend
python -m venv venv

# Activate virtual environment
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows
    venv\Scripts\activate
else
    # macOS/Linux
    source venv/bin/activate
fi

# Install Python dependencies
pip install -r requirements.txt

# Create .env file for backend
echo "⚙️ Creating backend configuration..."
cat > .env << EOF
DATABASE_URL=postgresql://user:password@localhost/autism_screening
SECRET_KEY=your-secret-key-change-in-production
DEBUG=True
EOF

cd ..

echo "✅ Installation complete!"
echo ""
echo "🚀 To start the app:"
echo "   Frontend: npm run android (or npm run ios)"
echo "   Backend:  cd backend && python app/main.py"
echo ""
echo "📚 See README.md for detailed setup instructions."









