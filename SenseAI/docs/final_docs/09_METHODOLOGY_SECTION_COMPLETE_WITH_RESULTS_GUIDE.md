# Complete Methodology Section with Results Guide
## Standard Undergraduate/MSc Research Paper Format

**Project ID:** 25-26J-273  
**Project Title:** Designing a Culturally Adapted, Multi-Language, Tablet-Based Intelligent System for Early Detection of Autism Spectrum Disorder Risk

---

## Part 1: Methodology Section (What Examiners Expect)

### 1. Data Collection

#### 1.1. Data Sources

**Where your data came from:**

| Data Source | Organization/Platform | Type of Data | Time Period | Number of Records |
|------------|----------------------|--------------|-------------|-------------------|
| **Clinical Assessment Data** | Participating hospitals and clinics in Sri Lanka | Numeric (scores, reaction times, accuracy), Categorical (responses, behavioral ratings) | [Start Date] to [End Date] | [N] children, [M] assessment sessions |
| **Questionnaire Responses** | Parent/caregiver reports collected via tablet app | Numeric (1-5 Likert scale responses), Categorical (Yes/No responses) | [Start Date] to [End Date] | [N] questionnaires completed |
| **Game Telemetry Data** | Tablet-based assessment games (Frog Jump, Color-Shape) | Numeric (reaction times in milliseconds, accuracy percentages, error counts) | [Start Date] to [End Date] | [N] game sessions |
| **Clinician Observations** | Behavioral rating forms completed by clinicians | Numeric (1-5 Likert scale ratings) | [Start Date] to [End Date] | [N] clinician reflection forms |
| **Clinical Labels** | Clinical diagnosis records from hospitals | Categorical (ASD / Typically Developing) | [Start Date] to [End Date] | [N] children with confirmed labels |

**Example sentence (simple and safe):**

> "Data was collected from participating hospitals and clinics in Sri Lanka, where children aged 2-6.9 years underwent tablet-based assessments. Parent/caregiver questionnaire responses and game telemetry data were collected over a [X]-month period, resulting in [N] assessment sessions from [M] children."

---

#### 1.2. Data Collection Procedure

**How the data was gathered:**

**Inclusion Criteria (Who was included):**
- Children aged 24-83 months (2-6.9 years)
- Parent/guardian provided informed consent
- Child able to complete assessment (no severe motor or visual impairments preventing task completion)
- Complete assessment session (at least 80% of items/trials completed)

**Exclusion Criteria (What was removed and why):**
- Children outside age range (24-83 months)
- Incomplete assessments (< 80% completion)
- Missing critical features (e.g., age not recorded, no game telemetry)
- Duplicate sessions (same child, same date, same session type)

**Tools Used:**
- **Tablet Application**: Flutter-based mobile app running on Android tablets (10-inch screens)
- **Questionnaire Interface**: Digital questionnaire with multilingual support (English/Sinhala/Tamil)
- **Game Applications**: HTML5-based games embedded in tablet app (Frog Jump for ages 3.5-5.5, Color-Shape for ages 5.5-6.9)
- **Data Storage**: Local SQLite database on tablet, later synced to backend server

**Collection Process:**
1. **Child Registration**: Clinician enters minimal demographic data (age in months, sex, language preference) into tablet app
2. **Age-Based Routing**: App automatically selects appropriate assessment based on age:
   - Age 24-42 months → Questionnaire (parent/caregiver reports)
   - Age 42-66 months → Frog Jump game (Go/No-Go task)
   - Age 66-83 months → Color-Shape game (DCCS task)
3. **Assessment Administration**: 
   - **Questionnaire**: Parent/caregiver answers questions on tablet (guided by clinician if needed)
   - **Games**: Child plays game on tablet while clinician observes
4. **Clinician Reflection**: Clinician completes behavioral observation form (5-point Likert scales)
5. **Data Capture**: All responses, game telemetry, and observations automatically recorded in tablet app
6. **Label Assignment**: Clinical labels (ASD / Typically Developing) assigned based on:
   - Clinician diagnosis (primary source)
   - ADOS-2 assessment (where available)
   - ADI-R assessment (where available)
   - Standardized screening thresholds (for typically developing group)

