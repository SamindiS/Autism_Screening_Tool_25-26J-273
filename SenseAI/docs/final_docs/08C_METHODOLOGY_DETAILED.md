# Methodology - Detailed Implementation

**Project ID:** 25-26J-273  
**Project Title:** Designing a Culturally Adapted, Multi-Language, Tablet-Based Intelligent System for Early Detection of Autism Spectrum Disorder Risk

---

## 3. Methodology

### 3.1. Data Preprocessing

#### 3.1.1. Transformation Techniques Applied

| Transformation Technique | Age 2-3.5 (Questionnaire) | Age 3.5-5.5 (Frog Jump) | Age 5.5-6.9 (Color-Shape) | Rationale |
|-------------------------|---------------------------|-------------------------|---------------------------|-----------|
| **Data Cleaning** | ✓ | ✓ | ✓ | Remove duplicates, invalid sessions, placeholder accounts |
| **Handling Missing Data** | ✓ (Median imputation) | ✓ (Median imputation) | ✓ (Median imputation) | Preserve sample size, robust to outliers |
| **Data Type Conversion** | ✓ | ✓ | ✓ | Ensure correct data types (numeric, categorical) |
| **Data Normalization** | ✓ (Age-normalized z-scores) | ✓ (Age-normalized z-scores) | ✓ (Age-normalized z-scores) | Enable fair comparison across ages |
| **Feature Engineering** | ✓ (Domain scores, composite indices) | ✓ (Inhibition indices, RT metrics) | ✓ (Flexibility indices, perseveration metrics) | Create clinically meaningful features |
| **Data Encoding** | ✓ (Categorical to numeric) | ✓ (Categorical to numeric) | ✓ (Categorical to numeric) | Required for ML algorithms |
| **Data Aggregation** | ✓ (Multi-view expansion) | ✓ (Multi-view expansion) | ✓ (Multi-view expansion) | Increase training signal without synthetic data |
| **Dimensionality Reduction (PCA)** | Optional (for visualization) | Optional (for visualization) | Optional (for visualization) | Visualize feature space, reduce noise |
| **Outlier Handling** | ✓ (Winsorization) | ✓ (Winsorization) | ✓ (Winsorization) | Preserve all real clinical data |
| **Feature Scaling** | ✓ (RobustScaler) | ✓ (RobustScaler) | ✓ (RobustScaler) | Required for distance-based algorithms |

---

### 3.2. Scalability

#### 3.2.1. Dataset Scalability

**Continuous Data Collection:**
- The clinical data collection infrastructure continuously accumulates new assessment sessions as children are screened in participating clinics
- Each new session adds to the dataset without requiring modification to preprocessing pipelines
- Feature extraction and normalization procedures are designed to accommodate additional children seamlessly

**Automatic Dataset Expansion:**
- Multi-view expansion automatically creates 3-4 views per new child
- Age normalization adapts to new age distributions as more data is collected
- Composite indices automatically incorporate new features if added

**Model Retraining Capability:**
- The predictive models can be periodically retrained with newly collected data
- Retraining improves accuracy and adapts to evolving behavioral patterns
- Version control system tracks model versions and performance over time

**Cross-Validation and External Validation:**
- Child-level train/test split ensures realistic performance estimates
- Holdout test set can be expanded as more data becomes available
- External validation possible with data from new hospitals/clinics

---

### 3.3. Feature Extraction and Preprocessing (Detailed)

#### 3.3.1. Data Source 1: Age 2-3.5 Questionnaire Data

**Data Cleaning and Verification:**
- Raw questionnaire response files were inspected to ensure completeness and correctness
- Duplicate session records, incomplete questionnaires (missing > 50% items), and test/placeholder accounts were removed
- Child identification numbers were anonymized to preserve privacy
- Missing question responses were handled through median imputation (for numerical scores) or mode imputation (for categorical responses)

**Feature Extraction:**
Meaningful engagement and behavioral indicators were derived from raw questionnaire responses:

1. **Critical Items Analysis**:
   - Identified critical items (Q1: Name response, Q4: Eye contact, Q5: Pointing, Q7: Imitation, Q9: Joint attention) based on M-CHAT-R/F framework
   - Calculated `critical_items_failed`: Count of critical items with score ≤ 2
   - Calculated `critical_items_fail_rate`: Percentage of critical items failed

