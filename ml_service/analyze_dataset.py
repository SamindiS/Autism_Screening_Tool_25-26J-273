"""
Dataset Analysis Script for RRB Detection
Analyzes the video dataset and generates statistics
"""
import os
import cv2
import numpy as np
from pathlib import Path
import json
from collections import defaultdict
import matplotlib.pyplot as plt
import seaborn as sns

def analyze_video(video_path):
    """Analyze a single video file"""
    try:
        cap = cv2.VideoCapture(str(video_path))
        
        info = {
            'path': str(video_path),
            'filename': video_path.name,
            'fps': int(cap.get(cv2.CAP_PROP_FPS)),
            'frame_count': int(cap.get(cv2.CAP_PROP_FRAME_COUNT)),
            'width': int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)),
            'height': int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)),
            'duration': 0.0,
            'file_size_mb': os.path.getsize(video_path) / (1024 * 1024)
        }
        
        if info['fps'] > 0:
            info['duration'] = info['frame_count'] / info['fps']
        
        cap.release()
        return info
        
    except Exception as e:
        return {
            'path': str(video_path),
            'filename': video_path.name,
            'error': str(e)
        }

def scan_dataset(dataset_root):
    """Scan entire dataset and collect statistics"""
    
    category_mapping = {
        'Atypical Children Hand Movements': 'atypical_hand_movements',
        'Atypical Children Head and Hand Movements/Hand_Flapping': 'hand_flapping',
        'Atypical Children Head and Hand Movements/Head_Bagging': 'head_banging',
        'Head Nodding': 'head_nodding_atypical',
        'Spinning': 'spinning',
        'Normal/Children': 'normal',
        'Normal/Adults': 'normal_adults'
    }
    
    dataset_stats = {
        'categories': {},
        'total_videos': 0,
        'total_duration': 0.0,
        'total_size_mb': 0.0,
        'videos': []
    }
    
    for folder_path, label in category_mapping.items():
        full_path = Path(dataset_root) / folder_path
        
        if not full_path.exists():
            print(f"Warning: Path not found: {full_path}")
            continue
        
        print(f"\nAnalyzing: {folder_path}")
        print("-" * 80)
        
        # Find all video files
        video_files = []
        for ext in ['*.mp4', '*.avi', '*.mov', '*.MP4']:
            video_files.extend(full_path.glob(ext))
        
        # Filter out hidden files
        video_files = [f for f in video_files if not f.name.startswith('.')]
        
        category_info = {
            'label': label,
            'folder': folder_path,
            'video_count': len(video_files),
            'videos': [],
            'total_duration': 0.0,
            'avg_duration': 0.0,
            'total_frames': 0,
            'avg_fps': 0.0
        }
        
        # Analyze each video
        for video_path in video_files:
            video_info = analyze_video(video_path)
            video_info['category'] = label
            
            if 'error' not in video_info:
                category_info['videos'].append(video_info)
                category_info['total_duration'] += video_info['duration']
                category_info['total_frames'] += video_info['frame_count']
                dataset_stats['total_duration'] += video_info['duration']
                dataset_stats['total_size_mb'] += video_info['file_size_mb']
                dataset_stats['videos'].append(video_info)
            else:
                print(f"  Error processing {video_path.name}: {video_info['error']}")
        
        # Calculate averages
        if category_info['video_count'] > 0:
            category_info['avg_duration'] = category_info['total_duration'] / category_info['video_count']
            category_info['avg_fps'] = category_info['total_frames'] / category_info['total_duration'] if category_info['total_duration'] > 0 else 0
        
        dataset_stats['categories'][label] = category_info
        dataset_stats['total_videos'] += category_info['video_count']
        
        print(f"  Videos: {category_info['video_count']}")
        print(f"  Total Duration: {category_info['total_duration']:.2f}s")
        print(f"  Avg Duration: {category_info['avg_duration']:.2f}s")
        print(f"  Avg FPS: {category_info['avg_fps']:.1f}")
    
    return dataset_stats

