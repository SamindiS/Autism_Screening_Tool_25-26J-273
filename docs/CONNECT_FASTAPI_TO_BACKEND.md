# 🔗 Connect FastAPI ML Engine to Backend & Frontend

## ✅ Step-by-Step Integration Guide

---

## 📊 Architecture Flow

```
Flutter App (Frontend)
    ↓ HTTP POST /api/ml/predict
Node.js Backend (Port 3000)
    ↓ HTTP POST http://localhost:8001/predict
FastAPI ML Engine (Port 8001)
    ↓ Returns prediction
Backend → Frontend
```

---

## ✅ Step 1: Install axios in Backend

**axios is needed to call FastAPI from Node.js:**

```powershell
cd senseai_backend
npm install axios
```

---

## ✅ Step 2: Switch to FastAPI Route

**Option A: Replace Current Route (Recommended)**

1. **Backup current route:**
   ```powershell
   Copy-Item routes\ml_predictions.js routes\ml_predictions_old.js
   ```

2. **Use FastAPI version:**
   ```powershell
   Copy-Item routes\ml_predictions_fastapi.js routes\ml_predictions.js
   ```

**Option B: Keep Both (Test First)**

Keep both files and test FastAPI version separately before switching.

---

## ✅ Step 3: Start Both Services

### Terminal 1: Start FastAPI ML Engine

```powershell
cd senseai_backend\ml_engine
venv\Scripts\activate
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**Keep this running!**

### Terminal 2: Start Node.js Backend

```powershell
cd senseai_backend
npm start
```

**You should see:**
```
✅ FastAPI ML Engine is available and models are loaded
```

---

## ✅ Step 4: Test the Connection

### Test 1: Backend Health Check

```powershell
Invoke-WebRequest -Uri http://localhost:3000/api/ml/health | Select-Object -ExpandProperty Content
```

**Should return:**
```json
{
  "available": true,
  "engine": "fastapi",
  "engine_url": "http://localhost:8001",
  "engine_status": {
    "models_loaded": true
  }
}
```

### Test 2: Backend Prediction

```powershell
$body = @{
    mlFeatures = @{
        age_months = 48
        post_switch_accuracy = 65
        switch_cost_ms = 450
        perseverative_error_rate_post_switch = 35
    }
    ageGroup = "4-5"
    sessionType = "color_shape"
} | ConvertTo-Json -Depth 10

Invoke-WebRequest -Uri http://localhost:3000/api/ml/predict -Method POST -Body $body -ContentType "application/json" | Select-Object -ExpandProperty Content
```

**Should return prediction with `"method": "ml"`**

---

## ✅ Step 5: Test from Flutter App

Your Flutter app already calls `/api/ml/predict` - it will automatically use FastAPI now!

**In your Flutter app:**
```dart
final result = await MLService.predict(
  mlFeatures: summary.mlFeatures,
  ageGroup: '5-6',
  sessionType: 'color_shape',
);
```

**This will now:**
1. Call Node.js backend
2. Backend calls FastAPI
3. FastAPI returns prediction
4. Backend returns to Flutter
5. Flutter displays result

---

## 🔍 Verify It's Working

### Check Backend Logs

When you make a prediction, you should see:
```
✅ FastAPI ML Engine is available and models are loaded
✅ ML Prediction: ASD Risk, Score: 78.9
```

### Check FastAPI Logs

You should see:
```
INFO: Prediction requested: age=48, child_id=N/A
INFO: Prediction complete: HIGH risk (score=78.9%, prob=0.789)
```

---

## 🐛 Troubleshooting

### "FastAPI ML Engine not available"

**Check:**
1. Is FastAPI running? (Terminal 1)
2. Is it on port 8001?
3. Can you access http://localhost:8001/health?

**Fix:**
```powershell
# Start FastAPI first
cd senseai_backend\ml_engine
python -m uvicorn app.main:app --reload --port 8001
```

### "axios is not defined"

**Fix:**
```powershell
cd senseai_backend
npm install axios
```

### Backend can't connect to FastAPI

**Check URL:**
- Default: `http://localhost:8001`
- If FastAPI is on different port, update `ML_ENGINE_URL` in route file

---

## ✅ Success Indicators

- ✅ Backend logs show "FastAPI ML Engine is available"
- ✅ `/api/ml/health` returns `"available": true`
- ✅ Predictions return `"method": "ml"`
- ✅ Flutter app gets ML predictions

---

## 📋 Quick Checklist

- [ ] axios installed (`npm install axios`)
- [ ] FastAPI route file copied (`routes/ml_predictions.js`)
- [ ] FastAPI service running (port 8001)
- [ ] Node.js backend running (port 3000)
- [ ] Backend health check works
- [ ] Backend prediction works
- [ ] Flutter app gets predictions

---

## 🎯 Right Now: Do These Steps

1. **Install axios:**
   ```powershell
   cd senseai_backend
   npm install axios
   ```

2. **Switch to FastAPI route:**
   ```powershell
   Copy-Item routes\ml_predictions.js routes\ml_predictions_old.js
   Copy-Item routes\ml_predictions_fastapi.js routes\ml_predictions.js
   ```

3. **Start FastAPI** (Terminal 1):
   ```powershell
   cd ml_engine
   python -m uvicorn app.main:app --reload --port 8001
   ```

4. **Start Backend** (Terminal 2):
   ```powershell
   cd senseai_backend
   npm start
   ```

5. **Test:**
   - http://localhost:3000/api/ml/health
   - Make prediction from Flutter app

---

**You're connecting everything together!** 🚀


