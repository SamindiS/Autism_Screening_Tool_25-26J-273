# 📊 Dataset Analysis: Age 3.5-5.5 and Age 5.5-6.9 Groups

**Date:** [Current Date]  
**Purpose:** Analyze newly added datasets for Frog Jump (3.5-5.5) and Color-Shape (5.5-6.9) models

---

## 🎯 **Target Age Groups**

| Age Group | Assessment Type | Required Features | Current Training Data |
|-----------|---------------|------------------|---------------------|
| **3.5-5.5 years** (42-66 months) | Frog Jump Game (Go/No-Go) | Go/No-Go accuracy, commission errors, RT metrics | 29 samples (10 ASD, 19 TD) |
| **5.5-6.9 years** (66-83 months) | Color-Shape Game (DCCS) | DCCS accuracy, switch cost, perseverative errors | 19 samples (10 ASD, 9 TD) |

---

## 📁 **Analyzed Datasets**

### **Dataset 1: Autism_Screening_Data_Combined.csv**

**Location:** `Online Datasets/Autism screening data for toddlers/Autism_Screening_Data_Combined.csv`

**Structure:**
- **Total Samples:** 6,075
- **Age Range:** 1-80 months (mean: 19.8 months)
- **Format:** CSV with questionnaire-based features

**Features Available:**
- `A1` to `A10`: Binary questionnaire items (0/1)
- `Age`: Age in months
- `Sex`: Gender (m/f)
- `Jauundice`: Yes/No (note: typo in column name)
- `Family_ASD`: Yes/No
- `Class`: Target variable (YES/NO)

**Age Distribution:**
- 2-3.5 years (24-42 months): **1,546 samples** ✅
- **3.5-5.5 years (42-66 months): 592 samples** ✅
- **5.5-6.9 years (66-83 months): 19 samples** ⚠️

**Class Distribution (Age 3.5-5.5):**
- **ASD (YES):** 210 samples (35.5%)
- **Control (NO):** 382 samples (64.5%)
- **Balance:** Imbalanced (Control-heavy)

**Class Distribution (Age 5.5-6.9):**
- **ASD (YES):** 4 samples (21%)
- **Control (NO):** 15 samples (79%)
- **Balance:** Highly imbalanced (Control-heavy)

---

### **Dataset 2: Autism-Child-Data.csv**

**Location:** `Online Datasets/Autism-Child-Data.csv`

**Structure:**
- **Total Samples:** 292
- **Age Range:** 4-11 years (48-132 months)
- **Format:** CSV with questionnaire-based features

**Features Available:**
- `A1_Score` to `A10_Score`: Questionnaire scores
- `age`: Age (stored as string: "4", "5", "6", etc.)
- `age_desc`: "4-11 years"
- `gender`: Gender (m/f)
- `ethnicity`: Ethnic background
- `jundice`: Jaundice history
- `austim`: Autism history (note: typo)
- `Class/ASD`: Target variable (YES/NO)

**Age Distribution:**
- 2-3.5 years (24-42 months): **0 samples** ❌
- **3.5-5.5 years (42-66 months): 0 samples** ❌ (age stored as years, not months)
- **5.5-6.9 years (66-83 months): 0 samples** ❌

**Class Distribution:**
- **ASD (YES):** 141 samples (48%)
- **Control (NO):** 151 samples (52%)
- **Balance:** Well-balanced ✅

**Note:** Age is stored as years (4, 5, 6, etc.), which would need conversion to months. However, even after conversion, the age range (4-11 years = 48-132 months) is outside the target ranges.

---

## ⚠️ **Critical Finding: Feature Mismatch**

### **Problem Identified**

All analyzed datasets contain **questionnaire-based features** (A1-A10), NOT game-based features.

**Required Features for Age 3.5-5.5 (Frog Jump):**
- ❌ `go_accuracy`, `nogo_accuracy`, `overall_accuracy`
- ❌ `commission_errors`, `commission_error_rate`
- ❌ `omission_errors`, `omission_error_rate`
- ❌ `avg_rt_go_ms`, `rt_variability`
- ❌ `inhibition_failure_rate`, `anticipatory_responses`, `late_responses`

