# 📥 How to Download Trained Model from Google Colab

## 🎯 Quick Methods

### Method 1: Direct Download (Easiest) ⭐

After training completes in Colab, the notebook saves files to `models/` directory. Download them:

#### Step 1: Check Files Were Saved

In your Colab notebook, after training, run:

```python
# List all files in models directory
import os
if os.path.exists('models'):
    files = os.listdir('models')
    print("Files in models/ directory:")
    for f in files:
        print(f"  - {f}")
        file_path = os.path.join('models', f)
        size = os.path.getsize(file_path) / 1024  # Size in KB
        print(f"    Size: {size:.2f} KB")
else:
    print("❌ models/ directory not found!")
```

#### Step 2: Download Files

**Option A: Download Individual Files**

```python
from google.colab import files

# Download each file
files.download('models/model_age_2_3_5_questionnaire.pkl')
files.download('models/scaler_age_2_3_5_questionnaire.pkl')
files.download('models/features_age_2_3_5_questionnaire.json')
files.download('models/model_metadata_age_2_3_5.json')
```

**Option B: Download All at Once**

```python
from google.colab import files
import zipfile
import os

# Create a zip file with all model files
zip_path = 'model_files.zip'
with zipfile.ZipFile(zip_path, 'w') as zipf:
    model_dir = 'models'
    if os.path.exists(model_dir):
        for root, dirs, files in os.walk(model_dir):
            for file in files:
                file_path = os.path.join(root, file)
                zipf.write(file_path, file)
        print("✅ Zip file created: model_files.zip")
    else:
        print("❌ models/ directory not found!")

# Download the zip file
files.download(zip_path)
```

---

### Method 2: Google Drive (Recommended for Large Files) ⭐⭐⭐

#### Step 1: Mount Google Drive

```python
from google.colab import drive
drive.mount('/content/drive')
```

#### Step 2: Copy Files to Drive

```python
import shutil
import os

# Create directory in Drive
drive_dir = '/content/drive/MyDrive/ASD_Models'
os.makedirs(drive_dir, exist_ok=True)

# Copy all model files
model_dir = 'models'
if os.path.exists(model_dir):
    for file in os.listdir(model_dir):
        src = os.path.join(model_dir, file)
        dst = os.path.join(drive_dir, file)
        shutil.copy2(src, dst)
        print(f"✅ Copied: {file}")
    
    print(f"\n✅ All files copied to: {drive_dir}")
    print("📥 Download from: https://drive.google.com/drive/my-drive")
else:
    print("❌ models/ directory not found!")
```

#### Step 3: Download from Google Drive

1. Go to: https://drive.google.com/drive/my-drive
2. Find `ASD_Models` folder
3. Right-click each file → Download
4. Or select all → Right-click → Download

---

### Method 3: Using Colab's File Browser

1. **Open Files Panel**: Click the folder icon (📁) in the left sidebar
2. **Navigate to `models/`**: Click on `models` folder
3. **Download Files**:
   - Right-click each file → Download
   - Or select multiple files → Right-click → Download

---

## 📋 Complete Download Script

Add this cell to your Colab notebook **after training**:

```python
# ============================================
# DOWNLOAD MODEL FILES FROM COLAB
# ============================================

from google.colab import files
import zipfile
import os

print("📥 Preparing model files for download...")
print("="*60)

# Check if models directory exists
model_dir = 'models'
if not os.path.exists(model_dir):
    print(f"❌ Error: {model_dir}/ directory not found!")
    print("   Make sure you've run the training cells.")
    raise FileNotFoundError(f"{model_dir}/ directory not found")

# List files to download
files_to_download = [
    'model_age_2_3_5_questionnaire.pkl',
    'scaler_age_2_3_5_questionnaire.pkl',
    'features_age_2_3_5_questionnaire.json',
    'model_metadata_age_2_3_5.json'
]

print("\n📊 Files found in models/ directory:")
all_files = os.listdir(model_dir)
for f in all_files:
    file_path = os.path.join(model_dir, f)
    size_kb = os.path.getsize(file_path) / 1024
    status = "✅" if f in files_to_download else "ℹ️"
    print(f"  {status} {f:50s} ({size_kb:.2f} KB)")

# Create zip file
zip_path = 'asd_model_age_2_3_5.zip'
print(f"\n📦 Creating zip file: {zip_path}")

with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for file in files_to_download:
        file_path = os.path.join(model_dir, file)
        if os.path.exists(file_path):
            zipf.write(file_path, file)
            print(f"  ✅ Added: {file}")
        else:
            print(f"  ⚠️  Missing: {file}")

zip_size = os.path.getsize(zip_path) / 1024
print(f"\n✅ Zip file created: {zip_path} ({zip_size:.2f} KB)")

# Download
print("\n📥 Downloading zip file...")
files.download(zip_path)

print("\n" + "="*60)
print("✅ Download complete!")
print("\nNext steps:")
print("  1. Extract the zip file on your local machine")
print("  2. Copy files to: senseai_backend/ml_engine/models/")
print("  3. Run: .\\copy_model_to_engine.ps1")
print("="*60)
```

