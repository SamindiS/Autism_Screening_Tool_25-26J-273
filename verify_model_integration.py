"""
Quick verification script to check if age-specific models are properly integrated
"""

import sys
from pathlib import Path

# Add the ml_engine to path
sys.path.insert(0, str(Path(__file__).parent / "senseai_backend" / "ml_engine"))

from app.core.config import (
    AGE_2_3_5_MODEL_PATH, AGE_2_3_5_SCALER_PATH, AGE_2_3_5_FEATURES_PATH, AGE_2_3_5_METADATA_PATH,
    AGE_3_5_5_5_MODEL_PATH, AGE_3_5_5_5_SCALER_PATH, AGE_3_5_5_5_FEATURES_PATH, AGE_3_5_5_5_METADATA_PATH,
    AGE_5_5_6_9_MODEL_PATH, AGE_5_5_6_9_SCALER_PATH, AGE_5_5_6_9_FEATURES_PATH, AGE_5_5_6_9_METADATA_PATH,
)
from app.ml.age_specific_loader import check_age_specific_models

import os
os.environ['PYTHONIOENCODING'] = 'utf-8'

print("=" * 60)
print("MODEL INTEGRATION VERIFICATION")
print("=" * 60)

# Check all age-specific models
status = check_age_specific_models()

print("\nModel Status by Age Group:\n")

for age_group, info in status.items():
    print(f"Age Group: {age_group}")
    print(f"  Model: {'[OK]' if info['model_exists'] else '[MISSING]'} {info['model_path']}")
    print(f"  Scaler: {'[OK]' if info['scaler_exists'] else '[MISSING]'}")
    print(f"  Features: {'[OK]' if info['features_exists'] else '[MISSING]'}")
    print(f"  Ready: {'YES' if info['ready'] else 'NO'}")
    print()

# Summary
ready_models = sum(1 for info in status.values() if info['ready'])
total_models = len(status)

print("=" * 60)
print(f"Summary: {ready_models}/{total_models} models ready")
print("=" * 60)

if ready_models == total_models:
    print("[SUCCESS] All models are ready!")
elif ready_models > 0:
    print(f"[WARNING] {ready_models} model(s) ready, {total_models - ready_models} missing")
else:
    print("[ERROR] No models are ready. Please check file locations.")

# Detailed file check
print("\n" + "=" * 60)
print("Detailed File Check:")
print("=" * 60)

age_groups = {
    "2-3.5": {
        "model": AGE_2_3_5_MODEL_PATH,
        "scaler": AGE_2_3_5_SCALER_PATH,
        "features": AGE_2_3_5_FEATURES_PATH,
        "metadata": AGE_2_3_5_METADATA_PATH,
    },
    "3.5-5.5": {
        "model": AGE_3_5_5_5_MODEL_PATH,
        "scaler": AGE_3_5_5_5_SCALER_PATH,
        "features": AGE_3_5_5_5_FEATURES_PATH,
        "metadata": AGE_3_5_5_5_METADATA_PATH,
    },
    "5.5-6.9": {
        "model": AGE_5_5_6_9_MODEL_PATH,
        "scaler": AGE_5_5_6_9_SCALER_PATH,
        "features": AGE_5_5_6_9_FEATURES_PATH,
        "metadata": AGE_5_5_6_9_METADATA_PATH,
    },
}

for age_group, paths in age_groups.items():
    print(f"\n{age_group}:")
    for file_type, path in paths.items():
        exists = path.exists()
        size = path.stat().st_size if exists else 0
        status_icon = "[OK]" if exists else "[MISSING]"
        if exists:
            print(f"  {status_icon} {file_type:12s}: {path.name:50s} ({size:,} bytes)")
        else:
            print(f"  {status_icon} {file_type:12s}: {path.name:50s} (NOT FOUND)")

print("\n" + "=" * 60)
print("[SUCCESS] Verification complete!")
print("=" * 60)
