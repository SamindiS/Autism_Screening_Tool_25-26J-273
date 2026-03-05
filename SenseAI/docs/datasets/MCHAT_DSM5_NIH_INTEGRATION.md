# 🔗 M-CHAT, DSM-5, and NIH Toolbox Integration Guide

**Purpose:** Integrate standardized clinical datasets into your training pipeline

---

## 📚 **Dataset Sources**

### **1. M-CHAT-R/F Dataset**

**What is M-CHAT?**
- **Full Name:** Modified Checklist for Autism in Toddlers - Revised/Follow-Up
- **Age Range:** 16-30 months
- **Questions:** 20 binary (yes/no) questions
- **Critical Items:** 2, 5, 7, 12, 13, 15
- **Scoring:** ≥3 critical items = high risk

**Where to Download:**

1. **Kaggle** (Recommended):
   - Search: "M-CHAT autism screening dataset"
   - Search: "Autism Screening Adult and Child Data"
   - URL: https://www.kaggle.com/datasets

2. **UCI Machine Learning Repository**:
   - Dataset: "Autism Screening Adult and Child Data"
   - URL: https://archive.ics.uci.edu/ml/datasets/Autism+Screening+Adult+and+Child+Data

3. **Research Papers**:
   - Search Google Scholar: "M-CHAT dataset"
   - Many papers publish M-CHAT data

**Expected Format:**
```csv
Case_No,Q1,Q2,Q3,...,Q20,Age_Mons,Sex,Class
1,0,1,0,...,1,24,m,Yes
2,0,0,0,...,0,28,f,No
```

---

### **2. DSM-5 Criteria Dataset**

**What is DSM-5?**
- **Full Name:** Diagnostic and Statistical Manual of Mental Disorders, 5th Edition
- **ASD Criteria:** Two core domains
  1. **Social Communication** (3 criteria)
  2. **Restricted/Repetitive Behaviors** (4 criteria)

**Where to Download:**

1. **ADOS-2 Datasets** (Aligned with DSM-5):
   - Search: "ADOS-2 dataset autism"
   - Many research papers publish ADOS-2 data
   - ADOS-2 scores map directly to DSM-5 criteria

2. **Clinical Databases**:
   - Hospital records coded with DSM-5
   - Research databases (with proper permissions)

3. **Research Papers**:
   - Search: "DSM-5 autism dataset"
   - Papers using DSM-5 diagnostic criteria

**Expected Format:**
```csv
Case_No,Social_Emotional_Reciprocity,Nonverbal_Communication,Relationships,
        Stereotyped_Movements,Insistence_Sameness,Restricted_Interests,Sensory_Issues,
        Age_Mons,Class
1,2,2,1,2,3,2,2,28,ASD
```

---

### **3. NIH Toolbox Dataset**

**What is NIH Toolbox?**
- **Full Name:** National Institutes of Health Toolbox
- **Components:** Standardized cognitive assessments
- **DCCS Norms:** Age-normalized scores for DCCS task
- **Age Range:** 3-85 years (with norms for each age)

**Where to Download:**

1. **NIH Toolbox Website** (Official):
   - URL: https://www.healthmeasures.net/explore-measurement-systems/nih-toolbox
   - Download: DCCS normative data
   - Requires: Registration (free)

2. **Research Papers**:
   - Papers using NIH Toolbox norms
   - Often include normative tables

**Expected Format (Norms):**
```csv
Age_Months,Mean_Score,Std_Dev,Percentile_25,Percentile_75
24,65.2,15.3,55.0,75.0
30,72.1,14.8,62.0,82.0
36,78.5,13.2,70.0,87.0
```

---

## 🔄 **Integration Scripts**

### **Script 1: M-CHAT Integration**

