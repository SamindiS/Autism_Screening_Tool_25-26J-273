# 📊 Data Expansion: Multi-View Approach

## How Many Sessions/Views Does One Child's Data Create?

### Summary by Age Group

| Age Group | Assessment Type | Number of Views Per Child | Expansion Factor |
|-----------|----------------|---------------------------|------------------|
| **2-3.5 years** | Questionnaire | **Up to 3 views** | ~3x |
| **3.5-5.5 years** | Frog Jump (Go/No-Go) | **Up to 3 views** | ~3x |
| **5.5-6.9 years** | Color-Shape (DCCS) | **Up to 4 views** | ~4x |

---

## Detailed Breakdown

### 1. Age 2-3.5: Questionnaire Model

**One child's data → Up to 3 views:**

#### **View 1: Social Domain**
- `social_responsiveness_score`
- `joint_attention_score`
- `social_communication_score`
- `critical_items_failed`
- `critical_items_fail_rate`
- `attention_level`
- `engagement_level`

#### **View 2: Behavioral Regulation**
- `attention_level`
- `engagement_level`
- `frustration_tolerance`
- `instruction_following`
- `overall_behavior`
- `completion_time_sec`

#### **View 3: Task Performance**
- `total_score`
- `accuracy_overall`
- `completion_time_sec`
- `critical_items_failed`
- `cognitive_flexibility_score`

**Example**:
- Original: 1 child = 1 row
- After expansion: 1 child = 3 rows (one for each view)
- **Expansion factor: 3x**

---

### 2. Age 3.5-5.5: Frog Jump (Go/No-Go) Model

**One child's data → Up to 3 views:**

#### **View 1: Inhibition Control**
- `nogo_accuracy`
- `commission_errors`
- `commission_error_rate`
- `inhibition_failure_rate`
- `anticipatory_responses`
- `anticipatory_rate`
- `attention_level`
- `engagement_level`

#### **View 2: Response Control**
- `go_accuracy`
- `overall_accuracy`
- `omission_errors`
- `omission_error_rate`
- `avg_rt_go_ms`
- `rt_variability`
- `late_responses`
- `late_response_rate`
- `longest_correct_streak`

#### **View 3: Behavioral Regulation**
- `attention_level`
- `engagement_level`
- `frustration_tolerance`
- `instruction_following`
- `overall_behavior`
- `completion_time_sec`
- `longest_error_streak`

**Example**:
- Original: 1 child = 1 row
- After expansion: 1 child = 3 rows (one for each view)
- **Expansion factor: 3x**

---

### 3. Age 5.5-6.9: Color-Shape (DCCS) Model

**One child's data → Up to 4 views:**

#### **View 1: Cognitive Flexibility**
- `pre_switch_accuracy`
- `post_switch_accuracy`
- `mixed_block_accuracy`
- `switch_cost_ms`
- `accuracy_drop_percent`
- `accuracy_overall`
- `attention_level`
- `engagement_level`

#### **View 2: Perseveration**
- `total_perseverative_errors`
- `perseverative_error_rate_post_switch`
- `number_of_consecutive_perseverations`
- `total_rule_switch_errors`
- `longest_streak_correct`
- `frustration_tolerance`

#### **View 3: Reaction Time**
- `avg_rt_pre_switch_ms`
- `avg_rt_post_switch_correct_ms`
- `switch_cost_ms`
- `avg_reaction_time_ms`
- `completion_time_sec`

#### **View 4: Behavioral Regulation**
- `attention_level`
- `engagement_level`
- `frustration_tolerance`
- `instruction_following`
- `overall_behavior`
- `completion_time_sec`

**Example**:
- Original: 1 child = 1 row
- After expansion: 1 child = 4 rows (one for each view)
- **Expansion factor: 4x**

---

## How It Works

### Logic Flow

```python
For each child's data:
  1. Check if View 1 features exist → Create View 1
  2. Check if View 2 features exist → Create View 2
  3. Check if View 3 features exist → Create View 3
  4. (For DCCS only) Check if View 4 features exist → Create View 4
  
  IMPORTANT: Even if features are missing, 
  each child MUST contribute at least 1 view
  (to preserve class balance)
```

### Example: Age 5.5-6.9 Child

**Original Data (1 row)**:
```
child_id: LRH-006
age_months: 76
group: asd
post_switch_accuracy: 50
switch_cost_ms: -1782
perseverative_error_rate: 50
avg_rt_pre_switch_ms: 6348.875
attention_level: 1
engagement_level: 3
```

**After Expansion (4 rows)**:

**Row 1 (Cognitive Flexibility View)**:
```
child_id: LRH-006
view_type: cognitive_flexibility
post_switch_accuracy: 50
switch_cost_ms: -1782
accuracy_drop_percent: ...
attention_level: 1
engagement_level: 3
```

**Row 2 (Perseveration View)**:
```
child_id: LRH-006
view_type: perseveration
perseverative_error_rate: 50
total_perseverative_errors: 6
frustration_tolerance: ...
```

**Row 3 (Reaction Time View)**:
```
child_id: LRH-006
view_type: reaction_time
avg_rt_pre_switch_ms: 6348.875
switch_cost_ms: -1782
avg_reaction_time_ms: ...
```

**Row 4 (Behavioral Regulation View)**:
```
child_id: LRH-006
view_type: behavioral
attention_level: 1
engagement_level: 3
frustration_tolerance: ...
instruction_following: ...
```

---

## Why Multi-View Expansion?

### Benefits

1. **Increases Training Data**: 1 child → 3-4 training samples
2. **Domain-Specific Learning**: Model learns from different aspects (social, cognitive, behavioral)
3. **Handles Missing Data**: If some features are missing, other views can still be created
4. **Preserves Class Balance**: Each child contributes at least 1 view (prevents class imbalance)

### Example Expansion Results

**Age 2-3.5**:
- Original: 6 children = 6 rows
- After expansion: 6 children = 18 rows (3 views each)
- **Expansion: 3x**

**Age 3.5-5.5**:
- Original: 10 children = 10 rows
- After expansion: 10 children = 30 rows (3 views each)
- **Expansion: 3x**

**Age 5.5-6.9**:
- Original: 9 children = 9 rows
- After expansion: 9 children = 36 rows (4 views each)
- **Expansion: 4x**

---

## Important Notes

### ✅ What This Is:
- **Data Expansion**: Same child, multiple perspectives
- **Feature Grouping**: Related features grouped into views
- **Training Signal**: Increases learning signal without creating fake data

### ❌ What This Is NOT:
- **Not Synthetic Data**: All views come from the same real child
- **Not Data Duplication**: Each view focuses on different features
- **Not Data Leakage**: Child-level train/test split prevents leakage

### 🔒 Data Integrity:
- **Same child_id**: All views from same child share same `child_id`
- **Child-level splitting**: Train/test split by `child_id` (not by row)
- **No data leakage**: Child in train set → all their views in train set

---

## Summary

**One child's data creates:**
- **Age 2-3.5**: **3 views** (Social, Behavioral, Task)
- **Age 3.5-5.5**: **3 views** (Inhibition, Response, Behavioral)
- **Age 5.5-6.9**: **4 views** (Cognitive Flexibility, Perseveration, Reaction Time, Behavioral)

**Expansion Factor**:
- Age 2-3.5: **~3x** (3 views per child)
- Age 3.5-5.5: **~3x** (3 views per child)
- Age 5.5-6.9: **~4x** (4 views per child)

This allows the model to learn from different aspects of the same child's assessment while maintaining data integrity and preventing data leakage.
