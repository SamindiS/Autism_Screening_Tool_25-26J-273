# 📋 Training Workflow Order - Step-by-Step Guide

## 🎯 Correct Order of Operations

### **Phase 1: Data Preparation (FIRST)**
**Goal**: Prepare training and test datasets separately

### **Phase 2: Model Training (SECOND)**
**Goal**: Train models using prepared datasets (automatically evaluates on test set)

---

## 📊 Detailed Workflow

### **STEP 1: Prepare Training Dataset** ✅

**Script**: `preprocessing/prepare_age_2_3_5_data.py`

**What it does:**
1. Loads **external datasets** (Toddler Autism July 2018, Autism Screening Combined)
2. Filters to age 24-42 months
3. Extracts features (A1-A10, Q-CHAT-10, domain scores)
4. Age-normalizes features
5. **Saves as**: `SAMPLE_DATASETS/prepared/train_age_2_3_5_questionnaire.csv`

**Output:**
- ✅ Training dataset ready (~2,314 samples)
- ✅ Features extracted and normalized
- ✅ Ready for model training

---

### **STEP 2: Prepare Test Dataset** ✅

**Same Script**: `preprocessing/prepare_age_2_3_5_data.py` (does both!)

**What it does:**
1. Loads **your hospital-collected data**
2. Filters to age 24-42 months
3. Extracts same features as training data
4. **Saves as**: `SAMPLE_DATASETS/prepared/test_age_2_3_5_questionnaire.csv`

**Output:**
- ✅ Test dataset ready (~40 samples)
- ✅ Same feature structure as training data
- ✅ Ready for evaluation

---

### **STEP 3: Train Model** ✅

**Script**: `training/train_age_2_3_5_model.py`

**What it does AUTOMATICALLY:**
1. **Loads BOTH datasets**:
   - Training: `train_age_2_3_5_questionnaire.csv`
   - Test: `test_age_2_3_5_questionnaire.csv`

2. **Preprocesses training data**:
   - Cleans missing values
   - Feature engineering
   - Outlier detection/handling
   - Data augmentation

3. **Trains model** on training data:
   - Logistic Regression
   - Random Forest
   - Cross-validation

4. **Evaluates on test data** AUTOMATICALLY:
   - Predicts on test set
   - Calculates metrics (accuracy, precision, recall, F1, ROC-AUC)
   - Generates reports

5. **Saves model**:
   - Model file (.pkl)
   - Scaler (.pkl)
   - Features list (.json)
   - Metadata (.json)

**Output:**
- ✅ Trained model
- ✅ Test evaluation results
- ✅ Model files ready for deployment

---

## 🔄 Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ PHASE 1: DATA PREPARATION                               │
└─────────────────────────────────────────────────────────┘

Step 1.1: Prepare Training Data
├── Run: python preprocessing/prepare_age_2_3_5_data.py
├── Input: External datasets (Online Datasets/)
├── Output: train_age_2_3_5_questionnaire.csv
└── Result: ✅ Training dataset ready (~2,314 samples)

Step 1.2: Prepare Test Data (same script!)
├── Same script also prepares test data
├── Input: Hospital data (SAMPLE_DATASETS/)
├── Output: test_age_2_3_5_questionnaire.csv
└── Result: ✅ Test dataset ready (~40 samples)

┌─────────────────────────────────────────────────────────┐
│ PHASE 2: MODEL TRAINING                                 │
└─────────────────────────────────────────────────────────┘

Step 2.1: Train Model
├── Run: python training/train_age_2_3_5_model.py
├── Input: 
│   ├── train_age_2_3_5_questionnaire.csv (training)
│   └── test_age_2_3_5_questionnaire.csv (test)
├── Process:
│   ├── Loads BOTH datasets
│   ├── Trains on training data
│   ├── Evaluates on test data (AUTOMATIC)
│   └── Saves model
└── Output: 
    ├── model_age_2_3_5_questionnaire.pkl
    ├── scaler_model_age_2_3_5_questionnaire.pkl
    ├── features_model_age_2_3_5_questionnaire.json
    ├── model_metadata_model_age_2_3_5_questionnaire.json
    └── training_results_model_age_2_3_5_questionnaire.json
