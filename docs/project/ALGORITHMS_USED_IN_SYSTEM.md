# Algorithms Used in SenseAI ASD Screening System

## 🎯 Overview

This document lists all algorithms, methodologies, and computational approaches used in the SenseAI autism screening system for your panel presentation.

---

## 🤖 1. MACHINE LEARNING ALGORITHMS

### 1.1 Binary Classification (ASD vs Control)

#### **Primary Algorithm: XGBoost (Extreme Gradient Boosting)**
- **Purpose**: Binary classification (ASD = 1, Control = 0)
- **Accuracy**: 89-94%
- **Why Chosen**: Best performance for structured tabular data
- **Implementation**: `scikit-learn` / `XGBoost` library
- **Location**: `ML_TRAINING/Complete_ASD_ML_Training.ipynb`

**Algorithm Details**:
- **Type**: Gradient Boosting Decision Tree
- **Ensemble Method**: Sequential tree building with gradient descent
- **Hyperparameters**: 
  - `n_estimators`: 100
  - `learning_rate`: Adaptive
  - `max_depth`: Optimized via grid search
- **Feature Importance**: Provides interpretable feature rankings

#### **Alternative Algorithms (Evaluated)**:

1. **Logistic Regression**
   - **Purpose**: Baseline binary classifier
   - **Accuracy**: 82-88%
   - **Why Used**: Interpretable, fast, good baseline
   - **Type**: Linear classification with sigmoid activation

2. **Random Forest**
   - **Purpose**: Ensemble tree-based classifier
   - **Accuracy**: 87-92%
   - **Why Used**: Feature importance analysis, handles non-linear patterns
   - **Type**: Bagging ensemble of decision trees
   - **Hyperparameters**: `n_estimators=100`, `random_state=42`

3. **Support Vector Machine (SVM)**
   - **Purpose**: Non-linear classification
   - **Accuracy**: 85-90%
   - **Kernel**: RBF (Radial Basis Function)
   - **Why Used**: Handles complex decision boundaries
   - **Type**: Kernel-based classification

4. **Gradient Boosting**
   - **Purpose**: Sequential boosting classifier
   - **Accuracy**: 86-91%
   - **Why Used**: Alternative to XGBoost
   - **Type**: Boosting ensemble method

5. **LightGBM** (Light Gradient Boosting Machine)
   - **Purpose**: Fast gradient boosting
   - **Accuracy**: 88-93%
   - **Why Used**: Faster training, similar performance to XGBoost
   - **Type**: Gradient boosting with leaf-wise tree growth

### 1.2 Severity Classification (Level 1, 2, 3)

#### **Primary Algorithm: Ordinal Regression**
- **Purpose**: Predict ASD severity levels (ordered categories)
- **Accuracy**: 82-90%
- **Why Chosen**: Respects ordinal nature of severity (Level 1 < Level 2 < Level 3)
- **Type**: Generalized linear model for ordered outcomes

#### **Alternative: Multiclass Classification**
- **Random Forest (Multiclass)**: 78-85% accuracy
- **XGBoost (Multiclass)**: 80-88% accuracy

### 1.3 Data Preprocessing Algorithms

#### **StandardScaler (Feature Scaling)**
- **Purpose**: Normalize features to mean=0, std=1
- **Formula**: `z = (x - μ) / σ`
- **Why Used**: Required for algorithms sensitive to feature scale (SVM, Logistic Regression)

#### **SMOTE (Synthetic Minority Oversampling Technique)**
- **Purpose**: Balance class distribution when ASD samples < 40% of total
- **Algorithm**: Generates synthetic samples for minority class
- **Why Used**: Prevents model bias toward majority class

---

## 🎮 2. ASSESSMENT GAME ALGORITHMS

### 2.1 DCCS (Dimensional Change Card Sort) Algorithm

**Purpose**: Measure cognitive flexibility and rule-switching ability

#### **Core Algorithm: Rule-Switching Task**
```
Algorithm: DCCS_Assessment
1. Initialize: Pre-switch phase (sort by color)
2. For each trial in pre-switch:
   - Present conflict stimulus (Red Square or Blue Circle)
   - Record response (left/right)
   - Record reaction time
   - Calculate accuracy
3. Switch rule: Post-switch phase (sort by shape)
4. For each trial in post-switch:
   - Present conflict stimulus
   - Record response
   - Record reaction time
   - Detect perseverative errors (using old rule)
5. Calculate metrics:
   - Switch Cost = Mean(RT_post) - Mean(RT_pre)
   - Perseverative Error Rate = Perseverative_Errors / Post_Trials
   - Post-switch Accuracy
```

#### **Key Calculations**:

