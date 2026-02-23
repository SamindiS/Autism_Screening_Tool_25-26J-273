/// =============================================================================
/// Gaze Stream Provider - Adapter for GazeService
/// =============================================================================
///
/// Provides a clean adapter to convert GazeService.gazeStream to
/// Stream<GazePoint> for use in games.
/// =============================================================================

import 'dart:async';
import 'gaze_point.dart';
import 'gaze_service.dart';

/// Adapter that converts GazeService stream to GazePoint stream
class GazeStreamProvider {
  final GazeService _gazeService;
  StreamSubscription<GazeData>? _subscription;
  final _controller = StreamController<GazePoint>.broadcast();

  GazeStreamProvider(this._gazeService);

  /// Get stream of GazePoint from GazeService
  Stream<GazePoint> get gazeStream {
    // Cancel existing subscription if any
    _subscription?.cancel();

    // Subscribe to GazeService stream and convert to GazePoint
    _subscription = _gazeService.gazeStream.listen(
      (gazeData) {
        final gazePoint = GazePoint.fromGazeData(gazeData);
        _controller.add(gazePoint);
      },
      onError: (error) {
        _controller.addError(error);
      },
    );

    return _controller.stream;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