**Example sentence:**

> "Only children meeting the defined age range (24-83 months) and data completeness criteria (≥80% completion) were included. Incomplete assessments and duplicate sessions were excluded during collection. Data was collected using a tablet-based application, with assessments automatically routed based on child age."

---

#### 1.3. Ethical Considerations (Very Important)

**What you must mention:**

**Personal Identifier Removal:**
- All child names, phone numbers, exact birthdates, and hospital identifiers were removed from research dataset
- Child IDs were anonymized (e.g., "LRH-001" instead of real names)
- Only age in months (not exact birthdate) was retained

**Consent and Approval:**
- Informed consent obtained from parents/guardians before data collection
- Ethical approval obtained from [Institution Name] Institutional Review Board (IRB Approval Number: [Number])
- Data collection followed Declaration of Helsinki guidelines

**Data Handling:**
- Data stored securely on encrypted devices
- Access restricted to authorized research personnel only
- Data used only for research purposes, not shared with third parties

**Example sentence:**

> "All personal identifiers were removed prior to analysis, and the data was handled according to institutional ethical guidelines. Informed consent was obtained from parents/guardians, and ethical approval was granted by [Institution Name] Institutional Review Board (IRB Approval Number: [Number])."

---

### 2. Data Handling and Storage

#### 2.1. Data Storage

**Where and how data was stored:**

| Storage Location | Format | Security | Backup |
|-----------------|--------|----------|--------|
| **Tablet Device (Local)** | SQLite database | Device encryption | Automatic local backup |
| **Backend Server** | SQLite database + JSON files | Encrypted storage, access control | Daily automated backups |
| **Research Dataset** | CSV files (anonymized) | Encrypted disk, controlled access | Version-controlled repository |

**Example sentence:**

> "Collected data was stored in structured SQLite database format on tablet devices and securely maintained in a controlled-access backend server. Research datasets were exported as anonymized CSV files and stored on encrypted disks with version control."

---

#### 2.2. Data Labeling or Annotation

**How labels were assigned:**

**Label Sources:**
- **Tier A (Highest Quality)**: ADOS-2 or ADI-R assessment results
- **Tier B (Standard Quality)**: Clinician diagnosis based on clinical evaluation
- **Tier C (Screening Quality)**: Standardized screening threshold (for typically developing group)

**Labeling Process:**
1. Clinical labels assigned by trained clinicians or specialists
2. Labels cross-verified with assessment data (e.g., ASD label should align with low questionnaire scores or high error rates)
3. Inconsistencies flagged for review (e.g., ASD label but high scores)

**Consistency Checks:**
- Inter-rater reliability checked where multiple clinicians assessed same child
- Label source documented for each child (clinician_diagnosis / ADOS-2 / ADI-R)
- Cross-validation with assessment features (e.g., ASD group should show lower scores, higher errors)

**Example sentence:**

> "Labels were assigned based on clinically validated criteria (clinician diagnosis, ADOS-2, or ADI-R assessment) and cross-checked with assessment data to ensure consistency. Label source was documented for each child to track data quality."

---

### 3. Data Preprocessing

#### 3.1. Data Cleaning

**What was done to clean the data:**

| Cleaning Step | Method | Purpose | Records Affected |
|--------------|--------|---------|------------------|
| **Remove Duplicates** | Identified duplicate sessions (same child_id, same date, same session_type) | Eliminate redundant data | [N] duplicate records removed |
| **Handle Missing Values** | Median imputation for numerical features, mode imputation for categorical | Preserve sample size, maintain data integrity | [X]% of features had missing values |
| **Remove Invalid Sessions** | Removed sessions with < 80% completion or invalid data (e.g., all zeros, impossible values) | Ensure data quality | [N] invalid sessions removed |
| **Outlier Detection** | Identified outliers using IQR method (1.5×IQR rule) and Z-score method (|Z| > 3) | Identify extreme values | [N] outliers detected |
| **Outlier Handling** | Winsorization (cap at 1.5×IQR bounds) rather than removal | Preserve all real clinical data | All outliers preserved (capped, not removed) |

