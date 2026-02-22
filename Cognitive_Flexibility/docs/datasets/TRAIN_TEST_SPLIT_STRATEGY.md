# 🎯 Train/Test Split Strategy: Hospital Data as Test Set

**Strategy:** Use external datasets for training, hospital data for testing

---

## 📊 **Your Current Data**

### **Hospital-Collected Data (Use as TEST SET)**

| Dataset | Samples | Group | Age Range | Status |
|---------|---------|-------|-----------|--------|
| `age_2_3_questionnaire_asd.csv.csv` | 10 | ASD | 24-36 months | ✅ Test Set |
| `age_2_3_questionnaire_control.csv` | 30 | Control | 24-32 months | ✅ Test Set |
| **Total** | **40** | **Mixed** | **24-36 months** | **TEST SET** |

**Why Use as Test Set:**
- ✅ Real clinical data from your hospital
- ✅ Represents actual deployment scenario
- ✅ Small but high-quality (gold standard)
- ✅ Ensures model works on YOUR data

---

### **External Datasets (Use as TRAINING SET)**

| Dataset | Samples | Age Group | Status |
|---------|---------|-----------|--------|
| Toddler Autism (July 2018) | 768 | 2-3.5 years | ✅ Training |
| Autism Screening Combined | 1,546 | 2-3.5 years | ✅ Training |
| **Total** | **~2,314** | **2-3.5 years** | **TRAINING SET** |

**Why Use for Training:**
- ✅ Large sample size (2,314 vs 40)
- ✅ Diverse population
- ✅ Public datasets (well-validated)
- ✅ Provides robust model training

---

## 🔄 **Feature Mapping: External → Your System**

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

### **External Dataset Features**

**Toddler Autism (July 2018):**
- `A1` to `A10`: Binary questionnaire items (0/1)
- `Qchat-10-Score`: Total score (0-10)
- `Age_Mons`: Age in months
- `Sex`: Gender
- `Class/ASD Traits`: Target (Yes/No)

**Autism Screening Combined:**
- `A1` to `A10`: Binary questionnaire items (0/1)
- `Age`: Age in months
- `Sex`: Gender
- `Class`: Target (YES/NO)

### **Feature Extraction Strategy**

You need to **derive** your features from external datasets:

| Your Feature | How to Extract from External Data |
|--------------|----------------------------------|
| `age_months` | Direct: `Age_Mons` or `Age` |
| `critical_items_failed` | **Calculate**: Count A1-A10 where value = 1 (ASD indicators) |
| `completion_time_sec` | **Missing**: Use median or impute |
| `social_responsiveness_zscore` | **Calculate**: From A1, A4, A5 (social items) → normalize by age |
| `joint_attention_zscore` | **Calculate**: From A5, A9 (joint attention items) → normalize by age |
| `total_score_zscore` | **Calculate**: Sum of A1-A10 → normalize by age |
| `low_attention_flag` | **Derive**: If attention-related items (A1, A4) < threshold |
| `high_critical_items_flag` | **Derive**: If critical_items_failed >= 3 |
| `low_social_flag` | **Derive**: If social items (A1, A4, A5) < threshold |

---

## 🧪 **M-CHAT, DSM-5, NIH Dataset Integration**

### **1. M-CHAT-R/F Dataset**

**What is M-CHAT?**
- Modified Checklist for Autism in Toddlers - Revised/Follow-Up
- Standardized screening tool for ages 16-30 months
- 20 questions (binary yes/no)
- Critical items: 2, 5, 7, 12, 13, 15

**Where to Find:**
- **Kaggle**: Search "M-CHAT autism dataset"
- **UCI ML Repository**: Autism Screening Dataset
- **Research Papers**: Many papers publish M-CHAT datasets

**Integration Strategy:**
```python
# Map M-CHAT questions to your Q1-Q10 structure
# M-CHAT has 20 questions, you have 10
# Use critical items mapping:
mchat_critical = [2, 5, 7, 12, 13, 15]  # M-CHAT critical items
your_critical = [1, 4, 5, 7, 9]  # Your critical items

# Map M-CHAT to your structure
def map_mchat_to_your_format(mchat_data):
    # Extract critical items
    # Calculate social responsiveness
    # Calculate joint attention
    # Normalize by age
    pass
```

---

### **2. DSM-5 Criteria Dataset**