---

## 🔄 After Downloading: Transfer to Your System

### Step 1: Extract Files (if downloaded as zip)

Extract `asd_model_age_2_3_5.zip` to a folder on your computer.

### Step 2: Copy to ML Engine

**Option A: Use the PowerShell Script**

1. Place extracted files in: `ML_TRAINING/models/`
2. Run: `.\copy_model_to_engine.ps1`

**Option B: Manual Copy**

```powershell
# Copy from Downloads folder (adjust path as needed)
$downloadPath = "$env:USERPROFILE\Downloads\asd_model_age_2_3_5"

# Copy to ML engine
Copy-Item "$downloadPath\model_age_2_3_5_questionnaire.pkl" `
          "senseai_backend\ml_engine\models\model_age_2_3_5_questionnaire.pkl"

Copy-Item "$downloadPath\scaler_age_2_3_5_questionnaire.pkl" `
          "senseai_backend\ml_engine\models\scaler_age_2_3_5_questionnaire.pkl"

Copy-Item "$downloadPath\features_age_2_3_5_questionnaire.json" `
          "senseai_backend\ml_engine\models\features_age_2_3_5_questionnaire.json"

Copy-Item "$downloadPath\model_metadata_age_2_3_5.json" `
          "senseai_backend\ml_engine\models\model_metadata_age_2_3_5.json"
```

### Step 3: Verify Files

```powershell
# Check files exist
Get-ChildItem "senseai_backend\ml_engine\models\model_age_2_3_5*"

# Should show:
# - model_age_2_3_5_questionnaire.pkl
# - scaler_age_2_3_5_questionnaire.pkl
# - features_age_2_3_5_questionnaire.json
# - model_metadata_age_2_3_5.json
```

### Step 4: Restart ML Engine

```powershell
.\start_python_engine.ps1
```

---

## 🚨 Troubleshooting

### "models/ directory not found"

**Solution**: Make sure you've run all training cells in the notebook. The models are saved at the end of training.

### "File download failed"

**Solution**: 
- Try downloading one file at a time
- Use Google Drive method instead
- Check your internet connection

### "File is too large"

**Solution**: 
- Use Google Drive method (no size limit)
- Or download files individually

### "Can't find downloaded files"

**Solution**:
- Check your browser's Downloads folder
- Check Colab's download history
- Use Google Drive method for easier access

---

## 📝 Quick Reference

### Files You Need:

1. ✅ `model_age_2_3_5_questionnaire.pkl` (Model file - largest)
2. ✅ `scaler_age_2_3_5_questionnaire.pkl` (Scaler file)
3. ✅ `features_age_2_3_5_questionnaire.json` (Feature list)
4. ✅ `model_metadata_age_2_3_5.json` (Metadata)

### File Sizes (Approximate):

- Model file: ~50-500 KB (depends on model type)
- Scaler file: ~1-10 KB
- Features JSON: ~1-5 KB
- Metadata JSON: ~1-5 KB

---

## ✅ Verification Checklist

After downloading:

- [ ] All 4 files downloaded
- [ ] Files extracted (if zip)
- [ ] Files copied to `senseai_backend/ml_engine/models/`
- [ ] File names match exactly (case-sensitive)
- [ ] ML engine restarted
- [ ] Health check passes: http://localhost:8001/health

---

## 🎯 Recommended Workflow

1. **Train model in Colab** → Files saved to `models/`
2. **Run download script** → Creates zip file
3. **Download zip** → Saves to your Downloads folder
4. **Extract zip** → Extract to a folder
5. **Copy files** → Use `copy_model_to_engine.ps1` script
6. **Restart engine** → `.\start_python_engine.ps1`
7. **Test** → http://localhost:8001/docs

---

**That's it! Your model is now ready to use.** 🎉