**Example sentence:**

> "Missing values were handled using median imputation for numerical features and mode imputation for categorical features. Duplicate records were removed, and outliers were handled using winsorization (capping at 1.5×IQR bounds) to preserve all real clinical data."

---

#### 3.2. Data Transformation

**How data was transformed:**

| Transformation | Method | Purpose | Applied To |
|---------------|--------|---------|------------|
| **Age Normalization** | Z-score normalization within age bins (e.g., 24-30, 30-36, 36-42 months) | Enable fair comparison across ages | All age-dependent features |
| **Feature Scaling** | RobustScaler (median and IQR-based) | Normalize feature ranges for ML algorithms | All numerical features |
| **Categorical Encoding** | Numeric encoding (1-5 scale for Likert scales) | Convert categorical to numeric | Behavioral ratings, questionnaire responses |
| **Composite Index Creation** | Weighted combination of related features (e.g., 0.4×feature1 + 0.3×feature2 + 0.3×feature3) | Create domain-level scores | Domain-specific features |
| **Multi-View Expansion** | Create multiple domain-specific views per child (3-4 views per child) | Increase training data without synthetic data | All children |

**Example sentence:**

> "Numerical features were normalized using age-stratified z-scores to enable fair comparison across ages, and then scaled using RobustScaler to ensure uniform feature ranges. Categorical variables were encoded numerically, and composite indices were created to represent domain-level scores."

---

#### 3.3. Data Splitting

**How data was split for training and testing:**

**Split Method:**
- **Child-Level Split**: Split by `child_id` (not by row) to prevent data leakage
- **Stratified Split**: Maintains class distribution (ASD / Typically Developing) in each split
- **Split Ratio**: 70% training, 15% validation, 15% test (holdout)

**Procedure:**
1. Group all data views by `child_id`
2. Split children (not individual rows) into train/validation/test sets
3. All views from a child go to the same split (prevents data leakage)
4. Verify class distribution maintained in each split

**Rationale:**
- Prevents overoptimistic performance estimates (same child in both train and test)
- Reflects real-world deployment (new child = new prediction)
- Clinically defensible evaluation

**Example sentence:**

> "The dataset was split by child ID (not by row) into training (70%), validation (15%), and testing (15%) subsets using stratified sampling to maintain class distribution. This ensures no child appears in both training and testing sets, preventing data leakage."

---

### 4. Data Processing Pipeline

**How everything connects (from raw data to results):**

```
Raw Data Collection
    ↓
[Child Registration] → [Age-Based Assessment Routing]
    ↓
[Questionnaire / Game Session] → [Clinician Reflection]
    ↓
[Feature Extraction] → [Data Cleaning] → [Missing Value Imputation]
    ↓
[Outlier Detection] → [Winsorization] → [Age Normalization]
    ↓
[Composite Index Creation] → [Multi-View Expansion]
    ↓
[Feature Scaling] → [Child-Level Train/Test Split]
    ↓
[Model Training] → [Risk Stratification] → [Results]
```

**Detailed Steps:**

1. **Input**: Raw assessment data (questionnaire responses, game telemetry, clinician observations)
2. **Preprocessing**: Cleaning, imputation, normalization, feature engineering
3. **Expansion**: Multi-view data expansion (3-4 views per child)
4. **Splitting**: Child-level train/validation/test split
5. **Model Training**: Train Logistic Regression and Random Forest models
6. **Risk Stratification**: Apply hybrid ML + clinical rules to assign risk levels
7. **Output**: Risk levels (Low/Moderate/High) with explanations

---

## Part 2: Results Section (What Data You Need)

### 5. What Results Data You Must Collect and Report

#### 5.1. Dataset Description Results

**What to report:**

