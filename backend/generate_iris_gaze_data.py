"""
Generate IRIS-BASED Gaze Training Data
======================================

This script generates training data that models ACTUAL EYE GAZE,
not head pose tracking.

Key concept: Track where the IRIS/PUPIL is within the eye socket.
- When looking RIGHT: iris moves toward right edge of eye
- When looking LEFT: iris moves toward left edge of eye
- When looking UP: iris moves toward top edge of eye
- When looking DOWN: iris moves toward bottom edge of eye

This is independent of head position!

Usage:
    python generate_iris_gaze_data.py --samples 20000 --output iris_gaze_data.json
"""

import json
import numpy as np
import argparse
import os


def generate_iris_gaze_data(n_samples=20000, seed=42):
    """
    Generate training data based on iris position within eye socket.
    
    The model input includes eye contour bounds and iris center.
    We need the model to learn: iris position in eye → gaze direction
    """
    np.random.seed(seed)
    
    print(f"Generating {n_samples} iris-based gaze samples...")
    
    samples = []
    
    for i in range(n_samples):
        # === TARGET: Where user is looking (0-1) ===
        sample_type = np.random.choice(['grid', 'random', 'edges', 'center'], 
                                       p=[0.3, 0.4, 0.15, 0.15])
        
        if sample_type == 'grid':
            grid_x = np.random.choice([0.15, 0.5, 0.85])
            grid_y = np.random.choice([0.15, 0.5, 0.85])
            target_x = grid_x + np.random.randn() * 0.02
            target_y = grid_y + np.random.randn() * 0.02
        elif sample_type == 'random':
            target_x = np.random.uniform(0.05, 0.95)
            target_y = np.random.uniform(0.05, 0.95)
        elif sample_type == 'edges':
            edge = np.random.choice(['left', 'right', 'top', 'bottom'])
            if edge == 'left':
                target_x = np.random.uniform(0.0, 0.15)
                target_y = np.random.uniform(0.2, 0.8)
            elif edge == 'right':
                target_x = np.random.uniform(0.85, 1.0)
                target_y = np.random.uniform(0.2, 0.8)
            elif edge == 'top':
                target_x = np.random.uniform(0.2, 0.8)
                target_y = np.random.uniform(0.0, 0.15)
            else:
                target_x = np.random.uniform(0.2, 0.8)
                target_y = np.random.uniform(0.85, 1.0)
        else:  # center
            target_x = 0.5 + np.random.randn() * 0.1
            target_y = 0.5 + np.random.randn() * 0.1
        
        target_x = np.clip(target_x, 0.0, 1.0)
        target_y = np.clip(target_y, 0.0, 1.0)
        
        # === IRIS POSITION IN EYE SOCKET ===
        # This is the KEY relationship we want the model to learn
        # 
        # Looking at target_x=0.0 (left edge) → iris at LEFT side of eye (relX ≈ 0.3)
        # Looking at target_x=1.0 (right edge) → iris at RIGHT side of eye (relX ≈ 0.7)
        # Looking at target_y=0.0 (top) → iris at TOP of eye (relY ≈ 0.3)
        # Looking at target_y=1.0 (bottom) → iris at BOTTOM of eye (relY ≈ 0.7)
        #
        # Note: Eye can only move so much, so iris stays within ~0.3-0.7 range
        
        # Map gaze target to iris relative position
        # IMPORTANT: Front camera is MIRRORED
        # When you look RIGHT (target_x=1), your iris appears to move LEFT in the image
        # So: target_x → (1 - iris_rel_x) after mirroring
        # We train with the MIRRORED values since that's what ML Kit outputs
        
        iris_rel_x_base = 0.3 + (1.0 - target_x) * 0.4  # 0.3 to 0.7 range (mirrored)
        iris_rel_y_base = 0.35 + target_y * 0.3  # 0.35 to 0.65 range
        
        # Add individual variation (different eye shapes, etc.)
        user_bias_x = np.random.randn() * 0.03
        user_bias_y = np.random.randn() * 0.02
        
        # Add frame-to-frame noise
        noise_x = np.random.randn() * 0.02
        noise_y = np.random.randn() * 0.015
        
        iris_rel_x = np.clip(iris_rel_x_base + user_bias_x + noise_x, 0.1, 0.9)
        iris_rel_y = np.clip(iris_rel_y_base + user_bias_y + noise_y, 0.2, 0.8)
        
        # === FACE AND EYE GEOMETRY ===
        # Face position is relatively stable (person sitting in front of camera)
        # These should NOT affect the gaze output - gaze depends on iris position
        
        # Random face position (doesn't correlate with gaze)
        face_center_x = 0.5 + np.random.randn() * 0.05
        face_center_y = 0.45 + np.random.randn() * 0.05
        face_width = 0.28 + np.random.randn() * 0.03
        face_height = 0.38 + np.random.randn() * 0.03
        
        # Random head pose (doesn't correlate with gaze - you can look left while turning head right)
        head_yaw = np.random.randn() * 10  # Random head rotation
        head_pitch = np.random.randn() * 8
        head_roll = np.random.randn() * 5
        
        # Eye positions relative to face
        eye_y_offset = -0.08
        eye_x_spacing = 0.055
        
        left_eye_cx = face_center_x + eye_x_spacing + np.random.randn() * 0.003
        left_eye_cy = face_center_y + eye_y_offset + np.random.randn() * 0.003
        right_eye_cx = face_center_x - eye_x_spacing + np.random.randn() * 0.003
        right_eye_cy = face_center_y + eye_y_offset + np.random.randn() * 0.003
        
        # Eye dimensions
        eye_width = 0.02 + np.random.randn() * 0.002
        eye_height = 0.012 + np.random.randn() * 0.001
        
        # Calculate iris absolute position from relative position
        # Iris position = eye_min + iris_rel * eye_size
        left_iris_x = (left_eye_cx - eye_width) + iris_rel_x * (2 * eye_width)
        left_iris_y = (left_eye_cy - eye_height) + iris_rel_y * (2 * eye_height)
        right_iris_x = (right_eye_cx - eye_width) + iris_rel_x * (2 * eye_width)
        right_iris_y = (right_eye_cy - eye_height) + iris_rel_y * (2 * eye_height)
        
        # Eye contour points (4 corners)
        def make_eye_contour(cx, cy, w, h):
            return [
                cx - w, cy,      # Left corner
                cx, cy - h,      # Top
                cx + w, cy,      # Right corner
                cx, cy + h       # Bottom
            ]
        
        left_contour = make_eye_contour(left_eye_cx, left_eye_cy, eye_width, eye_height)
        right_contour = make_eye_contour(right_eye_cx, right_eye_cy, eye_width, eye_height)
        
        # Add noise to contour
        left_contour = [v + np.random.randn() * 0.001 for v in left_contour]
        right_contour = [v + np.random.randn() * 0.001 for v in right_contour]
        
        # === BUILD MODEL INPUT (32 features) ===
        # The model needs to learn that IRIS position matters, not head pose
        
        model_input = [
            # Eye centers (4) - these are approximately where iris is
            left_iris_x, left_iris_y,    # Use iris position as "eye center"
            right_iris_x, right_iris_y,
            # Left eye contour - 4 points = 8 values
            left_contour[0], left_contour[1],
            left_contour[2], left_contour[3],
            left_contour[4], left_contour[5],
            left_contour[6], left_contour[7],
            # Right eye contour - 4 points = 8 values
            right_contour[0], right_contour[1],
            right_contour[2], right_contour[3],
            right_contour[4], right_contour[5],
            right_contour[6], right_contour[7],
            # Head euler angles (3) - these should be IGNORED by model
            head_pitch, head_yaw, head_roll,
            # Face center (2)
            face_center_x, face_center_y,
            # Padding (7 zeros)
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        ]
        
        assert len(model_input) == 32
        
        sample = {
            'modelInput': model_input,
            'targetX': float(target_x),
            'targetY': float(target_y),
            'metadata': {
                'iris_rel_x': float(iris_rel_x),
                'iris_rel_y': float(iris_rel_y),
                'head_yaw': float(head_yaw),
                'sample_type': sample_type
            }
        }
        
        samples.append(sample)
        
        if (i + 1) % 5000 == 0:
            print(f"  Generated {i + 1}/{n_samples} samples...")
    
    print(f"\nGenerated {len(samples)} samples")
    
    # Verify the relationship
    print("\nVerifying iris→gaze relationship:")
    left_samples = [s for s in samples if s['targetX'] < 0.3]
    right_samples = [s for s in samples if s['targetX'] > 0.7]
    
    if left_samples and right_samples:
        avg_iris_left = np.mean([s['metadata']['iris_rel_x'] for s in left_samples])
        avg_iris_right = np.mean([s['metadata']['iris_rel_x'] for s in right_samples])
        print(f"  Looking LEFT (target_x<0.3): avg iris_rel_x = {avg_iris_left:.3f}")
        print(f"  Looking RIGHT (target_x>0.7): avg iris_rel_x = {avg_iris_right:.3f}")
        print(f"  (Iris should be higher when looking left due to camera mirroring)")
    
    return samples


def main():
    parser = argparse.ArgumentParser(description='Generate iris-based gaze training data')
    parser.add_argument('--samples', type=int, default=20000, help='Number of samples')
    parser.add_argument('--output', type=str, default='iris_gaze_data.json', help='Output file')
    parser.add_argument('--seed', type=int, default=42, help='Random seed')
    
    args = parser.parse_args()
    
    samples = generate_iris_gaze_data(args.samples, args.seed)
    
    output_path = os.path.join(os.path.dirname(__file__), args.output)
    with open(output_path, 'w') as f:
        json.dump(samples, f)
    
    file_size = os.path.getsize(output_path) / 1024
    print(f"\nSaved to: {output_path}")
    print(f"File size: {file_size:.1f} KB")


if __name__ == '__main__':
    main()