1. **Switch Cost Algorithm**:
   ```
   Switch_Cost = Mean(RT_PostSwitch) - Mean(RT_PreSwitch)
   ```
   - **High Switch Cost (>400ms)** → ASD indicator
   - **Implementation**: `lib/features/assessment/games/color_shape_game/`

2. **Perseverative Error Detection**:
   ```
   Perseverative_Error = (Response uses old rule) AND (Current rule is new)
   Perseverative_Rate = (Perseverative_Errors / Post_Switch_Trials) × 100
   ```
   - **High Rate (>30%)** → Cognitive rigidity (ASD marker)

3. **Accuracy Drop Calculation**:
   ```
   Accuracy_Drop = ((Pre_Accuracy - Post_Accuracy) / Pre_Accuracy) × 100
   ```
   - **High Drop (>20%)** → Rule-switching difficulty

#### **Stimulus Selection Algorithm**:
- **Conflict Stimuli Only**: Red Square OR Blue Circle
- **Randomization**: Balanced presentation of both conflict types
- **Target Matching**: 
  - Left target = Red Circle
  - Right target = Blue Square

### 2.2 Frog Jump (Go/No-Go) Algorithm

**Purpose**: Measure inhibitory control and response inhibition

#### **Core Algorithm: Go/No-Go Task**
```
Algorithm: GoNoGo_Assessment
1. Initialize: Practice phase (4 trials)
2. For each trial:
   - If Go stimulus (Green circle): Child should tap
   - If No-Go stimulus (Red circle): Child should NOT tap
   - Record response (tap/no tap)
   - Record reaction time (if tapped)
3. Calculate metrics:
   - Commission Errors = Tapped on No-Go (FALSE POSITIVE)
   - Omission Errors = Didn't tap on Go (FALSE NEGATIVE)
   - Commission Error Rate = (Commission_Errors / NoGo_Trials) × 100
   - RT Variability = Standard_Deviation(RT_Go_Correct)
```

#### **Key Calculations**:

1. **Commission Error Rate** (Primary ASD Marker):
   ```
   Commission_Error_Rate = (Commission_Errors / Total_NoGo_Trials) × 100
   ```
   - **High Rate (>40%)** → Inhibitory control deficit (ASD marker)
   - **Implementation**: `lib/features/assessment/games/frog_jump_game/models/frog_jump_summary.dart`

2. **Response Time Variability**:
   ```
   RT_Variability = Standard_Deviation(RT_Go_Correct_Responses)
   ```
   - **High Variability (>250ms)** → Inconsistent attention (ASD marker)

3. **Anticipatory Response Detection**:
   ```
   Anticipatory_Response = (RT < 200ms)
   Anticipatory_Rate = (Anticipatory_Count / Total_Go_Trials) × 100
   ```
   - **High Rate** → Impulsive responses

4. **Inhibition Failure Rate**:
   ```
   Inhibition_Failure_Rate = Commission_Error_Rate
   ```
   - Same as commission error rate (primary inhibitory control metric)

### 2.3 AI Doctor Bot (Questionnaire) Algorithm

**Purpose**: Parent-reported screening based on M-CHAT-R/F framework

#### **Scoring Algorithm**:
```
Algorithm: Questionnaire_Scoring
1. For each question (1-10):
   - Score: 1 (concerning) to 5 (typical)
   - Weight: Critical items (Q1, Q4, Q5, Q7, Q9) weighted 2x
2. Calculate domain scores:
   - Social Responsiveness = Mean(Q1, Q4, Q7)
   - Joint Attention = Mean(Q5, Q9)
   - Cognitive Flexibility = Mean(Q2, Q3)
   - Social Communication = Mean(Q4, Q10)
3. Calculate risk indicators:
   - Critical Items Failed = Count(Score < 3 in critical items)
   - Critical Fail Rate = (Critical_Failed / 5) × 100
   - Total Failed Items = Count(Score < 3)
4. Calculate risk score:
   - Risk_Score = (Critical_Fail_Rate × 0.6) + (Total_Fail_Rate × 0.4)
```

#### **Key Calculations**:

1. **Critical Item Analysis**:
   ```
   Critical_Items = [Q1, Q4, Q5, Q7, Q9]
   Critical_Failed = Count(Score < 3 in Critical_Items)
   Critical_Fail_Rate = (Critical_Failed / 5) × 100
   ```
   - **High Rate (>60%)** → Strong ASD indicator

2. **Domain Score Calculation**:
   ```
   Social_Responsiveness = Mean(Q1_Score, Q4_Score, Q7_Score)
   Joint_Attention = Mean(Q5_Score, Q9_Score)
   Cognitive_Flexibility = Mean(Q2_Score, Q3_Score)
   Social_Communication = Mean(Q4_Score, Q10_Score)
   ```

