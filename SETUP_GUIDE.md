# 🚀 Autism Screening App - Setup Guide

## Quick Start

### 1. Install Dependencies
```bash
# Install core React Native dependencies
npm install

# Install additional packages as needed
npm install react-native-sqlite-storage
npm install react-native-vector-icons
npm install react-native-sound
npm install react-native-haptic-feedback
```

### 2. Run the App
```bash
# Start Metro bundler
npm start

# In another terminal, run on Android
npx react-native run-android

# Or run on iOS (macOS only)
npx react-native run-ios
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Metro Bundler Issues
If you see module resolution errors:
```bash
# Clear Metro cache
npx react-native start --reset-cache

# Clear npm cache
npm start -- --reset-cache
```

#### 2. Android Build Issues
```bash
# Clean Android build
cd android
./gradlew clean
cd ..

# Rebuild
npx react-native run-android
```

#### 3. iOS Build Issues (macOS only)
```bash
# Install iOS dependencies
cd ios
pod install
cd ..

# Run on iOS
npx react-native run-ios
```

### 4. Package Version Conflicts
If you encounter package version conflicts:

1. **Check React Native version compatibility**:
   ```bash
   npx react-native info
   ```

2. **Update package.json with compatible versions**:
   - Use React Native 0.82.0 compatible packages
   - Check package documentation for version requirements

3. **Install packages individually**:
   ```bash
   npm install @react-navigation/native@^6.1.9
   npm install @react-navigation/stack@^6.3.20
   npm install react-native-screens@^3.27.0
   npm install react-native-gesture-handler@^2.14.0
   ```

## 📱 Development Phases

### Phase 1: Basic Setup ✅
- [x] React Native project structure
- [x] Core dependencies installed
- [x] Basic app running
- [x] TypeScript configuration

### Phase 2: Core Features (In Progress)
- [ ] Navigation setup
- [ ] Authentication system
- [ ] Basic UI components
- [ ] Data storage

### Phase 3: Game Implementation
- [ ] Age selection screen
- [ ] Cognitive flexibility games
- [ ] Data collection system
- [ ] ML integration

### Phase 4: Advanced Features
- [ ] Multilingual support
- [ ] AI doctor bot
- [ ] Admin dashboard
- [ ] Report generation

## 🛠️ Development Commands

### Frontend
```bash
# Start development server
npm start

# Run on Android
npm run android

# Run on iOS
npm run ios

# Run tests
npm test

# Lint code
npm run lint
```

### Backend (Python)
```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
python app/main.py
```

## 📦 Package Management

### Core Dependencies (Required)
- `react` - React library
- `react-native` - React Native framework
- `@react-navigation/native` - Navigation
- `@react-navigation/stack` - Stack navigator
- `react-native-safe-area-context` - Safe area handling
- `react-native-screens` - Native screen optimization
- `react-native-gesture-handler` - Gesture handling
- `@react-native-async-storage/async-storage` - Local storage
- `axios` - HTTP client

### Optional Dependencies (Add as needed)
- `react-native-sqlite-storage` - Local database
- `react-native-vector-icons` - Icons
- `react-native-sound` - Audio playback
- `react-native-haptic-feedback` - Haptic feedback
- `react-native-paper` - Material Design components
- `react-native-chart-kit` - Charts and graphs
- `react-native-svg` - SVG support

## 🔍 Debugging

### Metro Bundler
```bash
# Start with verbose logging
npx react-native start --verbose

# Reset cache
npx react-native start --reset-cache
```

### Android Debugging
```bash
# Enable debug mode
adb shell input keyevent 82

# View logs
npx react-native log-android
```

### iOS Debugging
```bash
# View logs
npx react-native log-ios

# Open Xcode
npx react-native run-ios --simulator="iPhone 14"
```

## 📋 Next Steps

1. **Test Basic Setup**: Ensure the simple app runs without errors
2. **Add Navigation**: Implement React Navigation step by step
3. **Add Authentication**: Implement login system
4. **Build UI Components**: Create reusable components
5. **Implement Games**: Add cognitive flexibility games
6. **Add Data Storage**: Implement SQLite storage
7. **Integrate ML**: Add machine learning features

## 🆘 Getting Help

If you encounter issues:

1. **Check React Native documentation**: https://reactnative.dev/
2. **Check package documentation**: Each package has its own setup guide
3. **Check Metro bundler logs**: Look for specific error messages
4. **Check device/emulator logs**: Use debugging commands above
5. **Search GitHub issues**: Many issues have been solved before

## 📝 Notes

- This is a clinical assessment system for healthcare professionals
- The app is designed for tablet use in clinical settings
- All data is stored locally and can be synced to backend
- The system supports multiple languages (English, Sinhala, Tamil)
- Machine learning integration provides real-time risk assessment

---

**Happy Coding! 🧠✨**









