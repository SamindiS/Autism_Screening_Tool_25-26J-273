# 🪟 Virtual Environment Setup for Windows PowerShell

## ⚠️ Common Issues & Fixes

---

## ❌ Issue 1: "Unable to copy venvlauncher.exe"

This usually means:
- Python is in use by another process
- Permissions issue
- Antivirus blocking

**Solution:**

1. **Close all Python processes:**
   ```powershell
   # Check if Python is running
   Get-Process python* | Stop-Process -Force
   ```

2. **Delete existing venv and recreate:**
   ```powershell
   Remove-Item -Recurse -Force venv -ErrorAction SilentlyContinue
   python -m venv venv
   ```

3. **If still fails, try:**
   ```powershell
   python -m venv --clear venv
   ```

---

## ❌ Issue 2: "source is not recognized"

**Problem:** You're using Linux/Mac command in PowerShell

**Wrong (Linux/Mac):**
```bash
source venv/bin/activate
```

**Correct (Windows PowerShell):**
```powershell
venv\Scripts\activate
```

**Or (Windows CMD):**
```cmd
venv\Scripts\activate.bat
```

---

## ✅ Correct Setup Steps for Windows

### Step 1: Create Virtual Environment

```powershell
cd senseai_backend\ml_engine

# Remove old venv if exists
Remove-Item -Recurse -Force venv -ErrorAction SilentlyContinue

# Create new venv
python -m venv venv
```

### Step 2: Activate (PowerShell)

```powershell
venv\Scripts\activate
```

**You should see `(venv)` in your prompt!**

### Step 3: Install Dependencies

```powershell
pip install -r requirements.txt
```

### Step 4: Verify

```powershell
python --version
pip list
```

---

## 🔍 Troubleshooting

### If venv creation fails completely:

**Option 1: Use different Python**

```powershell
# Check Python version
python --version

# Try with full path
C:\Python313\python.exe -m venv venv
```

**Option 2: Use virtualenv instead**

```powershell
pip install virtualenv
virtualenv venv
venv\Scripts\activate
```

**Option 3: Check permissions**

```powershell
# Run PowerShell as Administrator
# Then try again
```

---

## ✅ Quick Reference

| Action | Windows PowerShell | Windows CMD | Linux/Mac |
|--------|-------------------|-------------|-----------|
| Create venv | `python -m venv venv` | `python -m venv venv` | `python -m venv venv` |
| Activate | `venv\Scripts\activate` | `venv\Scripts\activate.bat` | `source venv/bin/activate` |
| Deactivate | `deactivate` | `deactivate` | `deactivate` |

---

## 🚀 Complete Setup Script

Save this as `setup.ps1`:

```powershell
# Setup script for ML Engine
Write-Host "Setting up ML Engine virtual environment..." -ForegroundColor Green

# Remove old venv
if (Test-Path venv) {
    Write-Host "Removing old venv..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force venv
}

# Create venv
Write-Host "Creating virtual environment..." -ForegroundColor Green
python -m venv venv

# Activate venv
Write-Host "Activating virtual environment..." -ForegroundColor Green
& venv\Scripts\activate

# Upgrade pip
Write-Host "Upgrading pip..." -ForegroundColor Green
python -m pip install --upgrade pip

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Green
pip install -r requirements.txt

Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host "To activate: venv\Scripts\activate" -ForegroundColor Cyan
```

**Run it:**
```powershell
.\setup.ps1
```

---

## ✅ Your Current Status

I see you already have `(venv)` in your prompt - that means venv is **already activated**! ✅

**You can skip activation and just install:**

```powershell
# You're already in venv (see the (venv) prefix)
pip install -r requirements.txt
```

---

## 🎯 Next Steps

Since venv is already activated:

1. **Install dependencies:**
   ```powershell
   pip install -r requirements.txt
   ```

2. **Verify installation:**
   ```powershell
   pip list
   ```

3. **Test the service:**
   ```powershell
   uvicorn app.main:app --reload --port 8001
   ```

---

## 💡 Pro Tips

- **Always check prompt:** `(venv)` means you're in virtual environment
- **If prompt doesn't show (venv):** Run `venv\Scripts\activate`
- **To deactivate:** Just type `deactivate`
- **PowerShell vs CMD:** Use `venv\Scripts\activate` in both (PowerShell auto-detects)

---

**You're good to go!** The `(venv)` in your prompt means it's working! ✅


