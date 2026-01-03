# 🧠 ML Model Training Guide for Small Datasets (53-58 Children)

## 📊 Your Dataset
- **ASD:** 20-25 children
- **Control:** 33 children
- **Total:** 53-58 children

---

## 🎯 Step-by-Step Workflow

### Step 1: Export Data from Backend

#### Option A: Using Backend Script (Recommended)

```bash
cd senseai_backend
node scripts/export_firebase_to_csv.js --format=ml --output=ml_training_data.csv
```

This will create `ml_training_data.csv` with all ML features.

#### Option B: Using API Endpoint

1. Start your backend:
```bash
cd senseai_backend
npm start
```

2. Open browser or use curl:
```
http://YOUR_IP:3000/api/export/csv?format=ml
```

3. Save the downloaded CSV file.

---

### Step 2: Upload to Google Colab

1. Go to https://colab.research.google.com/
2. Sign in with Google account
3. Create new notebook
4. Upload your CSV file using the upload cell

---

### Step 3: Run the Training Notebook

I've created an optimized notebook: `Optimized_ML_Training_Small_Dataset.ipynb`

**Key Features:**
- ✅ **Logistic Regression** (Primary - best for small datasets)
- ✅ **Linear SVM** (Secondary comparison)
- ✅ **Restricted Random Forest** (Only after expansion)
- ✅ Child-level cross-validation (prevents data leakage)
- ✅ Age normalization
- ✅ Sensitivity-focused evaluation
- ✅ Probability calibration

---

## 🔧 Best Models for Your Dataset Size

### ✅ Tier 1: PRIMARY MODELS (Start Here)

#### 1. Logistic Regression (RECOMMENDED)
```python
LogisticRegression(
    penalty='l2',
    C=0.5,  # Moderate regularization
    class_weight='balanced',  # Handle class imbalance
    max_iter=2000
)
```

**Why it's best:**
- Works extremely well with small datasets
- Resistant to overfitting
- Interpretable (panels love this)
- Produces calibrated probabilities

#### 2. Linear SVM (Secondary)
```python
SVC(
    kernel='linear',  # NOT RBF (avoids overfitting)
    probability=True,
    class_weight='balanced',
    C=0.5
)
```

### ⚠️ Tier 2: Use Carefully

#### 3. Restricted Random Forest (Only after expansion)
```python
RandomForestClassifier(
    n_estimators=100,
    max_depth=3,  # SHALLOW (prevents overfitting)
    min_samples_leaf=5,
    class_weight='balanced'
)
```

**Only use if:**
- Dataset expanded via bootstrapping (≥100 samples)
- You've already trained LR and SVM

### ❌ Tier 3: NOT Recommended Yet

- ❌ XGBoost / LightGBM (too complex for 53-58 children)
- ❌ Deep Learning (needs much more data)
- ❌ RBF SVM (overfits small datasets)

---

## 📈 Dataset Expansion (Optional but Recommended)

### Option A: Trial-Level Bootstrapping (BEST)

If you have raw trial data (individual DCCS/Frog Jump trials):

1. Export trial-level data from backend
2. Bootstrap sessions from trials (20-50 per child)
3. This expands: 53 children → 800-2000 sessions
4. **Scientifically valid** - preserves behavioral patterns

**Why this works:**
- Resamples real behavioral trials
- Preserves child-level patterns
- Common in cognitive science research

### Option B: Bounded Noise Augmentation

If you only have summary features:

```python
# Add small noise (3-5%) to features
noise = np.random.normal(0, 0.1, size=X.shape)
X_aug = X + noise
```

**Rules:**
- Only augment training fold (never test)
- Augment ASD samples more (to balance classes)
- Keep noise small (≤5%)

---

## 🎯 Evaluation Metrics (Prioritize These)

### ⭐ MOST IMPORTANT: Recall (Sensitivity)

**Why:** In screening, missing ASD cases is worse than false positives.

**Target:** ≥80% recall (sensitivity)

### Secondary Metrics:
- **ROC-AUC:** ≥0.75 (good), ≥0.80 (excellent)
- **Precision:** ≥70% (acceptable for screening)
- **F1-Score:** Balance of precision and recall

### What to Report:
```
Model Performance:
- Accuracy: 82.5% ± 5.2%
- Recall (Sensitivity): 85.3% ± 6.1% ⭐
- Precision: 72.1% ± 8.3%
- F1-Score: 78.1% ± 6.8%
- ROC-AUC: 0.78 ± 0.05
```

---

## 🔬 Critical: Child-Level Cross-Validation

**MUST DO:** Use `GroupKFold` with `child_id` as groups.

**Why:** Prevents data leakage (same child in train and test).

