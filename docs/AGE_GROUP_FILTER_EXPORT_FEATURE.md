# ✅ Age Group Filter Added to CSV Export

## 🎯 What Was Added

Age-based filtering has been added to the CSV export feature, allowing you to filter data by age groups:
- **Age 2-3.5** (Questionnaire - AI Doctor Bot)
- **Age 3.5-5.5** (Frog Jump Game)
- **Age 5.5-6.9** (Color-Shape Game)

---

## 📱 Flutter App UI Changes

### New UI Elements

In the **Export Data** section of the Cognitive Dashboard:

1. **Age Group Filter Chips** (below Group Filter):
   - **All** - No age filter (default)
   - **2-3.5** - Ages 24-41 months
   - **3.5-5.5** - Ages 42-65 months
   - **5.5-6.9** - Ages 66-83 months

2. **Combined Filtering**:
   - You can now filter by **both Group AND Age Group** simultaneously
   - Example: Export only "ASD" group + "Age 3.5-5.5"

### How to Use

1. Open the Cognitive Dashboard
2. Scroll to "Export Data" section
3. Select **Group** filter (All, ASD, or Control)
4. Select **Age Group** filter (All, 2-3.5, 3.5-5.5, or 5.5-6.9)
5. Click **View** to preview or **Download** to save CSV

### File Naming

Exported files now include age group in filename:
- `ml_training_data_all_all_ages_2024-01-15T10-30-00.csv` (All groups, all ages)
- `ml_training_data_asd_3_5_5_5_2024-01-15T10-30-00.csv` (ASD group, age 3.5-5.5)
- `ml_training_data_control_2_3_5_2024-01-15T10-30-00.csv` (Control group, age 2-3.5)

---

## 🔧 Backend API Changes

### New Query Parameter

**Endpoint**: `GET /api/export/csv`

**New Parameter**: `ageGroup`
- Values: `2-3.5`, `3.5-5.5`, `5.5-6.9`
- Optional: If not provided, exports all ages

### Examples

```bash
# Export all data
curl http://localhost:3000/api/export/csv?format=ml

# Export only age 2-3.5
curl http://localhost:3000/api/export/csv?format=ml&ageGroup=2-3.5

# Export ASD group + Age 3.5-5.5
curl "http://localhost:3000/api/export/csv?format=ml&group=asd&ageGroup=3.5-5.5"

# Export Control group + Age 5.5-6.9
curl "http://localhost:3000/api/export/csv?format=ml&group=typically_developing&ageGroup=5.5-6.9"
```

### Filtering Logic

The backend filters sessions by:
1. **Session `age_group` field** (if present)
2. **Child's `age_in_months`** (if `age_group` not set)
   - Age 2-3.5: 24 ≤ age < 42 months
   - Age 3.5-5.5: 42 ≤ age < 66 months
   - Age 5.5-6.9: 66 ≤ age < 83 months

---

## 📜 Export Script Changes

### Updated Standalone Script

**File**: `senseai_backend/scripts/export_firebase_to_csv.js`

**New Option**: `--ageGroup`

### Usage Examples

```bash
cd senseai_backend

# Export all data
node scripts/export_firebase_to_csv.js --format=ml

# Export only age 2-3.5
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=2-3.5

# Export ASD + Age 3.5-5.5
node scripts/export_firebase_to_csv.js --format=ml --group=asd --ageGroup=3.5-5.5

# Export Control + Age 5.5-6.9
node scripts/export_firebase_to_csv.js --format=ml --group=typically_developing --ageGroup=5.5-6.9

# Export with custom filename
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=2-3.5 --output=age_2_3_5_data.csv
```

---

## 📊 Use Cases

### 1. Age-Specific ML Training Data

Export data for each age group separately for training separate models:

```bash
# Age 2-3.5 (Questionnaire)
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=2-3.5 --output=age_2_3_5_training.csv

# Age 3.5-5.5 (Frog Jump)
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=3.5-5.5 --output=age_3_5_5_5_training.csv

# Age 5.5-6.9 (Color-Shape)
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=5.5-6.9 --output=age_5_5_6_9_training.csv
```

### 2. Combined Filters

Export specific combinations:

```bash
# ASD children, age 3.5-5.5 (Frog Jump)
node scripts/export_firebase_to_csv.js --format=ml --group=asd --ageGroup=3.5-5.5 --output=asd_frog_jump.csv

# Control children, age 5.5-6.9 (Color-Shape)
node scripts/export_firebase_to_csv.js --format=ml --group=typically_developing --ageGroup=5.5-6.9 --output=control_color_shape.csv
```

### 3. From Flutter App

1. Open app → Cognitive Dashboard
2. Select filters:
   - Group: **ASD**
   - Age Group: **3.5-5.5**
3. Click **Download**
4. File saved: `ml_training_data_asd_3_5_5_5_<timestamp>.csv`

---

## 🔍 Technical Details

### Files Modified

1. **Backend**:
   - `senseai_backend/routes/export.js` - Added `ageGroup` parameter and filtering logic
   - `senseai_backend/scripts/export_firebase_to_csv.js` - Added `--ageGroup` option

2. **Flutter**:
   - `lib/features/cognitive/cognitive_dashboard_screen.dart` - Added age group filter UI
   - `lib/core/services/api_service.dart` - Added `ageGroup` parameter to `exportCSV()`

### Filtering Implementation

The age group filter checks:
1. **Primary**: Session's `age_group` field (if set)
2. **Fallback**: Child's `age_in_months` calculated against age ranges

This ensures compatibility with both:
- Sessions that have `age_group` explicitly set
- Sessions where age must be calculated from child's age

---

## ✅ Testing

### Test from Flutter App

1. ✅ Select "All" groups + "All" ages → Should export all data
2. ✅ Select "ASD" + "Age 3.5-5.5" → Should export only ASD children aged 3.5-5.5
3. ✅ Select "Control" + "Age 2-3.5" → Should export only Control children aged 2-3.5
4. ✅ Check filename includes age group suffix

### Test from API

```bash
# Test age group filter
curl "http://localhost:3000/api/export/csv?format=ml&ageGroup=3.5-5.5" | head -5

# Test combined filters
curl "http://localhost:3000/api/export/csv?format=ml&group=asd&ageGroup=5.5-6.9" | head -5
```

### Test from Script

```bash
cd senseai_backend

# Test age group filter
node scripts/export_firebase_to_csv.js --format=ml --ageGroup=2-3.5 --output=test_age_filter.csv

# Verify output file exists and contains filtered data
cat test_age_filter.csv | head -5
```

---

## 🎯 Benefits

1. **Age-Specific Training**: Export data for each age group separately for separate ML models
2. **Better Organization**: Easier to manage and analyze data by age group
3. **Combined Filtering**: Filter by both group and age for precise data extraction
4. **Consistent with ML Architecture**: Matches the separate age-specific model approach

---

## 📝 Notes

- Age group filtering works **in addition to** group and session type filtering
- All filters can be combined for precise data extraction
- The age group filter is **optional** - if not specified, all ages are included
- File names automatically include age group suffix for easy identification

---

✅ **Feature is ready to use!** You can now filter CSV exports by age group from both the Flutter app and backend API/scripts.