2. **Domain Scores**:
   - `social_responsiveness_score`: Mean of Q1, Q4, Q7 (name response, eye contact, imitation)
   - `joint_attention_score`: Mean of Q5, Q9 (pointing, joint attention)
   - `cognitive_flexibility_score`: Mean of Q2, Q3 (routine change, toy switching)
   - `social_communication_score`: Mean of Q4, Q10 (eye contact, communication)

3. **Total Score Metrics**:
   - `total_score`: Sum of all question responses (1-5 scale)
   - `percentage_score`: (total_score / max_possible_score) × 100
   - `risk_score`: 100 - percentage_score (inverted, higher = more risk)

4. **Completion Metrics**:
   - `completion_time_sec`: Time taken to complete questionnaire
   - `completion_rate`: Percentage of questions answered

**Feature Normalization:**
- All numerical questionnaire features were age-normalized using z-scores within age bins (24-30, 30-36, 36-42 months)
- Formula: `z = (x - μ_age_bin) / σ_age_bin`
- Inverted z-scores for risk indicators (lower score = higher risk → higher z-score)

**Feature Transformation:**
- Composite behavioral indices created:
  - `behavioral_regulation_index = mean(attention_level, engagement_level, instruction_following)`
  - `social_domain_index = mean(social_responsiveness_score, joint_attention_score, social_communication_score)`

**Feature Selection:**
- All engineered features retained (no feature elimination)
- Feature importance analysis performed post-training (Logistic Regression coefficients, Random Forest importance)

**Feature Evaluation:**
- Correlation analysis confirmed strong relationships between questionnaire features and clinical labels
- Domain scores showed expected patterns (ASD group: lower scores, higher critical item failure rates)

---

#### 3.3.2. Data Source 2: Age 3.5-5.5 Frog Jump (Go/No-Go) Data

**Data Cleaning:**
- Raw game telemetry logs were checked for:
  - Invalid trial data (reaction times < 100ms or > 5000ms removed as likely errors)
  - Incomplete sessions (< 20 trials removed)
  - Duplicate session records
- Missing trial-level data handled via median imputation

**Feature Extraction:**
Extracted attributes from Go/No-Go game telemetry:

1. **Go Trial Metrics**:
   - `go_accuracy`: Percentage of Go trials answered correctly
   - `omission_errors`: Count of Go trials not answered
   - `omission_error_rate`: (omission_errors / go_trials) × 100
   - `avg_rt_go_ms`: Mean reaction time for correct Go trials
   - `median_rt_go_ms`: Median reaction time for correct Go trials

2. **No-Go Trial Metrics**:
   - `nogo_accuracy`: Percentage of No-Go trials answered correctly (inhibited)
   - `commission_errors`: Count of No-Go trials answered incorrectly (failed inhibition)
   - `commission_error_rate`: (commission_errors / nogo_trials) × 100
   - `inhibition_failure_rate`: Alias for commission_error_rate

3. **Reaction Time Variability**:
   - `rt_variability`: Standard deviation of all reaction times
   - `rt_coefficient_of_variation`: (rt_variability / mean_rt) × 100

4. **Anticipatory and Late Responses**:
   - `anticipatory_responses`: Count of responses with RT < 200ms (likely guessing)
   - `anticipatory_rate`: (anticipatory_responses / total_trials) × 100
   - `late_responses`: Count of responses with RT > 2000ms (likely inattention)
   - `late_response_rate`: (late_responses / total_trials) × 100

5. **Streak Metrics**:
   - `longest_correct_streak`: Maximum consecutive correct responses
   - `longest_error_streak`: Maximum consecutive errors

6. **Overall Performance**:
   - `overall_accuracy`: (correct_trials / total_trials) × 100
   - `completion_time_sec`: Total time to complete game

**Normalization and Encoding:**
- Numerical features age-normalized using z-scores within age bins (42-48, 48-54, 54-66 months)
- Categorical features (attention_level, engagement_level) encoded as numeric (1-5 scale)

