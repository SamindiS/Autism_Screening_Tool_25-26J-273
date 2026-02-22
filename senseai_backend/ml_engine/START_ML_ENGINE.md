# 🚀 How to Start ML Engine (Quick Guide)

## Step 1: Open a NEW Terminal Window

**Keep your Node.js backend running in the first terminal.**

Open a **second terminal window** for the ML engine.

---

## Step 2: Navigate to ML Engine Directory

```powershell
cd D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273\senseai_backend\ml_engine
```

---

## Step 3: Activate Virtual Environment

```powershell
venv\Scripts\activate
```

**You should see `(venv)` in your prompt.**

---

## Step 4: Start the ML Engine

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
```

**What you'll see:**
```
INFO:     Will watch for changes in these directories: ['D:\\...\\ml_engine']
INFO:     Uvicorn running on http://0.0.0.0:8002 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
[OK] ML Engine ready
Age-specific models: 3/3 ready
```

**✅ Service is running!**

---

## Step 5: Verify It's Working

**In your browser, open:**
```
http://localhost:8002/docs
```

**Or test health endpoint:**
```powershell
Invoke-WebRequest -Uri http://localhost:8002/health -UseBasicParsing | Select-Object -ExpandProperty Content
```

**Expected response:**
```json
{
  "status": "OK",
  "age_specific_models": {
    "2-3.5": {"ready": true, ...},
    "3.5-5.5": {"ready": true, ...},
    "5.5-6.9": {"ready": true, ...}
  }
}
```

---

## ✅ Success Indicators

- ✅ You see "Uvicorn running on http://0.0.0.0:8002"
- ✅ You see "[OK] ML Engine ready"
- ✅ You see "Age-specific models: 3/3 ready"
- ✅ Health endpoint returns status "OK"
- ✅ Your Node.js backend stops showing "FastAPI ML Engine not available"

---

## 🐛 Troubleshooting

### "Module not found" error

**Fix:**
```powershell
# Make sure venv is activated
venv\Scripts\activate

# Reinstall dependencies
pip install -r requirements.txt
```

### "Models not found" error

**Fix:**
```powershell
# Check files are in models/ directory
ls models\

# Should see:
# - model_age_2_3_5_questionnaire.pkl
# - model_age_3_5_5_5_frog_jump.pkl
# - model_age_5_5_6_9_color_shape.pkl
# - scaler_age_2_3_5_questionnaire.pkl
# - scaler_age_3_5_5_5_frog_jump.pkl
# - scaler_age_5_5_6_9_color_shape.pkl
# - features_age_2_3_5_questionnaire.json
# - features_age_3_5_5_5_frog_jump.json
# - features_age_5_5_6_9_color_shape.json
```

### Port 8002 already in use

**Fix:**
```powershell
# Find what's using port 8002
netstat -ano | findstr :8002

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or use a different port (then update backend config)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8003
```

---

## 📋 Quick Command (All in One)

```powershell
cd D:\Desktop\FLUTTERAUTISM\Autism_Screening_Tool_25-26J-273\senseai_backend\ml_engine; venv\Scripts\activate; uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
```

---

**Once the ML engine is running, your Node.js backend should automatically connect to it!**
