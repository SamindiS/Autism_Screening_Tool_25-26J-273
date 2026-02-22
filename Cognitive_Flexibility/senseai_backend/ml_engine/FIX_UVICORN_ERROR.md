# 🔧 Fix: uvicorn Not Found Error

## ❌ Problem

**Error:** `uvicorn : The term 'uvicorn' is not recognized`

This means uvicorn is not installed in your virtual environment.

---

## ✅ Solution

### Step 1: Make Sure Venv is Activated

**Check your prompt** - you should see `(venv)` at the start.

**If you don't see `(venv)`:**
```powershell
venv\Scripts\activate
```

### Step 2: Verify You're Using Venv Python

```powershell
# Check which Python you're using
where python
# Should show: ...\ml_engine\venv\Scripts\python.exe

# Or check pip location
where pip
# Should show: ...\ml_engine\venv\Scripts\pip.exe
```

**If it shows global Python instead of venv:**
- Deactivate and reactivate: `deactivate` then `venv\Scripts\activate`

### Step 3: Install Dependencies in Venv

```powershell
# Make sure requirements.txt has content (I've fixed it)
# Then install:
pip install -r requirements.txt
```

**Or install uvicorn directly:**
```powershell
pip install uvicorn[standard] fastapi
```

### Step 4: Verify Installation

```powershell
pip list | Select-String uvicorn
# Should show: uvicorn
```

### Step 5: Try Again

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

---

## 🔍 Alternative: Use Python Module

If `uvicorn` command still doesn't work, use:

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

This always works because it uses Python's module system.

---

## ✅ Quick Fix (All in One)

```powershell
# 1. Make sure venv is activated
venv\Scripts\activate

# 2. Install uvicorn
pip install uvicorn[standard] fastapi

# 3. Start service using Python module (most reliable)
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

---

## 🎯 Recommended: Use Python Module

**Instead of:**
```powershell
uvicorn app.main:app --reload
```

**Use:**
```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**This always works!** ✅


