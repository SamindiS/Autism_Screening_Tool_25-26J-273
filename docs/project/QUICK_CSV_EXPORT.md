# Quick CSV Export Guide

## 🚀 Fastest Way to Export Your Firebase Data

You have **3 easy methods** to export your Firebase data to CSV:

---

## Method 1: Using Browser (Easiest) ⭐

### Step 1: Start Your Backend

```bash
cd senseai_backend
npm start
```

Backend should be running on `http://localhost:3000`

### Step 2: Open in Browser

Open your browser and go to:

**Export all data for ML training:**
```
http://localhost:3000/api/export/csv?format=ml
```

**Export only ASD group:**
```
http://localhost:3000/api/export/csv?format=ml&group=asd
```

**Export only Control group:**
```
http://localhost:3000/api/export/csv?format=ml&group=typically_developing
```

**Export specific session type:**
```
http://localhost:3000/api/export/csv?format=ml&sessionType=color_shape
```

The CSV file will **download automatically**! 📥

---

## Method 2: Using Command Line (PowerShell)

### Step 1: Start Backend

```powershell
cd senseai_backend
npm start
```

### Step 2: Export (in new terminal)

```powershell
# Export all data
Invoke-WebRequest -Uri "http://localhost:3000/api/export/csv?format=ml" -OutFile "ml_training_data.csv"

# Export only ASD group
Invoke-WebRequest -Uri "http://localhost:3000/api/export/csv?format=ml&group=asd" -OutFile "asd_data.csv"

# Export only Control group
Invoke-WebRequest -Uri "http://localhost:3000/api/export/csv?format=ml&group=typically_developing" -OutFile "control_data.csv"

# Export specific session type
Invoke-WebRequest -Uri "http://localhost:3000/api/export/csv?format=ml&sessionType=color_shape" -OutFile "color_shape_data.csv"
```

---

## Method 3: Using curl (If Available)

```bash
# Export all data
curl http://localhost:3000/api/export/csv?format=ml -o ml_training_data.csv

# Export only ASD group
curl http://localhost:3000/api/export/csv?format=ml&group=asd -o asd_data.csv

# Export only Control group
curl http://localhost:3000/api/export/csv?format=ml&group=typically_developing -o control_data.csv
```

---

## 📊 What You Get

The CSV file includes:

### Basic Information:
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
- `primary_asd_marker_1` - Perseverative errors
- `primary_asd_marker_2` - Perseverative rate
- `primary_asd_marker_3` - Switch cost (ms)
- `attention_level` - Attention level (1-5)
- `engagement_level` - Engagement level (1-5)
- `frustration_tolerance` - Frustration tolerance (1-5)
- `instruction_following` - Instruction following (1-5)
- `overall_behavior` - Overall behavior (1-5)
- `enhanced_risk_score` - Enhanced risk score
- `created_at` - Timestamp

---

## 🎯 Export Options

### Query Parameters:

| Parameter | Values | Description |
|-----------|--------|-------------|
| `format` | `ml` or `raw` | Export format (default: `ml`) |
| `group` | `asd` or `typically_developing` | Filter by study group |
| `sessionType` | `color_shape`, `frog_jump`, `ai_doctor_bot` | Filter by session type |

### Examples:

```bash
# All ASD color-shape sessions
http://localhost:3000/api/export/csv?format=ml&group=asd&sessionType=color_shape

# All control group data
http://localhost:3000/api/export/csv?format=ml&group=typically_developing

# All frog jump sessions
http://localhost:3000/api/export/csv?format=ml&sessionType=frog_jump

# Raw data export (all fields)
http://localhost:3000/api/export/csv?format=raw
```

---

## ✅ Quick Checklist

1. [ ] Backend is running (`npm start` in `senseai_backend`)
2. [ ] Backend is connected to Firebase (check console for errors)
3. [ ] Open browser or use command line
4. [ ] Visit export URL
5. [ ] CSV file downloads automatically
6. [ ] Open CSV file to verify data

---

## 🔍 Verify Your Data

After exporting, check your CSV:

```python
import pandas as pd

# Load your exported data
df = pd.read_csv('ml_training_data.csv')

# Check data shape
print(f"Total rows: {len(df)}")
print(f"ASD group: {len(df[df['group'] == 'asd'])}")
print(f"Control group: {len(df[df['group'] == 'typically_developing'])}")

# Preview data
print("\nFirst 5 rows:")
print(df.head())

# Check for missing values
print("\nMissing values:")
print(df.isnull().sum())
```

---

## 🚨 Troubleshooting

### Issue: "Cannot GET /api/export/csv"
**Solution**: 
- Make sure backend is running
- Check if route is registered in `server.js`
- Verify URL is correct

### Issue: Empty CSV file
**Solution**:
- Check if you have data in Firebase
- Verify Firebase connection in backend
- Check backend console for errors
- Try exporting without filters first

### Issue: "Connection refused"
**Solution**:
- Make sure backend is running on port 3000
- Check if another process is using port 3000
- Try `http://localhost:3000/health` to test connection

### Issue: Missing columns
**Solution**:
- Some sessions may not have all ML features
- This is normal - missing values will be empty
- You can filter by `sessionType` to get specific data

---

## 📝 Next Steps

After exporting:

1. ✅ **Review CSV file** - Check data quality
2. ✅ **Load into training notebook** - Use `ML_TRAINING/Complete_ASD_ML_Training.ipynb`
3. ✅ **Train your model** - Follow ML training guide
4. ✅ **Deploy model** - See ML_MODEL_INTEGRATION_GUIDE.md

---

## 💡 Pro Tips

1. **Export multiple times**: Export ASD and Control groups separately for better organization
2. **Check data quality**: Always verify exported data before training
3. **Backup exports**: Keep copies of exported CSV files
4. **Use filters**: Filter by `sessionType` or `group` to get specific data
5. **Raw format**: Use `format=raw` if you need all fields (not just ML features)

---

*Quick Reference for CSV Export*




