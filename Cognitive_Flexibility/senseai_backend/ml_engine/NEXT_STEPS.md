# 🚀 Next Steps After Installation

## ✅ Step 1: Copy Model Files

Copy your trained model files to `ml_engine/models/`:

### Option A: Copy from existing models directory

```powershell
# From ml_engine directory
Copy-Item ..\models\*.pkl models\
Copy-Item ..\models\feature_names.json models\
Copy-Item ..\models\age_norms.json models\ -ErrorAction SilentlyContinue
```

### Option B: Manual copy

Copy these files to `senseai_backend/ml_engine/models/`:
- `asd_detection_model.pkl` (or `asd_screening_model_calibrated.pkl`)
- `feature_scaler.pkl`
- `feature_names.json`
- `age_norms.json` (optional)

**Verify files are there:**
```powershell
ls models\
```

---

## ✅ Step 2: Create Model Metadata (Optional but Recommended)

```powershell
Copy-Item models\model_metadata.json.example models\model_metadata.json
```

Then edit `models/model_metadata.json` with your model information.

---

## ✅ Step 3: Start FastAPI Service

```powershell
# Make sure venv is activated (you should see (venv) in prompt)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**You should see:**
```
INFO:     Uvicorn running on http://0.0.0.0:8001
INFO:     Application startup complete.
```

---

## ✅ Step 4: Test the Service

### Test Health Endpoint

Open in browser or use curl:
```
http://localhost:8001/health
```

**Or use PowerShell:**
```powershell
Invoke-WebRequest -Uri http://localhost:8001/health | Select-Object -ExpandProperty Content
```

### Test Prediction

**Option A: Use test script**
```powershell
python scripts/test_predict.py
```

**Option B: Use Swagger UI**
Open in browser:
```
http://localhost:8001/docs
```

Click on `/predict` → Try it out → Enter test data → Execute

**Option C: Use curl**
```powershell
$body = @{
    age_months = 48
    features = @{
        post_switch_accuracy = 65
        switch_cost_ms = 450
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:8001/predict -Method POST -Body $body -ContentType "application/json" | Select-Object -ExpandProperty Content
```

---

## ✅ Step 5: Connect to Node.js Backend (Optional)

Once FastAPI is working, you can connect your Node.js backend:

### Update Backend Route

**Option A: Use the new FastAPI route**

1. Backup current route:
   ```powershell
   Copy-Item ..\routes\ml_predictions.js ..\routes\ml_predictions_old.js
   ```

2. Use FastAPI version:
   ```powershell
   Copy-Item ..\routes\ml_predictions_fastapi.js ..\routes\ml_predictions.js
   ```

3. Install axios (if not already):
   ```powershell
   cd ..
   npm install axios
   ```

4. Start backend:
   ```powershell
   npm start
   ```

**Option B: Keep current script-based approach**

Your current system works fine! You can keep using it and switch to FastAPI later.

---

## ✅ Step 6: Test End-to-End

1. **Start FastAPI** (Terminal 1):
   ```powershell
   cd senseai_backend\ml_engine
   venv\Scripts\activate
   uvicorn app.main:app --reload --port 8001
   ```

2. **Start Node.js Backend** (Terminal 2):
   ```powershell
   cd senseai_backend
   npm start
   ```

3. **Test from backend:**
   ```powershell
   Invoke-WebRequest -Uri http://localhost:3000/api/ml/health | Select-Object -ExpandProperty Content
   ```

---

## 📋 Quick Checklist

- [x] Dependencies installed ✅
- [ ] Model files copied to `models/`
- [ ] FastAPI service starts successfully
- [ ] Health endpoint works (`/health`)
- [ ] Prediction endpoint works (`/predict`)
- [ ] (Optional) Backend connected
- [ ] (Optional) End-to-end tested

---

## 🎯 What to Do Right Now

**Immediate next step:**

1. **Copy model files:**
   ```powershell
   Copy-Item ..\models\*.pkl models\
   Copy-Item ..\models\feature_names.json models\
   ```

2. **Start service:**
   ```powershell
   uvicorn app.main:app --reload --port 8001
   ```

3. **Test it:**
   - Open http://localhost:8001/docs
   - Try the `/health` endpoint
   - Try the `/predict` endpoint

---

## 🎉 You're Almost There!

Once the service starts and you can test predictions, your professional ML engine is ready! 🚀