| Metric | Age 2-3.5 | Age 3.5-5.5 | Age 5.5-6.9 | Total |
|--------|-----------|-------------|-------------|-------|
| **Number of Children** | [N] | [N] | [N] | [N_total] |
| **Number of Sessions** | [M] | [M] | [M] | [M_total] |
| **ASD Cases** | [N_asd] ([X]%) | [N_asd] ([X]%) | [N_asd] ([X]%) | [N_asd_total] |
| **Typically Developing** | [N_td] ([X]%) | [N_td] ([X]%) | [N_td] ([X]%) | [N_td_total] |
| **Mean Age (months)** | [X] ± [SD] | [X] ± [SD] | [X] ± [SD] | [X] ± [SD] |
| **Age Range (months)** | [Min] - [Max] | [Min] - [Max] | [Min] - [Max] | [Min] - [Max] |
| **Male/Female Ratio** | [M]:[F] | [M]:[F] | [M]:[F] | [M]:[F] |

**How to get this data:**
```python
# Example Python code to calculate these metrics
import pandas as pd

# Load your dataset
df = pd.read_csv('your_dataset.csv')

# Number of children per age group
age_2_3_5 = df[(df['age_months'] >= 24) & (df['age_months'] < 42)]
age_3_5_5_5 = df[(df['age_months'] >= 42) & (df['age_months'] < 66)]
age_5_5_6_9 = df[(df['age_months'] >= 66) & (df['age_months'] <= 83)]

print(f"Age 2-3.5: {age_2_3_5['child_id'].nunique()} children")
print(f"Age 3.5-5.5: {age_3_5_5_5['child_id'].nunique()} children")
print(f"Age 5.5-6.9: {age_5_5_6_9['child_id'].nunique()} children")

# Class distribution
print(f"ASD: {df[df['group'] == 'asd']['child_id'].nunique()}")
print(f"TD: {df[df['group'] == 'typically_developing']['child_id'].nunique()}")

# Mean age and standard deviation
print(f"Mean age: {df['age_months'].mean():.1f} ± {df['age_months'].std():.1f} months")
```

---

#### 5.2. Data Quality Results

**What to report:**

| Quality Metric | Age 2-3.5 | Age 3.5-5.5 | Age 5.5-6.9 |
|----------------|-----------|-------------|-------------|
| **Missing Values (%)** | [X]% | [X]% | [X]% |
| **Outliers Detected** | [N] | [N] | [N] |
| **Outliers (%)** | [X]% | [X]% | [X]% |
| **Duplicate Records Removed** | [N] | [N] | [N] |
| **Invalid Sessions Removed** | [N] | [N] | [N] |
| **Final Dataset Size (after cleaning)** | [N] | [N] | [N] |

**How to get this data:**
```python
# Missing values
missing_pct = (df.isnull().sum() / len(df)) * 100
print(f"Missing values: {missing_pct.mean():.1f}%")

# Outliers (IQR method)
Q1 = df['feature_name'].quantile(0.25)
Q3 = df['feature_name'].quantile(0.75)
IQR = Q3 - Q1
outliers = df[(df['feature_name'] < Q1 - 1.5*IQR) | (df['feature_name'] > Q3 + 1.5*IQR)]
print(f"Outliers: {len(outliers)} ({len(outliers)/len(df)*100:.1f}%)")

# Duplicates
duplicates = df.duplicated(subset=['child_id', 'session_date', 'session_type'])
print(f"Duplicates: {duplicates.sum()}")
```

---

#### 5.3. Feature Engineering Results

**What to report:**

| Feature Category | Number of Features | Example Features |
|------------------|-------------------|-----------------|
| **Raw Features** | [N] | `nogo_accuracy`, `commission_errors`, `post_switch_accuracy` |
| **Age-Normalized Features** | [N] | `nogo_accuracy_zscore`, `commission_error_rate_zscore` |
| **Composite Indices** | [N] | `inhibition_control_index`, `cognitive_flexibility_index` |
| **Total Features (Final)** | [N] | All features used in model training |

**Feature Importance (Top 5):**

