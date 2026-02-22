# 📊 Real-World Dataset Analysis and Model Mapping

**Date:** [Current Date]  
**Purpose:** Map external datasets to age-specific ML models

---

## 🎯 **Your Age-Specific Model Structure**

| Age Group | Assessment Type | Model Name | Features Used |
|-----------|----------------|------------|---------------|
| **2-3.5 years** (24-42 months) | Parent Questionnaire (Q-CHAT-10 style) | `model_age_2_3_5_questionnaire` | A1-A10, Q-CHAT-10 score, clinical reflection |
| **3.5-5.5 years** (42-66 months) | Frog Jump Game (Go/No-Go) | `model_age_3_5_5_5_frog_jump` | Go/No-Go accuracy, commission errors, RT metrics |
| **5.5-6.9 years** (66-83 months) | Color-Shape Game (DCCS) | `model_age_5_5_6_9_color_shape` | DCCS accuracy, switch cost, perseverative errors |

---

## 📁 **Available Datasets**

### **Dataset 1: Toddler Autism Dataset (July 2018)**

**File:** `Online Datasets/Toddler Autism dataset July 2018.csv`

**Structure:**
- **Total Samples:** 1,054
- **Age Range:** 12-36 months (mean: 27.9 months)
- **Age Distribution:**
  - 2-3.5 years (24-42 months): **768 samples** ✅
  - 3.5-5.5 years (42-66 months): **0 samples** ❌
  - 5.5-6.9 years (66-83 months): **0 samples** ❌

**Features:**
- `A1` to `A10`: Binary questionnaire items (0/1)
- `Qchat-10-Score`: Total score (0-10)
- `Age_Mons`: Age in months
- `Sex`: Gender (m/f)
- `Ethnicity`: Ethnic background
- `Jaundice`: Yes/No
- `Family_mem_with_ASD`: Yes/No
- `Class/ASD Traits`: Target variable (Yes/No)

**Class Distribution:**
- **ASD (Yes):** 728 samples (69%)
- **Control (No):** 326 samples (31%)
- **Balance:** Slightly imbalanced (ASD-heavy)

**✅ USAGE:** 
- **Model:** `model_age_2_3_5_questionnaire`
- **Compatibility:** ✅ **PERFECT MATCH**
- **Reason:** 
  - Age range fits 2-3.5 years perfectly
  - Features match Q-CHAT-10 structure (A1-A10)
  - Has Q-CHAT-10 score
  - Large sample size (768 usable samples)

**Preprocessing Needed:**
1. Filter to age 24-42 months (remove < 24 months)
2. Map `Class/ASD Traits` to binary (Yes=1, No=0)
3. Extract A1-A10 features
4. Use Q-CHAT-10 score as feature
5. Handle missing values (if any)

---

### **Dataset 2: Autism Screening Data Combined**

**File:** `Online Datasets/Autism screening data for toddlers/Autism_Screening_Data_Combined.csv`

**Structure:**
- **Total Samples:** 6,075
- **Age Range:** 1-80 months (mean: 19.8 months)
- **Age Distribution:**
  - 2-3.5 years (24-42 months): **1,546 samples** ✅
  - 3.5-5.5 years (42-66 months): **592 samples** ✅
  - 5.5-6.9 years (66-83 months): **19 samples** ⚠️ (very few)

**Features:**
- `A1` to `A10`: Binary questionnaire items (0/1)
- `Age`: Age in months
- `Sex`: Gender (m/f)
- `Jauundice`: Yes/No (note: typo in column name)
- `Family_ASD`: Yes/No
- `Class`: Target variable (YES/NO)

**Class Distribution:**
- **ASD (YES):** 1,804 samples (30%)
- **Control (NO):** 4,271 samples (70%)
- **Balance:** Imbalanced (Control-heavy)

**✅ USAGE:**

#### **For Age 2-3.5 Model:**
- **Model:** `model_age_2_3_5_questionnaire`
- **Compatibility:** ✅ **EXCELLENT MATCH**
- **Samples:** 1,546 samples
- **Reason:**
  - Age range includes 2-3.5 years
  - Features match Q-CHAT-10 structure (A1-A10)
  - Large sample size

