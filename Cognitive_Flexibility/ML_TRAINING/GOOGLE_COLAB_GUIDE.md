# 🚀 Google Colab Training Guide

## 📋 Overview

This guide shows you how to run the complete ML training pipeline on **Google Colab** (free GPU/CPU access).

---

## 🎯 Step-by-Step Setup

### **Step 1: Open Google Colab**

1. Go to: https://colab.research.google.com/
2. Click **"New Notebook"**
3. Rename notebook: `Autism_Screening_ML_Training.ipynb`

---

### **Step 2: Upload Project Files**

#### **Option A: Upload via Colab UI (Recommended)**

```python
# Run this cell first to upload files
from google.colab import files
import zipfile
import os

# Upload your project folder as ZIP
print("Please upload your project ZIP file:")
uploaded = files.upload()

# Extract ZIP file
for filename in uploaded.keys():
    if filename.endswith('.zip'):
        with zipfile.ZipFile(filename, 'r') as zip_ref:
            zip_ref.extractall('/content/')
        print(f"✅ Extracted {filename}")
```

**What to upload:**
- Create a ZIP file of your `ML_TRAINING` folder
- Include: `config.py`, `utils/`, `preprocessing/`, `training/`
- Include: `Online Datasets/` folder (or upload separately)

#### **Option B: Clone from GitHub (If you have repo)**

```python
# If your project is on GitHub
!git clone https://github.com/your-username/your-repo.git
%cd your-repo
```

#### **Option C: Mount Google Drive**

```python
from google.colab import drive
drive.mount('/content/drive')

# Copy files from Drive
!cp -r /content/drive/MyDrive/YourProject/ML_TRAINING /content/
!cp -r /content/drive/MyDrive/YourProject/Online\ Datasets /content/
```

---

### **Step 3: Install Dependencies**

```python
# Install required packages
!pip install pandas numpy scikit-learn matplotlib seaborn scipy joblib -q
!pip install imbalanced-learn -q  # For SMOTE augmentation

print("✅ All packages installed!")
```

---

### **Step 4: Set Up Directory Structure**

```python
import os
from pathlib import Path

# Create necessary directories
os.makedirs('/content/SAMPLE_DATASETS/prepared', exist_ok=True)
os.makedirs('/content/ML_TRAINING/models', exist_ok=True)
os.makedirs('/content/ML_TRAINING/output', exist_ok=True)

# Change to project directory
%cd /content/ML_TRAINING

print("✅ Directory structure created!")
```

---

### **Step 5: Verify Files**

```python
# Check if all files are present
import os

required_files = [
    'config.py',
    'utils/feature_engineering.py',
    'utils/outlier_detection.py',
    'utils/data_augmentation.py',
    'utils/preprocessing.py',
    'utils/evaluation.py',
    'preprocessing/prepare_age_2_3_5_data.py',
    'training/train_age_2_3_5_model.py'
]

print("Checking required files...")
for file in required_files:
    if os.path.exists(file):
        print(f"✅ {file}")
    else:
        print(f"❌ {file} - MISSING!")
```

---

## 🚀 Running the Training Pipeline

### **For Age 2-3.5 Model:**

#### **Step 1: Prepare Datasets**

```python
# Prepare training and test datasets
!python preprocessing/prepare_age_2_3_5_data.py
```

**Expected Output:**
```
[PREP] Preparing Training Data for Age 2-3.5...
============================================================

1. Loading: Toddler Autism Dataset (July 2018)...
   Filtered: 768 samples (age 24-42 months)
   Extracted features: 768 samples

2. Loading: Autism Screening Data Combined...
   Filtered: 1546 samples (age 24-42 months)
   Extracted features: 1546 samples

[OK] Combined training data: 2314 samples
   - ASD: 1500
   - Control: 814

[PREP] Preparing Test Data from Hospital Data...
[OK] Combined test data: 40 samples
   - ASD: 30
   - Control: 10

[OK] Dataset preparation complete!
```

#### **Step 2: Train Model**

```python
# Train the model
!python training/train_age_2_3_5_model.py
```