```python
import pandas as pd
import numpy as np

def integrate_mchat_dataset(mchat_file):
    """
    Integrate M-CHAT dataset into your training pipeline
    """
    # Load M-CHAT data
    mchat_df = pd.read_csv(mchat_file)
    
    # Filter to age 2-3.5 (24-42 months)
    mchat_df = mchat_df[
        (mchat_df['Age_Mons'] >= 24) & 
        (mchat_df['Age_Mons'] < 42)
    ]
    
    # Map M-CHAT 20 questions to your 10-question structure
    your_format = pd.DataFrame()
    
    # Your Q1 (Name Response) ← M-CHAT Q2, Q7 (critical items)
    your_format['q1_name_response'] = (
        (mchat_df['Q2'] == 1) | (mchat_df['Q7'] == 1)
    ).astype(int)
    
    # Your Q2 (Routine Change) ← M-CHAT Q3, Q4
    your_format['q2_routine_change'] = (
        (mchat_df['Q3'] == 1) | (mchat_df['Q4'] == 1)
    ).astype(int)
    
    # Your Q3 (Toy Switching) ← M-CHAT Q6
    your_format['q3_toy_switching'] = mchat_df['Q6']
    
    # Your Q4 (Eye Contact) ← M-CHAT Q5 (critical)
    your_format['q4_eye_contact'] = mchat_df['Q5']
    
    # Your Q5 (Pointing) ← M-CHAT Q12 (critical)
    your_format['q5_pointing'] = mchat_df['Q12']
    
    # Your Q6 (Sensory) ← M-CHAT Q8, Q9
    your_format['q6_sensory'] = (
        (mchat_df['Q8'] == 1) | (mchat_df['Q9'] == 1)
    ).astype(int)
    
    # Your Q7 (Imitation) ← M-CHAT Q10, Q11
    your_format['q7_imitation'] = (
        (mchat_df['Q10'] == 1) | (mchat_df['Q11'] == 1)
    ).astype(int)
    
    # Your Q8 (Peer Play) ← M-CHAT Q14
    your_format['q8_peer_play'] = mchat_df['Q14']
    
    # Your Q9 (Joint Attention) ← M-CHAT Q13, Q15 (critical)
    your_format['q9_joint_attention'] = (
        (mchat_df['Q13'] == 1) | (mchat_df['Q15'] == 1)
    ).astype(int)
    
    # Your Q10 (Communication) ← M-CHAT Q16, Q17, Q18
    your_format['q10_communication'] = (
        (mchat_df['Q16'] == 1) | 
        (mchat_df['Q17'] == 1) | 
        (mchat_df['Q18'] == 1)
    ).astype(int)
    
    # Calculate critical items (M-CHAT critical: 2, 5, 7, 12, 13, 15)
    critical_items = ['Q2', 'Q5', 'Q7', 'Q12', 'Q13', 'Q15']
    your_format['critical_items_failed'] = mchat_df[critical_items].sum(axis=1)
    
    # Calculate domain scores
    your_format['social_responsiveness_score'] = (
        your_format['q1_name_response'] + 
        your_format['q4_eye_contact'] + 
        your_format['q5_pointing']
    ) / 3.0 * 100
    
    your_format['joint_attention_score'] = (
        your_format['q5_pointing'] + 
        your_format['q9_joint_attention']
    ) / 2.0 * 100
    
    your_format['total_score'] = your_format[[f'q{i}' for i in range(1, 11)]].sum(axis=1) * 10
    
    # Add metadata
    your_format['age_months'] = mchat_df['Age_Mons']
    your_format['gender'] = mchat_df['Sex'].map({'m': 1, 'f': 0})
    your_format['group'] = mchat_df['Class'].map({'Yes': 1, 'No': 0})
    
    return your_format
```

---

### **Script 2: DSM-5 Integration**

