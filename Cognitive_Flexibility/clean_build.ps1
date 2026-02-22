# Clean Build Script - Fix Kotlin Cache Errors
# Run this from the project root directory

Write-Host "🧹 Cleaning Flutter and Android build caches..." -ForegroundColor Cyan

# Step 1: Delete build directory
Write-Host "`n1. Deleting build directory..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
    Write-Host "   ✅ build/ deleted" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  build/ not found (already clean)" -ForegroundColor Gray
}

# Step 2: Delete Android build directories
Write-Host "`n2. Deleting Android build directories..." -ForegroundColor Yellow
if (Test-Path "android\app\build") {
    Remove-Item -Recurse -Force "android\app\build" -ErrorAction SilentlyContinue
    Write-Host "   ✅ android/app/build/ deleted" -ForegroundColor Green
}
if (Test-Path "android\.gradle") {
    Remove-Item -Recurse -Force "android\.gradle" -ErrorAction SilentlyContinue
    Write-Host "   ✅ android/.gradle/ deleted" -ForegroundColor Green
}
if (Test-Path "android\build") {
    Remove-Item -Recurse -Force "android\build" -ErrorAction SilentlyContinue
    Write-Host "   ✅ android/build/ deleted" -ForegroundColor Green
}

# Step 3: Delete .dart_tool
Write-Host "`n3. Deleting .dart_tool..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool" -ErrorAction SilentlyContinue
    Write-Host "   ✅ .dart_tool/ deleted" -ForegroundColor Green
}

# Step 4: Flutter clean
Write-Host "`n4. Running flutter clean..." -ForegroundColor Yellow
flutter clean

# Step 5: Get dependencies
Write-Host "`n5. Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Clean complete! Now run: flutter run -d emulator-5554" -ForegroundColor Green