**What is DSM-5?**
- Diagnostic and Statistical Manual of Mental Disorders, 5th Edition
- Official ASD diagnostic criteria
- Two core domains:
  1. **Social Communication** (3 criteria)
  2. **Restricted/Repetitive Behaviors** (4 criteria)

**Where to Find:**
- **Research Datasets**: Papers using DSM-5 criteria
- **Clinical Databases**: Hospital records coded with DSM-5
- **ADOS-2 Datasets**: Often aligned with DSM-5

**Integration Strategy:**
```python
# Map DSM-5 criteria to your features
dsm5_social_communication = [
    'social_emotional_reciprocity',
    'nonverbal_communication',
    'developing_maintaining_relationships'
]

dsm5_restricted_repetitive = [
    'stereotyped_repetitive_movements',
    'insistence_on_sameness',
    'restricted_interests',
    'sensory_hyper_hyposensitivity'
]

# Map to your questionnaire structure
# Your Q1-Q10 can map to DSM-5 criteria
```

---

### **3. NIH Toolbox Dataset**

**What is NIH Toolbox?**
- National Institutes of Health Toolbox
- Standardized cognitive assessments
- Includes DCCS (Dimensional Change Card Sort) norms
- Age-normalized scores (z-scores)

**Where to Find:**
- **NIH Toolbox Website**: https://www.healthmeasures.net/
- **Research Papers**: Papers using NIH Toolbox norms
- **DCCS Norms**: Age-specific normative data

**Integration Strategy:**
```python
# Use NIH Toolbox norms for age normalization
# Your z-scores can use NIH norms as reference
from nih_toolbox_norms import get_dccs_norms

def normalize_with_nih_norms(score, age_months):
    norms = get_dccs_norms(age_months)
    zscore = (score - norms['mean']) / norms['std']
    return zscore
```

---

## 📝 **Complete Preprocessing Script**

