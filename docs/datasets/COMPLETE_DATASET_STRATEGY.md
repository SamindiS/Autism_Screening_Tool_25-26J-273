# 🎯 Complete Dataset Strategy: Train/Test Split + M-CHAT/DSM-5/NIH Integration

**Status:** ✅ **READY TO USE**

---

## 📊 **Current Status**

### **✅ Training Set (External Datasets)**
- **File:** `SAMPLE_DATASETS/prepared/train_age_2_3_5_external.csv`
- **Samples:** 983 (426 ASD + 557 Control)
- **Source:** Combined external datasets
- **Status:** ✅ Ready for training

### **✅ Test Set (Hospital Data)**
- **File:** `SAMPLE_DATASETS/prepared/test_age_2_3_5_hospital.csv`
- **Samples:** 40 (10 ASD + 30 Control)
- **Source:** Your hospital-collected data
- **Status:** ✅ Ready for testing (DO NOT use for training)

---

## 🎯 **Strategy Summary**

### **Why This Approach?**

1. **Training on External Data:**
   - ✅ Large sample size (983 vs 40)
   - ✅ Diverse population
   - ✅ Well-validated public datasets
   - ✅ Robust model training

2. **Testing on Hospital Data:**
   - ✅ Real clinical data from YOUR hospital
   - ✅ Represents actual deployment scenario
   - ✅ High-quality gold standard
   - ✅ Ensures model works on YOUR data

3. **Separation:**
   - ✅ Test set NEVER used for training
   - ✅ Unbiased evaluation
   - ✅ Clinically valid results

---

## 📋 **Feature Mapping**

### **Your Model Features (9 features)**

```json
[
  "age_months",
  "critical_items_failed",
  "completion_time_sec",
  "social_responsiveness_zscore",
  "joint_attention_zscore",
  "total_score_zscore",
  "low_attention_flag",
  "high_critical_items_flag",
  "low_social_flag"
]
```

### **How External Datasets Map to Your Features**

| Your Feature | External Dataset Source | Calculation |
|--------------|-------------------------|-------------|
| `age_months` | `Age_Mons` or `Age` | Direct |
| `critical_items_failed` | `A1`-`A10` | Sum of A1-A10 (count of 1s) |
| `completion_time_sec` | Missing | Imputed (median: 300s) |
| `social_responsiveness_zscore` | `A1`, `A4`, `A5` | (A1+A4+A5)/3 → age-normalized z-score |
| `joint_attention_zscore` | `A5`, `A9` | (A5+A9)/2 → age-normalized z-score |
| `total_score_zscore` | `A1`-`A10` or `Qchat-10-Score` | Sum A1-A10 or Q-CHAT*10 → age-normalized z-score |
| `low_attention_flag` | `A1`, `A4` | Binary: (A1==1 OR A4==1) |
| `high_critical_items_flag` | `critical_items_failed` | Binary: (critical_items_failed >= 3) |
| `low_social_flag` | `social_responsiveness_raw` | Binary: (social_responsiveness < 50) |

---

## 🔗 **M-CHAT, DSM-5, NIH Integration**

### **1. M-CHAT Dataset Integration**

**What is M-CHAT?**
- Modified Checklist for Autism in Toddlers - Revised/Follow-Up
- 20 questions (binary yes/no)
- Critical items: 2, 5, 7, 12, 13, 15
- Age range: 16-30 months

**Where to Find:**
- **Kaggle:** Search "M-CHAT autism screening dataset"
- **UCI ML Repository:** "Autism Screening Adult and Child Data"
- **Google Scholar:** "M-CHAT dataset" + "autism screening"

**Integration Script:**
```python
# See: docs/datasets/MCHAT_DSM5_NIH_INTEGRATION.md
# Function: integrate_mchat_dataset()
```

**Mapping:**
- M-CHAT Q2, Q7 → Your Q1 (Name Response)
- M-CHAT Q5 → Your Q4 (Eye Contact)
- M-CHAT Q12 → Your Q5 (Pointing)
- M-CHAT Q13, Q15 → Your Q9 (Joint Attention)

---

### **2. DSM-5 Criteria Dataset Integration**

**What is DSM-5?**
- Diagnostic and Statistical Manual of Mental Disorders, 5th Edition
- Two core domains:
  1. **Social Communication** (3 criteria)
  2. **Restricted/Repetitive Behaviors** (4 criteria)

**Where to Find:**
- **ADOS-2 Datasets:** Often aligned with DSM-5
- **Research Papers:** "DSM-5 autism dataset"
- **Clinical Databases:** Hospital records coded with DSM-5

**Integration Script:**
```python
# See: docs/datasets/MCHAT_DSM5_NIH_INTEGRATION.md
# Function: integrate_dsm5_dataset()
```

**Mapping:**
- DSM-5 Social Communication → Your `social_responsiveness_score`
- DSM-5 Restricted/Repetitive → Your `cognitive_flexibility_score`

---

### **3. NIH Toolbox Norms Integration**

**What is NIH Toolbox?**
- National Institutes of Health Toolbox
- Standardized cognitive assessments
- DCCS norms: Age-normalized scores (z-scores)

**Where to Find:**
- **Official Website:** https://www.healthmeasures.net/
- **Search:** "NIH Toolbox DCCS norms" OR "NIH Toolbox normative data"

**Integration Script:**
```python
# See: docs/datasets/MCHAT_DSM5_NIH_INTEGRATION.md
# Function: integrate_nih_norms()
# Function: normalize_with_nih_norms()
```