**Required Features for Age 5.5-6.9 (Color-Shape):**
- ❌ `pre_switch_accuracy`, `post_switch_accuracy`, `mixed_block_accuracy`
- ❌ `switch_cost_ms`, `accuracy_drop_percent`
- ❌ `total_perseverative_errors`, `perseverative_error_rate_post_switch`
- ❌ `number_of_consecutive_perseverations`
- ❌ `avg_rt_pre_switch_ms`, `avg_rt_post_switch_correct_ms`

**Available Features in Datasets:**
- ✅ `A1` to `A10` (questionnaire items)
- ✅ Demographics (age, sex)
- ✅ Clinical factors (jaundice, family history)

---

## ✅ **What CAN Be Used**

### **For Age 3.5-5.5 (Frog Jump Model)**

**From Autism_Screening_Data_Combined.csv:**
- **592 samples** in the correct age range (42-66 months)
- **Can be used as:**
  1. **Auxiliary features:** Add questionnaire scores (A1-A10) as additional context
  2. **Demographic baseline:** Use age, sex, clinical factors
  3. **Data augmentation:** Combine with existing 29 game samples

**Usage Strategy:**
```python
# Primary features: Game metrics (from your 29 samples)
# Auxiliary features: Questionnaire scores (from 592 samples)
# Combined model: Both feature types
```

**Expected Improvement:**
- Current: 29 game samples only
- With auxiliary features: 29 game samples + 592 questionnaire samples (for auxiliary features only)
- **Note:** Cannot replace game features, only supplement them

---

### **For Age 5.5-6.9 (Color-Shape Model)**

**From Autism_Screening_Data_Combined.csv:**
- **19 samples** in the correct age range (66-83 months)
- **Limitation:** Too few samples (same as your current dataset)

**Can be used as:**
- **Auxiliary features:** Add questionnaire scores (A1-A10) as additional context
- **Demographic baseline:** Use age, sex, clinical factors

**Usage Strategy:**
```python
# Primary features: DCCS game metrics (from your 19 samples)
# Auxiliary features: Questionnaire scores (from 19 samples)
# Combined model: Both feature types
```

**Expected Improvement:**
- Current: 19 game samples
- With auxiliary features: 19 game samples + 19 questionnaire samples (for auxiliary features only)
- **Note:** Very limited improvement due to small sample size

---

## ❌ **What CANNOT Be Used**

### **Direct Training Data**

**None of the datasets can be used as direct training data** for the game-based models because:

1. **Missing Game Features:** No Go/No-Go or DCCS metrics
2. **Feature Type Mismatch:** Questionnaire features ≠ Game features
3. **Different Assessment Types:** Questionnaires assess parent-reported behavior; games assess cognitive performance

### **Age 5.5-6.9 Dataset**

**Autism_Screening_Data_Combined.csv:**
- Only 19 samples (insufficient for training)
- Same size as your current dataset
- No additional benefit

**Autism-Child-Data.csv:**
- Age range (4-11 years) outside target (5.5-6.9 years)
- Cannot be used

---

## 🎯 **Recommended Usage Strategy**

### **Strategy 1: Hybrid Model (RECOMMENDED)**

**For Age 3.5-5.5:**
1. **Primary Features:** Use your 29 game samples for game metrics
2. **Auxiliary Features:** Add questionnaire scores (A1-A10) from 592 samples
3. **Combined Model:** Train with both feature types
4. **Expected Features:**
   - Game features: `go_accuracy`, `commission_errors`, `rt_metrics`, etc.
   - Auxiliary features: `questionnaire_score`, `critical_items_failed`, etc.
   - Demographics: `age_months`, `gender`, `jaundice`, `family_asd`

**For Age 5.5-6.9:**
1. **Primary Features:** Use your 19 game samples for DCCS metrics
2. **Auxiliary Features:** Add questionnaire scores (A1-A10) from 19 samples
3. **Combined Model:** Train with both feature types
4. **Expected Features:**
   - Game features: `pre_switch_accuracy`, `switch_cost_ms`, `perseverative_errors`, etc.
   - Auxiliary features: `questionnaire_score`, `critical_items_failed`, etc.
   - Demographics: `age_months`, `gender`, `jaundice`, `family_asd`

---