#### **For Age 3.5-5.5 Model:**
- **Model:** `model_age_3_5_5_5_frog_jump`
- **Compatibility:** ⚠️ **PARTIAL MATCH** (Questionnaire data, not game data)
- **Samples:** 592 samples (210 ASD, 382 Control)
- **Age Range:** 42-65 months ✅
- **Reason:**
  - Age range fits 3.5-5.5 years perfectly
  - **BUT:** This dataset has questionnaire features (A1-A10), NOT Frog Jump game features
  - **Can be used for:** 
    - ✅ Auxiliary features (questionnaire scores as additional context)
    - ✅ Demographic/clinical features (age, sex, jaundice, family history)
    - ✅ Hybrid model training (combine with existing 29 game samples)
  - **Cannot be used for:** 
    - ❌ Game-specific features (go_accuracy, commission_errors, RT metrics)
    - ❌ Primary training data (must use game data for primary features)

#### **For Age 5.5-6.9 Model:**
- **Model:** `model_age_5_5_6_9_color_shape`
- **Compatibility:** ⚠️ **LIMITED MATCH** (Questionnaire data, not game data)
- **Samples:** 19 samples (4 ASD, 15 Control)
- **Age Range:** 66-80 months ✅
- **Reason:**
  - Age range fits 5.5-6.9 years
  - **BUT:** Very few samples (same as your current dataset)
  - **BUT:** Has questionnaire features, not DCCS game features
  - **Can be used for:**
    - ✅ Auxiliary features (questionnaire scores as additional context)
    - ✅ Demographic/clinical features
    - ✅ Hybrid model training (combine with existing 19 game samples)
  - **Limitation:** 
    - ⚠️ Only 19 samples (insufficient for significant improvement)
    - ⚠️ Same size as current dataset (no additional benefit)

**Preprocessing Needed:**
1. Split by age groups:
   - Age 2-3.5: Filter 24-42 months
   - Age 3.5-5.5: Filter 42-66 months
   - Age 5.5-6.9: Filter 66-83 months (if using)
2. Map `Class` to binary (YES=1, NO=0)
3. Extract A1-A10 features
4. Handle missing values

---

### **Dataset 3: TASD-Dataset (Text-based)**

**Files:**
- `Online Datasets/TASD-Dataset Text-based Early Autism Spectrum Disorder Detection Dataset for Toddlers/Dataset-v1.csv`
- `Online Datasets/TASD-Dataset Text-based Early Autism Spectrum Disorder Detection Dataset for Toddlers/Dataset-v2.csv`

**Structure:**
- **Type:** Text-based behavioral descriptions
- **Features:**
  - `Text`: Parent/caregiver descriptions
  - `Class`: Behavioral category
  - `Sign`: Positive/Negative indicator
  - `ASD`: Target variable (0/1)

**✅ USAGE:**
- **Compatibility:** ⚠️ **NOT DIRECTLY COMPATIBLE**
- **Reason:**
  - Text-based data requires NLP preprocessing
  - Your models use structured features (A1-A10, game metrics)
  - Would need feature extraction (sentiment analysis, keyword extraction)
  - **Potential Use:** For data augmentation or feature engineering research

**Recommendation:** 
- Keep for future NLP-based feature extraction
- Not suitable for current structured ML models

---

### **Dataset 4: Autism-Child-Data.arff**

**File:** `Online Datasets/autistic+spectrum+disorder+screening+data+for+children/Autism-Child-Data.arff`

**Structure:**
- **Total Samples:** 292
- **Age Range:** 4-11 years (48-132 months)
- **Format:** ARFF (Weka format)
- **Features:**
  - `A1_Score` to `A10_Score`: Questionnaire scores (not binary, likely 0-10 scale)
  - `age`: Age in months
  - `gender`: Gender (m/f)
  - `ethnicity`: Ethnic background
  - `jundice`: Jaundice history
  - `austim`: Autism history (note: typo in column name)
  - `Class/ASD`: Target variable

**Age Distribution:**
- 2-3.5 years (24-42 months): **0 samples** ❌
- 3.5-5.5 years (42-66 months): **0 samples** ❌
- 5.5-6.9 years (66-83 months): **0 samples** ❌

**Class Distribution:**
- **ASD (YES):** 141 samples (48%)
- **Control (NO):** 151 samples (52%)
- **Balance:** Well-balanced ✅

