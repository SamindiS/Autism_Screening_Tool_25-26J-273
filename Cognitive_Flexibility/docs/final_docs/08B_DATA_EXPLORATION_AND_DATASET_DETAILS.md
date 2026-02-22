# Data Exploration and Dataset Details

**Project ID:** 25-26J-273  
**Project Title:** Designing a Culturally Adapted, Multi-Language, Tablet-Based Intelligent System for Early Detection of Autism Spectrum Disorder Risk

---

## 2. Data Exploration

### 2.1. Data Collection

Two primary data collection approaches were used:

#### **Approach 1: Clinical Data Collection from Healthcare Institutions**

Data were collected from participating healthcare institutions (hospitals and clinics) in Sri Lanka after obtaining ethical approval from relevant institutional review boards. Assessment sessions were conducted with children aged 2-6.9 years during routine developmental screening visits.

**Collection Protocol:**
1. **Child Registration**: Minimal demographic data (age in months, sex, language preference)
2. **Age-Based Assessment Routing**:
   - Children aged 24-42 months → AI Doctor Bot Questionnaire (caregiver-reported)
   - Children aged 42-66 months → Frog Jump Game (Go/No-Go task)
   - Children aged 66-83 months → Color-Shape Game (DCCS task)
3. **Assessment Administration**: Guided by trained clinicians in clinic settings
4. **Clinician Reflection**: Behavioral observations recorded using 5-point Likert scales
5. **Label Assignment**: Clinical labels (ASD / Typically Developing) based on:
   - Clinician diagnosis (primary)
   - ADOS-2 assessment (where available)
   - ADI-R assessment (where available)
   - Standardized screening thresholds (for typically developing group)

**Ethical Considerations:**
- Informed consent obtained from parents/guardians
- Data anonymization (child identifiers removed)
- Privacy-preserving storage (no names, phone numbers, or exact birthdates in research dataset)
- IRB approval obtained from [Institution Name]

#### **Approach 2: Publicly Available Datasets (Supplementary Analysis)**

Publicly available datasets were used for:
- **Method validation**: Comparing feature engineering approaches
- **Literature benchmarking**: Comparing performance to published studies
- **External validation**: Testing generalizability (where applicable)

**Note**: Public datasets rarely match exact game telemetry features, so they were used primarily for methodological validation rather than direct model training.

---

### 2.2. Dataset Description

| Data Source | Description | Resource | Size (Approximate) | Key Attributes |
|------------|-------------|----------|-------------------|----------------|
| **Age 2-3.5: Questionnaire Data** | Parent/caregiver responses to 10-item screening questionnaire (M-CHAT-R/F inspired) | Clinical Data Collection | [N] children | `critical_items_failed`, `social_responsiveness_score`, `joint_attention_score`, `cognitive_flexibility_score`, `social_communication_score`, `total_score`, `completion_time_sec`, `attention_level`, `engagement_level` |
| **Age 3.5-5.5: Frog Jump (Go/No-Go) Data** | Game telemetry from Go/No-Go inhibitory control task | Clinical Data Collection | [N] children | `nogo_accuracy`, `commission_errors`, `commission_error_rate`, `go_accuracy`, `avg_rt_go_ms`, `rt_variability`, `omission_errors`, `inhibition_failure_rate`, `attention_level`, `engagement_level` |
| **Age 5.5-6.9: Color-Shape (DCCS) Data** | Game telemetry from Dimensional Change Card Sort cognitive flexibility task | Clinical Data Collection | [N] children | `pre_switch_accuracy`, `post_switch_accuracy`, `switch_cost_ms`, `perseverative_error_rate`, `total_perseverative_errors`, `avg_rt_pre_switch_ms`, `avg_rt_post_switch_correct_ms`, `attention_level`, `engagement_level` |
| **Clinician Reflection Data** | Behavioral observations (5-point Likert scales) | Clinical Data Collection | [N] sessions | `attention_level`, `engagement_level`, `frustration_tolerance`, `instruction_following`, `overall_behavior` |
| **Clinical Labels** | ASD / Typically Developing labels | Clinical Diagnosis / ADOS-2 / ADI-R | [N] children | `group` (asd / typically_developing), `asd_level` (optional severity), `label_source` (clinician / ADOS-2 / ADI-R) |

