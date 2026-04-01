# ⚡ Quick Start Guide

## ✅ You're Ready! Here's What to Do:

---

## 🚀 Step 1: Start the Service

**Make sure you're in `ml_engine` directory and venv is activated:**

```powershell
# Check you're in right place
pwd
# Should show: ...\senseai_backend\ml_engine

# Check venv is activated (should see (venv) in prompt)
# If not, run:
venv\Scripts\activate

# Start the service
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**You'll see:**
```
INFO:     Uvicorn running on http://0.0.0.0:8001
INFO:     Application startup complete.
```

**✅ Service is running!**

---

## 🧪 Step 2: Test It

### Easiest Way: Use Browser

1. **Open Swagger UI:**
   ```
   http://localhost:8001/docs
   ```

2. **Test Health:**
   - Click `GET /health`
   - Click "Try it out"
   - Click "Execute"
   - Should see: `{"status": "OK", "models_loaded": true}`

3. **Test Prediction:**
   - Click `POST /predict`
   - Click "Try it out"
   - Paste this in the request body:
     ```json
     {
       "age_months": 48,
       "features": {
         "post_switch_accuracy": 65,
         "switch_cost_ms": 450,
         "perseverative_error_rate_post_switch": 35,
         "commission_error_rate": 28,
         "rt_variability": 280
       }
     }
     ```
   - Click "Execute"
   - Should see prediction result!

---

## 📊 What You Should See

### Health Check Response:
```json
{
  "status": "OK",
  "service": "SenseAI ML Engine",
  "models_loaded": true,
  "expected_features": 18,
  "age_norms_available": false
}
```

### Prediction Response:
```json
{
  "prediction": 1,
  "probability": [0.21, 0.79],
  "confidence": 0.79,
  "risk_level": "high",
  "risk_score": 78.9,
  "asd_probability": 0.789
}
```

---

## 🔗 Step 3: Connect Backend (Optional)

Once FastAPI is working, connect your Node.js backend:

```powershell
# In a NEW terminal
cd senseai_backend

# Backup current route
Copy-Item routes\ml_predictions.js routes\ml_predictions_old.js

# Use FastAPI version
Copy-Item routes\ml_predictions_fastapi.js routes\ml_predictions.js

# Install axios
npm install axios

# Start backend
npm start
```

**Test from backend:**
```powershell
Invoke-WebRequest -Uri http://localhost:3000/api/ml/health
```

---

## ✅ Success Checklist

- [x] Model files copied ✅
- [x] Dependencies installed ✅
- [ ] Service started (`uvicorn app.main:app --reload --port 8001`)
- [ ] Health endpoint works (http://localhost:8001/health)
- [ ] Prediction endpoint works (http://localhost:8001/docs)
- [ ] (Optional) Backend connected

---

## 🎯 Right Now: Start the Service!

**Run this command:**

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**Then open:** http://localhost:8001/docs

**That's it!** 🚀