**Expected Output:**
```
============================================================
TRAINING AGE 2-3.5 QUESTIONNAIRE MODEL
============================================================

[LOAD] Loading datasets...
   Training: 2314 samples
   Test: 40 samples

[PREPROCESS] Preprocessing data...
[OUTLIER] Detecting and handling outliers...
   [OK] Outliers winsorized

[AUGMENT] Augmenting training data...
   [OK] Augmented: 2000 samples (from 2314)

[TRAIN] Training models...

   Training Logistic Regression...
   [OK] LR - Train Accuracy: 0.875
   [OK] LR - Test Accuracy: 0.825

   Training Random Forest...
   [OK] RF - Train Accuracy: 0.890
   [OK] RF - Test Accuracy: 0.800

[SAVE] Saving logistic_regression...
   [OK] Model saved: models/model_age_2_3_5_questionnaire.pkl
   [OK] Scaler saved: models/scaler_model_age_2_3_5_questionnaire.pkl
   [OK] Features saved: models/features_model_age_2_3_5_questionnaire.json
   [OK] Metadata saved: models/model_metadata_model_age_2_3_5_questionnaire.json

[OK] Training complete!
```

---

### **For Age 3.5-5.5 Model:**

```python
# Prepare datasets
!python preprocessing/prepare_age_3_5_5_5_data.py

# Train model
!python training/train_age_3_5_5_5_model.py
```

---

### **For Age 5.5-6.9 Model:**

```python
# Prepare datasets
!python preprocessing/prepare_age_5_5_6_9_data.py

# Train model
!python training/train_age_5_5_6_9_model.py
```

---

## 📥 Download Results

### **Download Model Files**

```python
from google.colab import files
import zipfile
import os

# Create ZIP of model files
model_files = [
    'models/model_age_2_3_5_questionnaire.pkl',
    'models/scaler_model_age_2_3_5_questionnaire.pkl',
    'models/features_model_age_2_3_5_questionnaire.json',
    'models/model_metadata_model_age_2_3_5_questionnaire.json'
]

# Create ZIP
with zipfile.ZipFile('trained_models.zip', 'w') as zipf:
    for file in model_files:
        if os.path.exists(file):
            zipf.write(file)
            print(f"✅ Added {file}")

# Download
files.download('trained_models.zip')
print("✅ Model files downloaded!")
```

### **Download Results**

```python
# Download training results
if os.path.exists('output/training_results_model_age_2_3_5_questionnaire.json'):
    files.download('output/training_results_model_age_2_3_5_questionnaire.json')
    print("✅ Results downloaded!")
```

---

## 🔧 Complete Colab Notebook Template

Here's a complete notebook you can copy-paste:

```python
# ============================================================================
# CELL 1: Setup and Install
# ============================================================================
!pip install pandas numpy scikit-learn matplotlib seaborn scipy joblib -q
!pip install imbalanced-learn -q
print("✅ Packages installed!")

# ============================================================================
# CELL 2: Upload Project Files
# ============================================================================
from google.colab import files
import zipfile
import os

print("📤 Please upload your ML_TRAINING folder as ZIP:")
uploaded = files.upload()

for filename in uploaded.keys():
    if filename.endswith('.zip'):
        with zipfile.ZipFile(filename, 'r') as zip_ref:
            zip_ref.extractall('/content/')
        print(f"✅ Extracted {filename}")

# ============================================================================
# CELL 3: Upload Datasets
# ============================================================================
print("📤 Please upload your Online Datasets folder as ZIP:")
datasets = files.upload()

for filename in datasets.keys():
    if filename.endswith('.zip'):
        with zipfile.ZipFile(filename, 'r') as zip_ref:
            zip_ref.extractall('/content/')
        print(f"✅ Extracted {filename}")

# ============================================================================
# CELL 4: Setup Directories
# ============================================================================
os.makedirs('/content/SAMPLE_DATASETS/prepared', exist_ok=True)
os.makedirs('/content/ML_TRAINING/models', exist_ok=True)
os.makedirs('/content/ML_TRAINING/output', exist_ok=True)

%cd /content/ML_TRAINING
print("✅ Setup complete!")

# ============================================================================
# CELL 5: Prepare Age 2-3.5 Dataset
# ============================================================================
!python preprocessing/prepare_age_2_3_5_data.py

# ============================================================================
# CELL 6: Train Age 2-3.5 Model
# ============================================================================
!python training/train_age_2_3_5_model.py

# ============================================================================
# CELL 7: Download Results
# ============================================================================
from google.colab import files
import zipfile

# Create ZIP of all model files
with zipfile.ZipFile('trained_models.zip', 'w') as zipf:
    for root, dirs, files_list in os.walk('models'):
        for file in files_list:
            file_path = os.path.join(root, file)
            zipf.write(file_path)
            print(f"✅ Added {file_path}")

files.download('trained_models.zip')
print("✅ All model files downloaded!")
```