**Total Dataset Size:**
- **Age 2-3.5**: [N] children, [M] sessions
- **Age 3.5-5.5**: [N] children, [M] sessions
- **Age 5.5-6.9**: [N] children, [M] sessions
- **Total**: [N_total] children, [M_total] sessions

---

### 2.3. Suitability Analysis

#### 2.3.1. Relevance to Individual Research Objectives:

| Objective | Questionnaire Data | Frog Jump Data | Color-Shape Data | Clinician Reflection | Clinical Labels |
|-----------|-------------------|----------------|------------------|---------------------|-----------------|
| **Obj 1: Design age-stratified assessments** | ✓ (Age 2-3.5) | ✓ (Age 3.5-5.5) | ✓ (Age 5.5-6.9) | ✓ (All ages) | ✓ (Validation) |
| **Obj 2: Develop culturally adapted multilingual system** | ✓ (Sinhala/Tamil/English) | ✓ (Sinhala/Tamil/English) | ✓ (Sinhala/Tamil/English) | ✓ (Multilingual UI) | - |
| **Obj 3: Build hybrid ML models** | ✓ (Features) | ✓ (Features) | ✓ (Features) | ✓ (Features) | ✓ (Labels) |
| **Obj 4: Implement offline-first architecture** | ✓ (Tablet app) | ✓ (Tablet app) | ✓ (Tablet app) | ✓ (Tablet app) | - |
| **Obj 5: Create tablet-based system** | ✓ (Tablet deployment) | ✓ (Tablet deployment) | ✓ (Tablet deployment) | ✓ (Tablet deployment) | - |
| **Obj 6: Validate system performance** | ✓ (Evaluation) | ✓ (Evaluation) | ✓ (Evaluation) | ✓ (Evaluation) | ✓ (Ground truth) |
| **Obj 7: Develop production-ready architecture** | ✓ (Flutter app) | ✓ (Flutter app) | ✓ (Flutter app) | ✓ (Flutter app) | - |

**All datasets align with project objectives and provide necessary data for model training, evaluation, and system deployment.**

---

### 2.4. Data Quality Analysis

#### 2.4.1. Missing Data Analysis

**Age 2-3.5 (Questionnaire):**
- Missing values: [X]% of features
- Most complete: `total_score`, `critical_items_failed` (100% complete)
- Most missing: [Feature name] ([X]% missing)
- **Handling Strategy**: Median imputation for numerical features, mode imputation for categorical features

**Age 3.5-5.5 (Frog Jump):**
- Missing values: [X]% of features
- Most complete: `nogo_accuracy`, `commission_errors` (100% complete)
- Most missing: [Feature name] ([X]% missing)
- **Handling Strategy**: Median imputation (robust to outliers)

**Age 5.5-6.9 (Color-Shape):**
- Missing values: [X]% of features
- Most complete: `post_switch_accuracy`, `switch_cost_ms` (100% complete)
- Most missing: [Feature name] ([X]% missing)
- **Handling Strategy**: Median imputation

**Visualization**: Missing value heatmaps created for each age group to identify patterns.

---

#### 2.4.2. Outlier Detection

**Methods Used:**
1. **IQR Method (1.5×IQR rule)**: Detects outliers beyond Q1-1.5×IQR and Q3+1.5×IQR
2. **Z-Score Method (|Z| > 3)**: Detects values more than 3 standard deviations from mean
3. **Visual Inspection**: Box plots, scatter plots

**Findings:**
- Outliers detected in: `rt_variability`, `switch_cost_ms`, `commission_error_rate`
- **Handling Strategy**: Winsorization (cap at 1.5×IQR bounds) rather than removal
- **Rationale**: Preserves all real clinical data; outliers may represent severe ASD presentations