```

---

## ✅ Correct Order (Do This!)

### **For Age 2-3.5 Model:**

```bash
# Step 1: Prepare BOTH training and test datasets
python preprocessing/prepare_age_2_3_5_data.py
# This creates:
#   - train_age_2_3_5_questionnaire.csv (from external datasets)
#   - test_age_2_3_5_questionnaire.csv (from hospital data)

# Step 2: Train model (automatically uses both datasets)
python training/train_age_2_3_5_model.py
# This:
#   - Loads training data → trains model
#   - Loads test data → evaluates model
#   - Saves everything
```

### **For Age 3.5-5.5 Model:**

```bash
# Step 1: Prepare datasets
python preprocessing/prepare_age_3_5_5_5_data.py

# Step 2: Train model
python training/train_age_3_5_5_5_model.py
```

### **For Age 5.5-6.9 Model:**

```bash
# Step 1: Prepare datasets
python preprocessing/prepare_age_5_5_6_9_data.py

# Step 2: Train model
python training/train_age_5_5_6_9_model.py
```

---

## ❌ Common Mistakes (Don't Do This!)

### **Mistake 1: Training before preparing data**
```bash
# ❌ WRONG ORDER
python training/train_age_2_3_5_model.py  # Will fail - no prepared data!
python preprocessing/prepare_age_2_3_5_data.py
```

### **Mistake 2: Uploading datasets separately**
```bash
# ❌ WRONG APPROACH
# You don't "upload" datasets - the scripts load them automatically!
# Just run the preprocessing script once - it handles everything
```

### **Mistake 3: Running training script multiple times**
```bash
# ❌ UNNECESSARY
python training/train_age_2_3_5_model.py  # First time
python training/train_age_2_3_5_model.py  # Second time - unnecessary!
# The script loads both training AND test data automatically
```

---

## 📝 Key Points

### **1. No Manual Upload Needed**
- ✅ Scripts automatically load datasets from file paths
- ✅ No need to "upload" training or test sets separately
- ✅ Just run the preprocessing script once

### **2. Training Script Handles Both**
- ✅ Training script loads **BOTH** training and test datasets
- ✅ Trains on training data
- ✅ Evaluates on test data automatically
- ✅ No separate "test" step needed

### **3. Order Matters**
- ✅ **FIRST**: Prepare datasets (preprocessing)
- ✅ **SECOND**: Train model (training)
- ❌ **NEVER**: Train before preparing data

---

## 🔍 What Happens Inside Training Script

When you run `train_age_2_3_5_model.py`:

```python
# 1. Loads training data
train_df = pd.read_csv("SAMPLE_DATASETS/prepared/train_age_2_3_5_questionnaire.csv")

# 2. Loads test data (if exists)
test_df = pd.read_csv("SAMPLE_DATASETS/prepared/test_age_2_3_5_questionnaire.csv")

# 3. Preprocesses training data
train_df = preprocess_data(train_df)

# 4. Trains model on training data
model.fit(X_train, y_train)

# 5. Evaluates on test data (AUTOMATIC)
test_metrics = evaluate_model(model, X_test, y_test)

# 6. Saves everything
save_model(model, scaler, features, metadata)
```

---

## ✅ Summary: Correct Workflow

1. **Prepare datasets** (ONE script does both training + test)
   ```bash
   python preprocessing/prepare_age_2_3_5_data.py
   ```

2. **Train model** (automatically uses both datasets)
   ```bash
   python training/train_age_2_3_5_model.py
   ```

3. **Check results** (in `ML_TRAINING/output/`)

**That's it!** No separate uploads, no separate test step. The training script handles everything automatically.

---

## 🎯 Quick Answer

**Q: Should I train first, then test?**

**A: NO!** The training script does BOTH automatically:
- Trains on training data
- Evaluates on test data

**Q: Do I upload training set first, then test set?**

**A: NO!** The preprocessing script prepares BOTH:
- Training set from external datasets
- Test set from hospital data

**Just run:**
1. `preprocessing/prepare_age_2_3_5_data.py` (prepares both)
2. `training/train_age_2_3_5_model.py` (trains + evaluates)

---

**Status**: Follow this order for best results! ✅