def plot_statistics(dataset_stats, output_dir='outputs'):
    """Generate visualization plots"""
    os.makedirs(output_dir, exist_ok=True)
    
    # Set style
    sns.set_style("whitegrid")
    
    # 1. Video count per category
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    categories = list(dataset_stats['categories'].keys())
    video_counts = [dataset_stats['categories'][cat]['video_count'] for cat in categories]
    
    axes[0, 0].bar(range(len(categories)), video_counts, color='steelblue')
    axes[0, 0].set_xticks(range(len(categories)))
    axes[0, 0].set_xticklabels(categories, rotation=45, ha='right')
    axes[0, 0].set_ylabel('Number of Videos')
    axes[0, 0].set_title('Video Count per Category')
    axes[0, 0].grid(axis='y', alpha=0.3)
    
    # 2. Duration distribution
    durations = [v['duration'] for v in dataset_stats['videos'] if 'duration' in v]
    axes[0, 1].hist(durations, bins=30, color='coral', edgecolor='black')
    axes[0, 1].set_xlabel('Duration (seconds)')
    axes[0, 1].set_ylabel('Frequency')
    axes[0, 1].set_title('Video Duration Distribution')
    axes[0, 1].axvline(np.mean(durations), color='red', linestyle='--', label=f'Mean: {np.mean(durations):.2f}s')
    axes[0, 1].legend()
    
    # 3. Total duration per category
    total_durations = [dataset_stats['categories'][cat]['total_duration'] for cat in categories]
    axes[1, 0].bar(range(len(categories)), total_durations, color='lightgreen')
    axes[1, 0].set_xticks(range(len(categories)))
    axes[1, 0].set_xticklabels(categories, rotation=45, ha='right')
    axes[1, 0].set_ylabel('Total Duration (seconds)')
    axes[1, 0].set_title('Total Duration per Category')
    axes[1, 0].grid(axis='y', alpha=0.3)
    
    # 4. FPS distribution
    fps_values = [v['fps'] for v in dataset_stats['videos'] if 'fps' in v and v['fps'] > 0]
    axes[1, 1].hist(fps_values, bins=20, color='plum', edgecolor='black')
    axes[1, 1].set_xlabel('FPS')
    axes[1, 1].set_ylabel('Frequency')
    axes[1, 1].set_title('FPS Distribution')
    axes[1, 1].axvline(np.mean(fps_values), color='red', linestyle='--', label=f'Mean: {np.mean(fps_values):.1f}')
    axes[1, 1].legend()
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'dataset_statistics.png'), dpi=300, bbox_inches='tight')
    print(f"\nPlot saved to {output_dir}/dataset_statistics.png")
    plt.close()

def print_summary(dataset_stats):
    """Print dataset summary"""
    print("\n" + "=" * 80)
    print("DATASET SUMMARY")
    print("=" * 80)
    
    print(f"\nTotal Videos: {dataset_stats['total_videos']}")
    print(f"Total Duration: {dataset_stats['total_duration']:.2f}s ({dataset_stats['total_duration']/60:.2f} minutes)")
    print(f"Total Size: {dataset_stats['total_size_mb']:.2f} MB")
    print(f"Average Video Duration: {dataset_stats['total_duration']/dataset_stats['total_videos']:.2f}s")
    
    print("\nCategory Breakdown:")
    print("-" * 80)
    print(f"{'Category':<30} {'Videos':<10} {'Duration':<15} {'Avg Duration':<15}")
    print("-" * 80)
    
    for cat_name, cat_info in dataset_stats['categories'].items():
        print(f"{cat_name:<30} {cat_info['video_count']:<10} "
              f"{cat_info['total_duration']:<15.2f} {cat_info['avg_duration']:<15.2f}")
    
    print("-" * 80)
    
    # Duration statistics
    durations = [v['duration'] for v in dataset_stats['videos'] if 'duration' in v]
    if durations:
        print(f"\nDuration Statistics:")
        print(f"  Min: {min(durations):.2f}s")
        print(f"  Max: {max(durations):.2f}s")
        print(f"  Mean: {np.mean(durations):.2f}s")
        print(f"  Median: {np.median(durations):.2f}s")
        print(f"  Std Dev: {np.std(durations):.2f}s")
    
    # FPS statistics
    fps_values = [v['fps'] for v in dataset_stats['videos'] if 'fps' in v and v['fps'] > 0]
    if fps_values:
        print(f"\nFPS Statistics:")
        print(f"  Min: {min(fps_values)}")
        print(f"  Max: {max(fps_values)}")
        print(f"  Mean: {np.mean(fps_values):.1f}")
        print(f"  Median: {np.median(fps_values):.1f}")
    
    # Resolution statistics
    resolutions = [(v['width'], v['height']) for v in dataset_stats['videos'] if 'width' in v]
    if resolutions:
        unique_resolutions = list(set(resolutions))
        print(f"\nUnique Resolutions: {len(unique_resolutions)}")
        for res in unique_resolutions:
            count = resolutions.count(res)
            print(f"  {res[0]}x{res[1]}: {count} videos")

def main():
    """Main analysis function"""
    dataset_root = '../Dataset'
    
    print("=" * 80)
    print("RRB Dataset Analysis")
    print("=" * 80)
    
    if not os.path.exists(dataset_root):
        print(f"Error: Dataset not found at {dataset_root}")
        return
    
    # Scan dataset
    print(f"\nScanning dataset at: {dataset_root}")
    dataset_stats = scan_dataset(dataset_root)
    
    # Print summary
    print_summary(dataset_stats)
    
    # Save statistics to JSON
    output_dir = 'outputs'
    os.makedirs(output_dir, exist_ok=True)
    
    # Remove video details for cleaner JSON
    stats_for_json = dataset_stats.copy()
    for cat in stats_for_json['categories'].values():
        cat.pop('videos', None)
    stats_for_json.pop('videos', None)
    
    with open(os.path.join(output_dir, 'dataset_statistics.json'), 'w') as f:
        json.dump(stats_for_json, f, indent=2)
    
    print(f"\nStatistics saved to {output_dir}/dataset_statistics.json")
    
    # Generate plots
    print("\nGenerating visualization plots...")
    plot_statistics(dataset_stats, output_dir)
    
    print("\n" + "=" * 80)
    print("Analysis Complete!")
    print("=" * 80)

if __name__ == '__main__':
    main()