| Rank | Feature Name | Coefficient/Importance | Interpretation |
|------|--------------|----------------------|----------------|
| 1 | `critical_items_failed` | +2.34 | Higher failures → Higher ASD risk |
| 2 | `social_responsiveness_zscore` | -1.89 | Lower score → Higher ASD risk |
| 3 | `joint_attention_zscore` | -1.56 | Lower score → Higher ASD risk |
| 4 | `commission_error_rate_zscore` | +1.45 | Higher errors → Higher ASD risk |
| 5 | `rt_variability_zscore` | +1.23 | Higher variability → Higher ASD risk |

**How to get this data:**
```python
from sklearn.linear_model import LogisticRegression

# Train model
model = LogisticRegression()
model.fit(X_train, y_train)

# Get feature importance (coefficients)
feature_importance = pd.DataFrame({
    'feature': feature_names,
    'coefficient': model.coef_[0],
    'abs_coefficient': np.abs(model.coef_[0])
}).sort_values('abs_coefficient', ascending=False)

print(feature_importance.head(10))
```

---

#### 5.4. Model Performance Results (CRITICAL - This is Your Final Answer)

**What to report (for each age group):**

| Metric | Age 2-3.5 | Age 3.5-5.5 | Age 5.5-6.9 | Target |
|--------|-----------|-------------|-------------|--------|
| **Accuracy (%)** | [X]% | [X]% | [X]% | ≥ 80% |
| **Sensitivity/Recall (%)** | [X]% ⭐ | [X]% ⭐ | [X]% ⭐ | ≥ 85% |
| **Specificity (%)** | [X]% | [X]% | [X]% | ≥ 75% |
| **Precision (%)** | [X]% | [X]% | [X]% | ≥ 75% |
| **F1-Score** | [X] | [X] | [X] | ≥ 0.80 |
| **ROC-AUC** | [X] | [X] | [X] | ≥ 0.80 |

**Confusion Matrix (for each age group):**

```
Age 2-3.5:
                Predicted
Actual      TD      ASD
TD          [TN]    [FP]
ASD         [FN]    [TP]

Sensitivity = TP / (TP + FN) = [X]%
Specificity = TN / (TN + FP) = [X]%
```

**How to get this data:**
```python
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, confusion_matrix

# Predictions
y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)[:, 1]

# Calculate metrics
accuracy = accuracy_score(y_test, y_pred)
sensitivity = recall_score(y_test, y_pred)  # Same as recall
specificity = (confusion_matrix(y_test, y_pred)[0,0] / 
               (confusion_matrix(y_test, y_pred)[0,0] + confusion_matrix(y_test, y_pred)[0,1]))
precision = precision_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)
roc_auc = roc_auc_score(y_test, y_proba)

# Confusion matrix
cm = confusion_matrix(y_test, y_pred)
print(f"Confusion Matrix:\n{cm}")
print(f"TN: {cm[0,0]}, FP: {cm[0,1]}, FN: {cm[1,0]}, TP: {cm[1,1]}")

# Print results
print(f"Accuracy: {accuracy:.3f} ({accuracy*100:.1f}%)")
print(f"Sensitivity: {sensitivity:.3f} ({sensitivity*100:.1f}%)")
print(f"Specificity: {specificity:.3f} ({specificity*100:.1f}%)")
print(f"Precision: {precision:.3f} ({precision*100:.1f}%)")
print(f"F1-Score: {f1:.3f}")
print(f"ROC-AUC: {roc_auc:.3f}")
```

---

#### 5.5. Risk Level Distribution Results

**What to report:**

| Risk Level | Age 2-3.5 | Age 3.5-5.5 | Age 5.5-6.9 | Total |
|------------|-----------|-------------|-------------|-------|
| **Low Risk** | [N] ([X]%) | [N] ([X]%) | [N] ([X]%) | [N_total] |
| **Moderate Risk** | [N] ([X]%) | [N] ([X]%) | [N] ([X]%) | [N_total] |
| **High Risk** | [N] ([X]%) | [N] ([X]%) | [N] ([X]%) | [N_total] |

**Agreement with Clinical Assessment:**

