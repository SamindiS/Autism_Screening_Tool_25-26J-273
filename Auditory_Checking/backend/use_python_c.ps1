# Script to use Python 3.12.5 from C drive
# Run this in PowerShell: .\use_python_c.ps1

Write-Host "Setting up Python 3.12.5 from C drive..." -ForegroundColor Green
Write-Host ""

# Common Python 3.12.5 installation paths on C drive
$pythonPaths = @(
    "C:\Python312\python.exe",
    "C:\Python3125\python.exe",
    "C:\Program Files\Python312\python.exe",
    "C:\Program Files\Python3125\python.exe",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python312\python.exe",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python3125\python.exe"
)

$pythonExe = $null

# Check if python command works
Write-Host "Checking if 'python' command works..." -ForegroundColor Yellow
try {
    $version = python --version 2>&1
    if ($version -match "3.12") {
        Write-Host "✅ Found: $version" -ForegroundColor Green
        $pythonExe = "python"
    }
} catch {
    Write-Host "❌ 'python' command not found" -ForegroundColor Red
}

# If python command doesn't work, try to find Python executable
if (-not $pythonExe) {
    Write-Host "`nSearching for Python 3.12.5 on C drive..." -ForegroundColor Yellow
    foreach ($path in $pythonPaths) {
        if (Test-Path $path) {
            Write-Host "✅ Found Python at: $path" -ForegroundColor Green
            $pythonExe = $path
            break
        }
    }
}

# If still not found, ask user
if (-not $pythonExe) {
    Write-Host "`n❌ Could not find Python 3.12.5 automatically" -ForegroundColor Red
    Write-Host "Please provide the full path to Python.exe" -ForegroundColor Yellow
    Write-Host "Example: C:\Python312\python.exe" -ForegroundColor White
    $pythonExe = Read-Host "Enter Python path"
    
    if (-not (Test-Path $pythonExe)) {
        Write-Host "❌ Path not found: $pythonExe" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nUsing Python: $pythonExe" -ForegroundColor Cyan

# Check Python version
Write-Host "`nChecking Python version..." -ForegroundColor Yellow
$version = & $pythonExe --version 2>&1
Write-Host "Version: $version" -ForegroundColor Green

# Check if pip is available
Write-Host "`nChecking pip..." -ForegroundColor Yellow
try {
    $pipVersion = & $pythonExe -m pip --version 2>&1
    Write-Host "✅ Pip found: $pipVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Pip not found, installing..." -ForegroundColor Yellow
    & $pythonExe -m ensurepip --upgrade --default-pip
}

# Create virtual environment
Write-Host "`nSetting up virtual environment..." -ForegroundColor Yellow
if (Test-Path "venv") {
    Write-Host "Virtual environment already exists" -ForegroundColor Cyan
} else {
    Write-Host "Creating virtual environment..." -ForegroundColor Cyan
    & $pythonExe -m venv venv
}

# Activate virtual environment
Write-Host "`nActivating virtual environment..." -ForegroundColor Yellow
.\venv\Scripts\Activate.ps1

# Upgrade pip in venv
Write-Host "`nUpgrading pip in virtual environment..." -ForegroundColor Yellow
python -m pip install --upgrade pip

# Install required packages
Write-Host "`nInstalling ML packages..." -ForegroundColor Green
python -m pip install pandas scikit-learn joblib

# Verify installation
Write-Host "`nVerifying installation..." -ForegroundColor Yellow
python -m pip list | Select-String -Pattern "pandas|scikit|joblib"

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host "`nTo use in future, activate venv first:" -ForegroundColor Yellow
Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "`nThen install packages:" -ForegroundColor Yellow
Write-Host "  python -m pip install <package-name>" -ForegroundColor White



























