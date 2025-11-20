# Flutter Diagnostic Script
Write-Host "=== Flutter Diagnostic ===" -ForegroundColor Cyan

Write-Host "`n1. Checking Flutter installation path..." -ForegroundColor Yellow
$flutterPath = "C:\Program Files\flutter\bin\flutter.bat"
if (Test-Path $flutterPath) {
    Write-Host "   ✓ Flutter.bat exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ Flutter.bat NOT found at: $flutterPath" -ForegroundColor Red
}

Write-Host "`n2. Checking if Flutter is in PATH..." -ForegroundColor Yellow
$pathEntries = $env:Path -split ';'
$flutterInPath = $pathEntries | Where-Object { $_ -like "*flutter*" }
if ($flutterInPath) {
    Write-Host "   ✓ Flutter found in PATH:" -ForegroundColor Green
    $flutterInPath | ForEach-Object { Write-Host "     $_" -ForegroundColor Gray }
} else {
    Write-Host "   ✗ Flutter NOT in PATH" -ForegroundColor Red
}

Write-Host "`n3. Testing Flutter command..." -ForegroundColor Yellow
try {
    $flutterVersion = & "C:\Program Files\flutter\bin\flutter.bat" --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Flutter command works!" -ForegroundColor Green
        Write-Host $flutterVersion -ForegroundColor Gray
    } else {
        Write-Host "   ✗ Flutter command failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Error output:" -ForegroundColor Red
        Write-Host $flutterVersion -ForegroundColor Red
    }
} catch {
    Write-Host "   ✗ Error running Flutter:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n4. Checking Flutter directory structure..." -ForegroundColor Yellow
$flutterDir = "C:\Program Files\flutter"
if (Test-Path $flutterDir) {
    Write-Host "   ✓ Flutter directory exists" -ForegroundColor Green
    $binDir = Join-Path $flutterDir "bin"
    if (Test-Path $binDir) {
        Write-Host "   ✓ bin directory exists" -ForegroundColor Green
        $files = Get-ChildItem $binDir -File | Select-Object -First 5 Name
        Write-Host "   Files in bin:" -ForegroundColor Gray
        $files | ForEach-Object { Write-Host "     $($_.Name)" -ForegroundColor Gray }
    } else {
        Write-Host "   ✗ bin directory NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ Flutter directory NOT found" -ForegroundColor Red
}

Write-Host "`n=== Diagnostic Complete ===" -ForegroundColor Cyan