```python
import pandas as pd
import numpy as np
from scipy import stats

def prepare_training_data_from_external():
    """
    Prepare training data from external datasets
    Maps external features to your model's feature structure
    """
    
    # Load external datasets
    df1 = pd.read_csv('Online Datasets/Toddler Autism dataset July 2018.csv')
    df2 = pd.read_csv('Online Datasets/Autism screening data for toddlers/Autism_Screening_Data_Combined.csv')
    
    # Filter to age 2-3.5 (24-42 months)
    df1_filtered = df1[(df1['Age_Mons'] >= 24) & (df1['Age_Mons'] < 42)]
    df2_filtered = df2[(df2['Age'] >= 24) & (df2['Age'] < 42)]
    
    # Standardize column names
    df1_features = extract_features_from_external(df1_filtered, 'Age_Mons', 'Qchat-10-Score')
    df2_features = extract_features_from_external(df2_filtered, 'Age', None)
    
    # Combine
    training_df = pd.concat([df1_features, df2_features], ignore_index=True)
    
    return training_df

def extract_features_from_external(df, age_col, qchat_col):
    """
    Extract your model features from external dataset structure
    """
    features = pd.DataFrame()
    
    # 1. age_months (direct)
    features['age_months'] = df[age_col]
    
    # 2. critical_items_failed
    # Count how many A1-A10 are 1 (ASD indicators)
    a_cols = [f'A{i}' for i in range(1, 11)]
    features['critical_items_failed'] = df[a_cols].sum(axis=1)
    
    # 3. completion_time_sec (missing - impute)
    features['completion_time_sec'] = 300  # Use median/mean from your data
    
    # 4. Calculate domain scores
    # Social Responsiveness: A1 (name response), A4 (eye contact), A5 (pointing)
    features['social_responsiveness_raw'] = (
        df['A1'] + df['A4'] + df['A5']
    ) / 3.0 * 100  # Convert to 0-100 scale
    
    # Joint Attention: A5 (pointing), A9 (joint attention)
    features['joint_attention_raw'] = (
        df['A5'] + df['A9']
    ) / 2.0 * 100
    
    # Total Score: Sum of A1-A10, convert to 0-100
    if qchat_col and qchat_col in df.columns:
        features['total_score_raw'] = df[qchat_col] * 10  # Q-CHAT is 0-10, convert to 0-100
    else:
        features['total_score_raw'] = df[a_cols].sum(axis=1) * 10
    
    # 5. Age-normalize (z-scores)
    # Group by age bins for normalization
    age_bins = [24, 30, 36, 42]
    features['age_bin'] = pd.cut(features['age_months'], bins=age_bins, labels=False)
    
    for col in ['social_responsiveness_raw', 'joint_attention_raw', 'total_score_raw']:
        zscore_col = col.replace('_raw', '_zscore')
        features[zscore_col] = features.groupby('age_bin')[col].transform(
            lambda x: stats.zscore(x.fillna(x.mean()))
        )
    
    # 6. Binary flags
    features['low_attention_flag'] = (
        (df['A1'] == 1) | (df['A4'] == 1)
    ).astype(int)
    
    features['high_critical_items_flag'] = (
        features['critical_items_failed'] >= 3
    ).astype(int)
    
    features['low_social_flag'] = (
        features['social_responsiveness_raw'] < 50
    ).astype(int)
    
    # 7. Target variable
    if 'Class/ASD Traits ' in df.columns:
        features['group'] = df['Class/ASD Traits '].map({'Yes': 1, 'No': 0})
    elif 'Class' in df.columns:
        features['group'] = df['Class'].map({'YES': 1, 'NO': 0})
    
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
    
    return features[final_features]

def prepare_test_data_from_hospital():
    """
    Prepare test data from your hospital-collected data
    """
    df_asd = pd.read_csv('SAMPLE_DATASETS/age_2_3_questionnaire_asd.csv.csv')
    df_control = pd.read_csv('SAMPLE_DATASETS/age_2_3_questionnaire_control.csv')
    
    # Extract features matching your model structure
    test_features = []
    
    for df in [df_asd, df_control]:
        features = pd.DataFrame()
        
        # Direct features
        features['age_months'] = df['age_months']
        features['critical_items_failed'] = df['critical_items_failed']
        features['completion_time_sec'] = df['completion_time_sec']
        
        # Z-scores (if not present, calculate)
        if 'social_responsiveness_zscore' in df.columns:
            features['social_responsiveness_zscore'] = df['social_responsiveness_zscore']
        else:
            # Calculate from raw scores
            features['social_responsiveness_zscore'] = stats.zscore(
                df['social_responsiveness_score'].fillna(df['social_responsiveness_score'].mean())
            )
        
        if 'joint_attention_zscore' in df.columns:
            features['joint_attention_zscore'] = df['joint_attention_zscore']
        else:
            features['joint_attention_zscore'] = stats.zscore(
                df['joint_attention_score'].fillna(df['joint_attention_score'].mean())
            )
        
        if 'total_score_zscore' in df.columns:
            features['total_score_zscore'] = df['total_score_zscore']
        else:
            features['total_score_zscore'] = stats.zscore(
                df['total_score'].fillna(df['total_score'].mean())
            )
        
        # Binary flags
        features['low_attention_flag'] = (df['attention_level'] <= 2).astype(int)
        features['high_critical_items_flag'] = (df['critical_items_failed'] >= 3).astype(int)
        features['low_social_flag'] = (df['social_responsiveness_score'] < 50).astype(int)
        
        # Target
        if 'asd_label' in df.columns:
            features['group'] = df['asd_label']
        elif 'study_group' in df.columns:
            features['group'] = df['study_group'].map({'asd': 1, 'typically_developing': 0})
        
        test_features.append(features)
    
    test_df = pd.concat(test_features, ignore_index=True)
    return test_df

# Main execution
if __name__ == '__main__':
    print("🔄 Preparing Training Data from External Datasets...")
    train_df = prepare_training_data_from_external()
    print(f"✅ Training data: {len(train_df)} samples")
    
    print("\n🔄 Preparing Test Data from Hospital Data...")
    test_df = prepare_test_data_from_hospital()
    print(f"✅ Test data: {len(test_df)} samples")
    
    # Save
    train_df.to_csv('SAMPLE_DATASETS/train_age_2_3_5_external.csv', index=False)
    test_df.to_csv('SAMPLE_DATASETS/test_age_2_3_5_hospital.csv', index=False)
    
    print("\n✅ Datasets prepared!")
    print(f"Training: {len(train_df)} samples")
    print(f"Test: {len(test_df)} samples")
```

---

## 🎯 **M-CHAT Integration Guide**

### **Step 1: Download M-CHAT Dataset**

**Sources:**
1. **Kaggle**: "Autism Screening Dataset" (often includes M-CHAT)
2. **UCI ML Repository**: "Autism Screening Adult and Child Data"
3. **Research Papers**: Search "M-CHAT dataset" on Google Scholar