| Comparison | Agreement % | Kappa Coefficient |
|------------|-------------|-------------------|
| **Hybrid ML + Rules vs. Clinician** | [X]% | [X] |
| **ML-Only vs. Clinician** | [X]% | [X] |

**How to get this data:**
```python
# Risk level distribution
risk_dist = df['risk_level'].value_counts()
print(risk_dist)

# Agreement with clinician
from sklearn.metrics import cohen_kappa_score

agreement = (predictions == clinician_labels).mean()
kappa = cohen_kappa_score(predictions, clinician_labels)
print(f"Agreement: {agreement:.3f} ({agreement*100:.1f}%)")
print(f"Kappa: {kappa:.3f}")
```

---

#### 5.6. System Performance Results

**What to report:**

| Performance Metric | Value | Target |
|-------------------|-------|--------|
| **Prediction Time (end-to-end)** | [X] seconds | < 2 seconds |
| **ML Engine Processing Time** | [X] milliseconds | < 100ms |
| **Backend Processing Time** | [X] milliseconds | < 200ms |
| **Offline Functionality** | ✅ Working | ✅ Required |
| **Multilingual Support** | ✅ English/Sinhala/Tamil | ✅ Required |
| **Concurrent Users Supported** | [N] users | ≥ 10 users |

**How to get this data:**
```python
import time

# Measure prediction time
start_time = time.time()
prediction = model.predict(features)
end_time = time.time()

prediction_time = (end_time - start_time) * 1000  # Convert to milliseconds
print(f"Prediction time: {prediction_time:.2f} ms")
```

---

### 6. Observations and Insights (What to Report)

#### 6.1. Key Observations

**What to observe and report:**

1. **Feature Patterns:**
   - ASD group shows lower accuracy scores, higher error rates
   - Age-normalized features show stronger predictive power than raw features
   - Composite indices capture domain-level patterns better than individual features

2. **Model Behavior:**
   - Logistic Regression performs better than Random Forest (or vice versa)
   - Hybrid ML + rules approach shows better clinical alignment than ML-only
   - Sensitivity is higher than specificity (acceptable for screening tool)

3. **Data Quality:**
   - Missing values are < 20% for critical features (acceptable)
   - Outliers represent real clinical cases (severe ASD presentations)
   - Class balance maintained after multi-view expansion

4. **System Usability:**
   - Clinicians find system easy to use
   - Children engage well with games
   - Multilingual support improves accessibility

---

#### 6.2. Error Analysis

**What errors to report:**

| Error Type | Count | Percentage | Impact |
|------------|-------|------------|--------|
| **False Positives (TD → ASD)** | [N] | [X]% | Acceptable for screening (can be resolved by specialist) |
| **False Negatives (ASD → TD)** | [N] | [X]% | Critical (missed cases) - must minimize |
| **Borderline Cases (0.4-0.6 probability)** | [N] | [X]% | Clinical rules help resolve these |

**How to analyze errors:**
```python
# False positives (TD predicted as ASD)
fp_indices = (y_test == 0) & (y_pred == 1)
fp_cases = X_test[fp_indices]

# False negatives (ASD predicted as TD)
fn_indices = (y_test == 1) & (y_pred == 0)
fn_cases = X_test[fn_indices]

# Analyze common patterns in errors
print(f"False Positives: {fp_indices.sum()} ({fp_indices.sum()/len(y_test)*100:.1f}%)")
print(f"False Negatives: {fn_indices.sum()} ({fn_indices.sum()/len(y_test)*100:.1f}%)")
```

---

## Part 3: How to Add This Data to Your Paper

### 7. Tables You MUST Include

#### Table 1: Dataset Description
```
| Attribute | Description |
|-----------|-------------|
| Source | Participating hospitals and clinics in Sri Lanka |
| Data Type | Numeric (scores, reaction times), Categorical (responses) |
| Records | [N] children, [M] assessment sessions |
| Time Period | [Start Date] to [End Date] |
| Age Range | 24-83 months (2-6.9 years) |
```