```python
from sklearn.model_selection import GroupKFold

gkf = GroupKFold(n_splits=5)
# Use groups=child_id when cross-validating
```

---

## 📝 What to Say in Viva/Panel

### When Asked: "Why Logistic Regression?"

> "Logistic regression was selected as the primary model due to our limited sample size (53-58 children) and the need for interpretability in a clinical screening context. It is resistant to overfitting and produces well-calibrated probability estimates, which is critical for risk scoring."

### When Asked: "Is your dataset large enough?"

> "With 53-58 children, we are in a pilot study range. We use child-level cross-validation to ensure robust evaluation, and we prioritize sensitivity (recall) over accuracy, which is appropriate for screening tools. We acknowledge sample size limitations and plan to expand the dataset in future work."

### When Asked: "How do you handle class imbalance?"

> "We use class_weight='balanced' to account for the 20-25 ASD vs 33 control imbalance. We also prioritize recall (sensitivity) in our evaluation, as missing ASD cases is more critical than false positives in a screening context."

---

## 🚀 Quick Start Commands

### 1. Export Data
```bash
cd senseai_backend
node scripts/export_firebase_to_csv.js --format=ml --output=ml_training_data.csv
```

### 2. Open Google Colab
- Go to https://colab.research.google.com/
- Upload `ml_training_data.csv`
- Copy the notebook cells from `Optimized_ML_Training_Small_Dataset.ipynb`

### 3. Run Training
- Execute cells sequentially
- Review cross-validation results
- Select best model (usually Logistic Regression)
- Save calibrated model

### 4. Use Model in Backend
- Download `asd_screening_model_calibrated.pkl`
- Download `feature_scaler.pkl`
- Integrate into backend for real-time predictions

---

## 📊 Expected Results

With 53-58 children and proper methodology:

**Realistic Targets:**
- **Accuracy:** 75-85%
- **Recall (Sensitivity):** 80-90% ⭐
- **Precision:** 70-80%
- **ROC-AUC:** 0.75-0.85

**Don't expect:**
- ❌ 95%+ accuracy (unrealistic for this sample size)
- ❌ Perfect predictions

**Do expect:**
- ✅ Good sensitivity (catches most ASD cases)
- ✅ Interpretable results
- ✅ Defensible methodology

---

## 🔍 Feature Importance

After training, review feature importance:

**Expected Top Features:**
1. `perseverative_error_rate_post_switch` (DCCS)
2. `commission_error_rate` (Frog Jump)
3. `switch_cost_ms` (DCCS)
4. `rt_variability` (Frog Jump)
5. `critical_items_failed` (Questionnaire)

These align with ASD research literature.

---

## ✅ Checklist Before Training

- [ ] Data exported from backend
- [ ] CSV uploaded to Google Colab
- [ ] Missing values handled
- [ ] Age normalization applied
- [ ] Child-level cross-validation set up
- [ ] Models configured (LR, Linear SVM)
- [ ] Evaluation metrics defined (prioritize recall)
- [ ] Probability calibration enabled

---

## 🎓 Scientific Justification

Your approach is **scientifically sound** because:

1. ✅ **Age normalization** - Accounts for developmental differences
2. ✅ **Multi-domain assessment** - DCCS + Frog Jump + Questionnaire
3. ✅ **Child-level splitting** - Prevents data leakage
4. ✅ **Sensitivity focus** - Appropriate for screening
5. ✅ **Real data** - Collected from actual children (not synthetic)

**This is defensible at international conference level!**

---

## 📚 Next Steps After Training

1. **Evaluate model** - Review cross-validation results
2. **Save model** - Download `.pkl` files
3. **Integrate** - Add to backend for real-time predictions
4. **Test** - Validate on new children (if available)
5. **Document** - Record methodology and results

---

## 🆘 Troubleshooting

### Issue: Low accuracy (<70%)
- **Check:** Are you using child-level splitting?
- **Check:** Are features properly normalized?
- **Check:** Is there too much missing data?

### Issue: Low recall (<75%)
- **Adjust:** Increase class_weight for ASD class
- **Adjust:** Lower decision threshold (default 0.5 → try 0.4)
- **Check:** Are ASD markers (perseveration, commission errors) present?

### Issue: Overfitting (train >> test)
- **Solution:** Increase regularization (C=0.3 instead of 0.5)
- **Solution:** Use shallower models
- **Solution:** Reduce feature count

---

## 📞 Support

If you encounter issues:
1. Check data export (are all features present?)
2. Verify child-level grouping
3. Review cross-validation splits
4. Check for missing values

**Remember:** With 53-58 children, focus on **sensitivity** and **interpretability**, not perfect accuracy!