### **Strategy 2: Data Augmentation**

**For Age 3.5-5.5:**
- Use 592 questionnaire samples to generate synthetic game features
- **Method:** Train a mapping model (questionnaire → game features)
- **Risk:** May introduce bias if mapping is inaccurate

**For Age 5.5-6.9:**
- Use 19 questionnaire samples (very limited)
- **Not recommended** due to small sample size

---

### **Strategy 3: Continue with Current Data**

**For Age 3.5-5.5:**
- Continue with 29 game samples
- Use data augmentation techniques (bootstrap, SMOTE)
- Focus on improving model robustness

**For Age 5.5-6.9:**
- Continue with 19 game samples
- Use aggressive data augmentation
- Consider collecting more hospital data

---

## 📊 **Summary Table**

| Age Group | Dataset | Samples | Feature Type | Usability | Recommendation |
|-----------|---------|---------|--------------|-----------|---------------|
| **3.5-5.5** | Autism_Screening_Data_Combined | 592 | Questionnaire | ⚠️ Auxiliary only | Use as auxiliary features |
| **3.5-5.5** | Autism-Child-Data | 0 | Questionnaire | ❌ Age mismatch | Skip |
| **5.5-6.9** | Autism_Screening_Data_Combined | 19 | Questionnaire | ⚠️ Auxiliary only | Use as auxiliary features (limited benefit) |
| **5.5-6.9** | Autism-Child-Data | 0 | Questionnaire | ❌ Age mismatch | Skip |

---

## 🚀 **Next Steps**

### **Immediate Actions:**

1. **For Age 3.5-5.5:**
   - ✅ Extract 592 samples from Autism_Screening_Data_Combined.csv
   - ✅ Prepare auxiliary features (A1-A10, demographics)
   - ✅ Combine with existing 29 game samples
   - ✅ Train hybrid model with both feature types

2. **For Age 5.5-6.9:**
   - ✅ Extract 19 samples from Autism_Screening_Data_Combined.csv
   - ✅ Prepare auxiliary features (A1-A10, demographics)
   - ✅ Combine with existing 19 game samples
   - ✅ Train hybrid model with both feature types
   - ⚠️ Consider aggressive data augmentation

### **Long-term Actions:**

1. **Continue Data Collection:**
   - Focus on collecting more game-based data from hospitals
   - Prioritize Age 5.5-6.9 (currently only 19 samples)

2. **Search for Game-Based Datasets:**
   - Look for Go/No-Go task datasets (for Age 3.5-5.5)
   - Look for DCCS task datasets (for Age 5.5-6.9)
   - Check research repositories (NIH Toolbox, ADOS-2 datasets)

3. **Consider Alternative Approaches:**
   - Transfer learning from similar cognitive tasks
   - Multi-task learning across age groups
   - Ensemble methods combining questionnaire + game features

---

## 📝 **Preprocessing Script Needed**

Create a script to:
1. Load Autism_Screening_Data_Combined.csv
2. Filter to age 3.5-5.5 (42-66 months) and age 5.5-6.9 (66-83 months)
3. Extract questionnaire features (A1-A10)
4. Calculate questionnaire scores
5. Map to auxiliary feature format
6. Save as separate CSV files for each age group

**Output Files:**
- `SAMPLE_DATASETS/prepared/auxiliary_age_3_5_5_5_questionnaire.csv`
- `SAMPLE_DATASETS/prepared/auxiliary_age_5_5_6_9_questionnaire.csv`

---

## ✅ **Conclusion**

### **Key Findings:**

1. **Age 3.5-5.5:** Found 592 questionnaire samples that can be used as **auxiliary features** (not primary training data)
2. **Age 5.5-6.9:** Found 19 questionnaire samples (same as current dataset, limited benefit)
3. **No game-based datasets found** for either age group
4. **Recommendation:** Use questionnaire data as auxiliary features in hybrid models

### **Impact:**

- **Age 3.5-5.5:** Moderate improvement (592 auxiliary samples)
- **Age 5.5-6.9:** Minimal improvement (19 auxiliary samples)
- **Overall:** Cannot replace game-based training data, but can enhance models with additional context

---

**Status:** Analysis complete. Ready for preprocessing and hybrid model training! 🎉