#### Table 2: Features Used (Sample)
```
| Feature Name | Type | Description | Age Group |
|--------------|------|-------------|-----------|
| critical_items_failed | Numeric | Count of failed critical items | 2-3.5 |
| nogo_accuracy | Numeric | No-Go trial accuracy (%) | 3.5-5.5 |
| post_switch_accuracy | Numeric | Post-switch block accuracy (%) | 5.5-6.9 |
| commission_error_rate_zscore | Numeric | Age-normalized commission error rate | 3.5-5.5 |
```

#### Table 3: Preprocessing Steps
```
| Step | Method | Purpose | Records Affected |
|------|--------|---------|------------------|
| Cleaning | Remove duplicates | Improve data quality | [N] removed |
| Missing Values | Median imputation | Preserve sample size | [X]% imputed |
| Outliers | Winsorization | Preserve real data | [N] capped |
| Normalization | Age-stratified z-scores | Enable age comparison | All features |
| Scaling | RobustScaler | Normalize ranges | All features |
```

#### Table 4: Model Performance Results
```
| Metric | Age 2-3.5 | Age 3.5-5.5 | Age 5.5-6.9 |
|--------|-----------|-------------|-------------|
| Accuracy | [X]% | [X]% | [X]% |
| Sensitivity | [X]% | [X]% | [X]% |
| Specificity | [X]% | [X]% | [X]% |
| ROC-AUC | [X] | [X] | [X] |
```

---

### 8. Diagrams You SHOULD Include

#### Diagram 1: Overall System / Data Flow
```
[Child Registration] 
    ↓
[Age-Based Assessment Routing]
    ↓
[Questionnaire / Game Session] → [Clinician Reflection]
    ↓
[Feature Extraction] → [Data Preprocessing]
    ↓
[Model Training] → [Risk Stratification]
    ↓
[Risk Level Output (Low/Moderate/High)]
```

#### Diagram 2: Data Collection Architecture
```
[Hospitals/Clinics]
    ↓
[Tablet App (Flutter)]
    ↓
[Local SQLite Storage]
    ↓
[Backend Server (Node.js)]
    ↓
[ML Engine (FastAPI)]
    ↓
[Results Display]
```

---

### 9. Example Results Section (Template)

**Results Section Structure:**

```markdown
## 4. Results

### 4.1. Dataset Characteristics

Data was collected from [N] children aged 2-6.9 years across [X] hospitals and clinics. 
The dataset included [M] assessment sessions, with [N_asd] ASD cases ([X]%) and 
[N_td] typically developing children ([X]%). 

[Insert Table 1: Dataset Description]

### 4.2. Data Quality

Missing values were present in [X]% of features, handled via median imputation. 
[N] outliers were detected and handled using winsorization to preserve all real 
clinical data. [N] duplicate records and [N] invalid sessions were removed.

[Insert Table 3: Preprocessing Steps]

### 4.3. Model Performance

The Logistic Regression model achieved the following performance on the test set:

[Insert Table 4: Model Performance Results]

[Insert Confusion Matrix]

The model showed high sensitivity ([X]%), indicating strong ability to detect 
ASD cases, which is critical for screening tools.

### 4.4. Risk Level Distribution

Risk levels were assigned as follows: [N] Low Risk ([X]%), [N] Moderate Risk 
([X]%), and [N] High Risk ([X]%). The hybrid ML + clinical rules approach 
showed [X]% agreement with clinician assessment.

### 4.5. System Performance

The system achieved end-to-end prediction time of [X] seconds, with ML engine 
processing time of [X] milliseconds. Offline functionality and multilingual 
support (English/Sinhala/Tamil) were successfully implemented.
```

---

## Part 4: How to Get This Data (Step-by-Step)

### 10. Step-by-Step Guide to Collect Results

#### Step 1: Load Your Dataset
```python
import pandas as pd
import numpy as np

# Load your dataset
df = pd.read_csv('your_dataset.csv')

# Check basic info
print(df.info())
print(df.describe())
```

