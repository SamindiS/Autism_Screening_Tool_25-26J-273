# 🎓 Complete Google Colab ML Training Guide

## SenseAI ASD Screening - Machine Learning Training from Scratch

---

## 📋 Table of Contents
1. [Getting Started with Google Colab](#1-getting-started)
2. [Upload Your Dataset](#2-upload-dataset)
3. [Understanding the ML Pipeline](#3-ml-pipeline)
4. [Training Models](#4-training-models)
5. [Exporting Models](#5-exporting-models)

---

## 1. Getting Started with Google Colab {#1-getting-started}

### Step 1: Open Google Colab
1. Go to: **https://colab.research.google.com**
2. Sign in with your Google account

### Step 2: Create New Notebook
1. Click **File → New notebook**
2. Rename it: Click on "Untitled" → Type "ASD_ML_Training"

### Step 3: Enable GPU (Optional - for faster training)
1. Click **Runtime → Change runtime type**
2. Select **GPU** under Hardware accelerator
3. Click **Save**

---

## 2. Upload Your Dataset {#2-upload-dataset}

### Option A: Direct Upload (Easiest)
```python
from google.colab import files
uploaded = files.upload()  # Select your CSV files
```

### Option B: Google Drive (Recommended for large datasets)
```python
from google.colab import drive
drive.mount('/content/drive')

# Then access files at:
# /content/drive/MyDrive/SAMPLE_DATASETS/
```

### Option C: GitHub
```python
!git clone https://github.com/YOUR_USERNAME/Autism_Screening_Tool_25-26J-273.git
%cd Autism_Screening_Tool_25-26J-273/SAMPLE_DATASETS
```

---

## 3. Understanding the ML Pipeline {#3-ml-pipeline}

### Your Data Flow:
```
┌─────────────────────────────────────────────────────────────┐
│                    DATA COLLECTION                          │
├─────────────────────────────────────────────────────────────┤
│  Age 2-3      │  Age 3.5-5     │  Age 5.5-6+               │
│  Questionnaire│  Frog Jump     │  DCCS Game                │
│  + Clinical   │  + Clinical    │  + Clinical               │
│  Reflection   │  Reflection    │  Reflection               │
└───────┬───────┴───────┬────────┴───────┬────────────────────┘
        │               │                │
        ▼               ▼                ▼
┌─────────────────────────────────────────────────────────────┐
│                    FEATURE EXTRACTION                       │
├─────────────────────────────────────────────────────────────┤
│  • Critical Items Failed    • Commission Errors             │
│  • Risk Score               • RT Variability                │
│  • Category Scores          • Perseverative Errors          │
│                             • Switch Cost                   │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    ML MODELS                                │
├─────────────────────────────────────────────────────────────┤
│  Task 1: Binary Classification (ASD vs Control)             │
│  ├── Logistic Regression                                    │
│  ├── Random Forest                                          │
│  ├── XGBoost                                                │
│  └── SVM                                                    │
│                                                             │
│  Task 2: Severity Classification (Level 1, 2, 3)            │
│  ├── Ordinal Regression                                     │
│  ├── Random Forest (Multiclass)                             │
│  └── XGBoost (Multiclass)                                   │
└─────────────────────────────────────────────────────────────┘
```

### Key Equations:

#### 1. Switch Cost (DCCS)
```
Switch_Cost = RT_PostSwitch - RT_PreSwitch
```
- **High Switch Cost (>400ms)** → ASD indicator

#### 2. Perseverative Error Rate
```
Perseverative_Rate = (Perseverative_Errors / Post_Switch_Trials) × 100
```
- **High Rate (>30%)** → Cognitive rigidity indicator

#### 3. Inhibition Error Rate (Frog Jump)
```
Commission_Error_Rate = (Commission_Errors / Total_NoGo_Trials) × 100
```
- **High Rate (>40%)** → Inhibitory control deficit

#### 4. Accuracy Drop
```
Accuracy_Drop = ((Pre_Accuracy - Post_Accuracy) / Pre_Accuracy) × 100
```
- **High Drop (>20%)** → Rule-switching difficulty

---

## 4. Training Models {#4-training-models}

### Model Selection Guide:

| Algorithm | Use Case | Pros | Cons |
|-----------|----------|------|------|
| **Logistic Regression** | Binary ASD detection | Interpretable, fast | Linear only |
| **Random Forest** | Both tasks | Feature importance, handles non-linear | Can overfit |
| **XGBoost** | Best accuracy | State-of-the-art performance | Complex tuning |
| **SVM** | Small datasets | Good with high dimensions | Slow on large data |
| **Ordinal Regression** | Severity levels | Respects order (L1 < L2 < L3) | Less common |

### Recommended Approach:
1. **Start with Logistic Regression** (baseline)
2. **Try Random Forest** (understand feature importance)
3. **Use XGBoost** (best performance)
4. **Use Ordinal Regression** for severity levels

---

## 5. Exporting Models {#5-exporting-models}

### Save trained models:
```python
import joblib
joblib.dump(model, 'asd_model.pkl')
joblib.dump(scaler, 'scaler.pkl')
```

### Download to your computer:
```python
from google.colab import files
files.download('asd_model.pkl')
```

### Load in Flutter (via API):
```python
# Create a Flask/FastAPI backend
model = joblib.load('asd_model.pkl')
prediction = model.predict(features)
```

---

## 🎯 Quick Start Commands

Copy and paste these into Google Colab:

```python
# Cell 1: Setup
!pip install pandas numpy scikit-learn xgboost mord matplotlib seaborn -q
from google.colab import files
uploaded = files.upload()  # Upload merged_complete_dataset.csv

# Cell 2: Load data
import pandas as pd
df = pd.read_csv('merged_complete_dataset.csv')
print(f"Loaded {len(df)} samples")
df.head()
```

---

## 📞 Need Help?

- Google Colab FAQ: https://research.google.com/colaboratory/faq.html
- Scikit-learn docs: https://scikit-learn.org/stable/
- XGBoost docs: https://xgboost.readthedocs.io/







