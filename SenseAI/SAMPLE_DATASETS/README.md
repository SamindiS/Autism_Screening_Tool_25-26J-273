# 📊 Sample Datasets for SenseAI ASD Screening Project

## Overview

This folder contains sample datasets demonstrating the expected ML training data format for each age group.

## 🔗 Connect to Google Colab

### Option 1: Google Drive (Recommended)
1. Upload this `SAMPLE_DATASETS/` folder to Google Drive
2. Open `ML_TRAINING/ASD_ML_Training.ipynb` in Colab
3. Run the cells!

### Option 2: Direct File Upload
```python
from google.colab import files
uploaded = files.upload()  # Select CSV files
```

### Option 3: GitHub Clone
```python
!git clone https://github.com/yourusername/Autism_Screening_Tool.git
%cd Autism_Screening_Tool/SAMPLE_DATASETS
```

## Dataset Structure

```
SAMPLE_DATASETS/
├── age_2_3_questionnaire_asd.csv
├── age_2_3_questionnaire_control.csv
├── age_3_5_frog_jump_asd.csv
├── age_3_5_frog_jump_control.csv
├── age_5_6_dccs_asd.csv
├── age_5_6_dccs_control.csv
└── merged_complete_dataset.csv
```

## Dataset Statistics

### Current Sample Datasets (For ML Training Demo)

| Group | Age 2-3 | Age 3.5-5 | Age 5.5-6+ | Total |
|-------|---------|-----------|------------|-------|
| **ASD Level 1** | 10 | 10 | 10 | **30** |
| **ASD Level 2** | 10 | 10 | 10 | **30** |
| **ASD Level 3** | 10 | 10 | 10 | **30** |
| **Control (TD)** | 30 | 30 | 30 | **90** |
| **Total** | **60** | **60** | **60** | **180** |

### Data Collection Targets (For Production)

| Group | Minimum | Ideal | Current Sample |
|-------|---------|-------|----------------|
| ASD (Level 1) | 20 | 40 | 30 ✅ |
| ASD (Level 2) | 20 | 40 | 30 ✅ |
| ASD (Level 3) | 10 | 20 | 30 ✅ |
| Control (TD) | 80 | 150 | 90 ✅ |
| **Total** | **130** | **250** | **180** ✅ |

## Key Features Per Age Group

### Age 2-3 (Questionnaire - M-CHAT-R/F Style)
**Primary ASD Markers:**
- `critical_items_failed` (0-5): Q1, Q4, Q5, Q7, Q9
- `q5_pointing`: Joint attention (MOST CRITICAL)
- `q1_name_response`: Social responsiveness
- `q4_eye_contact`: Social communication

**Domain Scores (0-100):**
- `social_responsiveness_score`
- `cognitive_flexibility_score`
- `joint_attention_score`
- `social_communication_score`

**Distribution in Sample:**
- ASD Level 1: 0-1 critical items failed, 70-80% scores
- ASD Level 2: 2-3 critical items failed, 50-60% scores
- ASD Level 3: 4-5 critical items failed, 30-40% scores
- Control: 0 critical items failed, 90-100% scores

### Age 3.5-5 (Frog Jump - Go/No-Go)
**Primary ASD Markers:**
- `commission_errors` (0-8): False positives on No-Go trials
- `commission_error_rate` (0-100%): Inhibitory control failure
- `nogo_accuracy` (0-100%): Ability to inhibit responses
- `rt_variability` (ms): Attention consistency (HIGH in ASD)

**Distribution in Sample:**
- ASD Level 1: 1-2 commission errors, 70-80% No-Go accuracy
- ASD Level 2: 3-4 commission errors, 45-55% No-Go accuracy
- ASD Level 3: 6-7 commission errors, 12-25% No-Go accuracy
- Control: 0 commission errors, 93-100% No-Go accuracy

### Age 5.5-6+ (DCCS - Cognitive Flexibility)
**Primary ASD Markers:**
- `total_perseverative_errors` (0-12): GOLD STANDARD marker
- `post_switch_accuracy` (0-100%): Rule-switching ability
- `switch_cost_ms` (ms): Cognitive flexibility cost
- `perseverative_error_rate_post_switch` (0-100%)

**Distribution in Sample:**
- ASD Level 1: 2-3 perseverative errors, 73-78% post-switch accuracy
- ASD Level 2: 5-7 perseverative errors, 50-58% post-switch accuracy
- ASD Level 3: 8-12 perseverative errors, 25-38% post-switch accuracy
- Control: 0 perseverative errors, 94-96% post-switch accuracy

## Target Labels

| Column | Description | Values |
|--------|-------------|--------|
| `asd_label` | Binary ASD diagnosis | 0=TD (Control), 1=ASD |
| `severity_label` | ASD severity level | 0=TD, 1=Level 1 (Mild), 2=Level 2 (Moderate), 3=Level 3 (Severe) |
| `risk_level` | Clinical risk | low, moderate, high |

## Dataset Quality & Realism

### ✅ Realistic Distributions
- **Age stratification**: Proper age ranges for each assessment type
- **Severity gradients**: Clear differences between Level 1, 2, 3 ASD
- **Control group**: High-performing typically developing children
- **Feature correlations**: Realistic relationships between features (e.g., higher perseverative errors = lower accuracy)

### ✅ Clinical Patterns
- **ASD Level 1**: Mild impairments, some difficulty with rule-switching
- **ASD Level 2**: Moderate impairments, significant cognitive flexibility deficits
- **ASD Level 3**: Severe impairments, high perseveration, low accuracy

### ✅ Multilingual Support
- Languages: English (en), Sinhala (si), Tamil (ta)
- Balanced distribution across language groups

### ✅ Geographic Distribution
- **ASD Group**: LRH (Lady Ridgeway Hospital) - Clinical setting
- **Control Group**: Preschools in Kandy, Colombo, Jaffna - Community settings

## Using These Datasets

### For ML Training
1. Use `merged_complete_dataset.csv` for complete training
2. Or use individual age-group files for age-specific models
3. All features are standardized and ready for ML algorithms

### For Model Evaluation
- **Binary Classification**: `asd_label` (0 vs 1)
- **Multiclass Classification**: `severity_label` (0, 1, 2, 3)
- **Risk Prediction**: `risk_level` (low, moderate, high)

### Expected Model Performance (With Real Data)
- **Binary Classification**: Target 85-95% accuracy
- **Severity Classification**: Target 75-85% accuracy
- **Risk Level Prediction**: Target 80-90% accuracy