### **Step 2: Map M-CHAT to Your Structure**

```python
def map_mchat_to_your_format(mchat_df):
    """
    Map M-CHAT 20 questions to your 10-question structure
    """
    mapping = {
        # Your Q1 (Name Response) ← M-CHAT Q2, Q7
        'q1_name_response': mchat_df[['Q2', 'Q7']].max(axis=1),
        
        # Your Q4 (Eye Contact) ← M-CHAT Q5
        'q4_eye_contact': mchat_df['Q5'],
        
        # Your Q5 (Pointing) ← M-CHAT Q12
        'q5_pointing': mchat_df['Q12'],
        
        # Your Q9 (Joint Attention) ← M-CHAT Q13, Q15
        'q9_joint_attention': mchat_df[['Q13', 'Q15']].max(axis=1),
        
        # ... map other questions
    }
    
    # Convert to your format
    your_format = pd.DataFrame(mapping)
    
    # Calculate critical items (M-CHAT critical: 2, 5, 7, 12, 13, 15)
    critical_items = ['Q2', 'Q5', 'Q7', 'Q12', 'Q13', 'Q15']
    your_format['critical_items_failed'] = mchat_df[critical_items].sum(axis=1)
    
    return your_format
```

---

## 📋 **DSM-5 Integration Guide**

### **DSM-5 Criteria Mapping**

```python
def map_dsm5_to_your_features(dsm5_df):
    """
    Map DSM-5 criteria to your questionnaire features
    """
    # DSM-5 Social Communication Domain
    dsm5_social = [
        'social_emotional_reciprocity',  # Maps to Q1, Q9
        'nonverbal_communication',       # Maps to Q4, Q5
        'developing_relationships'        # Maps to Q8, Q10
    ]
    
    # DSM-5 Restricted/Repetitive Domain
    dsm5_rrb = [
        'stereotyped_movements',         # Maps to Q6
        'insistence_on_sameness',        # Maps to Q2, Q3
        'restricted_interests',          # Maps to Q3
        'sensory_issues'                 # Maps to Q6
    ]
    
    # Calculate your features from DSM-5
    features = pd.DataFrame()
    features['social_responsiveness_score'] = dsm5_df[dsm5_social].mean(axis=1) * 100
    features['cognitive_flexibility_score'] = dsm5_df[['insistence_on_sameness', 'restricted_interests']].mean(axis=1) * 100
    
    return features
```

---

## 🏥 **NIH Toolbox Integration Guide**

### **Using NIH DCCS Norms for Age Normalization**

```python
# NIH Toolbox DCCS Norms (example - you'll need actual norms)
NIH_DCCS_NORMS = {
    '24-30_months': {'mean': 65.0, 'std': 15.0},
    '30-36_months': {'mean': 72.0, 'std': 14.0},
    '36-42_months': {'mean': 78.0, 'std': 13.0},
}

def normalize_with_nih_norms(score, age_months):
    """Normalize score using NIH Toolbox norms"""
    if 24 <= age_months < 30:
        norms = NIH_DCCS_NORMS['24-30_months']
    elif 30 <= age_months < 36:
        norms = NIH_DCCS_NORMS['30-36_months']
    elif 36 <= age_months < 42:
        norms = NIH_DCCS_NORMS['36-42_months']
    else:
        return 0  # Out of range
    
    zscore = (score - norms['mean']) / norms['std']
    return zscore
```

---

## ✅ **Final Strategy Summary**

### **Training Set:**
- ✅ External datasets: ~2,314 samples
- ✅ M-CHAT datasets: Add if available
- ✅ Public research datasets: Add if available

### **Test Set:**
- ✅ Your hospital data: 40 samples (10 ASD + 30 Control)
- ✅ **DO NOT** use for training (keep separate)

### **Validation:**
- ✅ Use LOCO-CV (Leave-One-Child-Out) on training set
- ✅ Final evaluation on hospital test set
- ✅ Report both metrics

---

## 🚀 **Next Steps**

1. ✅ **Run preprocessing script** to prepare training/test sets
2. ✅ **Search for M-CHAT datasets** on Kaggle/UCI
3. ✅ **Download DSM-5-aligned datasets** from research papers
4. ✅ **Get NIH Toolbox norms** from official website
5. ✅ **Retrain model** with combined training set
6. ✅ **Evaluate** on hospital test set

---

**Status:** Ready to implement! 🎉
