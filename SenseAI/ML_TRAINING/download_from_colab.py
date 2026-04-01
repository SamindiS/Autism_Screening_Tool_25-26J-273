"""
Download model files from Google Colab
Add this as a cell in your Colab notebook after training
"""

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