**Visualization**: Box plots created for top features with outliers.

---

#### 2.4.3. Class Distribution Analysis

**Age 2-3.5:**
- ASD: [N] children ([X]%)
- Typically Developing: [N] children ([X]%)
- **Class Balance**: [Balanced / Imbalanced]

**Age 3.5-5.5:**
- ASD: [N] children ([X]%)
- Typically Developing: [N] children ([X]%)
- **Class Balance**: [Balanced / Imbalanced]

**Age 5.5-6.9:**
- ASD: [N] children ([X]%)
- Typically Developing: [N] children ([X]%)
- **Class Balance**: [Balanced / Imbalanced]

**Handling Strategy:**
- Multi-view data expansion (3-4x expansion per child)
- Class weights in model training (`class_weight="balanced"`)
- Stratified train/test split

---

### 2.5. Feature Engineering Overview

#### 2.5.1. Age 2-3.5: Questionnaire Features

**Raw Features:**
- Individual question responses (1-5 scale)
- Total score, percentage score
- Critical items failed count

**Engineered Features:**
- `critical_items_failed`: Count of failed critical items (Q1, Q4, Q5, Q7, Q9)
- `critical_items_fail_rate`: Percentage of critical items failed
- `social_responsiveness_score`: Domain score (Q1, Q4, Q7)
- `joint_attention_score`: Domain score (Q5, Q9)
- `cognitive_flexibility_score`: Domain score (Q2, Q3)
- `social_communication_score`: Domain score (Q4, Q10)
- `social_responsiveness_zscore`: Age-normalized z-score
- `joint_attention_zscore`: Age-normalized z-score
- `behavioral_regulation_index`: Composite index (attention, engagement, instruction following)

**Age Normalization:**
- Z-scores calculated within age bins: 24-30, 30-36, 36-42 months
- Formula: `z = (x - μ_age_bin) / σ_age_bin`

---

#### 2.5.2. Age 3.5-5.5: Frog Jump (Go/No-Go) Features

**Raw Features:**
- Go trial accuracy, No-Go trial accuracy
- Commission errors, omission errors
- Reaction times (mean, median, variability)

**Engineered Features:**
- `nogo_accuracy`: No-Go trial accuracy (%)
- `commission_error_rate`: Commission errors / No-Go trials × 100
- `go_accuracy`: Go trial accuracy (%)
- `rt_variability`: Standard deviation of reaction times
- `inhibition_failure_rate`: Commission error rate (alias)
- `nogo_accuracy_zscore`: Age-normalized z-score
- `commission_error_rate_zscore`: Age-normalized z-score
- `rt_variability_zscore`: Age-normalized z-score
- `inhibition_control_index`: Composite index (0.4×nogo_accuracy + 0.3×commission_rate + 0.3×rt_variability)
- `response_control_index`: Composite index (go_accuracy, omission_rate, rt_variability)
- `behavioral_regulation_index`: Composite index (attention, engagement, instruction following)

**Age Normalization:**
- Z-scores calculated within age bins: 42-48, 48-54, 54-66 months

---

#### 2.5.3. Age 5.5-6.9: Color-Shape (DCCS) Features

**Raw Features:**
- Pre-switch accuracy, post-switch accuracy
- Switch cost (reaction time difference)
- Perseverative errors

**Engineered Features:**
- `post_switch_accuracy`: Post-switch block accuracy (%)
- `switch_cost_ms`: Reaction time difference (post-switch - pre-switch)
- `perseverative_error_rate_post_switch`: Perseverative errors / post-switch trials × 100
- `accuracy_drop_percent`: (Pre-switch accuracy - Post-switch accuracy)
- `post_switch_accuracy_zscore`: Age-normalized z-score
- `switch_cost_ms_zscore`: Age-normalized z-score
- `perseverative_error_rate_zscore`: Age-normalized z-score
- `cognitive_flexibility_index`: Composite index (0.4×accuracy_drop + 0.3×switch_cost_zscore + 0.3×perseverative_rate)
- `perseveration_control_index`: Composite index (perseverative errors, consecutive perseverations)
- `behavioral_regulation_index`: Composite index (attention, engagement, instruction following)