#### Step 2: Calculate Dataset Statistics
```python
# Number of children per age group
age_groups = {
    '2-3.5': df[(df['age_months'] >= 24) & (df['age_months'] < 42)],
    '3.5-5.5': df[(df['age_months'] >= 42) & (df['age_months'] < 66)],
    '5.5-6.9': df[(df['age_months'] >= 66) & (df['age_months'] <= 83)]
}

for group, data in age_groups.items():
    print(f"Age {group}: {data['child_id'].nunique()} children")
    print(f"  ASD: {data[data['group'] == 'asd']['child_id'].nunique()}")
    print(f"  TD: {data[data['group'] == 'typically_developing']['child_id'].nunique()}")
```

#### Step 3: Train Models and Get Performance
```python
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, confusion_matrix

# Split data (child-level)
# [Your split code here]

# Train model
model = LogisticRegression(max_iter=2000, class_weight='balanced')
model.fit(X_train, y_train)

# Predict
y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)[:, 1]

# Calculate metrics
metrics = {
    'Accuracy': accuracy_score(y_test, y_pred),
    'Sensitivity': recall_score(y_test, y_pred),
    'Specificity': (confusion_matrix(y_test, y_pred)[0,0] / 
                   (confusion_matrix(y_test, y_pred)[0,0] + confusion_matrix(y_test, y_pred)[0,1])),
    'Precision': precision_score(y_test, y_pred),
    'F1-Score': f1_score(y_test, y_pred),
    'ROC-AUC': roc_auc_score(y_test, y_proba)
}

# Print results
for metric, value in metrics.items():
    if metric in ['Accuracy', 'Sensitivity', 'Specificity', 'Precision']:
        print(f"{metric}: {value:.3f} ({value*100:.1f}%)")
    else:
        print(f"{metric}: {value:.3f}")

# Confusion matrix
cm = confusion_matrix(y_test, y_pred)
print(f"\nConfusion Matrix:\n{cm}")
print(f"TN: {cm[0,0]}, FP: {cm[0,1]}, FN: {cm[1,0]}, TP: {cm[1,1]}")
```

#### Step 4: Create Tables and Save Results
```python
# Create results table
results_df = pd.DataFrame({
    'Metric': ['Accuracy', 'Sensitivity', 'Specificity', 'Precision', 'F1-Score', 'ROC-AUC'],
    'Age 2-3.5': [acc_2_3_5, sens_2_3_5, spec_2_3_5, prec_2_3_5, f1_2_3_5, auc_2_3_5],
    'Age 3.5-5.5': [acc_3_5_5_5, sens_3_5_5_5, spec_3_5_5_5, prec_3_5_5_5, f1_3_5_5_5, auc_3_5_5_5],
    'Age 5.5-6.9': [acc_5_5_6_9, sens_5_5_6_9, spec_5_5_6_9, prec_5_5_6_9, f1_5_5_6_9, auc_5_5_6_9]
})

# Save to CSV
results_df.to_csv('model_performance_results.csv', index=False)
print(results_df)
```

---

## Summary Checklist

✅ **Data Collection**: Explained where data came from (hospitals, parents, children)  
✅ **Data Collection Procedure**: Explained inclusion/exclusion criteria, tools used  
✅ **Ethical Considerations**: Mentioned consent, IRB approval, anonymization  
✅ **Data Storage**: Explained storage format, security, backup  
✅ **Data Labeling**: Explained label sources, consistency checks  
✅ **Data Cleaning**: Explained missing values, duplicates, outliers  
✅ **Data Transformation**: Explained normalization, scaling, encoding  
✅ **Data Splitting**: Explained child-level split, ratios  
✅ **Results Tables**: Created tables for dataset, features, preprocessing, performance  
✅ **Results Metrics**: Calculated accuracy, sensitivity, specificity, ROC-AUC  
✅ **Confusion Matrix**: Created and interpreted  
✅ **Observations**: Reported key insights and error analysis  

**Your methodology and results sections are now complete and examiner-ready!**

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Project:** 25-26J-273 - SenseAI ASD Screening System
