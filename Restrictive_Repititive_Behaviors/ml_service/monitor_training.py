"""Monitor training progress in real-time"""
import time
import os
from pathlib import Path

def monitor_training(interval=30, max_checks=20):
    """Monitor training progress"""
    output_dir = Path("outputs")
    
    for i in range(max_checks):
        print(f"\n{'='*80}")
        print(f"Check #{i+1} at {time.strftime('%H:%M:%S')}")
        print(f"{'='*80}")
        
        # Find latest training directory
        training_dirs = sorted([d for d in output_dir.glob("training_*") if d.is_dir()], reverse=True)
        
        if not training_dirs:
            print("No training directories found!")
            time.sleep(interval)
            continue
        
        latest_dir = training_dirs[0]
        print(f"Latest training: {latest_dir.name}")
        
        # Check checkpoints
        checkpoint_dir = latest_dir / "checkpoints"
        if checkpoint_dir.exists():
            checkpoints = list(checkpoint_dir.glob("*.h5")) + list(checkpoint_dir.glob("*.keras"))
            print(f"\n✓ Checkpoints: {len(checkpoints)}")
            for cp in sorted(checkpoints)[-3:]:  # Show last 3
                size_mb = cp.stat().st_size / (1024 * 1024)
                mtime = time.strftime('%H:%M:%S', time.localtime(cp.stat().st_mtime))
                print(f"  - {cp.name} ({size_mb:.2f} MB) at {mtime}")
        
        # Check logs
        log_dir = latest_dir / "logs"
        if log_dir.exists():
            log_files = list(log_dir.rglob("events.out.tfevents.*"))
            if log_files:
                latest_log = max(log_files, key=lambda x: x.stat().st_mtime)
                size_kb = latest_log.stat().st_size / 1024
                mtime = time.strftime('%H:%M:%S', time.localtime(latest_log.stat().st_mtime))
                print(f"\n✓ TensorBoard log: {size_kb:.2f} KB (updated at {mtime})")
        
        # Check history
        history_file = latest_dir / "training_history.json"
        if history_file.exists():
            import json
            with open(history_file, 'r') as f:
                history = json.load(f)
            epochs = len(history.get('loss', []))
            print(f"\n✓ Training history: {epochs} epochs completed")
            if epochs > 0:
                print(f"  Latest metrics:")
                print(f"    - loss: {history['loss'][-1]:.4f}")
                print(f"    - accuracy: {history['accuracy'][-1]:.4f}")
                if 'val_loss' in history and history['val_loss']:
                    print(f"    - val_loss: {history['val_loss'][-1]:.4f}")
                    print(f"    - val_accuracy: {history['val_accuracy'][-1]:.4f}")
        
        # Check if training is complete
        final_model = latest_dir / "final_model.h5"
        if final_model.exists():
            print(f"\n🎉 Training complete! Final model saved.")
            break
        
        if i < max_checks - 1:
            print(f"\nWaiting {interval} seconds...")
            time.sleep(interval)

if __name__ == "__main__":
    monitor_training(interval=60, max_checks=15)  # Check every 60 seconds for 15 minutes

