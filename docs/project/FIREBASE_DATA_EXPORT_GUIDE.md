# Firebase Data Export Guide

## Overview

Export your Firebase assessment data to CSV format for ML training or analysis.

---

## Quick Export via API

### Method 1: Export for ML Training (Recommended)

**Export all data formatted for ML training:**

```bash
# Export all data
curl http://localhost:3000/api/export/csv?format=ml -o ml_training_data.csv

# Export only ASD group
curl http://localhost:3000/api/export/csv?format=ml&group=asd -o asd_data.csv

# Export only Control group
curl http://localhost:3000/api/export/csv?format=ml&group=typically_developing -o control_data.csv

# Export specific session type
curl http://localhost:3000/api/export/csv?format=ml&sessionType=color_shape -o color_shape_data.csv
```

**Or use in browser:**
```
http://localhost:3000/api/export/csv?format=ml
```

The file will download automatically!

### Method 2: Export Raw Data

```bash
curl http://localhost:3000/api/export/csv?format=raw -o raw_data.csv
```

---

## CSV Format for ML Training

The ML export includes:

### Basic Info:
- `session_id` - Unique session ID
- `child_id` - Child ID
- `child_code` - Child code/name
- `age_months` - Age in months
- `gender` - Gender
- `group` - **Target variable**: `asd` or `typically_developing`
- `session_type` - Type of assessment
- `age_group` - Age group category

### ML Features:
- `completion_time_sec` - Time to complete assessment
- `accuracy_overall` - Overall accuracy percentage
- `total_score` - Total score
- `risk_score` - Risk score (0-100)
- `risk_level` - Risk level (low/moderate/high)

### Primary ASD Markers:
- `primary_asd_marker_1` - Perseverative errors / Commission errors
- `primary_asd_marker_2` - Perseverative rate / Commission error rate
- `primary_asd_marker_3` - Switch cost (ms)

### Behavioral Markers:
- `attention_level` - Attention level (1-5)
- `engagement_level` - Engagement level (1-5)
- `frustration_tolerance` - Frustration tolerance (1-5)
- `instruction_following` - Instruction following (1-5)
- `overall_behavior` - Overall behavior (1-5)

### Additional:
- `enhanced_risk_score` - Enhanced risk score
- `created_at` - Timestamp

---

## Using Exported Data for ML Training

### Step 1: Export Data

```bash
# Export ASD group
curl http://localhost:3000/api/export/csv?format=ml&group=asd -o asd_data.csv

# Export Control group
curl http://localhost:3000/api/export/csv?format=ml&group=typically_developing -o control_data.csv
```

### Step 2: Combine Datasets (Optional)

If you want a single file:

```python
import pandas as pd

# Load both datasets
asd = pd.read_csv('asd_data.csv')
control = pd.read_csv('control_data.csv')

# Combine
combined = pd.concat([asd, control], ignore_index=True)

# Save
combined.to_csv('combined_training_data.csv', index=False)
```

### Step 3: Use in Training Notebook

1. Open `ML_TRAINING/Complete_ASD_ML_Training.ipynb`
2. Upload your exported CSV file
3. The `group` column is your target variable:
   - `asd` = 1 (ASD risk)
   - `typically_developing` = 0 (Control)

### Step 4: Prepare for Training

```python
import pandas as pd

# Load your exported data
df = pd.read_csv('ml_training_data.csv')

# Create target variable
df['target'] = (df['group'] == 'asd').astype(int)

# Select features (exclude IDs and target)
feature_cols = [
    'age_months',
    'completion_time_sec',
    'accuracy_overall',
    'primary_asd_marker_1',
    'primary_asd_marker_2',
    'primary_asd_marker_3',
    'attention_level',
    'engagement_level',
    # ... add other features
]

X = df[feature_cols]
y = df['target']
```

---

## Export Options

### Query Parameters:

- `format` - `ml` (ML training format) or `raw` (raw data)
- `group` - Filter by group: `asd` or `typically_developing`
- `sessionType` - Filter by type: `color_shape`, `frog_jump`, `ai_doctor_bot`

### Examples:

```bash
# All ASD color-shape sessions
/api/export/csv?format=ml&group=asd&sessionType=color_shape

# All control group data
/api/export/csv?format=ml&group=typically_developing

# All frog jump sessions
/api/export/csv?format=ml&sessionType=frog_jump
```

---

## Data Quality Checks

After exporting, verify your data:

```python
import pandas as pd

df = pd.read_csv('ml_training_data.csv')

# Check data shape
print(f"Total rows: {len(df)}")
print(f"ASD group: {len(df[df['group'] == 'asd'])}")
print(f"Control group: {len(df[df['group'] == 'typically_developing'])}")

# Check for missing values
print("\nMissing values:")
print(df.isnull().sum())

# Check feature distributions
print("\nFeature statistics:")
print(df.describe())
```

---

## Alternative: Manual Firebase Export

If you prefer to export directly from Firebase:

1. **Firebase Console**:
   - Go to Firestore Database
   - Select collection (e.g., `sessions`)
   - Click "Export" (if available)

2. **Firebase CLI**:
   ```bash
   firebase firestore:export ./export_data
   ```

3. **Convert to CSV**:
   - Use a script to convert JSON export to CSV
   - Format according to ML training requirements

---

## Troubleshooting

### Issue: Empty CSV file
**Solution**: 
- Check if you have data in Firebase
- Verify backend is running
- Check backend logs for errors

### Issue: Missing features
**Solution**:
- Some sessions may not have all ML features
- Check which session types have which features
- Filter by `sessionType` if needed

### Issue: Data format mismatch
**Solution**:
- Verify session data structure in Firebase
- Check `game_results` and `questionnaire_results` fields
- Ensure ML features are being saved correctly

---

## Next Steps

1. ✅ Export your data: `GET /api/export/csv?format=ml`
2. ✅ Review CSV file
3. ✅ Load into training notebook
4. ✅ Train your model
5. ✅ Deploy trained model (see ML_MODEL_INTEGRATION_GUIDE.md)

---

## Example Workflow

```bash
# 1. Start backend
cd senseai_backend
npm start

# 2. Export data (in another terminal)
curl http://localhost:3000/api/export/csv?format=ml -o my_training_data.csv

# 3. Check data
python -c "import pandas as pd; df = pd.read_csv('my_training_data.csv'); print(df.head()); print(f'\nTotal: {len(df)} rows')"

# 4. Use in training notebook
# Upload my_training_data.csv to Google Colab
# Follow ML_TRAINING/Complete_ASD_ML_Training.ipynb
```

---

## Notes

- **Target Variable**: The `group` column is your target (asd = 1, typically_developing = 0)
- **Feature Selection**: Not all features may be available for all session types
- **Data Quality**: Review exported data before training
- **Privacy**: Ensure exported data is handled securely




