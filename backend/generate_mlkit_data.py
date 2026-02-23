"""
Generate Realistic ML Kit Gaze Training Data
=============================================

This script generates training data that closely mimics what Google ML Kit 
Face Detection actually outputs on Android devices.

Key insights from ML Kit behavior:
1. Head euler angles are the PRIMARY signal for gaze direction
2. Eye contours track eyelid shape, NOT iris position
3. Face bounds and eye positions are relative to image frame
4. Front camera images are mirrored

The model needs to learn:
- headYaw (rotation left/right) → gazeX
- headPitch (rotation up/down) → gazeY

Usage:
    python generate_mlkit_data.py --samples 20000 --output mlkit_gaze_data.json
"""

import json
import numpy as np
import argparse
from datetime import datetime


def generate_mlkit_realistic_data(n_samples=20000, seed=42):
    """
    Generate training data that mimics actual ML Kit face detection output.
    
    ML Kit provides:
    - headEulerAngleX: Pitch (up/down tilt), typically -30 to +30 degrees
      - Negative = looking UP
      - Positive = looking DOWN
    - headEulerAngleY: Yaw (left/right rotation), typically -45 to +45 degrees  
      - Negative = turned LEFT (looking left)
      - Positive = turned RIGHT (looking right)
    - headEulerAngleZ: Roll (head tilt), typically -30 to +30 degrees
    
    Front camera is MIRRORED, so:
    - When user turns head RIGHT, yaw is positive, and they're looking at RIGHT side of screen
    """
    np.random.seed(seed)
    
    print(f"Generating {n_samples} ML Kit realistic gaze samples...")
    print("This data models the actual relationship between head pose and gaze direction")
    
    samples = []
    
    for i in range(n_samples):
        # === TARGET: Where user is looking on screen (0-1) ===
        # Mix of grid points, random, and edge cases
        sample_type = np.random.choice(['grid', 'random', 'edges', 'center'], 
                                       p=[0.3, 0.4, 0.15, 0.15])
        
        if sample_type == 'grid':
            # 9-point calibration grid with noise
            grid_x = np.random.choice([0.15, 0.5, 0.85])
            grid_y = np.random.choice([0.15, 0.5, 0.85])
            target_x = grid_x + np.random.randn() * 0.03
            target_y = grid_y + np.random.randn() * 0.03
        elif sample_type == 'random':
            # Uniform random
            target_x = np.random.uniform(0.1, 0.9)
            target_y = np.random.uniform(0.1, 0.9)
        elif sample_type == 'edges':
            # Edge cases - looking at corners/edges
            edge = np.random.choice(['left', 'right', 'top', 'bottom', 'corner'])
            if edge == 'left':
                target_x = np.random.uniform(0.0, 0.2)
                target_y = np.random.uniform(0.2, 0.8)
            elif edge == 'right':
                target_x = np.random.uniform(0.8, 1.0)
                target_y = np.random.uniform(0.2, 0.8)
            elif edge == 'top':
                target_x = np.random.uniform(0.2, 0.8)
                target_y = np.random.uniform(0.0, 0.2)
            elif edge == 'bottom':
                target_x = np.random.uniform(0.2, 0.8)
                target_y = np.random.uniform(0.8, 1.0)
            else:  # corner
                target_x = np.random.choice([0.05, 0.95])
                target_y = np.random.choice([0.05, 0.95])
        else:  # center
            target_x = 0.5 + np.random.randn() * 0.1
            target_y = 0.5 + np.random.randn() * 0.1
        
        target_x = np.clip(target_x, 0.0, 1.0)
        target_y = np.clip(target_y, 0.0, 1.0)
        
        # === HEAD POSE: ML Kit euler angles ===
        # These are the PRIMARY predictors of gaze
        
        # The relationship between gaze and head pose:
        # Looking at center (0.5, 0.5) → head roughly straight (yaw=0, pitch=0)
        # Looking at right edge (1.0) → head turned right (yaw positive, ~+20 to +30)
        # Looking at left edge (0.0) → head turned left (yaw negative, ~-20 to -30)
        # Looking at top (0.0) → head tilted up (pitch negative, ~-15 to -25)
        # Looking at bottom (1.0) → head tilted down (pitch positive, ~+15 to +25)
        
        # Sensitivity: how many degrees of head rotation for full screen travel
        # These values are calibrated to match typical phone viewing distances
        yaw_range = 25.0   # ±25 degrees for 0→1 horizontal
        pitch_range = 20.0  # ±20 degrees for 0→1 vertical
        
        # Base head pose from target
        base_yaw = (target_x - 0.5) * 2 * yaw_range  # -25 to +25 for 0 to 1
        base_pitch = (target_y - 0.5) * 2 * pitch_range  # -20 to +20 for 0 to 1
        
        # Add individual variation (different people hold phone/head differently)
        user_yaw_bias = np.random.randn() * 3  # Some people naturally tilt head
        user_pitch_bias = np.random.randn() * 3
        
        # Add noise for natural head movement variation
        head_yaw = base_yaw + user_yaw_bias + np.random.randn() * 2
        head_pitch = base_pitch + user_pitch_bias + np.random.randn() * 2
        head_roll = np.random.randn() * 5  # Roll doesn't affect gaze much
        
        # Clamp to realistic ML Kit ranges
        head_yaw = np.clip(head_yaw, -45, 45)
        head_pitch = np.clip(head_pitch, -35, 35)
        head_roll = np.clip(head_roll, -30, 30)
        
        # === FACE BOUNDS: Where face appears in frame (normalized 0-1) ===
        # Face position is relatively stable, centered in frame
        # Slight variation based on head pose (turning head shifts face in frame slightly)
        
        face_center_x = 0.5 + head_yaw * 0.002 + np.random.randn() * 0.02
        face_center_y = 0.45 + head_pitch * 0.001 + np.random.randn() * 0.02
        
        # Face size varies by distance from camera
        face_width = 0.28 + np.random.randn() * 0.04
        face_height = 0.38 + np.random.randn() * 0.04
        
        face_left = np.clip(face_center_x - face_width/2, 0, 1)
        face_top = np.clip(face_center_y - face_height/2, 0, 1)
        face_right = np.clip(face_center_x + face_width/2, 0, 1)
        face_bottom = np.clip(face_center_y + face_height/2, 0, 1)
        
        # === EYE POSITIONS: ML Kit eye landmarks ===
        # Eyes are positioned relative to face, don't move much with gaze
        # (ML Kit tracks face structure, not iris position)
        
        # Eye positions relative to face center
        eye_y_offset = -0.08  # Eyes are above face center
        eye_x_spacing = 0.055  # Distance from center to each eye
        
        # In MIRRORED front camera:
        # - "Left eye" in ML Kit is actually user's right eye (appears on left in image)
        # - Positions are as they appear in the mirrored image
        
        left_eye_x = face_center_x + eye_x_spacing + np.random.randn() * 0.003
        left_eye_y = face_center_y + eye_y_offset + np.random.randn() * 0.003
        right_eye_x = face_center_x - eye_x_spacing + np.random.randn() * 0.003
        right_eye_y = face_center_y + eye_y_offset + np.random.randn() * 0.003
        
        # === EYE CONTOURS: Eyelid shape (4 key points per eye) ===
        # These track the eyelid shape, NOT the iris
        # Format: left corner, top, right corner, bottom
        
        def make_eye_contour(cx, cy, width=0.02, height=0.012):
            """Generate 4-point eye contour (corners and top/bottom)"""
            return [
                cx - width, cy,           # Left corner
                cx, cy - height,          # Top
                cx + width, cy,           # Right corner  
                cx, cy + height           # Bottom
            ]
        
        left_contour = make_eye_contour(left_eye_x, left_eye_y)
        right_contour = make_eye_contour(right_eye_x, right_eye_y)
        
        # Add slight noise to contour points
        left_contour = [v + np.random.randn() * 0.001 for v in left_contour]
        right_contour = [v + np.random.randn() * 0.001 for v in right_contour]
        
        # === BUILD MODEL INPUT (32 features) ===
        # Must match EyeLandmarks.toModelInput() in gaze_tracker.dart:
        # [0-3]: Eye centers (leftX, leftY, rightX, rightY)
        # [4-11]: Left eye contour 4 points (x,y pairs)
        # [12-19]: Right eye contour 4 points (x,y pairs)
        # [20-22]: Head euler angles (X=pitch, Y=yaw, Z=roll)
        # [23-24]: Face center (x, y)
        # [25-31]: Padding zeros
        
        model_input = [
            # Eye centers (4)
            left_eye_x, left_eye_y,
            right_eye_x, right_eye_y,
            # Left eye contour - 4 points = 8 values
            left_contour[0], left_contour[1],  # Left corner
            left_contour[2], left_contour[3],  # Top
            left_contour[4], left_contour[5],  # Right corner
            left_contour[6], left_contour[7],  # Bottom
            # Right eye contour - 4 points = 8 values
            right_contour[0], right_contour[1],  # Left corner
            right_contour[2], right_contour[3],  # Top
            right_contour[4], right_contour[5],  # Right corner
            right_contour[6], right_contour[7],  # Bottom
            # Head euler angles (3) - THIS IS THE KEY DATA
            head_pitch,  # X - up/down
            head_yaw,    # Y - left/right
            head_roll,   # Z - tilt
            # Face center (2)
            face_center_x, face_center_y,
            # Padding (7 zeros)
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        ]
        
        assert len(model_input) == 32, f"Expected 32 features, got {len(model_input)}"
        
        sample = {
            'modelInput': model_input,
            'targetX': float(target_x),
            'targetY': float(target_y),
            'metadata': {
                'head_yaw': float(head_yaw),
                'head_pitch': float(head_pitch),
                'sample_type': sample_type
            }
        }
        
        samples.append(sample)
        
        if (i + 1) % 5000 == 0:
            print(f"  Generated {i + 1}/{n_samples} samples...")
    
    # Statistics
    print(f"\nGenerated {len(samples)} samples")
    yaws = [s['metadata']['head_yaw'] for s in samples]
    pitches = [s['metadata']['head_pitch'] for s in samples]
    target_xs = [s['targetX'] for s in samples]
    target_ys = [s['targetY'] for s in samples]
    
    print(f"Head yaw range: {min(yaws):.1f}° to {max(yaws):.1f}°")
    print(f"Head pitch range: {min(pitches):.1f}° to {max(pitches):.1f}°")
    print(f"Target X range: {min(target_xs):.2f} to {max(target_xs):.2f}")
    print(f"Target Y range: {min(target_ys):.2f} to {max(target_ys):.2f}")
    
    return samples


def main():
    parser = argparse.ArgumentParser(description='Generate ML Kit realistic gaze training data')
    parser.add_argument('--samples', type=int, default=20000, help='Number of samples')
    parser.add_argument('--output', type=str, default='mlkit_gaze_data.json', help='Output file')
    parser.add_argument('--seed', type=int, default=42, help='Random seed')
    
    args = parser.parse_args()
    
    # Generate data
    samples = generate_mlkit_realistic_data(args.samples, args.seed)
    
    # Save
    output_path = os.path.join(os.path.dirname(__file__), args.output)
    with open(output_path, 'w') as f:
        json.dump(samples, f)
    
    file_size = os.path.getsize(output_path) / 1024
    print(f"\nSaved to: {output_path}")
    print(f"File size: {file_size:.1f} KB")
    
    # Verify data can be loaded
    print("\nVerifying data format...")
    with open(output_path, 'r') as f:
        loaded = json.load(f)
    print(f"Loaded {len(loaded)} samples successfully")
    print(f"Sample input shape: {len(loaded[0]['modelInput'])} features")


if __name__ == '__main__':
    import os
    main()