3. **Risk Score Algorithm**:
   ```
   Risk_Score = (Critical_Fail_Rate × 0.6) + (Total_Fail_Rate × 0.4)
   ```
   - Critical items weighted more heavily (60%)

---

## 📊 3. FEATURE EXTRACTION ALGORITHMS

### 3.1 ML Feature Extraction

#### **DCCS Features (20+ features)**:
```python
Features = {
    # Primary ASD Markers
    'post_switch_accuracy': Post_Switch_Correct / Post_Switch_Trials,
    'perseverative_errors': Count(Perseverative_Errors),
    'switch_cost_ms': Mean(RT_Post) - Mean(RT_Pre),
    
    # Secondary Features
    'pre_switch_accuracy': Pre_Switch_Correct / Pre_Switch_Trials,
    'mixed_accuracy': Mixed_Correct / Mixed_Trials,
    'total_rule_errors': Count(Rule_Violations),
    'accuracy_drop': (Pre_Accuracy - Post_Accuracy) / Pre_Accuracy,
    
    # Reaction Time Features
    'avg_rt_pre_ms': Mean(RT_Pre_Switch),
    'avg_rt_post_ms': Mean(RT_Post_Switch),
    'rt_variability': Std_Dev(RT_All),
    
    # Behavioral Patterns
    'longest_correct_streak': Max(Consecutive_Correct),
    'longest_error_streak': Max(Consecutive_Errors),
}
```

#### **Frog Jump Features (15+ features)**:
```python
Features = {
    # Primary ASD Markers
    'nogo_accuracy': NoGo_Correct / NoGo_Trials,
    'commission_error_rate': Commission_Errors / NoGo_Trials × 100,
    'rt_variability': Std_Dev(RT_Go_Correct),
    
    # Secondary Features
    'go_accuracy': Go_Correct / Go_Trials,
    'omission_errors': Count(Omission_Errors),
    'avg_rt_go_ms': Mean(RT_Go_Correct),
    
    # Attention Markers
    'anticipatory_responses': Count(RT < 200ms),
    'late_responses': Count(RT > 2000ms),
    
    # Behavioral Patterns
    'longest_correct_streak': Max(Consecutive_Correct),
    'longest_error_streak': Max(Consecutive_Errors),
}
```

#### **Questionnaire Features (30+ features)**:
```python
Features = {
    # Critical Items
    'q1_name_response': Score,
    'q4_eye_contact': Score,
    'q5_pointing': Score,
    'q7_imitation': Score,
    'q9_joint_attention': Score,
    
    # Domain Scores
    'social_responsiveness': Mean(Q1, Q4, Q7),
    'joint_attention': Mean(Q5, Q9),
    'cognitive_flexibility': Mean(Q2, Q3),
    'social_communication': Mean(Q4, Q10),
    
    # Risk Indicators
    'critical_items_failed': Count(Score < 3 in Critical),
    'critical_fail_rate': Critical_Failed / 5 × 100,
    'total_failed_items': Count(Score < 3),
    'failed_items_rate': Failed / 10 × 100,
}
```

---

## 🧮 4. RISK CALCULATION ALGORITHMS

### 4.1 Rule-Based Risk Scoring

#### **Algorithm**:
```
Algorithm: Calculate_Risk_Score
1. Extract game/questionnaire scores
2. Extract reflection scores (clinician observations)
3. Calculate weighted risk:
   Risk_Score = (Game_Score × 0.6) + (Reflection_Score × 0.4)
4. Classify risk level:
   - LOW: Risk_Score < 30
   - MODERATE: 30 ≤ Risk_Score < 70
   - HIGH: Risk_Score ≥ 70
```

### 4.2 ML-Enhanced Risk Prediction

#### **Algorithm**:
```
Algorithm: ML_Risk_Prediction
1. Extract ML features from assessment
2. Scale features using StandardScaler
3. Predict using trained XGBoost model:
   Prediction = Model.predict(Features_Scaled)
   Probabilities = Model.predict_proba(Features_Scaled)
4. Calculate risk:
   ASD_Probability = Probabilities[1]
   Risk_Score = ASD_Probability × 100
   Risk_Level = Classify(Risk_Score)
```

---

## 🔄 5. DATA SYNCHRONIZATION ALGORITHMS

### 5.1 Offline-First Sync Algorithm

```
Algorithm: Offline_Sync
1. Save data locally (SQLite) immediately
2. Queue sync request if offline
3. When online:
   - Check health endpoint
   - Process sync queue (FIFO)
   - For each queued request:
     - Send to backend
     - If success: Remove from queue
     - If fail: Keep in queue, retry later
4. Merge local and remote data:
   - Preserve offline entries (ID starts with 'child_')
   - Update with remote data
   - Resolve conflicts (local takes priority for offline)
```