**❌ USAGE:**
- **Compatibility:** ❌ **NOT COMPATIBLE**
- **Reason:** 
  - Age range (4-11 years / 48-132 months) is outside all three target age groups
  - Too old for your models (your max age is 6.9 years / 83 months)
  - Would need different models for older children

**Recommendation:** 
- Not suitable for current age-specific models
- Could be used for future expansion (age 7+ models)

---

## 🎯 **Final Dataset-to-Model Mapping**

### **✅ Model 1: Age 2-3.5 (Questionnaire)**

**Primary Dataset:**
- ✅ **Toddler Autism Dataset (July 2018)**: 768 samples
- ✅ **Autism Screening Data Combined**: 1,546 samples
- **Total Usable:** ~2,314 samples

**Features Available:**
- A1-A10 (questionnaire items)
- Q-CHAT-10 score
- Demographics (age, sex, ethnicity)
- Clinical factors (jaundice, family history)

**Preprocessing Steps:**
1. Filter age 24-42 months
2. Extract A1-A10 features
3. Calculate Q-CHAT-10 score (if not present)
4. Map target variable to binary
5. Handle missing values
6. Balance classes (if needed)

---

### **⚠️ Model 2: Age 3.5-5.5 (Frog Jump)**

**Available Dataset:**
- ⚠️ **Autism Screening Data Combined**: 592 samples (210 ASD, 382 Control)
- **Age Range:** 42-65 months ✅

**Limitation:**
- Dataset has questionnaire features (A1-A10), NOT Frog Jump game features
- Cannot use game-specific features (go_accuracy, commission_errors, RT metrics) as primary features

**What CAN be used:**
- ✅ **Auxiliary Features:** Questionnaire scores (A1-A10) as additional context
- ✅ **Demographics:** Age, sex
- ✅ **Clinical Factors:** Jaundice, family history
- ✅ **Hybrid Model:** Combine with existing 29 game samples

**What CANNOT be used:**
- ❌ Go/No-Go accuracy metrics (primary features)
- ❌ Commission/omission errors (primary features)
- ❌ Reaction time metrics (primary features)
- ❌ Game-specific features (primary features)

**Recommended Strategy:**
1. **Primary Features:** Use your 29 game samples for game metrics
2. **Auxiliary Features:** Add questionnaire scores from 592 samples
3. **Hybrid Model:** Train with both feature types
4. **Expected Improvement:** Moderate (592 auxiliary samples add context)

**Preprocessing Needed:**
- Extract 592 samples (age 42-66 months)
- Calculate questionnaire scores (A1-A10 sum)
- Map to auxiliary feature format
- Combine with existing 29 game samples

---

### **⚠️ Model 3: Age 5.5-6.9 (Color-Shape)**

**Available Dataset:**
- ⚠️ **Autism Screening Data Combined**: 19 samples (4 ASD, 15 Control)
- **Age Range:** 66-80 months ✅

**Limitation:**
- Very few samples (same as your current dataset)
- Dataset has questionnaire features (A1-A10), NOT DCCS game features
- Cannot use game-specific features as primary features

**What CAN be used:**
- ✅ **Auxiliary Features:** Questionnaire scores (A1-A10) as additional context
- ✅ **Demographics:** Age, sex
- ✅ **Clinical Factors:** Jaundice, family history
- ✅ **Hybrid Model:** Combine with existing 19 game samples

**What CANNOT be used:**
- ❌ DCCS accuracy metrics (primary features)
- ❌ Switch cost metrics (primary features)
- ❌ Perseverative errors (primary features)
- ❌ Game-specific features (primary features)

**Recommended Strategy:**
1. **Primary Features:** Use your 19 game samples for DCCS metrics
2. **Auxiliary Features:** Add questionnaire scores from 19 samples
3. **Hybrid Model:** Train with both feature types
4. **Expected Improvement:** Minimal (only 19 auxiliary samples, same as current)

**Preprocessing Needed:**
- Extract 19 samples (age 66-83 months)
- Calculate questionnaire scores (A1-A10 sum)
- Map to auxiliary feature format
- Combine with existing 19 game samples