```python
def integrate_dsm5_dataset(dsm5_file):
    """
    Integrate DSM-5 criteria dataset into your training pipeline
    """
    dsm5_df = pd.read_csv(dsm5_file)
    
    # Filter to age 2-3.5
    dsm5_df = dsm5_df[
        (dsm5_df['Age_Mons'] >= 24) & 
        (dsm5_df['Age_Mons'] < 42)
    ]
    
    # Map DSM-5 criteria to your questionnaire structure
    your_format = pd.DataFrame()
    
    # Social Communication Domain → Your Social Features
    social_criteria = [
        'Social_Emotional_Reciprocity',  # 0-3 severity
        'Nonverbal_Communication',       # 0-3 severity
        'Developing_Relationships'       # 0-3 severity
    ]
    
    your_format['social_responsiveness_score'] = (
        dsm5_df[social_criteria].mean(axis=1) / 3.0 * 100
    )
    
    # Restricted/Repetitive Domain → Your Cognitive Flexibility
    rrb_criteria = [
        'Stereotyped_Movements',         # 0-3 severity
        'Insistence_Sameness',           # 0-3 severity
        'Restricted_Interests',          # 0-3 severity
        'Sensory_Issues'                 # 0-3 severity
    ]
    
    your_format['cognitive_flexibility_score'] = (
        dsm5_df[rrb_criteria].mean(axis=1) / 3.0 * 100
    )
    
    # Map to your Q1-Q10 structure (approximate mapping)
    # Q1 (Name Response) ← Social Emotional Reciprocity
    your_format['q1_name_response'] = (
        dsm5_df['Social_Emotional_Reciprocity'] >= 2
    ).astype(int)
    
    # Q4 (Eye Contact) ← Nonverbal Communication
    your_format['q4_eye_contact'] = (
        dsm5_df['Nonverbal_Communication'] >= 2
    ).astype(int)
    
    # Q2, Q3 (Routine/Toy) ← Insistence Sameness
    your_format['q2_routine_change'] = (
        dsm5_df['Insistence_Sameness'] >= 2
    ).astype(int)
    your_format['q3_toy_switching'] = (
        dsm5_df['Restricted_Interests'] >= 2
    ).astype(int)
    
    # Q6 (Sensory) ← Sensory Issues
    your_format['q6_sensory'] = (
        dsm5_df['Sensory_Issues'] >= 2
    ).astype(int)
    
    # Calculate critical items (DSM-5: ≥2 criteria in each domain)
    your_format['critical_items_failed'] = (
        (dsm5_df[social_criteria] >= 2).sum(axis=1) +
        (dsm5_df[rrb_criteria] >= 2).sum(axis=1)
    )
    
    # Add metadata
    your_format['age_months'] = dsm5_df['Age_Mons']
    your_format['group'] = dsm5_df['Class'].map({'ASD': 1, 'TD': 0})
    
    return your_format
```

---

### **Script 3: NIH Toolbox Norms Integration**

```python
def integrate_nih_norms(nih_norms_file):
    """
    Load NIH Toolbox DCCS norms for age normalization
    """
    nih_norms = pd.read_csv(nih_norms_file)
    
    # Create lookup dictionary
    norms_dict = {}
    for _, row in nih_norms.iterrows():
        age_months = row['Age_Months']
        norms_dict[age_months] = {
            'mean': row['Mean_Score'],
            'std': row['Std_Dev'],
            'p25': row['Percentile_25'],
            'p75': row['Percentile_75']
        }
    
    return norms_dict

def normalize_with_nih_norms(score, age_months, norms_dict):
    """
    Normalize score using NIH Toolbox norms
    """
    # Find closest age norm
    closest_age = min(norms_dict.keys(), key=lambda x: abs(x - age_months))
    norms = norms_dict[closest_age]
    
    # Calculate z-score
    zscore = (score - norms['mean']) / norms['std']
    
    return zscore

# Usage in feature engineering
def add_nih_normalized_features(df, norms_dict):
    """
    Add NIH-normalized features to dataset
    """
    df['social_responsiveness_nih_zscore'] = df.apply(
        lambda row: normalize_with_nih_norms(
            row['social_responsiveness_score'],
            row['age_months'],
            norms_dict
        ),
        axis=1
    )
    
    df['joint_attention_nih_zscore'] = df.apply(
        lambda row: normalize_with_nih_norms(
            row['joint_attention_score'],
            row['age_months'],
            norms_dict
        ),
        axis=1
    )
    
    return df
```

---

## 📋 **Complete Integration Pipeline**

