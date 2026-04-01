# 🔧 Dataset Preprocessing Script Guide

**Purpose:** Prepare external datasets for age-specific model training

---

## 📋 **Quick Summary**

| Dataset | Age Group | Samples | Action |
|---------|-----------|---------|--------|
| Toddler Autism (July 2018) | 2-3.5 years | 768 | ✅ Use directly |
| Autism Screening Combined | 2-3.5 years | 1,546 | ✅ Use directly |
| Autism Screening Combined | 3.5-5.5 years | 592 | ⚠️ Use as auxiliary |
| Autism-Child-Data.arff | 4-11 years | 292 | ❌ Skip (age mismatch) |

---

## 🐍 **Python Preprocessing Script**

### **Script 1: Prepare Age 2-3.5 Dataset**

```python
import pandas as pd
import numpy as np

def prepare_age_2_3_5_dataset():
    """
    Combine and preprocess datasets for Age 2-3.5 questionnaire model
    """
    
    # Load Dataset 1: Toddler Autism Dataset (July 2018)
    df1 = pd.read_csv('Online Datasets/Toddler Autism dataset July 2018.csv')
    
    # Load Dataset 2: Autism Screening Data Combined
    df2 = pd.read_csv('Online Datasets/Autism screening data for toddlers/Autism_Screening_Data_Combined.csv')
    
    # ===== Dataset 1 Preprocessing =====
    # Filter to age 2-3.5 (24-42 months)
    df1_filtered = df1[(df1['Age_Mons'] >= 24) & (df1['Age_Mons'] < 42)].copy()
    
    # Extract features
    df1_features = pd.DataFrame()
    df1_features['age_months'] = df1_filtered['Age_Mons']
    df1_features['gender'] = df1_filtered['Sex'].map({'m': 1, 'f': 0})
    
    # Extract A1-A10 features
    for i in range(1, 11):
        df1_features[f'A{i}'] = df1_filtered[f'A{i}']
    
    # Q-CHAT-10 score
    df1_features['qchat_10_score'] = df1_filtered['Qchat-10-Score']
    
    # Calculate total score from A1-A10
    df1_features['total_score'] = df1_filtered[[f'A{i}' for i in range(1, 11)]].sum(axis=1)
    
    # Clinical factors
    df1_features['jaundice'] = df1_filtered['Jaundice'].map({'yes': 1, 'no': 0})
    df1_features['family_asd'] = df1_filtered['Family_mem_with_ASD'].map({'yes': 1, 'no': 0})
    
    # Target variable
    df1_features['group'] = df1_filtered['Class/ASD Traits '].map({'Yes': 1, 'No': 0})
    
    # ===== Dataset 2 Preprocessing =====
    # Filter to age 2-3.5 (24-42 months)
    df2_filtered = df2[(df2['Age'] >= 24) & (df2['Age'] < 42)].copy()
    
    # Extract features
    df2_features = pd.DataFrame()
    df2_features['age_months'] = df2_filtered['Age']
    df2_features['gender'] = df2_filtered['Sex'].map({'m': 1, 'f': 0})
    
    # Extract A1-A10 features
    for i in range(1, 11):
        df2_features[f'A{i}'] = df2_filtered[f'A{i}']
    
    # Calculate Q-CHAT-10 score from A1-A10
    df2_features['qchat_10_score'] = df2_filtered[[f'A{i}' for i in range(1, 11)]].sum(axis=1)
    df2_features['total_score'] = df2_features['qchat_10_score']
    
    # Clinical factors
    df2_features['jaundice'] = df2_filtered['Jauundice'].map({'yes': 1, 'no': 0})
    df2_features['family_asd'] = df2_filtered['Family_ASD'].map({'yes': 1, 'no': 0})
    
    # Target variable
    df2_features['group'] = df2_filtered['Class'].map({'YES': 1, 'NO': 0})
    
    # ===== Combine Datasets =====
    # Ensure same columns
    common_columns = ['age_months', 'gender', 'A1', 'A2', 'A3', 'A4', 'A5', 
                      'A6', 'A7', 'A8', 'A9', 'A10', 'qchat_10_score', 
                      'total_score', 'jaundice', 'family_asd', 'group']
    
    df1_features = df1_features[common_columns]
    df2_features = df2_features[common_columns]
    
    # Combine
    combined_df = pd.concat([df1_features, df2_features], ignore_index=True)
    
    # ===== Final Preprocessing =====
    # Remove duplicates (if any)
    combined_df = combined_df.drop_duplicates()
    
    # Handle missing values
    combined_df = combined_df.fillna(combined_df.median())
    
    # Verify class distribution
    print("Class Distribution:")
    print(combined_df['group'].value_counts())
    print(f"\nTotal samples: {len(combined_df)}")
    print(f"ASD samples: {combined_df['group'].sum()}")
    print(f"Control samples: {len(combined_df) - combined_df['group'].sum()}")
    
    # Save preprocessed dataset
    combined_df.to_csv('SAMPLE_DATASETS/age_2_3_5_questionnaire_combined.csv', index=False)
    
    return combined_df

# Run preprocessing
if __name__ == '__main__':
    df = prepare_age_2_3_5_dataset()
    print("\n✅ Dataset prepared successfully!")
    print(f"Saved to: SAMPLE_DATASETS/age_2_3_5_questionnaire_combined.csv")
```