**Feature Evaluation:**
- Correlation analysis confirmed strong relationships between Go/No-Go features and clinical labels
- Commission error rate and No-Go accuracy showed strongest predictive power (aligned with inhibitory control theory)

---

#### 3.3.3. Data Source 3: Age 5.5-6.9 Color-Shape (DCCS) Data

**Data Cleaning:**
- Raw DCCS game telemetry logs were checked for:
  - Invalid trial data (reaction times < 200ms or > 10000ms removed)
  - Incomplete sessions (< 30 trials removed)
  - Duplicate session records
- Missing trial-level data handled via median imputation

**Feature Extraction:**
Extracted attributes from DCCS game telemetry:

1. **Pre-Switch Block Metrics**:
   - `pre_switch_accuracy`: Percentage of correct responses in pre-switch block
   - `avg_rt_pre_switch_ms`: Mean reaction time for correct pre-switch trials
   - `pre_switch_trials`: Total number of pre-switch trials

2. **Post-Switch Block Metrics**:
   - `post_switch_accuracy`: Percentage of correct responses in post-switch block
   - `avg_rt_post_switch_correct_ms`: Mean reaction time for correct post-switch trials
   - `post_switch_trials`: Total number of post-switch trials

3. **Switch Cost Metrics**:
   - `switch_cost_ms`: Difference in reaction time (post-switch - pre-switch)
   - `switch_cost_percent`: (switch_cost_ms / avg_rt_pre_switch_ms) × 100
   - `accuracy_drop_percent`: (pre_switch_accuracy - post_switch_accuracy)

4. **Perseveration Metrics**:
   - `total_perseverative_errors`: Count of errors using previous rule after switch
   - `perseverative_error_rate_post_switch`: (perseverative_errors / post_switch_trials) × 100
   - `number_of_consecutive_perseverations`: Maximum consecutive perseverative errors
   - `total_rule_switch_errors`: Count of all rule-switching errors

5. **Mixed Block Metrics** (if applicable):
   - `mixed_block_accuracy`: Accuracy in mixed/randomized block
   - `mixed_block_trials`: Total number of mixed block trials

6. **Overall Performance**:
   - `accuracy_overall`: Overall accuracy across all blocks
   - `avg_reaction_time_ms`: Mean reaction time across all trials
   - `completion_time_sec`: Total time to complete game

**Normalization and Encoding:**
- Numerical features age-normalized using z-scores within age bins (66-72, 72-78, 78-83 months)
- Categorical features (attention_level, engagement_level) encoded as numeric (1-5 scale)

**Feature Evaluation:**
- Correlation analysis confirmed strong relationships between DCCS features and clinical labels
- Post-switch accuracy, switch cost, and perseverative error rate showed strongest predictive power (aligned with cognitive flexibility theory)

---

#### 3.3.4. Data Source 4: Clinician Reflection Data

**Data Cleaning:**
- Clinician behavioral observation forms were checked for completeness
- Missing ratings handled via median imputation (if < 50% missing) or removed (if > 50% missing)

**Feature Extraction:**
Extracted attributes from clinician reflection forms:

1. **Behavioral Ratings** (5-point Likert scales):
   - `attention_level`: Child's attention during assessment (1=very poor, 5=excellent)
   - `engagement_level`: Child's engagement with tasks (1=very poor, 5=excellent)
   - `frustration_tolerance`: Child's ability to handle frustration (1=very poor, 5=excellent)
   - `instruction_following`: Child's ability to follow instructions (1=very poor, 5=excellent)
   - `overall_behavior`: Overall behavioral rating (1=very poor, 5=excellent)

2. **Composite Behavioral Index**:
   - `behavioral_regulation_index`: Mean of attention_level, engagement_level, instruction_following

**Normalization and Encoding:**
- Behavioral ratings used as-is (already numeric, 1-5 scale)
- No age normalization needed (behavioral ratings are age-independent)

**Feature Evaluation:**
- Behavioral ratings showed moderate correlation with clinical labels
- Used as supplementary features (not primary predictors)

---

#### 3.3.5. Data Source 5: Clinical Labels

