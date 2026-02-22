# 📦 ML Model Files Directory

This directory contains the trained ML model files for ASD screening predictions.

---

## 📋 Required Files

### 1. Model File (Required)
- **File**: `asd_detection_model.pkl` OR `asd_screening_model_calibrated.pkl`
- **Description**: Trained and calibrated ML model (Logistic Regression)
- **Source**: Exported from Google Colab after training

### 2. Feature Scaler (Required)
- **File**: `feature_scaler.pkl`
- **Description**: StandardScaler used during training
- **Source**: Exported from Google Colab after training

### 3. Feature Names (Recommended)
- **File**: `feature_names.json`
- **Description**: List of feature names in training order
- **Source**: Generated from training notebook (Cell 13: `selected_features`)

---

## 🚀 How to Add Your Trained Model

### Step 1: Export from Colab

After training completes in Google Colab:

1. Run Cell 20 (Step 8: Save Model)
2. Files will download automatically:
   - `asd_screening_model_calibrated.pkl`
   - `feature_scaler.pkl`
   - `feature_names.json` (if generated)

### Step 2: Rename Model File

Rename the model file to match backend expectations:

**Option A:** Rename downloaded file:
- `asd_screening_model_calibrated.pkl` → `asd_detection_model.pkl`

**Option B:** Keep original name (backend supports both)

### Step 3: Copy to This Directory

Copy all files to:
```
senseai_backend/models/
```

**Final structure:**
```
models/
├── asd_detection_model.pkl      ← Your trained model
├── feature_scaler.pkl            ← Feature scaler
├── feature_names.json            ← Feature names (order)
└── README.md                     ← This file
```

### Step 4: Verify

```bash
cd senseai_backend
npm start
```

**Check logs for:**
```
✅ ML models loaded and ready
```

**OR test endpoint:**
```bash
curl http://localhost:3000/api/ml/health
```

---

## 🔍 File Details

### Model File (`asd_detection_model.pkl`)

- **Type**: Calibrated Logistic Regression
- **Training**: Google Colab notebook
- **Calibration**: Platt Scaling (sigmoid)
- **Purpose**: Predicts ASD risk from ML features

### Scaler File (`feature_scaler.pkl`)

- **Type**: StandardScaler from scikit-learn
- **Purpose**: Normalizes features to match training distribution
- **Critical**: Must use same scaler as training!

### Feature Names (`feature_names.json`)

- **Format**: JSON array of strings
- **Example**:
  ```json
  [
    "age_months",
    "post_switch_accuracy",
    "perseverative_error_rate_post_switch",
    "switch_cost_ms"
  ]
  ```
- **Purpose**: Ensures features are in correct order for prediction

---

## ⚠️ Important Notes

1. **Feature Order Matters**: Features must be in the same order as training
2. **Scaler Must Match**: Use the exact scaler from training
3. **Model Version**: Keep track of model versions (v1, v2, etc.)
4. **Backup**: Always keep backups of working models

---

## 🔄 Updating the Model

When you retrain with more data:

1. Train new model in Colab
2. Export new files
3. **Backup** current model files
4. Replace files in this directory
5. Restart backend
6. Test with `/api/ml/health`

---

## 🐛 Troubleshooting

### "Model not found" error

**Solution:**
- Check file names match exactly
- Check files are in `models/` directory (not parent)
- Verify file permissions (should be readable)

### "Feature mismatch" error

**Solution:**
- Ensure `feature_names.json` matches training features
- Check feature order is correct
- Verify all features from training are included

### Predictions seem wrong

**Solution:**
- Verify you're using the correct model version
- Check feature scaling is applied
- Ensure feature names match training

---

## 📞 Support

If models aren't working:
1. Check backend logs for errors
2. Test Python script directly:
   ```bash
   python ml_scripts/predict.py '{"features": {"age_months": 48}}'
   ```
3. Verify Python dependencies:
   ```bash
   pip install scikit-learn joblib numpy pandas
   ```

---

**Your model files go here!** 📦
