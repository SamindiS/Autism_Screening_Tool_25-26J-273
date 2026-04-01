# 🚀 How to Start and Test FastAPI Service

## ✅ Step-by-Step Guide

---

## Step 1: Verify Model Files

Check that model files are in place:

```powershell
# You're in ml_engine directory
ls models\
```

**Should see:**
- `asd_detection_model.pkl` (or `asd_screening_model_calibrated.pkl`)
- `feature_scaler.pkl`
- `feature_names.json`
- `age_norms.json` (optional)

---

## Step 2: Create Model Metadata (Quick)

```powershell
# Copy example file
Copy-Item models\model_metadata.json.example models\model_metadata.json
```

**Edit it later** with your model details (optional, but recommended).

---

## Step 3: Start FastAPI Service

### Make sure venv is activated

You should see `(venv)` in your prompt. If not:

```powershell
venv\Scripts\activate
```

### Start the service

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**What you'll see:**
```
INFO:     Will watch for changes in these directories: ['D:\\...\\ml_engine']
INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

**✅ Service is running!**

---

## Step 4: Test the Service

### Option A: Use Browser (Easiest)

1. **Open Swagger UI:**
   ```
   http://localhost:8001/docs
   ```

2. **Test Health:**
   - Click on `GET /health`
   - Click "Try it out"
   - Click "Execute"
   - See the response

3. **Test Prediction:**
   - Click on `POST /predict`
   - Click "Try it out"
   - Enter test data:
     ```json
     {
       "age_months": 48,
       "features": {
         "post_switch_accuracy": 65,
         "switch_cost_ms": 450,
         "perseverative_error_rate_post_switch": 35
       }
     }
     ```
   - Click "Execute"
   - See the prediction result!

### Option B: Use Test Script

**In a NEW terminal window** (keep service running in first terminal):

```powershell
cd senseai_backend\ml_engine
venv\Scripts\activate
python scripts/test_predict.py
```

### Option C: Use PowerShell Commands

**Test Health:**
```powershell
Invoke-WebRequest -Uri http://localhost:8001/health | Select-Object -ExpandProperty Content
```

**Test Prediction:**
```powershell
$body = @{
    age_months = 48
    features = @{
        post_switch_accuracy = 65
        switch_cost_ms = 450
        perseverative_error_rate_post_switch = 35
    }
} | ConvertTo-Json -Depth 10

Invoke-WebRequest -Uri http://localhost:8001/predict -Method POST -Body $body -ContentType "application/json" | Select-Object -ExpandProperty Content
```

---

## Step 5: Connect to Node.js Backend (Optional)

### Option A: Switch to FastAPI (Recommended for final project)

1. **Backup current route:**
   ```powershell
   cd ..
   Copy-Item routes\ml_predictions.js routes\ml_predictions_old.js
   ```

2. **Use FastAPI version:**
   ```powershell
   Copy-Item routes\ml_predictions_fastapi.js routes\ml_predictions.js
   ```

3. **Install axios:**
   ```powershell
   npm install axios
   ```

4. **Start backend:**
   ```powershell
   npm start
   ```

5. **Test from backend:**
   ```powershell
   Invoke-WebRequest -Uri http://localhost:3000/api/ml/health | Select-Object -ExpandProperty Content
   ```

### Option B: Keep Current System

Your current script-based system works fine! You can:
- Keep using it for now
- Switch to FastAPI later
- Or use both (test FastAPI, use script-based in production)

---

## 🎯 Quick Start Commands

**All in one go:**

```powershell
# 1. Activate venv (if not already)
venv\Scripts\activate

# 2. Start service
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**Then in browser:**
- Open: http://localhost:8001/docs
- Test endpoints!

---

## ✅ Success Indicators

**Service is working if:**
- ✅ You see "Uvicorn running on http://0.0.0.0:8001"
- ✅ Health endpoint returns `{"status": "OK", "models_loaded": true}`
- ✅ Prediction endpoint returns risk scores
- ✅ Swagger UI loads at `/docs`

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

# Copy from parent directory if missing
Copy-Item ..\models\*.pkl models\
Copy-Item ..\models\feature_names.json models\
```

### Port 8001 already in use

**Fix:**
```powershell
# Use different port
uvicorn app.main:app --reload --port 8002
```

---

## 📋 Checklist

- [x] Model files copied ✅
- [ ] Service started
- [ ] Health endpoint tested
- [ ] Prediction endpoint tested
- [ ] (Optional) Backend connected

---

**Ready to start? Run:**
```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

Then open http://localhost:8001/docs in your browser! 🚀