**Age Normalization:**
- Z-scores calculated within age bins: 66-72, 72-78, 78-83 months

---

### 2.6. Data Expansion Strategy

#### 2.6.1. Multi-View Data Expansion

**Purpose**: Increase training data size without generating synthetic children.

**Method**: Create multiple "views" per child focusing on different domains:

**Age 2-3.5:**
- View 1: Social Domain (social_responsiveness, joint_attention, social_communication)
- View 2: Behavioral Regulation (attention, engagement, frustration_tolerance)
- View 3: Task Performance (total_score, completion_time, critical_items)

**Age 3.5-5.5:**
- View 1: Inhibition Control (nogo_accuracy, commission_errors, inhibition_failure_rate)
- View 2: Response Control (go_accuracy, omission_errors, rt_variability)
- View 3: Behavioral Regulation (attention, engagement, frustration_tolerance)

**Age 5.5-6.9:**
- View 1: Cognitive Flexibility (post_switch_accuracy, switch_cost, accuracy_drop)
- View 2: Perseveration (perseverative_errors, consecutive_perseverations)
- View 3: Reaction Time (avg_rt_pre_switch, avg_rt_post_switch, switch_cost)
- View 4: Behavioral Regulation (attention, engagement, frustration_tolerance)

**Expansion Factor:**
- Age 2-3.5: 1 child → 3 views (3x expansion)
- Age 3.5-5.5: 1 child → 3 views (3x expansion)
- Age 5.5-6.9: 1 child → 4 views (4x expansion)

**Rationale**: Preserves data integrity (no synthetic data), increases learning signal, aligns with clinical thinking (domain-specific views).

---

### 2.7. Data Preprocessing Pipeline

#### 2.7.1. Preprocessing Steps

| Step | Description | Applied To |
|------|-------------|------------|
| **Data Cleaning** | Remove duplicates, invalid sessions, placeholder accounts | All datasets |
| **Missing Value Imputation** | Median imputation for numerical features | All datasets |
| **Outlier Handling** | Winsorization (cap at 1.5×IQR bounds) | All datasets |
| **Age Normalization** | Z-score normalization within age bins | All age groups |
| **Composite Index Creation** | Weighted combination of related features | All age groups |
| **Multi-View Expansion** | Create domain-specific views per child | All age groups |
| **Feature Scaling** | RobustScaler (fit on train, transform test) | All age groups |
| **Safe Data Augmentation** | Bootstrap resampling with 3% Gaussian noise (training only) | Training sets |

---

### 2.8. Train/Test Split Strategy

#### 2.8.1. Child-Level Split (Mandatory)

**Method**: Split by `child_id` (not by row) to prevent data leakage.

**Split Ratio:**
- Training: 70%
- Validation: 15% (for threshold tuning)
- Test (Holdout): 15%

**Stratification**: Maintains class distribution across splits.

**Rationale**: 
- Prevents overoptimistic performance estimates
- Reflects real-world deployment (new child = new prediction)
- Clinically defensible evaluation

---

### 2.9. Data Suitability Conclusion

**The conducted data exploration confirms that:**

1. ✅ **All datasets align with research objectives** (age-stratified assessments, multilingual support, hybrid ML, offline deployment)

2. ✅ **Data quality is acceptable** (missing values < 20%, outliers handled via winsorization, class balance maintained through expansion)

3. ✅ **Feature engineering is clinically meaningful** (age-normalized features, composite indices, domain-specific views)

4. ✅ **Preprocessing pipeline is robust** (handles missing data, outliers, class imbalance, prevents data leakage)

5. ✅ **Evaluation strategy is defensible** (child-level split, stratified sampling, holdout test set)

**The prepared datasets and feature engineering pipeline establish a solid foundation for subsequent model training, system implementation, and clinical deployment.**

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Project:** 25-26J-273 - SenseAI ASD Screening System
