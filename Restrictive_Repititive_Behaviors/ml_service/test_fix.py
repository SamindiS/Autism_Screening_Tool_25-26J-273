"""
Test script to verify the ML server crash fix
"""
import os
import sys

# Set environment variables before importing TensorFlow
os.environ['TF_USE_LEGACY_KERAS'] = '1'
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'

from utils.inference import RRBInference
from config import Config

def test_inference_initialization():
    """Test that inference engine initializes without PoseEstimator"""
    print("=" * 80)
    print("TEST 1: Inference Engine Initialization")
    print("=" * 80)
    
    try:
        engine = RRBInference(
            model_path=Config.MODEL_PATH,
            label_encoder_path=Config.LABEL_ENCODER_PATH,
            sequence_length=Config.SEQUENCE_LENGTH,
            img_size=Config.IMG_SIZE,
            confidence_threshold=Config.CONFIDENCE_THRESHOLD,
            min_duration=Config.MIN_DETECTION_DURATION
        )
        
        # Check that PoseEstimator is NOT initialized
        if engine._pose_estimator is None:
            print("✅ PASS: PoseEstimator is NOT initialized (lazy loading works)")
        else:
            print("❌ FAIL: PoseEstimator was initialized (should be lazy-loaded)")
            return False
        
        print("✅ PASS: Inference engine initialized successfully")
        
        # Cleanup
        engine.cleanup()
        print("✅ PASS: Cleanup successful")
        
        return True
        
    except Exception as e:
        print(f"❌ FAIL: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def test_basic_detection():
    """Test basic detection without pose estimation"""
    print("\n" + "=" * 80)
    print("TEST 2: Basic Detection (No Pose Estimation)")
    print("=" * 80)
    
    # Find a test video
    test_video = None
    uploads_dir = "uploads"
    
    if os.path.exists(uploads_dir):
        videos = [f for f in os.listdir(uploads_dir) if f.endswith('.mp4')]
        if videos:
            test_video = os.path.join(uploads_dir, videos[0])
    
    if not test_video:
        print("⚠️  SKIP: No test video found in uploads directory")
        return True
    
    print(f"Using test video: {test_video}")
    
    try:
        engine = RRBInference(
            model_path=Config.MODEL_PATH,
            label_encoder_path=Config.LABEL_ENCODER_PATH,
            sequence_length=Config.SEQUENCE_LENGTH,
            img_size=Config.IMG_SIZE,
            confidence_threshold=Config.CONFIDENCE_THRESHOLD,
            min_duration=Config.MIN_DETECTION_DURATION
        )
        
        # Run detection
        print("Running detection...")
        result = engine.detect_rrb(test_video)
        
        # Check that PoseEstimator is still NOT initialized
        if engine._pose_estimator is None:
            print("✅ PASS: PoseEstimator still NOT initialized after basic detection")
        else:
            print("❌ FAIL: PoseEstimator was initialized during basic detection")
            return False
        
        # Check result
        if 'error' in result:
            print(f"❌ FAIL: Detection returned error: {result['error']}")
            return False
        
        print(f"✅ PASS: Detection completed successfully")
        print(f"   - Detected: {result.get('detected', False)}")
        print(f"   - Primary behavior: {result.get('primary_behavior', 'N/A')}")
        print(f"   - Confidence: {result.get('confidence', 0):.2f}")
        
        # Cleanup
        engine.cleanup()
        
        return True
        
    except Exception as e:
        print(f"❌ FAIL: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def test_pose_estimator_lazy_loading():
    """Test that PoseEstimator is loaded when accessed"""
    print("\n" + "=" * 80)
    print("TEST 3: PoseEstimator Lazy Loading")
    print("=" * 80)
    
    try:
        engine = RRBInference(
            model_path=Config.MODEL_PATH,
            label_encoder_path=Config.LABEL_ENCODER_PATH,
            sequence_length=Config.SEQUENCE_LENGTH,
            img_size=Config.IMG_SIZE,
            confidence_threshold=Config.CONFIDENCE_THRESHOLD,
            min_duration=Config.MIN_DETECTION_DURATION
        )
        
        # Check initial state
        if engine._pose_estimator is None:
            print("✅ PASS: PoseEstimator initially None")
        else:
            print("❌ FAIL: PoseEstimator should be None initially")
            return False
        
        # Access pose_estimator property (should trigger lazy loading)
        print("Accessing pose_estimator property...")
        pose_est = engine.pose_estimator
        
        # Check that it's now initialized
        if engine._pose_estimator is not None:
            print("✅ PASS: PoseEstimator initialized on first access")
        else:
            print("❌ FAIL: PoseEstimator should be initialized after access")
            return False
        
        # Cleanup
        engine.cleanup()
        
        # Check cleanup
        if engine._pose_estimator is None:
            print("✅ PASS: PoseEstimator cleaned up successfully")
        else:
            print("❌ FAIL: PoseEstimator should be None after cleanup")
            return False
        
        return True
        
    except Exception as e:
        print(f"❌ FAIL: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run all tests"""
    print("\n" + "=" * 80)
    print("ML SERVER CRASH FIX - TEST SUITE")
    print("=" * 80)
    
    results = []
    
    # Run tests
    results.append(("Inference Initialization", test_inference_initialization()))
    results.append(("Basic Detection", test_basic_detection()))
    results.append(("PoseEstimator Lazy Loading", test_pose_estimator_lazy_loading()))
    
    # Print summary
    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    
    for test_name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status}: {test_name}")
    
    total = len(results)
    passed = sum(1 for _, p in results if p)
    
    print(f"\nTotal: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! The fix is working correctly.")
        return 0
    else:
        print("\n⚠️  Some tests failed. Please review the output above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