**Usage:**
- Use NIH norms for age normalization instead of internal z-scores
- More clinically valid
- Internationally recognized

---

## 🚀 **How to Use**

### **Step 1: Run Preprocessing Script**

```bash
python ML_TRAINING/prepare_train_test_datasets.py
```

**Output:**
- `SAMPLE_DATASETS/prepared/train_age_2_3_5_external.csv` (983 samples)
- `SAMPLE_DATASETS/prepared/test_age_2_3_5_hospital.csv` (40 samples)
- `SAMPLE_DATASETS/prepared/features_age_2_3_5_questionnaire.json` (feature list)

---

### **Step 2: Update Training Notebook**

**In `ML_TRAINING/Age_2_3_5_Questionnaire_Model_Training.ipynb`:**

```python
# Replace data loading section with:

# Load TRAINING data (external datasets)
train_df = pd.read_csv('SAMPLE_DATASETS/prepared/train_age_2_3_5_external.csv')

# Load TEST data (hospital data) - DO NOT use for training
test_df = pd.read_csv('SAMPLE_DATASETS/prepared/test_age_2_3_5_hospital.csv')

# Separate features and target
X_train = train_df.drop('group', axis=1)
y_train = train_df['group']

X_test = test_df.drop('group', axis=1)
y_test = test_df['group']

print(f"Training: {len(X_train)} samples")
print(f"Test: {len(X_test)} samples")
```

---

### **Step 3: Train Model**

```python
# Train on external data
model = LogisticRegression(
    max_iter=2000,
    class_weight='balanced',
    solver='liblinear',
    random_state=42
)

model.fit(X_train, y_train)

# Evaluate on TRAINING set (for comparison)
train_pred = model.predict(X_train)
train_acc = accuracy_score(y_train, train_pred)
print(f"Training Accuracy: {train_acc:.2%}")

# Evaluate on TEST set (hospital data) - FINAL METRIC
test_pred = model.predict(X_test)
test_acc = accuracy_score(y_test, test_pred)
print(f"Test Accuracy (Hospital Data): {test_acc:.2%}")
```

---

### **Step 4: Add M-CHAT/DSM-5/NIH (Optional)**

**When you find these datasets:**

1. **Add M-CHAT integration function** (see `MCHAT_DSM5_NIH_INTEGRATION.md`)
2. **Add DSM-5 integration function** (see `MCHAT_DSM5_NIH_INTEGRATION.md`)
3. **Add NIH norms** (download from official website)
4. **Re-run preprocessing** to include new datasets
5. **Retrain model** with combined dataset

---

## 📊 **Expected Results**

### **Before (Current Model):**
- Training: 13 samples (your hospital data)
- Test: N/A (same data)
- Accuracy: ~85% (LOCO-CV)

### **After (New Strategy):**
- Training: 983 samples (external datasets)
- Test: 40 samples (hospital data - separate)
- Expected Training Accuracy: 80-90%
- Expected Test Accuracy: 75-85% (on hospital data)

**Why Test Accuracy Might Be Lower:**
- Test set is REAL clinical data (harder)
- Different population characteristics
- More realistic evaluation

---

## ✅ **Summary**

### **What You Have Now:**

1. ✅ **Training Set:** 983 samples from external datasets
2. ✅ **Test Set:** 40 samples from your hospital
3. ✅ **Preprocessing Script:** Ready to run
4. ✅ **Feature Mapping:** Complete
5. ✅ **Integration Guides:** M-CHAT, DSM-5, NIH

### **What You Can Do:**

1. ✅ **Train model** on 983 external samples
2. ✅ **Test model** on 40 hospital samples
3. ✅ **Add M-CHAT datasets** when found
4. ✅ **Add DSM-5 datasets** when found
5. ✅ **Use NIH norms** for better normalization

---

## 🎯 **Answer to Your Questions**

### **Q: Can I use hospital data as test data and external datasets as training data?**

**Answer: YES ✅**

**This is the CORRECT approach:**
- ✅ Training on large external datasets (983 samples)
- ✅ Testing on your hospital data (40 samples)
- ✅ Keeps test set separate (no data leakage)
- ✅ Clinically valid evaluation

### **Q: Can I use M-CHAT, DSM-5, NIH datasets?**

**Answer: YES ✅**

**Integration Strategy:**
1. **M-CHAT:** Map 20 questions to your 10-question structure
2. **DSM-5:** Map criteria to your domain scores
3. **NIH Toolbox:** Use norms for age normalization

**See:** `docs/datasets/MCHAT_DSM5_NIH_INTEGRATION.md` for complete scripts

---

## 📝 **Files Created**

1. ✅ `ML_TRAINING/prepare_train_test_datasets.py` - Preprocessing script
2. ✅ `docs/datasets/TRAIN_TEST_SPLIT_STRATEGY.md` - Strategy guide
3. ✅ `docs/datasets/MCHAT_DSM5_NIH_INTEGRATION.md` - Integration guide
4. ✅ `docs/datasets/COMPLETE_DATASET_STRATEGY.md` - This file

---

## 🚀 **Next Steps**

1. ✅ **Run preprocessing script** (already done!)
2. ✅ **Update training notebook** to use new datasets
3. ✅ **Train model** on 983 external samples
4. ✅ **Evaluate** on 40 hospital samples
5. 🔍 **Search for M-CHAT/DSM-5/NIH datasets** (optional)
6. ✅ **Report results** with both training and test metrics

---

**Status:** Ready to train! 🎉