---

### **Script 2: Prepare Age 3.5-5.5 Auxiliary Dataset**

```python
def prepare_age_3_5_5_5_auxiliary():
    """
    Extract questionnaire data for Age 3.5-5.5 as auxiliary features
    Note: This is questionnaire data, NOT game data
    """
    
    # Load dataset
    df = pd.read_csv('Online Datasets/Autism screening data for toddlers/Autism_Screening_Data_Combined.csv')
    
    # Filter to age 3.5-5.5 (42-66 months)
    df_filtered = df[(df['Age'] >= 42) & (df['Age'] < 66)].copy()
    
    # Extract features (same as age 2-3.5)
    df_features = pd.DataFrame()
    df_features['age_months'] = df_filtered['Age']
    df_features['gender'] = df_filtered['Sex'].map({'m': 1, 'f': 0})
    
    # Extract A1-A10 features
    for i in range(1, 11):
        df_features[f'A{i}'] = df_filtered[f'A{i}']
    
    # Calculate Q-CHAT-10 score
    df_features['qchat_10_score'] = df_filtered[[f'A{i}' for i in range(1, 11)]].sum(axis=1)
    df_features['total_score'] = df_features['qchat_10_score']
    
    # Clinical factors
    df_features['jaundice'] = df_filtered['Jauundice'].map({'yes': 1, 'no': 0})
    df_features['family_asd'] = df_filtered['Family_ASD'].map({'yes': 1, 'no': 0})
    
    # Target variable
    df_features['group'] = df_filtered['Class'].map({'YES': 1, 'NO': 0})
    
    # Save
    df_features.to_csv('SAMPLE_DATASETS/age_3_5_5_5_questionnaire_auxiliary.csv', index=False)
    
    print(f"✅ Auxiliary dataset prepared: {len(df_features)} samples")
    print("Note: This is questionnaire data, not game data!")
    print("Use as auxiliary features alongside your 29 game samples.")
    
    return df_features
```

---

## 📊 **Expected Output**

### **Age 2-3.5 Combined Dataset**

**Expected Statistics:**
- **Total Samples:** ~2,314 (768 + 1,546)
- **ASD Samples:** ~1,500-1,600
- **Control Samples:** ~700-800
- **Features:** 17 columns (age, gender, A1-A10, qchat_10_score, total_score, jaundice, family_asd, group)

**File:** `SAMPLE_DATASETS/age_2_3_5_questionnaire_combined.csv`

---

### **Age 3.5-5.5 Auxiliary Dataset**

**Expected Statistics:**
- **Total Samples:** 592
- **Features:** Same as above (questionnaire features only)

**File:** `SAMPLE_DATASETS/age_3_5_5_5_questionnaire_auxiliary.csv`

**Usage:** Combine with your existing 29 game samples for enhanced model training

---

## ✅ **Next Steps**

1. **Run Script 1** to create Age 2-3.5 combined dataset
2. **Run Script 2** to create Age 3.5-5.5 auxiliary dataset
3. **Update training notebooks** to use new datasets
4. **Retrain models** with larger datasets
5. **Evaluate performance** improvements

---

## 🎯 **Feature Mapping Reference**

| External Dataset | Your System | Description |
|----------------|-------------|-------------|
| `A1` - `A10` | `Q1` - `Q10` | Questionnaire items (binary 0/1) |
| `Qchat-10-Score` | `total_score` | Total questionnaire score |
| `Age_Mons` / `Age` | `age_months` | Age in months |
| `Sex` | `gender` | Gender (m=1, f=0) |
| `Jaundice` / `Jauundice` | `jaundice` | Jaundice history (yes=1, no=0) |
| `Family_mem_with_ASD` / `Family_ASD` | `family_asd` | Family ASD history (yes=1, no=0) |
| `Class/ASD Traits` / `Class` | `group` | Target (Yes/YES=1, No/NO=0) |

---

**Status:** Ready to run! 🚀
