# 🚀 Start Command

## ✅ Uvicorn is Now Installed!

All dependencies are installed in your venv. Now start the service:

---

## 🎯 Start the Service

**Make sure venv is activated** (you should see `(venv)` in prompt):

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**OR use the venv Python directly:**

```powershell
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

---

## ✅ What You'll See

```
INFO:     Will watch for changes in these directories: ['D:\\...\\ml_engine']
INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
2026-01-02 12:00:00 | senseai-ml | INFO | ==================================================
2026-01-02 12:00:00 | senseai-ml | INFO | Starting SenseAI ASD ML Engine v1.0.0
2026-01-02 12:00:00 | senseai-ml | INFO | ==================================================
2026-01-02 12:00:00 | senseai-ml | INFO | Loading ML models...
2026-01-02 12:00:00 | senseai-ml | INFO | Model loaded from: asd_detection_model.pkl
2026-01-02 12:00:00 | senseai-ml | INFO | Scaler loaded: feature_scaler.pkl (expects 18 features)
2026-01-02 12:00:00 | senseai-ml | INFO | ✅ All models loaded successfully
2026-01-02 12:00:00 | senseai-ml | INFO | ✅ ML Engine ready
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
```

---

## 🧪 Test It

Once you see "Application startup complete", open:

**Swagger UI (Interactive API Docs):**
```
http://localhost:8001/docs
```

**Health Check:**
```
http://localhost:8001/health
```

---

## 🎉 You're Ready!

Run the start command and open the Swagger UI to test! 🚀

