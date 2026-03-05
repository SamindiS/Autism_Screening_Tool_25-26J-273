# 🧠 SenseAI ML Engine

Professional FastAPI-based ML inference service for ASD screening predictions.

**Status:** ✅ Production-ready, research-grade, industry-standard

---

## 🎯 Features

- ✅ **Professional Structure**: Modular, scalable, maintainable
- ✅ **Auto-Generated API Docs**: Swagger UI at `/docs`
- ✅ **Structured Logging**: Audit trail for clinical use
- ✅ **Centralized Configuration**: Reproducible, no hard-coded paths
- ✅ **Model Metadata**: Transparency and versioning
- ✅ **Feature Validation**: Safe error handling
- ✅ **Child ID Tracking**: Ethics compliance
- ✅ **Age Normalization**: Z-score calculation from control norms

---

## 🚀 Quick Start

### 1. Setup Virtual Environment

```bash
cd senseai_backend/ml_engine
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

**⚠️ Important:** `venv/` is in `.gitignore` - do NOT commit it. Use `requirements.txt` instead.

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Place Model Files

Copy your trained model files to `models/`:

```
models/
├── asd_detection_model.pkl      (or asd_screening_model_calibrated.pkl)
├── feature_scaler.pkl
├── feature_names.json
└── age_norms.json               (optional, for age normalization)
```

### 4. Run Service

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

Service will be available at:
- **API**: http://localhost:8001
- **Docs**: http://localhost:8001/docs (Swagger UI)
- **ReDoc**: http://localhost:8001/redoc

---

## 📋 API Endpoints

### Health Check

```bash
GET /health
```

Returns service status and model availability.

### Prediction

```bash
POST /predict
```

**Request:**
```json
{
  "age_months": 48,
  "features": {
    "post_switch_accuracy": 65,
    "switch_cost_ms": 450,
    "perseverative_error_rate_post_switch": 35
  },
  "age_group": "4-5",
  "session_type": "color_shape"
}
```

**Response:**
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

## 🧪 Testing

### Test with curl

```bash
curl -X POST http://localhost:8001/predict \
  -H "Content-Type: application/json" \
  -d '{
    "age_months": 48,
    "features": {
      "post_switch_accuracy": 65,
      "switch_cost_ms": 450
    }
  }'
```

### Test with Python

```python
import requests

response = requests.post(
    "http://localhost:8001/predict",
    json={
        "age_months": 48,
        "features": {
            "post_switch_accuracy": 65,
            "switch_cost_ms": 450
        }
    }
)
print(response.json())
```

---

## 🔗 Integration with Node.js Backend

Update `senseai_backend/routes/ml_predictions.js`:

```javascript
const axios = require('axios');

const ML_ENGINE_URL = process.env.ML_ENGINE_URL || 'http://localhost:8001';

router.post('/predict', async (req, res) => {
  try {
    const { mlFeatures, ageGroup, sessionType } = req.body;
    
    // Call FastAPI service
    const response = await axios.post(`${ML_ENGINE_URL}/predict`, {
      age_months: mlFeatures.age_months || 36,
      features: mlFeatures,
      age_group: ageGroup,
      session_type: sessionType
    });
    
    res.json({
      success: true,
      ...response.data,
      method: 'ml'
    });
  } catch (err) {
    // Fallback to rule-based
    return res.json(fallbackPrediction(mlFeatures));
  }
});
```

---

## 📁 Project Structure

```
ml_engine/
├── app/
│   ├── main.py              # FastAPI app
│   ├── api/
│   │   ├── predict.py       # /predict endpoint
│   │   └── health.py        # /health endpoint
│   ├── ml/
│   │   ├── model_loader.py  # Load models
│   │   ├── preprocessing.py # Age normalization
│   │   └── predictor.py     # Prediction logic
│   └── schemas/
│       ├── request.py       # Request schemas
│       └── response.py      # Response schemas
├── models/                  # Model files go here
├── requirements.txt
└── README.md
```

---

## ✅ Features

- ✅ Professional FastAPI structure
- ✅ Auto-generated API documentation (Swagger)
- ✅ Type-safe with Pydantic schemas
- ✅ Age normalization support
- ✅ Error handling
- ✅ Health checks
- ✅ CORS enabled for backend integration

---

## 🚀 Production Deployment

For production, use a process manager:

```bash
# Using gunicorn with uvicorn workers
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8001
```

Or use Docker, systemd, or your preferred deployment method.

---

## 📝 Notes

- Models are loaded once at startup (cached)
- Age normalization is optional (works without age_norms.json)
- Feature count mismatch is handled automatically
- All errors return proper HTTP status codes
- Logs are saved to `logs/ml_engine.log`
- Model metadata is included in health check if available

---

## 🔍 Logging

Logs are automatically saved to:
```
ml_engine/logs/ml_engine.log
```

View logs:
```bash
tail -f logs/ml_engine.log  # Linux/Mac
Get-Content logs/ml_engine.log -Wait  # Windows PowerShell
```

---

## 📊 Model Metadata

Create `models/model_metadata.json` for transparency:

```bash
cp models/model_metadata.json.example models/model_metadata.json
# Edit with your model information
```

This will be included in health check responses.

---

## ✅ Professional Improvements

See `README_IMPROVEMENTS.md` for details on:
- Centralized configuration
- Structured logging
- Model metadata
- Feature validation
- Child ID tracking

---

**Your professional ML engine is ready!** 🎉

