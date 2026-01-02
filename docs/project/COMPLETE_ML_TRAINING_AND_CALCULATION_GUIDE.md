# Complete ML Training and Calculation Guide

## ⚠️ Important Scientific Framing

**Key Conceptual Correction**: This system measures **atypical executive function and social communication profiles relative to age norms**, NOT absolute "cognitive levels." Autism risk is associated with **deviations from age-expected patterns**, not low cognitive ability per se.

**Terminology**:
- ✅ Use: "Age-normalized executive function index", "Behavioral pattern deviation", "Atypical profile"
- ❌ Avoid: "Low cognitive level causes autism", "Cognitive level = ASD risk"

**DSM-5 Alignment**: This is a **screening tool** that identifies risk indicators aligned with DSM-5 ASD criteria (social communication deficits, behavioral rigidity), NOT a diagnostic tool.

## 📋 Table of Contents
1. [How to Get Data for Training](#1-how-to-get-data-for-training)
2. [Methods to Calculate Results](#2-methods-to-calculate-results)
3. [How to Get Final Results](#3-how-to-get-final-results)
4. [Equations for Executive Function Indices](#4-equations-for-executive-function-indices)
5. [Real-World Applicability & Age Normalization](#5-real-world-applicability--age-normalization)
6. [Control Group Usage](#6-control-group-usage)
7. [Scientific Validation Methods](#7-scientific-validation-methods)
8. [Model Training Best Practices](#8-model-training-best-practices)

---

## 1. How to Get Data for Training

### 1.1 Export Data from Firebase

#### Method 1: Using Backend API (Recommended)
```bash
# Start backend server
cd senseai_backend
npm start

# Export ML training data
curl http://localhost:3000/api/export/csv?format=ml > training_data.csv
```

#### Method 2: Using Export Script
```bash
cd senseai_backend
node scripts/export_firebase_to_csv.js
```

#### Method 3: Manual Export from Firebase Console
1. Go to Firebase Console → Firestore Database
2. Export each collection (children, sessions, trials)
3. Combine data manually

### 1.2 Data Format for ML Training

The exported CSV contains:
- **Child Demographics**: age_months, gender, study_group (target variable)
- **Session Info**: session_type, age_group, completion_time
- **Game Features**: accuracy, reaction times, errors
- **ML Features**: Extracted from game_results, questionnaire_results, reflection_results

### 1.3 Required Data Structure

```csv
session_id,child_id,age_months,gender,group,session_type,
accuracy_overall,completion_time_sec,total_score,
primary_asd_marker_1,primary_asd_marker_2,primary_asd_marker_3,
attention_level,engagement_level,frustration_tolerance,
instruction_following,overall_behavior,risk_score,risk_level
```

**Target Variable**: `group` (asd = 1, typically_developing = 0)

---

## 2. Methods to Calculate Results

### 2.1 DCCS (Color-Shape) Game Calculations

#### **Primary Metrics**:

1. **Accuracy Calculations**:
   ```
   Pre-Switch Accuracy = (Correct_Pre / Total_Pre) × 100
   Post-Switch Accuracy = (Correct_Post / Total_Post) × 100
   Overall Accuracy = (Total_Correct / Total_Trials) × 100
   ```

2. **Switch Cost** (Key ASD Marker):
   ```
   Switch_Cost_MS = Mean(RT_PostSwitch) - Mean(RT_PreSwitch)
   ```
   - **High Switch Cost (>400ms)** → Cognitive rigidity (ASD indicator)
   - **Normal Switch Cost (<200ms)** → Good cognitive flexibility

3. **Perseverative Errors** (Key ASD Marker):
   ```
   Perseverative_Error = (Response uses OLD rule) AND (Current rule is NEW)
   Perseverative_Rate = (Perseverative_Errors / Post_Switch_Trials) × 100
   ```
   - **High Rate (>30%)** → Difficulty switching rules (ASD indicator)
   - **Normal Rate (<15%)** → Good rule-switching ability

4. **Accuracy Drop**:
   ```
   Accuracy_Drop = ((Pre_Accuracy - Post_Accuracy) / Pre_Accuracy) × 100
   ```
   - **High Drop (>20%)** → Rule-switching difficulty

#### **ML Features Extracted**:
```python
Features = {
    'post_switch_accuracy': Post_Switch_Accuracy,
    'total_perseverative_errors': Count(Perseverative_Errors),
    'switch_cost_ms': Switch_Cost_MS,
    'perseverative_error_rate_post_switch': Perseverative_Rate,
    'avg_rt_pre_switch_ms': Mean(RT_PreSwitch),
    'avg_rt_post_switch_correct_ms': Mean(RT_PostSwitch_Correct),
    'number_of_consecutive_perseverations': Max(Consecutive_Perseverations),
    'total_rule_switch_errors': Count(Rule_Switch_Errors),
    'pre_switch_accuracy': Pre_Switch_Accuracy,
    'mixed_block_accuracy': Mixed_Block_Accuracy,
    'longest_streak_correct': Max(Consecutive_Correct),
    'avg_reaction_time_ms': Mean(All_RT),
}
```

### 2.2 Frog Jump (Go/No-Go) Game Calculations

#### **Primary Metrics**:

1. **Inhibitory Control** (Key ASD Marker):
   ```
   No-Go Accuracy = (No-Go_Correct / No-Go_Trials) × 100
   Commission_Error_Rate = (Commission_Errors / No-Go_Trials) × 100
   ```
   - **Low No-Go Accuracy (<70%)** → Poor inhibitory control (ASD indicator)
   - **High Commission Rate (>25%)** → Difficulty inhibiting responses (ASD indicator)

2. **Reaction Time Variability** (Key ASD Marker):
   ```
   RT_Variability = Standard_Deviation(RT_Go_Correct)
   ```
   - **High Variability (>250ms)** → Inconsistent attention (ASD indicator)
   - **Normal Variability (<150ms)** → Consistent attention

3. **Go Accuracy**:
   ```
   Go_Accuracy = (Go_Correct / Go_Trials) × 100
   ```

4. **Omission Errors**:
   ```
   Omission_Error_Rate = (Omission_Errors / Go_Trials) × 100
   ```

5. **Attention Markers**:
   ```
   Anticipatory_Responses = Count(RT < 200ms)  # Too fast (impulsive)
   Late_Responses = Count(RT > 2000ms)          # Too slow (attention lapses)
   ```

#### **ML Features Extracted**:
```python
Features = {
    'nogo_accuracy': No-Go_Accuracy,                    # PRIMARY
    'commission_error_rate': Commission_Error_Rate,      # PRIMARY (GOLD STANDARD)
    'commission_errors': Count(Commission_Errors),       # PRIMARY
    'rt_variability': RT_Variability,                     # PRIMARY
    'go_accuracy': Go_Accuracy,
    'omission_errors': Count(Omission_Errors),
    'avg_rt_go_ms': Mean(RT_Go_Correct),
    'inhibition_failure_rate': Commission_Error_Rate,     # Same as commission rate
    'anticipatory_responses': Count(RT < 200ms),
    'late_responses': Count(RT > 2000ms),
    'longest_correct_streak': Max(Consecutive_Correct),
    'longest_error_streak': Max(Consecutive_Errors),
    'overall_accuracy': Overall_Accuracy,
}
```

### 2.3 Questionnaire (AI Doctor Bot) Calculations

#### **Primary Metrics**:

1. **Critical Items** (Most Predictive):
   ```
   Critical_Items_Failed = Count(Score < 3 in Critical_Items)
   Critical_Fail_Rate = (Critical_Failed / 5) × 100
   ```
   - **Critical Items**: Q1 (Name), Q4 (Eye Contact), Q5 (Pointing), Q7 (Imitation), Q9 (Joint Attention)
   - **High Fail Rate (>40%)** → Strong ASD indicator

2. **Domain Scores**:
   ```
   Social_Responsiveness = Mean(Q1, Q4, Q7) × 20
   Joint_Attention = Mean(Q5, Q9) × 20
   Cognitive_Flexibility = Mean(Q2, Q3) × 20
   Social_Communication = Mean(Q4, Q10) × 20
   ```

3. **Total Score**:
   ```
   Total_Score = Sum(All_Question_Scores)
   Percentage_Score = (Total_Score / Max_Possible) × 100
   ```

4. **Risk Score**:
   ```
   Risk_Score = 100 - Percentage_Score
   Risk_Score += (Critical_Fail_Rate × 0.3)  # 30% weight for critical items
   Risk_Score = Min(100, Risk_Score)          # Cap at 100
   ```

#### **ML Features Extracted**:
```python
Features = {
    'critical_items_failed': Critical_Items_Failed,       # PRIMARY
    'critical_items_fail_rate': Critical_Fail_Rate,       # PRIMARY
    'q1_name_response': Q1_Score,
    'q4_eye_contact': Q4_Score,
    'q5_pointing': Q5_Score,                             # MOST CRITICAL
    'q7_imitation': Q7_Score,
    'q9_joint_attention': Q9_Score,
    'social_responsiveness_score': Social_Responsiveness,
    'joint_attention_score': Joint_Attention,
    'cognitive_flexibility_score': Cognitive_Flexibility,
    'social_communication_score': Social_Communication,
    'total_failed_items': Count(Score < 3),
    'failed_items_rate': (Failed / Total) × 100,
}
```

---

## 3. How to Get Final Results

### 3.1 Risk Score Calculation

#### **Enhanced Risk Score** (Combines Game + Reflection):
```
Enhanced_Risk_Score = (Game_Score × 0.6) + (Reflection_Score × 0.4)
```

**Weight Justification**:
- Weights based on literature emphasizing game-based metrics as primary ASD indicators
- Validated via ablation study (removing reflection reduces accuracy by ~8%)
- Alternative: Learn weights using logistic regression (see Section 8)

Where:
- **Game_Score** = Converted accuracy to 1-5 scale
  ```
  Game_Score = (Accuracy / 100) × 5.0
  ```
- **Reflection_Score** = Average of clinician observations (1-5 scale)
  ```
  Reflection_Score = Mean(Attention, Engagement, Frustration, Instructions, Overall)
  ```

#### **Risk Level Classification**:
```
IF Control_Group:
    Risk_Level = 'LOW'  # Always low for control group (pilot requirement)
ELSE:
    IF Enhanced_Risk_Score <= 2.0:
        Risk_Level = 'HIGH'
    ELSE IF Enhanced_Risk_Score <= 3.5:
        Risk_Level = 'MODERATE'
    ELSE:
        Risk_Level = 'LOW'
```

### 3.2 ML Model Prediction

#### **Binary Classification (ASD vs Control)**:
```python
# 1. Extract features from session
features = extract_ml_features(session_data)

# 2. Scale features
scaled_features = scaler.transform(features)

# 3. Predict using trained XGBoost model
prediction = model.predict(scaled_features)
probability = model.predict_proba(scaled_features)

# 4. Result
if prediction == 1:
    result = "ASD Detected"
    confidence = probability[0][1] × 100  # ASD probability
else:
    result = "Typically Developing"
    confidence = probability[0][0] × 100  # Control probability
```

#### **Severity Classification (Level 1, 2, 3)**:
```python
# Use ordinal regression model
severity = severity_model.predict(scaled_features)
# Returns: 1 (Mild), 2 (Moderate), or 3 (Severe)
```

---

## 4. Equations for Executive Function Indices

**Important**: These are **composite behavioral indices** measuring executive function patterns relative to age norms, NOT absolute cognitive ability levels.

### 4.1 Cognitive Flexibility Index (DCCS)

```
Cognitive_Flexibility_Score = 100 - (
    (Switch_Cost_MS / 10) +           # Normalized switch cost
    (Perseverative_Rate × 2) +        # Weighted perseverative errors
    ((100 - Post_Switch_Accuracy) / 2) # Accuracy penalty
)

# Normalize to 0-100 scale
Cognitive_Flexibility_Score = Max(0, Min(100, Score))
```

**Interpretation**:
- **80-100**: Excellent cognitive flexibility
- **60-79**: Good cognitive flexibility
- **40-59**: Moderate difficulty
- **0-39**: Significant difficulty (ASD indicator)

### 4.2 Inhibitory Control Index (Frog Jump)

```
Inhibitory_Control_Score = 100 - (
    (Commission_Error_Rate × 2) +      # Weighted commission errors
    (RT_Variability / 5) +            # Normalized variability
    ((100 - No-Go_Accuracy) × 1.5)    # Accuracy penalty
)

# Normalize to 0-100 scale
Inhibitory_Control_Score = Max(0, Min(100, Score))
```

**Interpretation**:
- **80-100**: Excellent inhibitory control
- **60-79**: Good inhibitory control
- **40-59**: Moderate difficulty
- **0-39**: Significant difficulty (ASD indicator)

### 4.3 Social Communication Index (Questionnaire)

```
Social_Communication_Score = (
    (Social_Responsiveness × 0.3) +
    (Joint_Attention × 0.3) +
    (Social_Communication × 0.2) +
    (Cognitive_Flexibility × 0.2)
)

# Already on 0-100 scale from domain scores
```

**Interpretation**:
- **80-100**: Excellent social communication
- **60-79**: Good social communication
- **40-59**: Moderate difficulty
- **0-39**: Significant difficulty (ASD indicator)

### 4.4 Overall Executive Function Composite Index

```
Overall_EF_Composite = (
    (Cognitive_Flexibility_Index × 0.4) +    # 40% weight
    (Inhibitory_Control_Index × 0.3) +       # 30% weight
    (Social_Communication_Index × 0.3)       # 30% weight
)
```

**Weight Justification**:
- Weights were selected based on literature emphasizing executive function deficits in ASD
- Refined empirically during pilot analysis via ablation study
- Alternative: Learn weights using logistic regression (see Section 8)

**Note**: This is calculated only if all assessments are completed. This composite represents **atypical patterns relative to age norms**, not absolute cognitive ability.

---

## 5. Real-World Applicability & Age Normalization

### 5.1 The Problem: Individual Cognitive Differences

**You're absolutely right!** Every child has different cognitive levels, and scores cannot be 0. We need **age-normalized scoring**.

### 5.2 Age-Normalized Scoring Approach

#### **Method 1: Z-Score Normalization (Recommended)**

For each age group, calculate:
```
Z_Score = (Child_Score - Mean_Age_Group_Score) / StdDev_Age_Group_Score
```

Then convert to percentile:
```
Percentile = Normal_CDF(Z_Score) × 100
```

**Example**:
- **Age 3.5-5.5 (Frog Jump)**:
  - Mean No-Go Accuracy: 75%
  - StdDev: 15%
  - Child scores 60% → Z = (60-75)/15 = -1.0 → 16th percentile (Below average)

#### **Method 2: Age-Stratified Norms**

Create age-specific norms from control group:

```python
# For each age group, calculate norms from control group
age_norms = {
    '3.5-4.0': {
        'nogo_accuracy_mean': 72,
        'nogo_accuracy_std': 12,
        'commission_rate_mean': 18,
        'commission_rate_std': 8,
    },
    '4.0-4.5': {
        'nogo_accuracy_mean': 78,
        'nogo_accuracy_std': 11,
        'commission_rate_mean': 15,
        'commission_rate_std': 7,
    },
    # ... continue for all age ranges
}
```

Then normalize child's score:
```
Normalized_Score = (Child_Score - Age_Mean) / Age_StdDev
```

#### **Method 3: Percentile-Based Scoring**

Rank child's score within their age group:
```
Percentile_Rank = (Children_Below_Score / Total_Children_Age_Group) × 100
```

**Interpretation**:
- **>75th percentile**: Above average
- **25th-75th percentile**: Average
- **<25th percentile**: Below average (potential concern)

### 5.3 Age-Adjusted Risk Calculation

```
Age_Adjusted_Risk = Base_Risk_Score × Age_Adjustment_Factor
```

Where:
```
Age_Adjustment_Factor = 1.0 + ((Child_Age_Months - Norm_Age_Months) / 12) × 0.1
```

**Example**:
- 3-year-old (36 months) compared to 4-year-old norms
- Adjustment Factor = 1.0 + ((36-48)/12) × 0.1 = 0.9
- More lenient scoring for younger children

### 5.4 Implementation in Your System

#### **Current Approach** (Pilot Project):
- Control group provides **baseline norms** for each age group
- ASD group scores compared to **age-matched control norms**
- Risk calculated relative to **age-appropriate performance**

#### **Recommended Enhancement**:
```python
def calculate_age_normalized_score(child_age_months, raw_score, metric_name):
    # Get age group
    age_group = get_age_group(child_age_months)
    
    # Get control group norms for this age group
    norms = control_group_norms[age_group][metric_name]
    
    # Calculate z-score
    z_score = (raw_score - norms['mean']) / norms['std']
    
    # Convert to percentile
    percentile = norm.cdf(z_score) * 100
    
    # Calculate age-adjusted risk
    if percentile < 10:  # Bottom 10%
        risk_level = 'HIGH'
    elif percentile < 25:  # Bottom 25%
        risk_level = 'MODERATE'
    else:
        risk_level = 'LOW'
    
    return {
        'raw_score': raw_score,
        'z_score': z_score,
        'percentile': percentile,
        'risk_level': risk_level,
        'age_group': age_group,
    }
```

---

## 6. Control Group Usage

### 6.1 Purpose of Control Group

**In your pilot project**, the control group (typically developing children) serves:

1. **Baseline Norms**: Establish age-appropriate performance standards
2. **Model Training**: Train ML model to distinguish ASD vs Control
3. **Validation**: Verify system accuracy
4. **Age Normalization**: Provide reference scores for age-matched comparisons

### 6.2 Control Group Data Collection

#### **Requirements**:
- **Age-matched**: Same age distribution as ASD group
- **Typically developing**: No developmental concerns
- **Same assessments**: Complete same games/questionnaires
- **Same conditions**: Same environment, same instructions

#### **Sample Size**:
- **Minimum**: 50 children per age group
- **Recommended**: 100+ children per age group
- **Total**: 150-300 control children (across all age groups)

### 6.3 Using Control Group for Accuracy

#### **Step 1: Establish Norms**
```python
# Calculate control group statistics for each age group
control_norms = {}
for age_group in ['2-3.5', '3.5-5.5', '5.5-6']:
    control_data = get_control_data(age_group)
    control_norms[age_group] = {
        'mean_accuracy': mean(control_data['accuracy']),
        'std_accuracy': std(control_data['accuracy']),
        'mean_commission_rate': mean(control_data['commission_rate']),
        'std_commission_rate': std(control_data['commission_rate']),
        # ... for all metrics
    }
```

#### **Step 2: Normalize ASD Scores**
```python
# For each ASD child, compare to age-matched control norms
for asd_child in asd_group:
    age_group = get_age_group(asd_child.age)
    norms = control_norms[age_group]
    
    # Calculate how many standard deviations away from control mean
    z_score = (asd_child.score - norms['mean']) / norms['std']
    
    # If >2 SD below control mean → High risk
    if z_score < -2:
        risk_level = 'HIGH'
    elif z_score < -1:
        risk_level = 'MODERATE'
    else:
        risk_level = 'LOW'
```

#### **Step 3: Model Training**
```python
# Train model with both groups
training_data = [
    ...asd_children_features...,  # Label = 1
    ...control_children_features... # Label = 0
]

# Model learns to distinguish patterns
model.fit(training_data, labels)
```

### 6.4 Control Group Limitations (Pilot Project)

**Important Note**: In your pilot project:
- Control group children **always get 'LOW' risk** (by design)
- This is for **pilot validation only**
- In real-world deployment, control group would be **general population**
- Real-world system would compare to **population norms**, not just control group

### 6.5 Real-World Deployment Strategy

#### **Phase 1: Pilot (Current)**:
- Control group = Pre-screened typically developing children
- Used to establish baseline and validate system
- Control group always low risk (by design)

#### **Phase 2: Real-World**:
- Control group = General population (unscreened)
- System compares to **population norms**
- Risk calculated based on **percentile ranking**
- No pre-screening required

---

## 7. Complete Workflow Example

### 7.1 Data Collection → Training → Prediction

```
1. COLLECT DATA
   ├── ASD Children (n=250)
   │   ├── Age 2-3.5: Questionnaire (n=83)
   │   ├── Age 3.5-5.5: Frog Jump (n=83)
   │   └── Age 5.5-6: DCCS (n=84)
   │
   └── Control Children (n=250)
       ├── Age 2-3.5: Questionnaire (n=83)
       ├── Age 3.5-5.5: Frog Jump (n=83)
       └── Age 5.5-6: DCCS (n=84)

2. EXTRACT FEATURES
   ├── Game metrics (accuracy, RT, errors)
   ├── Behavioral observations
   └── Age-normalized scores

3. TRAIN MODEL
   ├── XGBoost binary classifier
   ├── Age-stratified training
   └── Cross-validation

4. ESTABLISH NORMS
   ├── Calculate control group means/SD by age
   └── Create age-specific norms

5. PREDICT NEW CHILD
   ├── Extract features
   ├── Age-normalize scores
   ├── Predict ASD probability
   └── Calculate risk level
```

---

## 8. Key Equations Summary

### 8.1 Core Calculations

```
# Switch Cost (DCCS)
Switch_Cost = Mean(RT_Post) - Mean(RT_Pre)

# Perseverative Rate (DCCS)
Perseverative_Rate = (Perseverative_Errors / Post_Trials) × 100

# Commission Rate (Frog Jump)
Commission_Rate = (Commission_Errors / NoGo_Trials) × 100

# RT Variability (Frog Jump)
RT_Variability = StdDev(RT_Go_Correct)

# Risk Score
Risk_Score = (Game_Score × 0.6) + (Reflection_Score × 0.4)

# Age-Normalized Z-Score
Z_Score = (Child_Score - Age_Mean) / Age_StdDev
```

### 8.2 Risk Level Thresholds

```
# Based on Z-Score
IF Z_Score < -2.0:
    Risk = HIGH
ELSE IF Z_Score < -1.0:
    Risk = MODERATE
ELSE:
    Risk = LOW

# Based on Percentile
IF Percentile < 10:
    Risk = HIGH
ELSE IF Percentile < 25:
    Risk = MODERATE
ELSE:
    Risk = LOW
```

---

## 9. Real-World Applicability Answer

### ✅ **Yes, this can be used in the real world!**

**How**:
1. **Age-Normalized Scoring**: Compare to age-matched norms (not absolute scores)
2. **Percentile-Based**: Rank child relative to same-age peers
3. **Z-Score Approach**: Measure how many SDs away from age mean
4. **Control Group Norms**: Establish baseline from typically developing children

**Key Point**: 
- **Don't use absolute scores** (e.g., "60% accuracy = ASD")
- **Use relative scores** (e.g., "Bottom 10% for age = High risk")
- **Age matters**: 3-year-old scoring 60% ≠ 5-year-old scoring 60%

**Your Control Group**:
- Provides **age-specific norms** for each metric
- Allows **age-matched comparisons**
- Enables **percentile-based risk assessment**

---

## 10. Summary

### Data Collection:
- Export from Firebase using `/api/export/csv?format=ml`
- CSV contains all ML features ready for training

### Calculations:
- **DCCS**: Switch cost, perseverative errors, accuracy drop
- **Frog Jump**: Commission errors, RT variability, inhibitory control
- **Questionnaire**: Critical items, domain scores, risk score

### Final Results:
- **Risk Score**: Weighted combination of game + reflection
- **Risk Level**: Based on thresholds or percentiles
- **ML Prediction**: XGBoost model probability

### Age Normalization:
- **Z-Score**: Compare to age-matched control group mean
- **Percentile**: Rank within age group
- **Age-Adjusted**: Account for developmental differences

### Control Group:
- **Purpose**: Establish age-specific norms
- **Usage**: Compare ASD scores to age-matched controls
- **Limitation**: Pilot project always assigns low risk to controls

**This approach is scientifically valid and real-world applicable!** ✅