**Additional Recommendation:**
- ⚠️ Consider aggressive data augmentation (bootstrap, SMOTE)
- ⚠️ Continue collecting hospital data (prioritize this age group)
- ⚠️ Look for DCCS-specific datasets (NIH Toolbox, research repositories)

---

## 📋 **Recommended Action Plan**

### **Step 1: Prepare Age 2-3.5 Dataset** ✅

```python
# Combine both questionnaire datasets
df1 = pd.read_csv('Online Datasets/Toddler Autism dataset July 2018.csv')
df2 = pd.read_csv('Online Datasets/Autism screening data for toddlers/Autism_Screening_Data_Combined.csv')

# Filter to age 2-3.5 (24-42 months)
df1_filtered = df1[(df1['Age_Mons'] >= 24) & (df1['Age_Mons'] < 42)]
df2_filtered = df2[(df2['Age'] >= 24) & (df2['Age'] < 42)]

# Standardize column names and combine
# Extract A1-A10 features
# Map target variables
# Combine datasets
```

**Expected Result:**
- ~2,314 samples for Age 2-3.5 model
- Significant improvement over current 13 samples

---

### **Step 2: Prepare Age 3.5-5.5 Dataset** ⚠️

```python
# Extract questionnaire data for age 3.5-5.5
df2_filtered = df2[(df2['Age'] >= 42) & (df2['Age'] < 66)]

# Use as auxiliary features only
# Combine with existing 29 game samples
# Use questionnaire features as additional context
```

**Expected Result:**
- 592 questionnaire samples (auxiliary features)
- 29 game samples (primary features)
- Combined model with both feature types

---

### **Step 3: Continue with Age 5.5-6.9** ❌

- Keep using existing 19 game samples
- Consider data augmentation techniques
- Look for DCCS-specific datasets

---

## 🔍 **Feature Mapping**

### **Questionnaire Features (A1-A10)**

These map to your Q-CHAT-10 questionnaire:

| Dataset Feature | Your System Feature | Description |
|----------------|---------------------|-------------|
| `A1` | `Q1` | First questionnaire item |
| `A2` | `Q2` | Second questionnaire item |
| ... | ... | ... |
| `A10` | `Q10` | Tenth questionnaire item |
| `Qchat-10-Score` | `total_score` | Total questionnaire score |

### **Demographic Features**

| Dataset Feature | Your System Feature | Description |
|----------------|---------------------|-------------|
| `Age_Mons` / `Age` | `age_months` | Age in months |
| `Sex` | `gender` | Gender (m/f) |
| `Ethnicity` | (optional) | Ethnic background |
| `Jaundice` | (optional) | Jaundice history |
| `Family_mem_with_ASD` / `Family_ASD` | (optional) | Family ASD history |

---

## ✅ **Summary**

| Model | Dataset | Samples | Compatibility | Action |
|-------|---------|---------|---------------|--------|
| **Age 2-3.5** | Toddler Autism (July 2018) | 768 | ✅ Perfect | Use directly |
| **Age 2-3.5** | Autism Screening Combined | 1,546 | ✅ Perfect | Use directly |
| **Age 3.5-5.5** | Autism Screening Combined | 592 | ⚠️ Partial | Use as auxiliary features (hybrid model) |
| **Age 5.5-6.9** | Autism Screening Combined | 19 | ⚠️ Limited | Use as auxiliary features (minimal benefit) |
| **All Ages** | Autism-Child-Data.arff | 292 | ❌ Age mismatch | Not compatible (4-11 years) |

**Total Usable Samples:**
- **Age 2-3.5:** ~2,314 samples ✅ (huge improvement!)
- **Age 3.5-5.5:** 592 auxiliary samples ⚠️ (for hybrid model)
- **Age 5.5-6.9:** 19 auxiliary samples ⚠️ (limited benefit)

---

## 🚀 **Next Steps**

1. ✅ **Create preprocessing script** to combine and filter datasets
2. ✅ **Extract features** matching your model requirements
3. ✅ **Train Age 2-3.5 model** with ~2,314 samples
4. ⚠️ **Enhance Age 3.5-5.5 model** with hybrid approach (29 game + 592 auxiliary)
5. ⚠️ **Enhance Age 5.5-6.9 model** with hybrid approach (19 game + 19 auxiliary) + augmentation

---

**Status:** Ready for preprocessing and model training! 🎉
