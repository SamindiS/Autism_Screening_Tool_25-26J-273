"""
Setup script for RRB Detection ML Service
"""
import os
import sys
import subprocess

def create_directories():
    """Create necessary directories"""
    directories = [
        'models',
        'uploads',
        'processed',
        'logs',
        'outputs',
        'preprocessed_data'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"✓ Created directory: {directory}")

def install_dependencies():
    """Install Python dependencies"""
    print("\nInstalling Python dependencies...")
    try:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'])
        print("✓ Dependencies installed successfully")
    except subprocess.CalledProcessError as e:
        print(f"✗ Error installing dependencies: {e}")
        return False
    return True

def check_dataset():
    """Check if dataset exists"""
    dataset_path = '../Dataset'
    if os.path.exists(dataset_path):
        print(f"\n✓ Dataset found at {dataset_path}")
        
        # Count videos
        video_count = 0
        for root, dirs, files in os.walk(dataset_path):
            video_count += len([f for f in files if f.endswith(('.mp4', '.avi', '.mov', '.MP4')) and not f.startswith('.')])
        
        print(f"  Total videos: {video_count}")
        return True
    else:
        print(f"\n✗ Dataset not found at {dataset_path}")
        print("  Please ensure the Dataset folder is in the parent directory")
        return False

def create_env_file():
    """Create .env file if it doesn't exist"""
    if not os.path.exists('.env'):
        print("\n✓ Creating .env file from .env.example")
        if os.path.exists('.env.example'):
            with open('.env.example', 'r') as src:
                with open('.env', 'w') as dst:
                    dst.write(src.read())
        else:
            print("  Warning: .env.example not found")
    else:
        print("\n✓ .env file already exists")

def main():
    """Main setup function"""
    print("=" * 80)
    print("RRB Detection ML Service - Setup")
    print("=" * 80)
    
    print("\n[1/4] Creating directories...")
    create_directories()
    
    print("\n[2/4] Creating environment file...")
    create_env_file()
    
    print("\n[3/4] Checking dataset...")
    dataset_exists = check_dataset()
    
    print("\n[4/4] Installing dependencies...")
    deps_installed = install_dependencies()
    
    print("\n" + "=" * 80)
    print("Setup Summary")
    print("=" * 80)
    
    if dataset_exists and deps_installed:
        print("✓ Setup completed successfully!")
        print("\nNext steps:")
        print("1. Train the model:")
        print("   python train.py --epochs 50 --batch_size 8")
        print("\n2. Test inference:")
        print("   python test_inference.py --mode single --video_path <path_to_video>")
        print("\n3. Start the API server:")
        print("   python app.py")
    else:
        print("✗ Setup completed with warnings")
        if not dataset_exists:
            print("  - Dataset not found. Please add the Dataset folder.")
        if not deps_installed:
            print("  - Dependencies installation failed. Please install manually.")
    
    print("=" * 80)

if __name__ == '__main__':
    main()

