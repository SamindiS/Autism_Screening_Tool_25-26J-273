import os
import sys
import argparse
import json
from pathlib import Path

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from utils.inference import RRBInference
from config import Config

def test_single_video(inference_engine, video_path):
    """Test inference on a single video"""
    print(f"\nTesting video: {video_path}")
    print("-" * 80)
    
    result = inference_engine.detect_rrb(video_path)
    
    print(f"Detected: {result['detected']}")
    print(f"Primary Behavior: {result['primary_behavior']}")
    print(f"Confidence: {result['confidence']:.4f}")
    
    if result['behaviors']:
        print("\nAll Detected Behaviors:")
        for behavior in result['behaviors']:
            print(f"  - {behavior['behavior']}: {behavior['confidence']:.4f} "
                  f"({behavior['occurrences']} occurrences, "
                  f"{behavior['total_duration']:.2f}s total)")
    
    print(f"\nVideo Info:")
    print(f"  Duration: {result['video_info']['duration']:.2f}s")
    print(f"  FPS: {result['video_info']['fps']}")
    print(f"  Resolution: {result['video_info']['width']}x{result['video_info']['height']}")
    print(f"  Sequences Analyzed: {result['total_sequences_analyzed']}")
    print(f"  Sequences with Detections: {result['sequences_with_detections']}")
    
    return result

def test_dataset_folder(inference_engine, folder_path, output_file=None):
    """Test inference on all videos in a folder"""
    video_files = []
    for ext in ['*.mp4', '*.avi', '*.mov', '*.MP4']:
        video_files.extend(Path(folder_path).glob(ext))
    
    # Filter out hidden files
    video_files = [f for f in video_files if not f.name.startswith('.')]
    
    print(f"\nFound {len(video_files)} videos in {folder_path}")
    
    results = []
    for i, video_path in enumerate(video_files):
        print(f"\n[{i+1}/{len(video_files)}] Processing: {video_path.name}")
        
        try:
            result = inference_engine.detect_rrb(str(video_path))
            result['filename'] = video_path.name
            result['folder'] = folder_path
            results.append(result)
            
            print(f"  Result: {result['primary_behavior']} (confidence: {result['confidence']:.4f})")
            
        except Exception as e:
            print(f"  Error: {e}")
            results.append({
                'filename': video_path.name,
                'folder': folder_path,
                'error': str(e),
                'detected': False
            })
    
    # Save results if output file specified
    if output_file:
        with open(output_file, 'w') as f:
            json.dump(results, f, indent=2)
        print(f"\nResults saved to {output_file}")
    
    # Print summary
    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    
    behavior_counts = {}
    for result in results:
        if 'error' not in result:
            behavior = result['primary_behavior']
            behavior_counts[behavior] = behavior_counts.get(behavior, 0) + 1
    
    print(f"Total videos processed: {len(results)}")
    print(f"Successful detections: {len([r for r in results if 'error' not in r])}")
    print(f"Errors: {len([r for r in results if 'error' in r])}")
    
    print("\nBehavior Distribution:")
    for behavior, count in sorted(behavior_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {behavior}: {count} ({count/len(results)*100:.1f}%)")
    
    return results

def main(args):
    """Main test function"""
    print("=" * 80)
    print("RRB Detection Inference Testing")
    print("=" * 80)
    
    # Initialize inference engine
    print("\nInitializing inference engine...")
    
    if not os.path.exists(args.model_path):
        print(f"Error: Model not found at {args.model_path}")
        print("Please train the model first using train.py")
        return
    
    if not os.path.exists(args.label_encoder_path):
        print(f"Error: Label encoder not found at {args.label_encoder_path}")
        print("Please train the model first using train.py")
        return
    
    inference_engine = RRBInference(
        model_path=args.model_path,
        label_encoder_path=args.label_encoder_path,
        sequence_length=args.sequence_length,
        img_size=tuple(args.img_size),
        confidence_threshold=args.confidence_threshold,
        min_duration=args.min_duration
    )
    
    # Test based on mode
    if args.mode == 'single':
        if not args.video_path:
            print("Error: --video_path required for single mode")
            return
        
        test_single_video(inference_engine, args.video_path)
        
    elif args.mode == 'folder':
        if not args.folder_path:
            print("Error: --folder_path required for folder mode")
            return
        
        test_dataset_folder(inference_engine, args.folder_path, args.output_file)
        
    elif args.mode == 'dataset':
        # Test on entire dataset
        dataset_root = args.dataset_path
        
        categories = [
            'Atypical Children Hand Movements',
            'Atypical Children Head and Hand Movements/Hand_Flapping',
            'Atypical Children Head and Hand Movements/Head_Bagging',
            'Head Nodding',
            'Spinning',
            'Normal/Children'
        ]
        
        all_results = []
        for category in categories:
            folder_path = os.path.join(dataset_root, category)
            if os.path.exists(folder_path):
                print(f"\n{'='*80}")
                print(f"Testing category: {category}")
                print(f"{'='*80}")
                
                results = test_dataset_folder(inference_engine, folder_path)
                all_results.extend(results)
        
        # Save all results
        if args.output_file:
            with open(args.output_file, 'w') as f:
                json.dump(all_results, f, indent=2)
            print(f"\nAll results saved to {args.output_file}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Test RRB Detection Inference')
    
    # Mode
    parser.add_argument('--mode', type=str, default='single',
                       choices=['single', 'folder', 'dataset'],
                       help='Testing mode')
    
    # Paths
    parser.add_argument('--video_path', type=str,
                       help='Path to single video file (for single mode)')
    parser.add_argument('--folder_path', type=str,
                       help='Path to folder containing videos (for folder mode)')
    parser.add_argument('--dataset_path', type=str, default='../Dataset',
                       help='Path to dataset root (for dataset mode)')
    parser.add_argument('--output_file', type=str,
                       help='Path to save results JSON')
    
    # Model paths
    parser.add_argument('--model_path', type=str, 
                       default='models/rrb_classifier.h5',
                       help='Path to trained model')
    parser.add_argument('--label_encoder_path', type=str,
                       default='preprocessed_data/label_encoder.pkl',
                       help='Path to label encoder')
    
    # Inference parameters
    parser.add_argument('--sequence_length', type=int, default=30,
                       help='Number of frames per sequence')
    parser.add_argument('--img_size', type=int, nargs=2, default=[224, 224],
                       help='Image size')
    parser.add_argument('--confidence_threshold', type=float, default=0.70,
                       help='Confidence threshold for detection')
    parser.add_argument('--min_duration', type=float, default=3.0,
                       help='Minimum duration in seconds')
    
    args = parser.parse_args()
    main(args)

