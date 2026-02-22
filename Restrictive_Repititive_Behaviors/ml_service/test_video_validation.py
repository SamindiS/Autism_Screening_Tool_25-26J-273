"""
Test script for video validation and error handling
"""
import os
import sys
from utils.video_validator import VideoValidator
from utils.video_processor import VideoProcessor

def test_video_validation():
    """Test video validation functionality"""
    print("=" * 80)
    print("Video Validation Test")
    print("=" * 80)
    
    validator = VideoValidator()
    
    # Test with a video file
    print("\nEnter path to a video file to test:")
    print("(or press Enter to skip)")
    video_path = input("> ").strip()
    
    if not video_path:
        print("\nNo video path provided. Using default test...")
        # Create a dummy test
        print("\nTest 1: Non-existent file")
        is_valid, msg, info = validator.validate_video("nonexistent.mp4")
        print(f"Valid: {is_valid}")
        print(f"Message: {msg}")
        print(f"Info: {info}")
        return
    
    if not os.path.exists(video_path):
        print(f"\nError: File not found: {video_path}")
        return
    
    print("\n" + "-" * 80)
    print("Test 1: Video Validation")
    print("-" * 80)
    
    is_valid, error_msg, video_info = validator.validate_video(video_path)
    
    print(f"\nValidation Result: {'✓ VALID' if is_valid else '✗ INVALID'}")
    print(f"Message: {error_msg}")
    
    if video_info:
        print("\nVideo Information:")
        print(f"  FPS: {video_info.get('fps', 'N/A')}")
        print(f"  Frame Count: {video_info.get('frame_count', 'N/A')}")
        print(f"  Dimensions: {video_info.get('width', 'N/A')}x{video_info.get('height', 'N/A')}")
        print(f"  Duration: {video_info.get('duration', 'N/A'):.2f} seconds")
        print(f"  File Size: {video_info.get('file_size', 0) / (1024*1024):.2f} MB")
        print(f"  Frames Validated: {video_info.get('frames_validated', 'N/A')}")
    
    if not is_valid:
        print("\n" + "-" * 80)
        print("Test 2: Video Repair")
        print("-" * 80)
        
        print("\nAttempting to repair video...")
        repair_success, repair_msg, repaired_path = validator.repair_video(video_path)
        
        print(f"\nRepair Result: {'✓ SUCCESS' if repair_success else '✗ FAILED'}")
        print(f"Message: {repair_msg}")
        
        if repair_success and repaired_path:
            print(f"Repaired video saved to: {repaired_path}")
            
            # Validate repaired video
            print("\nValidating repaired video...")
            is_valid2, error_msg2, video_info2 = validator.validate_video(repaired_path)
            
            print(f"Repaired Video Valid: {'✓ YES' if is_valid2 else '✗ NO'}")
            if video_info2:
                print(f"  FPS: {video_info2.get('fps', 'N/A')}")
                print(f"  Frame Count: {video_info2.get('frame_count', 'N/A')}")
                print(f"  Duration: {video_info2.get('duration', 'N/A'):.2f} seconds")
    
    print("\n" + "-" * 80)
    print("Test 3: Frame Extraction")
    print("-" * 80)
    
    if is_valid:
        print("\nTesting frame extraction...")
        processor = VideoProcessor()
        
        try:
            frames = processor.extract_frames(video_path, max_frames=30)
            print(f"✓ Successfully extracted {len(frames)} frames")
            print(f"  Frame shape: {frames[0].shape if frames else 'N/A'}")
        except Exception as e:
            print(f"✗ Frame extraction failed: {str(e)}")
    else:
        print("\nSkipping frame extraction (video is invalid)")
    
    print("\n" + "=" * 80)
    print("Test Complete")
    print("=" * 80)

def test_error_handling():
    """Test error handling with various scenarios"""
    print("\n" + "=" * 80)
    print("Error Handling Test")
    print("=" * 80)
    
    validator = VideoValidator()
    processor = VideoProcessor()
    
    test_cases = [
        ("Empty file path", ""),
        ("Non-existent file", "nonexistent_video.mp4"),
        ("Invalid extension", "test.txt"),
    ]
    
    for test_name, test_path in test_cases:
        print(f"\n{test_name}: {test_path}")
        print("-" * 40)
        
        try:
            is_valid, msg, info = validator.validate_video(test_path)
            print(f"  Valid: {is_valid}")
            print(f"  Message: {msg}")
        except Exception as e:
            print(f"  Exception: {str(e)}")

if __name__ == "__main__":
    print("\n")
    print("╔" + "=" * 78 + "╗")
    print("║" + " " * 20 + "VIDEO VALIDATION TEST SUITE" + " " * 30 + "║")
    print("╚" + "=" * 78 + "╝")
    print("\n")
    
    try:
        test_video_validation()
        test_error_handling()
        
        print("\n✓ All tests completed!")
        print("\nNote: For full testing, restart the ML service and try uploading videos")
        print("through the Flutter app or API endpoints.")
        
    except KeyboardInterrupt:
        print("\n\nTest interrupted by user")
    except Exception as e:
        print(f"\n✗ Test failed with error: {str(e)}")
        import traceback
        traceback.print_exc()
    
    print("\n")

