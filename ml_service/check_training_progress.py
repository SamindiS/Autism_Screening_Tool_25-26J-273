"""Check training progress"""
import os
import glob
from pathlib import Path

# Find the latest training directory
output_dir = Path("outputs")
training_dirs = sorted([d for d in output_dir.glob("training_*") if d.is_dir()], reverse=True)

if not training_dirs:
    print("No training directories found!")
    exit(1)

latest_dir = training_dirs[0]
print(f"Latest training directory: {latest_dir}")
print("=" * 80)

# Check for checkpoints
checkpoint_dir = latest_dir / "checkpoints"
if checkpoint_dir.exists():
    checkpoints = list(checkpoint_dir.glob("*.h5")) + list(checkpoint_dir.glob("*.keras"))
    print(f"\nCheckpoints found: {len(checkpoints)}")
    for cp in sorted(checkpoints):
        size_mb = cp.stat().st_size / (1024 * 1024)
        print(f"  - {cp.name} ({size_mb:.2f} MB)")
else:
    print("\nNo checkpoint directory found")

# Check for logs
log_dir = latest_dir / "logs"
if log_dir.exists():
    log_files = list(log_dir.rglob("events.out.tfevents.*"))
    print(f"\nTensorBoard log files found: {len(log_files)}")
    for log in sorted(log_files):
        size_kb = log.stat().st_size / 1024
        print(f"  - {log.name} ({size_kb:.2f} KB)")
else:
    print("\nNo log directory found")

# Check for training history
history_file = latest_dir / "training_history.json"
if history_file.exists():
    import json
    with open(history_file, 'r') as f:
        history = json.load(f)
    print(f"\nTraining history:")
    print(f"  Epochs completed: {len(history.get('loss', []))}")
    if 'loss' in history and history['loss']:
        print(f"  Latest loss: {history['loss'][-1]:.4f}")
        print(f"  Latest accuracy: {history['accuracy'][-1]:.4f}")
        if 'val_loss' in history and history['val_loss']:
            print(f"  Latest val_loss: {history['val_loss'][-1]:.4f}")
            print(f"  Latest val_accuracy: {history['val_accuracy'][-1]:.4f}")
else:
    print("\nNo training history file found yet")

print("\n" + "=" * 80)
print("Training is in progress..." if not checkpoints else "Training has saved checkpoints!")

