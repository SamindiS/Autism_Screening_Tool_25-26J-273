# Quick Start: ML Engine (Port 8002)

## ✅ Status
- Unicode encoding fixed ✅
- Age-specific models detected (2/3 ready) ✅
- Port changed to 8002 to avoid conflict ✅

## 🚀 Start the ML Engine

```powershell
cd senseai_backend/ml_engine
python -m uvicorn app.main:app --host 0.0.0.0 --port 8002
```

## 📝 Update Backend Configuration

If your backend is configured to call port 8001, update it to use port 8002:

**File:** `senseai_backend/.env` or wherever ML engine URL is configured
```env
ML_ENGINE_URL=http://localhost:8002
```

Or in your backend code:
```javascript
const ML_ENGINE_URL = process.env.ML_ENGINE_URL || 'http://localhost:8002';
```

## ✅ Verify It's Working

1. **Check health endpoint:**
   ```
   http://localhost:8002/health
   ```

2. **Check API docs:**
   ```
   http://localhost:8002/docs
   ```

3. **Expected startup output:**
   ```
   [OK] All models loaded successfully
   [OK] ML Engine ready
   Age-specific models: 2/3 ready
   ```

## 🎯 Available Models

- ✅ Age 2-3.5 (Questionnaire) - Ready
- ✅ Age 3.5-5.5 (Frog Jump) - Ready  
- ⚠️ Age 5.5-6.9 (Color-Shape) - Not trained yet

## 🔧 To Free Port 8001 Later

If you want to use port 8001 again:

1. Restart your computer (clears all port bindings)
2. Or find and kill the process:
   ```powershell
   Get-NetTCPConnection -LocalPort 8001 | Select-Object OwningProcess
   Stop-Process -Id <PID> -Force
   ```

For now, port 8002 works perfectly! 🎉
