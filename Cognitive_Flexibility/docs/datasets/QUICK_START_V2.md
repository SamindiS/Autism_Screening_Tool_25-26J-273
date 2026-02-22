# 🚀 Quick Start: Train Model v2 in Google Colab

## 📋 **BEFORE YOU START**

1. **Open Google Colab**: https://colab.research.google.com/
2. **Create new notebook**: File → New notebook
3. **Upload your dataset**: You'll do this in Cell 2

---

## 📝 **STEP-BY-STEP INSTRUCTIONS**

### **Option 1: Copy from Markdown Guide**
1. Open `ML_TRAINING/TRAIN_MODEL_V2_GOOGLE_COLAB.md`
2. Copy each cell code block
3. Paste into Colab cells
4. Run sequentially

### **Option 2: Copy from Python File**
1. Open `ML_TRAINING/COLAB_NOTEBOOK_V2.py`
2. Copy each `# CELL X:` section
3. Paste into separate Colab cells
4. Run sequentially

---

## ⚡ **QUICK COPY-PASTE VERSION**

### **Cell 1: Setup**
```python
!pip install pandas numpy scikit-learn joblib matplotlib seaborn -q
import pandas as pd
import numpy as np
import json
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
import matplotlib.pyplot as plt
import seaborn as sns
from google.colab import files
print("✅ Setup complete!")
```

### **Cell 2: Upload Dataset**
```python
uploaded = files.upload()
df = pd.read_csv('master_training_dataset.csv')
print(f"📊 Dataset loaded: {len(df)} rows")
print(f"Data sources: {df['data_source'].value_counts().to_dict()}")
print(f"Groups: {df['group'].value_counts().to_dict()}")
```

### **Cell 3-13: Continue from Full Guide**
👉 See `TRAIN_MODEL_V2_GOOGLE_COLAB.md` for complete cells

---

## ✅ **WHAT YOU'LL GET**

After running all cells, you'll download:
- ✅ `asd_detection_model_v2.pkl` - Trained model
- ✅ `feature_scaler_v2.pkl` - Feature scaler
- ✅ `feature_names_v2.json` - Feature list
- ✅ `label_encoder_v2.json` - Label mapping
- ✅ `model_training_summary_v2.json` - Training summary

---

## 🔄 **AFTER TRAINING: UPDATE YOUR SYSTEM**

### **Step 1: Replace Old Model Files**

Copy downloaded files to:
```
senseai_backend/models/
  ├── asd_detection_model.pkl → Replace with v2
  ├── feature_scaler.pkl → Replace with v2
  └── feature_names.json → Replace with v2
```

### **Step 2: Update ML Engine (if needed)**

Check if your ML engine needs updates:
- Feature count matches?
- Feature names match?
- Label encoding matches?

### **Step 3: Test New Model**

```bash
# Test prediction with new model
cd senseai_backend
python test_predict.py
```

---

## 📊 **KEY IMPROVEMENTS IN V2**

| Feature | v1 | v2 |
|---------|----|----|
| Dataset size | ~53 samples | Real + Synthetic |
| Sample weighting | ❌ | ✅ Real=1.0, Synth=0.3 |
| Validation set | ❌ | ✅ |
| Test on real only | ❌ | ✅ |
| Reproducible | Partial | ✅ Full |

---

## 🎯 **WHAT TO REPORT**

**In your thesis, report:**
- Test set accuracy (real data only)
- Test set ROC-AUC (real data only)
- Confusion matrix (test set)
- Feature importance (top 10)

**Do NOT report:**
- Validation set results (internal only)
- Training set results (overfitted)
- Synthetic data test results (not real)

---

## ⚠️ **TROUBLESHOOTING**

### **Error: "Feature not found"**
- Check which features exist in your dataset
- Cell 4 will show available vs missing features
- Adjust `FEATURE_COLUMNS` list if needed

### **Error: "Too many missing values"**
- Cell 5 fills missing values with median
- Check if too many features are missing
- Consider removing features with >50% missing

### **Error: "Class imbalance too severe"**
- Model uses `class_weight='balanced'` to handle this
- Check class distribution in Cell 5
- If still issues, adjust sample weights

---

## 📞 **NEED HELP?**

1. Check the full guide: `TRAIN_MODEL_V2_GOOGLE_COLAB.md`
2. Review dataset structure in Cell 2 output
3. Check feature availability in Cell 4 output

---

**Last Updated:** 2025-01-XX

