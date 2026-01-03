# 📋 Notebook Execution Order - IMPORTANT!

## ⚠️ Critical: Run Cells in Order

The notebook **MUST** be executed in sequential order. Some cells depend on variables created in previous cells.

---

## ✅ Correct Execution Order

### Step 1: Setup (Cells 2-3)
1. **Cell 2**: Install packages (`!pip install...`)
2. **Cell 3**: Import libraries

### Step 2: Load Data (Cells 5-6)
3. **Cell 5**: Upload and load CSV file
4. **Cell 6**: Explore data

### Step 3: Preprocessing (Cells 8-11)
5. **Cell 8**: Encode target and handle missing values (initial)
6. **Cell 10**: Calculate derived features
7. **Cell 11**: Age normalization

### Step 4: Feature Preparation (Cell 13) ⭐ CRITICAL
8. **Cell 13**: **Prepare Features for Training**
   - Creates: `X_scaled`, `y`, `groups`, `scaler`
   - **MUST run before any model training!**

### Step 5: Model Training (Cells 15-16)
9. **Cell 15**: Train Logistic Regression
10. **Cell 16**: Train Linear SVM

### Step 6: Model Comparison (Cell 18)
11. **Cell 18**: Compare models

### Step 7: Calibration & Save (Cell 20)
12. **Cell 20**: Calibrate and save model

### Step 8: Visualizations (Cells 25+)
13. **Cell 25+**: All visualization cells (can run after Step 5)

---

## ❌ Common Errors

### Error: `NameError: name 'X_scaled' is not defined`

**Cause:** You skipped Cell 13 (Step 5: Prepare Features)

**Fix:** 
1. Go back to **Cell 13**
2. Run it completely
3. Then continue with model training cells

### Error: `NameError: name 'lr' is not defined`

**Cause:** You skipped Cell 15 (Train Logistic Regression)

**Fix:**
1. Run **Cell 15** first
2. Then run visualization cells

### Error: Missing values causing issues

**Cause:** Data has many missing values (>50% for some features)

**Fix:** 
- Cell 13 automatically filters out features with >50% missing
- Remaining missing values are filled with median (numeric) or 0
- This is handled automatically

---

## 🔍 How to Check if Variables Exist

If you're unsure, run this in a new cell:

```python
# Check if required variables exist
required_vars = ['X_scaled', 'y', 'groups', 'lr', 'svm', 'gkf']
missing = [v for v in required_vars if v not in globals()]

if missing:
    print(f"❌ Missing variables: {missing}")
    print("   Please run the cells that create these variables first!")
else:
    print("✅ All required variables exist!")
```

---

## 📊 Data Quality Check

Your dataset has many missing values. This is **normal** for real-world data.

**What the notebook does:**
1. **Filters out** features with >50% missing (in Cell 13)
2. **Fills remaining** missing values with median (numeric) or 0
3. **Uses only** features with sufficient data for training

**This is appropriate** for small datasets (53-58 children).

---

## 🚀 Quick Start (If Starting Fresh)

1. **Run all cells from top to bottom** using "Run All" (but check markdown cells are set to Markdown type)
2. **OR** run cells sequentially, checking for errors
3. **If you get an error**, check which variable is missing and run the cell that creates it

---

## 💡 Pro Tips

1. **Don't skip cells** - Each cell builds on previous ones
2. **Check cell numbers** - They're numbered in order
3. **Read error messages** - They tell you what's missing
4. **Run cells one at a time** - Easier to debug if something goes wrong

---

## ✅ Verification Checklist

Before running visualization cells, verify:

- [ ] Cell 2: Packages installed
- [ ] Cell 3: Libraries imported
- [ ] Cell 5: Data loaded (`df` exists)
- [ ] Cell 13: Features prepared (`X_scaled`, `y`, `groups` exist)
- [ ] Cell 15: Logistic Regression trained (`lr`, `lr_scores` exist)
- [ ] Cell 16: Linear SVM trained (`svm`, `svm_scores` exist)

If all checked, you're ready for visualizations!