```python
def create_combined_training_dataset():
    """
    Combine all datasets: External + M-CHAT + DSM-5
    """
    datasets = []
    
    # 1. External datasets (from previous script)
    print("Loading external datasets...")
    external_df = prepare_training_data_from_external()
    datasets.append(external_df)
    
    # 2. M-CHAT dataset (if available)
    try:
        print("Loading M-CHAT dataset...")
        mchat_df = integrate_mchat_dataset('datasets/mchat_data.csv')
        datasets.append(mchat_df)
    except FileNotFoundError:
        print("⚠️ M-CHAT dataset not found, skipping...")
    
    # 3. DSM-5 dataset (if available)
    try:
        print("Loading DSM-5 dataset...")
        dsm5_df = integrate_dsm5_dataset('datasets/dsm5_data.csv')
        datasets.append(dsm5_df)
    except FileNotFoundError:
        print("⚠️ DSM-5 dataset not found, skipping...")
    
    # 4. Combine all datasets
    combined_df = pd.concat(datasets, ignore_index=True)
    
    # 5. Apply NIH Toolbox normalization (if available)
    try:
        print("Applying NIH Toolbox norms...")
        nih_norms = integrate_nih_norms('datasets/nih_dccs_norms.csv')
        combined_df = add_nih_normalized_features(combined_df, nih_norms)
    except FileNotFoundError:
        print("⚠️ NIH norms not found, using internal normalization...")
    
    # 6. Final feature engineering
    combined_df = engineer_final_features(combined_df)
    
    return combined_df

def engineer_final_features(df):
    """
    Create final model features matching your structure
    """
    # Age-normalize (if NIH norms not available)
    if 'social_responsiveness_nih_zscore' not in df.columns:
        df['social_responsiveness_zscore'] = stats.zscore(
            df['social_responsiveness_score'].fillna(df['social_responsiveness_score'].mean())
        )
    
    if 'joint_attention_nih_zscore' not in df.columns:
        df['joint_attention_zscore'] = stats.zscore(
            df['joint_attention_score'].fillna(df['joint_attention_score'].mean())
        )
    
    df['total_score_zscore'] = stats.zscore(
        df['total_score'].fillna(df['total_score'].mean())
    )
    
    # Binary flags
    df['low_attention_flag'] = (df['attention_level'] <= 2).astype(int)
    df['high_critical_items_flag'] = (df['critical_items_failed'] >= 3).astype(int)
    df['low_social_flag'] = (df['social_responsiveness_score'] < 50).astype(int)
    
    # Select final features
    final_features = [
        'age_months',
        'critical_items_failed',
        'completion_time_sec',
        'social_responsiveness_zscore',
        'joint_attention_zscore',
        'total_score_zscore',
        'low_attention_flag',
        'high_critical_items_flag',
        'low_social_flag',
        'group'
    ]
    
    return df[final_features]
```

---

## 🔍 **Where to Find These Datasets**

### **Quick Search Guide**

1. **M-CHAT Dataset:**
   ```
   Kaggle: "M-CHAT autism" OR "Autism Screening"
   UCI: "Autism Screening Adult and Child Data"
   Google Scholar: "M-CHAT dataset" + "autism screening"
   ```

2. **DSM-5 Dataset:**
   ```
   Google Scholar: "DSM-5 autism dataset" OR "ADOS-2 dataset"
   ResearchGate: "autism DSM-5 criteria dataset"
   ```

3. **NIH Toolbox:**
   ```
   Official: https://www.healthmeasures.net/
   Search: "NIH Toolbox DCCS norms" OR "NIH Toolbox normative data"
   ```

---

## ✅ **Summary**

**Training Set Composition:**
- ✅ External datasets: ~2,314 samples
- ✅ M-CHAT datasets: Add when found
- ✅ DSM-5 datasets: Add when found
- ✅ **Total:** ~2,500+ samples (estimated)

**Test Set:**
- ✅ Your hospital data: 40 samples (gold standard)

**Normalization:**
- ✅ Use NIH Toolbox norms when available
- ✅ Fallback to internal z-score normalization

---

**Status:** Ready to integrate! 🚀