---

## 🎯 Quick Start (Copy-Paste Ready)

### **Complete Notebook:**

```python
# ============================================
# AUTISM SCREENING ML TRAINING - GOOGLE COLAB
# ============================================

# Step 1: Install packages
!pip install pandas numpy scikit-learn matplotlib seaborn scipy joblib imbalanced-learn -q

# Step 2: Setup
import os
os.makedirs('/content/SAMPLE_DATASETS/prepared', exist_ok=True)
os.makedirs('/content/ML_TRAINING/models', exist_ok=True)
os.makedirs('/content/ML_TRAINING/output', exist_ok=True)

# Step 3: Upload files (run this cell, then upload ZIP files)
from google.colab import files
import zipfile

print("📤 Upload ML_TRAINING folder as ZIP:")
ml_training = files.upload()

print("📤 Upload Online Datasets folder as ZIP:")
datasets = files.upload()

# Extract
for f in list(ml_training.keys()) + list(datasets.keys()):
    if f.endswith('.zip'):
        with zipfile.ZipFile(f, 'r') as z:
            z.extractall('/content/')
        print(f"✅ Extracted {f}")

# Step 4: Change directory
%cd /content/ML_TRAINING

# Step 5: Prepare datasets
!python preprocessing/prepare_age_2_3_5_data.py

# Step 6: Train model
!python training/train_age_2_3_5_model.py

# Step 7: Download results
import zipfile
with zipfile.ZipFile('models.zip', 'w') as z:
    for root, dirs, files_list in os.walk('models'):
        for file in files_list:
            z.write(os.path.join(root, file))

files.download('models.zip')
print("✅ Done! Models downloaded.")
```

---

## ⚠️ Important Notes

### **1. File Paths**
- Colab uses `/content/` as root directory
- Update paths in `config.py` if needed:
  ```python
  BASE_DIR = Path("/content/ML_TRAINING")
  ONLINE_DATASETS_DIR = Path("/content/Online Datasets")
  ```

### **2. Dataset Upload**
- Upload `Online Datasets/` folder as ZIP
- Or upload individual CSV files
- Place in `/content/Online Datasets/`

### **3. Session Timeout**
- Colab sessions timeout after ~90 minutes of inactivity
- Save your work frequently
- Download models immediately after training

### **4. GPU/CPU**
- Colab provides free GPU/CPU
- ML training works on CPU (default)
- GPU not required for these models

---

## 🔍 Troubleshooting

### **Issue: "FileNotFoundError"**

**Solution:**
```python
# Check current directory
import os
print("Current directory:", os.getcwd())

# List files
print("\nFiles in current directory:")
print(os.listdir('.'))

# Check if datasets exist
print("\nChecking datasets:")
print(os.path.exists('/content/Online Datasets/Toddler Autism dataset July 2018.csv'))
```

### **Issue: "ModuleNotFoundError"**

**Solution:**
```python
# Reinstall packages
!pip install --upgrade pandas numpy scikit-learn matplotlib seaborn scipy joblib imbalanced-learn
```

### **Issue: "Path not found"**

**Solution:**
```python
# Update config.py paths
import sys
sys.path.append('/content/ML_TRAINING')

# Or modify config.py directly
from pathlib import Path
BASE_DIR = Path("/content/ML_TRAINING")
```

---

## ✅ Checklist

Before running:
- [ ] Uploaded `ML_TRAINING` folder
- [ ] Uploaded `Online Datasets` folder
- [ ] Installed all packages
- [ ] Created directories
- [ ] Changed to correct directory

After training:
- [ ] Downloaded model files (.pkl)
- [ ] Downloaded scaler files (.pkl)
- [ ] Downloaded feature lists (.json)
- [ ] Downloaded metadata (.json)
- [ ] Downloaded results (.json)

---

## 📊 Expected Runtime| Model | Preparation Time | Training Time | Total |
|-------|-----------------|---------------|-------|
| **Age 2-3.5** | ~2-3 minutes | ~5-10 minutes | ~10-15 min |
| **Age 3.5-5.5** | ~1-2 minutes | ~3-5 minutes | ~5-8 min |
| **Age 5.5-6.9** | ~1 minute | ~2-3 minutes | ~3-5 min |---**Status**: Ready to train on Google Colab! 🚀