**Label Encoding:**
- Final clinical outcomes (ASD / Typically Developing) were encoded as binary class labels:
  - `group`: "asd" → 1, "typically_developing" → 0
  - `asd_label`: 1 (ASD), 0 (Typically Developing)

**Label Source Documentation:**
- `label_source`: Documented source of label (clinician_diagnosis / ADOS-2 / ADI-R / screening_threshold)
- Label quality tier assigned (Tier A: ADOS-2/ADI-R, Tier B: Clinician diagnosis, Tier C: Screening threshold)

**Consistency Checking:**
- Clinical labels were cross-verified with assessment data to ensure accurate mapping
- Inconsistencies (e.g., ASD label but high questionnaire scores) flagged for review

---

### 3.4. Model Training Methodology

#### 3.4.1. Model Selection

**Primary Model: Logistic Regression**
- Algorithm: `LogisticRegression` from scikit-learn
- Hyperparameters:
  - `max_iter=2000`: Ensure convergence
  - `class_weight="balanced"`: Handle class imbalance
  - `solver="liblinear"`: Efficient for small datasets
  - Regularization: L2 (default)
- **Rationale**: Interpretable, stable with small datasets, clinically explainable (odds ratios)

**Secondary Model: Random Forest (Shallow)**
- Algorithm: `RandomForestClassifier` from scikit-learn
- Hyperparameters:
  - `n_estimators=100`: Sufficient for small datasets
  - `max_depth=5`: Prevent overfitting
  - `min_samples_leaf=5`: Ensure robust splits
  - `class_weight="balanced"`: Handle class imbalance
  - `random_state=42`: Reproducibility
- **Rationale**: Comparison model, feature importance analysis, handles non-linear relationships

**Models NOT Used:**
- Deep Learning / Neural Networks: Too complex for small datasets, not interpretable
- XGBoost: Risk of overfitting with small data
- SVM (RBF): Poor interpretability, computationally expensive

---

#### 3.4.2. Feature Scaling

**Method: RobustScaler**
- Less sensitive to outliers than StandardScaler
- Uses median and IQR instead of mean and standard deviation
- Formula: `x_scaled = (x - median) / IQR`

**Procedure:**
1. Fit RobustScaler on training set only
2. Transform training set
3. Transform validation set (using training set statistics)
4. Transform test set (using training set statistics)

**Rationale**: Prevents data leakage (test set statistics never used during training)

---

#### 3.4.3. Train/Test Split

**Method: Child-Level Stratified Split**
- Split by `child_id` (not by row) to prevent data leakage
- Stratified by class (maintains class distribution)
- Split ratio: 70% train, 15% validation, 15% test (holdout)

**Procedure:**
1. Group all views by `child_id`
2. Split children (not views) into train/val/test
3. All views from a child go to the same split
4. Verify class distribution maintained in each split

**Rationale**: 
- Prevents overoptimistic performance estimates
- Reflects real-world deployment (new child = new prediction)
- Clinically defensible evaluation

---

#### 3.4.4. Model Training Procedure

**Step 1: Data Preparation**
- Load dataset for age group
- Apply multi-view expansion
- Engineer features (age normalization, composite indices)
- Handle missing values (median imputation)
- Handle outliers (winsorization)
- Encode target variable (ASD = 1, TD = 0)

**Step 2: Train/Test Split**
- Child-level stratified split (70/15/15)
- Verify both classes present in each split

**Step 3: Safe Data Augmentation (Training Only)**
- Bootstrap resampling with 3% Gaussian noise
- Applied only to training set
- Increases training data size while preserving data integrity

**Step 4: Feature Scaling**
- Fit RobustScaler on training set
- Transform train/val/test sets

**Step 5: Model Training**
- Train Logistic Regression on training set
- Train Random Forest on training set (for comparison)
- Evaluate on validation set (for threshold tuning)

**Step 6: Model Evaluation**
- Evaluate on holdout test set
- Calculate metrics: Accuracy, Precision, Recall (Sensitivity), Specificity, F1-Score, ROC-AUC
- Generate confusion matrix
- Analyze feature importance

---

#### 3.4.5. Risk Stratification Methodology

**Hybrid ML + Clinical Rules Approach:**

**Step 1: ML Probability**
- Model outputs probability P(ASD | features)
- Range: [0, 1]