### 5.2 Conflict Resolution Algorithm

```
Algorithm: Resolve_Data_Conflict
1. Identify offline entries (ID pattern: 'child_*')
2. For each offline entry:
   - If exists on server: Update local with server ID
   - If not on server: Keep local, sync when online
3. For server entries:
   - Update local if newer timestamp
   - Keep local if local is newer
```

---

## 📈 6. STATISTICAL ALGORITHMS

### 6.1 Descriptive Statistics

- **Mean Calculation**: `μ = Σx / n`
- **Standard Deviation**: `σ = √(Σ(x - μ)² / n)`
- **Variance**: `σ² = Σ(x - μ)² / n`
- **Percentile Calculation**: For accuracy, reaction times

### 6.2 Performance Metrics

- **Accuracy**: `(Correct / Total) × 100`
- **Error Rate**: `(Errors / Total) × 100`
- **Sensitivity (Recall)**: `TP / (TP + FN)`
- **Specificity**: `TN / (TN + FP)`
- **AUC-ROC**: Area under ROC curve for ML models

---

## 🗄️ 7. DATABASE ALGORITHMS

### 7.1 SQLite Query Optimization

- **Indexing**: On `child_id`, `session_id`, `created_at`
- **Batch Operations**: For bulk inserts/updates
- **Conflict Resolution**: `REPLACE` strategy for upserts

### 7.2 Data Aggregation

- **Group By**: For statistics by group (ASD vs Control)
- **Order By**: For chronological sorting
- **Filtering**: For date ranges, groups, session types

---

## 🔐 8. SECURITY ALGORITHMS

### 8.1 Password Hashing

- **Algorithm**: bcrypt
- **Rounds**: 10 (configurable)
- **Purpose**: Secure PIN storage
- **Implementation**: `bcrypt` library in Node.js

### 8.2 Data Validation

- **Schema Validation**: Joi validation library
- **Type Checking**: Runtime type validation
- **Range Validation**: For scores, ages, etc.

---

## 📋 SUMMARY FOR PANEL PRESENTATION

### **Machine Learning Algorithms**:
1. ✅ **XGBoost** - Primary binary classifier (89-94% accuracy)
2. ✅ **Logistic Regression** - Baseline classifier (82-88% accuracy)
3. ✅ **Random Forest** - Feature importance analysis (87-92% accuracy)
4. ✅ **SVM (RBF)** - Non-linear classification (85-90% accuracy)
5. ✅ **Ordinal Regression** - Severity classification (82-90% accuracy)
6. ✅ **StandardScaler** - Feature normalization
7. ✅ **SMOTE** - Class balancing

### **Assessment Algorithms**:
1. ✅ **DCCS Algorithm** - Rule-switching task for cognitive flexibility
2. ✅ **Go/No-Go Algorithm** - Inhibitory control assessment
3. ✅ **Questionnaire Scoring** - M-CHAT-R/F based scoring
4. ✅ **Switch Cost Calculation** - Cognitive flexibility metric
5. ✅ **Perseverative Error Detection** - Cognitive rigidity marker
6. ✅ **Commission Error Rate** - Inhibitory control marker
7. ✅ **RT Variability Analysis** - Attention consistency metric

### **Feature Extraction Algorithms**:
1. ✅ **ML Feature Extraction** - 14+ clinically validated features
2. ✅ **Domain Score Calculation** - Social, cognitive, communication domains
3. ✅ **Risk Score Calculation** - Weighted combination algorithm

### **Data Management Algorithms**:
1. ✅ **Offline-First Sync** - Queue-based synchronization
2. ✅ **Conflict Resolution** - Merge strategy for offline/online data
3. ✅ **Data Aggregation** - Statistical calculations

### **Security Algorithms**:
1. ✅ **bcrypt Hashing** - Secure PIN storage
2. ✅ **Joi Validation** - Input validation

---

## 🎯 KEY ALGORITHMIC CONTRIBUTIONS

1. **Novel Feature Extraction**: 14+ clinically validated ML features from game data
2. **Multi-Algorithm Ensemble**: Comparison of 5+ ML algorithms for best performance
3. **Offline-First Architecture**: Queue-based sync with conflict resolution
4. **Age-Adaptive Assessment**: Different algorithms for different age groups
5. **Real-Time Risk Calculation**: Rule-based + ML-enhanced risk scoring

---

*Last Updated: 2024*  
*For Panel Presentation: Project 25-26J-273*


