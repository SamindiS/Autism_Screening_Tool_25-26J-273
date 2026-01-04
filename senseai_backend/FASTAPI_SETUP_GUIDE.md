# 🚀 FastAPI ML Engine Setup Guide

## ✅ Complete FastAPI Structure Created!

I've created a professional FastAPI ML Engine structure for you. Here's how to set it up:

---

## 📋 Step 1: Setup Virtual Environment

```bash
cd senseai_backend/ml_engine
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac  
source venv/bin/activate
```

---

## 📦 Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

---

## 📁 Step 3: Copy Model Files

Copy your trained model files to `ml_engine/models/`:

```bash
# From your Colab downloads or existing models directory
cp ../models/asd_detection_model.pkl models/
cp ../models/feature_scaler.pkl models/
cp ../models/feature_names.json models/
cp ../models/age_norms.json models/  # Optional
```

**Or create symlinks (Windows):**
```powershell
# In ml_engine directory
New-Item -ItemType SymbolicLink -Path "models\asd_detection_model.pkl" -Target "..\models\asd_detection_model.pkl"
New-Item -ItemType SymbolicLink -Path "models\feature_scaler.pkl" -Target "..\models\feature_scaler.pkl"
New-Item -ItemType SymbolicLink -Path "models\feature_names.json" -Target "..\models\feature_names.json"
```

---

## 🚀 Step 4: Start FastAPI Service

```bash
# In ml_engine directory with venv activated
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**Service will be available at:**
- **API**: http://localhost:8001
- **Swagger Docs**: http://localhost:8001/docs
- **ReDoc**: http://localhost:8001/redoc

---

## 🧪 Step 5: Test the Service

### Test Health Endpoint

```bash
curl http://localhost:8001/health
```

### Test Prediction

```bash
curl -X POST http://localhost:8001/predict \
  -H "Content-Type: application/json" \
  -d @data/sample_input.json
```

**Or use the test script:**

```bash
python scripts/test_predict.py
```

---

## 🔗 Step 6: Connect to Node.js Backend

### Option A: Update Existing Route

Update `senseai_backend/routes/ml_predictions.js` to use FastAPI:

```javascript
const axios = require('axios');
const ML_ENGINE_URL = process.env.ML_ENGINE_URL || 'http://localhost:8001';

// In the /predict route, replace spawn() with:
const response = await axios.post(`${ML_ENGINE_URL}/predict`, {
  age_months: mlFeatures.age_months || 36,
  features: mlFeatures,
  age_group: ageGroup,
  session_type: sessionType
});
```

### Option B: Use New Route File

I've created `routes/ml_predictions_fastapi.js` - you can:

1. **Backup current file:**
   ```bash
   mv routes/ml_predictions.js routes/ml_predictions_old.js
   ```

2. **Use FastAPI version:**
   ```bash
   mv routes/ml_predictions_fastapi.js routes/ml_predictions.js
   ```

3. **Install axios (if not already):**
   ```bash
   npm install axios
   ```

---

## ✅ Step 7: Verify Integration

1. **Start FastAPI service:**
   ```bash
   cd ml_engine
   uvicorn app.main:app --reload --port 8001
   ```

2. **Start Node.js backend:**
   ```bash
   cd senseai_backend
   npm start
   ```

3. **Test from backend:**
   ```bash
   curl http://localhost:3000/api/ml/health
   ```

---

## 📊 Features

✅ **Professional Structure**
- Clean separation of concerns
- Modular design
- Easy to extend

✅ **Auto-Generated API Docs**
- Swagger UI at `/docs`
- ReDoc at `/redoc`
- Interactive testing

✅ **Type Safety**
- Pydantic schemas
- Request/response validation
- Clear error messages

✅ **Production Ready**
- Error handling
- Health checks
- CORS enabled
- Scalable architecture

---

## 🎯 Benefits Over Script-Based Approach

| Feature | Script | FastAPI |
|---------|--------|---------|
| API Documentation | ❌ | ✅ Auto-generated |
| Scalability | Limited | Better |
| Testing | Harder | Easy (HTTP) |
| Monitoring | Basic | Better |
| Professional | Good | Excellent |
| **Your Use Case** | ✅ Works | ✅ **Better for final project** |

---

## 🚀 Production Deployment

For production, use a process manager:

```bash
# Using gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8001
```

Or use Docker, systemd, or cloud services.

---

## 📝 Environment Variables

Create `.env` file (optional):

```env
ML_ENGINE_URL=http://localhost:8001
MODEL_DIR=models
```

---

## ✅ Checklist

- [ ] Virtual environment created and activated
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Model files copied to `models/` directory
- [ ] FastAPI service starts successfully
- [ ] Health endpoint works (`/health`)
- [ ] Prediction endpoint works (`/predict`)
- [ ] Node.js backend updated to use FastAPI
- [ ] Integration tested end-to-end

---

## 🎉 You're Ready!

Your professional FastAPI ML Engine is set up and ready to use!

**Next steps:**
1. Test the service independently
2. Connect to your Node.js backend
3. Test end-to-end from Flutter app
4. Deploy for production when ready

**This structure is perfect for your final project!** ✅

