# 📦 How to Export and Save Your ML Model Files

## 🎯 Quick Answer

**Where to save:**
```
senseai_backend/models/
```

**Files needed:**
1. `asd_detection_model.pkl` (or `asd_screening_model_calibrated.pkl`)
2. `feature_scaler.pkl`
3. `feature_names.json` (optional but recommended)

---

## 📋 Step-by-Step Guide

### Step 1: Export from Google Colab

After training completes, the notebook automatically saves and downloads the files:

1. **Run Cell 20** (Step 8: Probability Calibration & Save Model)
   - This saves:
     - `asd_screening_model_calibrated.pkl`
     - `feature_scaler.pkl`
   - Files are automatically downloaded to your computer

2. **Check your Downloads folder:**
   - `asd_screening_model_calibrated.pkl`
   - `feature_scaler.pkl`

---

### Step 2: Rename Files (Important!)

The backend expects specific file names. Rename the downloaded files:

**Option A: Rename in Colab (Before Download)**

Add this cell after Cell 20:

```python
# Rename files to match backend expectations
import shutil

# Rename model file
shutil.move('asd_screening_model_calibrated.pkl', 'asd_detection_model.pkl')

# Scaler name is already correct
# feature_scaler.pkl stays the same

# Download with correct names
files.download('asd_detection_model.pkl')
files.download('feature_scaler.pkl')

print("✅ Files renamed and ready for backend!")
```

**Option B: Rename After Download (On Your Computer)**

1. Rename `asd_screening_model_calibrated.pkl` → `asd_detection_model.pkl`
2. Keep `feature_scaler.pkl` as is

---

### Step 3: Create Feature Names File (Recommended)

Create `feature_names.json` to ensure features are in the correct order:

**In Colab, add this cell:**

```python
# Save feature names for backend
import json

feature_names_data = {
    'feature_names': selected_features,
    'feature_count': len(selected_features),
    'model_type': 'Logistic Regression (Calibrated)',
    'training_date': pd.Timestamp.now().strftime('%Y-%m-%d'),
    'dataset_size': len(df),
    'asd_samples': int(y.sum()),
    'control_samples': int((y == 0).sum())
}

with open('feature_names.json', 'w') as f:
    json.dump(feature_names_data, f, indent=2)

files.download('feature_names.json')
print("✅ Feature names file created!")
```

---

### Step 4: Save Files to Backend

**Copy files to:**
```
senseai_backend/models/
```

**Final structure should be:**
```
senseai_backend/
├── models/
│   ├── asd_detection_model.pkl      ← Your trained model
│   ├── feature_scaler.pkl            ← Feature scaler
│   ├── feature_names.json             ← Feature names (optional)
│   └── README.md                      ← Already exists
├── ml_scripts/
│   └── predict.py                     ← Already exists
└── routes/
    └── ml_predictions.js              ← Already exists
```

---

## 🔧 Manual Method (If Download Doesn't Work)

### Method 1: Using Colab File Browser

1. In Colab, click the **folder icon** (📁) on the left sidebar
2. Navigate to the files:
   - `asd_screening_model_calibrated.pkl`
   - `feature_scaler.pkl`
3. Right-click each file → **Download**
4. Rename and move to `senseai_backend/models/`

### Method 2: Using Google Drive

1. Mount Google Drive in Colab:
```python
from google.colab import drive
drive.mount('/content/drive')
```

2. Copy files to Drive:
```python
import shutil

# Copy to Drive
shutil.copy('asd_screening_model_calibrated.pkl', '/content/drive/MyDrive/')
shutil.copy('feature_scaler.pkl', '/content/drive/MyDrive/')

print("✅ Files copied to Google Drive!")
```

3. Download from Google Drive to your computer
4. Move to `senseai_backend/models/`

---

## ✅ Verification

After saving files, verify they're in the right place:

**Check file locations:**
```bash
cd senseai_backend
ls models/
```

**Should see:**
- `asd_detection_model.pkl` (or `asd_screening_model_calibrated.pkl`)
- `feature_scaler.pkl`
- `feature_names.json` (if created)

**Test ML endpoint:**
```bash
# Start backend
npm start

# In another terminal, test ML health
curl http://localhost:3000/api/ml/health
```

**Expected response:**
```json
{
  "available": true,
  "model_path": ".../models/asd_detection_model.pkl",
  "scaler_path": ".../models/feature_scaler.pkl",
  "message": "ML models loaded and ready"
}
```

---

## 🐛 Troubleshooting

### Issue: "ML models not found"

**Solution:**
1. Check file names match exactly:
   - `asd_detection_model.pkl` (or backend will look for this)
   - `feature_scaler.pkl`
2. Check files are in `senseai_backend/models/` (not root directory)
3. Restart backend after adding files

### Issue: "File not found" error

**Solution:**
- Use absolute paths or ensure files are in `models/` directory
- Check file permissions (should be readable)

### Issue: Model predictions don't work

**Solution:**
1. Verify Python dependencies:
   ```bash
   pip install scikit-learn joblib numpy
   ```
2. Check `predict.py` can load the model:
   ```bash
   cd senseai_backend
   python ml_scripts/predict.py '{"features": {}, "age_group": "5-6"}'
   ```

---

## 📝 Quick Checklist

- [ ] Model trained in Colab
- [ ] Files downloaded from Colab
- [ ] Files renamed correctly:
  - [ ] `asd_screening_model_calibrated.pkl` → `asd_detection_model.pkl`
  - [ ] `feature_scaler.pkl` (keep as is)
- [ ] Files copied to `senseai_backend/models/`
- [ ] Feature names file created (optional but recommended)
- [ ] Backend restarted
- [ ] ML health check passed (`/api/ml/health`)

---

## 🎯 Alternative: Update Backend to Use Your File Names

If you prefer to keep `asd_screening_model_calibrated.pkl`, update the backend:

**Edit `senseai_backend/routes/ml_predictions.js`:**

Change line 9:
```javascript
const MODEL_PATH = path.join(MODEL_DIR, 'asd_screening_model_calibrated.pkl');
```

And update `senseai_backend/ml_scripts/predict.py` line 18:
```python
MODEL_PATH = MODEL_DIR / 'asd_screening_model_calibrated.pkl'
```

---

## 💡 Pro Tips

1. **Keep backups**: Save model files in a separate backup folder
2. **Version control**: Add model version to filename:
   - `asd_detection_model_v1.pkl`
   - `asd_detection_model_v2.pkl`
3. **Documentation**: Note the training date and dataset size in a README
4. **Test before deployment**: Always test predictions on known cases

---

## 📞 Need Help?

If files aren't working:
1. Check backend logs for error messages
2. Verify Python version (needs Python 3.6+)
3. Ensure all dependencies are installed
4. Check file paths are correct

**Your model is ready to use once files are in the right place!** 🚀

