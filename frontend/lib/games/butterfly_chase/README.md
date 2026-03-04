# Butterfly Chase Game - Real-Time Gaze Control

A real-time gaze-controlled game built with Flame that uses eye tracking to control butterfly movement.

## Features

- **Real-time gaze tracking**: Butterfly continuously follows user's gaze with smooth easing
- **Gaze lost handling**: Automatically switches to gentle wander mode when gaze is lost
- **Data logging**: Comprehensive logging for ML analysis
- **Performance optimized**: Uses Flame's update loop for smooth 60 FPS gameplay

## Usage

### Basic Integration

```dart
import 'package:senseai_mobile/games/butterfly_chase/butterfly_chase_screen.dart';
import 'package:senseai_mobile/gaze/gaze_service.dart';

// Navigate to the game
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ButterflyChaseScreen(
      testId: 'test_123',
      gazeService: gazeService, // Optional - uses global if not provided
    ),
  ),
);
```

### With Custom Gaze Stream

```dart
import 'package:senseai_mobile/games/butterfly_chase/butterfly_chase_screen.dart';
import 'package:senseai_mobile/gaze/gaze_point.dart';
import 'package:senseai_mobile/gaze/fake_gaze_stream.dart';

// Use fake gaze stream for testing
final fakeStream = fakeGazeStreamCircular();

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ButterflyChaseScreen(
      testId: 'test_123',
      gazeStream: fakeStream,
    ),
  ),
);
```

### Testing with Fake Gaze Streams

```dart
import 'package:senseai_mobile/gaze/fake_gaze_stream.dart';

// Circular motion
final circularStream = fakeGazeStreamCircular(
  radius: 0.3,
  centerX: 0.5,
  centerY: 0.5,
  speed: 1.0,
);

// Random movement
final randomStream = fakeGazeStreamRandom(
  minX: 0.2,
  maxX: 0.8,
  minY: 0.2,
  maxY: 0.8,
);

// Figure-8 pattern
final figure8Stream = fakeGazeStreamFigure8(
  scale: 0.25,
  centerX: 0.5,
  centerY: 0.5,
  speed: 1.0,
);
```

## Game Behavior

1. **Real-time target**: Each gaze sample updates the target immediately
2. **Smoothing**: Uses low-pass filter to reduce jitter
3. **Confidence gating**: Gaze below threshold (0.5) is treated as lost
4. **Gaze lost mode**: After 0.5s without valid gaze, butterfly wanders randomly
5. **Bounds**: Butterfly stays within safe area (20px padding)

## Data Logging

The game logs:
- Gaze samples (timestamp, xNorm, yNorm, confidence)
- Mapped target positions (x, y)
- Butterfly position every 200ms
- Engagement metrics (gaze valid time, average distance, reaction latency)

Results are returned as `ButterflyChaseResult` with:
- `score`: Engagement and accuracy score
- `gazeValidMs`: Total time with valid gaze
- `avgDistance`: Average distance between butterfly and gaze target
- `events`: All logged events
- `duration`: Game duration

## Debug Features

- **Gaze indicator**: Toggle visibility with the eye icon in the top-right
- Shows a blue dot where the gaze target is located
- Useful for testing gaze tracking accuracy

## File Structure

```
lib/games/butterfly_chase/
├── butterfly_chase_screen.dart    # Flutter screen wrapper
├── butterfly_chase_game.dart      # Main Flame game
└── components/
    ├── butterfly_component.dart   # Butterfly sprite
    └── gaze_indicator_component.dart # Debug indicator
```