**Step 2: Clinical Rules**
- Age-normalized z-scores (normative deviation)
- Composite indices (domain-level deficits)
- Thresholds: -1 SD (moderate), -2 SD (severe)

**Step 3: Risk Level Decision**
```
IF ML probability ≥ 0.7 AND clinical rules indicate Moderate/High → HIGH RISK
ELSE IF ML probability ≥ 0.4 AND clinical rules indicate Moderate → MODERATE RISK
ELSE → LOW RISK
```

**Rationale**: Combines ML predictive power with clinical interpretability. Not ML-only (black box) or rules-only (rigid).

---

### 3.5. System Architecture Methodology

#### 3.5.1. Three-Tier Architecture

**Tier 1: Flutter Mobile App (Tablet)**
- Framework: Flutter 3.38+ (Dart 3.0+)
- Local Storage: SQLite (sqflite package)
- Offline-First: All assessments run without internet
- Multilingual: ARB-based i18n (English/Sinhala/Tamil)
- Games: HTML5 embedded via WebView

**Tier 2: Node.js Backend**
- Runtime: Node.js with Express.js
- Validation: Joi schema validation
- Database: SQLite (local) + Firebase Firestore (optional cloud)
- APIs: REST endpoints for mobile app and web admin

**Tier 3: FastAPI ML Engine**
- Framework: FastAPI with Pydantic schemas
- ML Libraries: scikit-learn, joblib
- Features: Age normalization, feature scaling, risk stratification
- API Docs: Auto-generated Swagger UI

**Web Admin Portal:**
- Framework: React 18+ with TypeScript
- UI Library: Material-UI (MUI)
- Build Tool: Vite

---

#### 3.5.2. Offline-First Design

**Method:**
- Local SQLite storage (all data stored locally)
- Sync queue (background sync when online)
- Conflict resolution (never overwrite clinician-entered values)

**Rationale:**
- Enables deployment in low-resource settings (no internet required)
- Prevents data loss (local storage)
- Reduces barriers to adoption

---

### 3.6. Cultural Adaptation Methodology

#### 3.6.1. Language Adaptation

**Languages Supported:**
- English (baseline)
- Sinhala (සිංහල) - cultural adaptation
- Tamil (தமிழ்) - cultural adaptation

**Adaptation Process:**
1. Professional translation of all UI text, instructions, questions
2. Cultural review by local clinicians
3. Back-translation verification
4. Pilot testing with local families

---

#### 3.6.2. Content Adaptation

**M-CHAT-R/F Inspired Questionnaire:**
- Core items aligned with M-CHAT-R/F critical items
- Wording adapted for Sri Lankan cultural context
- Examples and scenarios use local references
- Response scales culturally validated

**Game Instructions:**
- Simplified language appropriate for local literacy levels
- Visual cues and animations support understanding
- Practice rounds ensure comprehension

---

### 3.7. Evaluation Methodology

#### 3.7.1. Performance Metrics

**Primary Metrics:**
- **Sensitivity (Recall)**: TP / (TP + FN) - Ability to detect ASD cases
- **Specificity**: TN / (TN + FP) - Ability to identify typically developing children
- **ROC-AUC**: Area under receiver operating characteristic curve

**Secondary Metrics:**
- **Accuracy**: (TP + TN) / (TP + TN + FP + FN)
- **Precision**: TP / (TP + FP)
- **F1-Score**: 2 × (Precision × Recall) / (Precision + Recall)

**Target Performance:**
- Sensitivity ≥ 85-90% (catch most ASD cases)
- Specificity ≥ 75-80% (acceptable false positive rate)
- ROC-AUC > 0.80 (acceptable discrimination)

---

#### 3.7.2. Clinical Validation

**Risk Level Validation:**
- Verify risk levels (Low/Moderate/High) align with clinical expectations
- Compare ML-only vs. Hybrid (ML + rules) performance
- Validate thresholds using validation set

**Feature Importance Validation:**
- Verify top features align with ASD research (executive function deficits)
- Confirm age-normalized features show stronger predictive power than raw features

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Project:** 25-26J-273 - SenseAI ASD Screening System
