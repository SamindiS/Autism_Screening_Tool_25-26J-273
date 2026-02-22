"""
Manual video repair utility for severely corrupted videos
"""
import os
import sys
import subprocess
from pathlib import Path

def repair_video(input_path, output_path=None):
    """
    Repair a corrupted video file
    
    Args:
        input_path: Path to corrupted video
        output_path: Path for repaired video (optional)
    """
    if not os.path.exists(input_path):
        print(f"❌ Error: Input file not found: {input_path}")
        return False
    
    if output_path is None:
        # Create output path
        input_file = Path(input_path)
        output_path = str(input_file.parent / f"{input_file.stem}_repaired{input_file.suffix}")
    
    print("=" * 80)
    print("Video Repair Utility")
    print("=" * 80)
    print(f"Input:  {input_path}")
    print(f"Output: {output_path}")
    print("=" * 80)
    
    # Check FFmpeg
    try:
        result = subprocess.run(['ffmpeg', '-version'], 
                              stdout=subprocess.PIPE, 
                              stderr=subprocess.PIPE,
                              check=True)
        print("✓ FFmpeg found")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ FFmpeg not found. Please install FFmpeg first.")
        return False
    
    print("\nAttempting repair with aggressive settings...")
    print("-" * 80)
    
    # Aggressive repair command
    cmd = [
        'ffmpeg',
        '-err_detect', 'ignore_err',  # Ignore decoding errors
        '-i', input_path,
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-crf', '28',
        '-c:a', 'aac',
        '-b:a', '128k',
        '-movflags', '+faststart',
        '-max_muxing_queue_size', '1024',
        '-fflags', '+genpts',  # Generate timestamps
        '-avoid_negative_ts', 'make_zero',  # Fix timestamp issues
        '-y',
        output_path
    ]
    
    print("Running FFmpeg...")
    print(f"Command: {' '.join(cmd)}")
    print("-" * 80)
    
    try:
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=600  # 10 minute timeout
        )
        
        if result.returncode == 0 and os.path.exists(output_path):
            file_size = os.path.getsize(output_path)
            print("\n" + "=" * 80)
            print("✓ Video repaired successfully!")
            print("=" * 80)
            print(f"Output file: {output_path}")
            print(f"File size: {file_size / (1024*1024):.2f} MB")
            print("\nYou can now upload this repaired video to the ML service.")
            return True
        else:
            print("\n" + "=" * 80)
            print("❌ Repair failed")
            print("=" * 80)
            stderr = result.stderr.decode('utf-8', errors='ignore')
            print("Error details:")
            print(stderr[-1000:])  # Last 1000 chars
            print("\nThe video may be too corrupted to repair.")
            print("Try converting it with a video converter application.")
            return False
            
    except subprocess.TimeoutExpired:
        print("\n❌ Repair timed out (took more than 10 minutes)")
        return False
    except Exception as e:
        print(f"\n❌ Error during repair: {str(e)}")
        return False

def main():
    print("\n")
    print("╔" + "=" * 78 + "╗")
    print("║" + " " * 25 + "VIDEO REPAIR UTILITY" + " " * 33 + "║")
    print("╚" + "=" * 78 + "╝")
    print("\n")
    
    if len(sys.argv) < 2:
        print("Usage: python repair_video.py <input_video> [output_video]")
        print("\nExample:")
        print("  python repair_video.py corrupted.mp4")
        print("  python repair_video.py corrupted.mp4 fixed.mp4")
        print("\n")
        
        # Interactive mode
        input_path = input("Enter path to corrupted video: ").strip().strip('"')
        if not input_path:
            print("No input provided. Exiting.")
            return
        
        output_path = input("Enter output path (or press Enter for auto): ").strip().strip('"')
        if not output_path:
            output_path = None
    else:
        input_path = sys.argv[1]
        output_path = sys.argv[2] if len(sys.argv) > 2 else None
    
    success = repair_video(input_path, output_path)
    
    if success:
        print("\n✓ Done! You can now use the repaired video.")
    else:
        print("\n✗ Repair failed. Please try:")
        print("  1. Using a different video converter")
        print("  2. Re-recording/re-downloading the video")
        print("  3. Using a different video file")
    
    print("\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nOperation cancelled by user")
    except Exception as e:
        print(f"\n❌ Unexpected error: {str(e)}")
        import traceback
        traceback.print_exc()

