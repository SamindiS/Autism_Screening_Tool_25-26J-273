import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:typed_data';

/// Platform channel wrapper for a native FaceMesh / MediaPipe implementation.
///
/// Native side should implement:
/// - MethodChannel 'senseai/face_mesh' with methods: 'start', 'stop'
/// - EventChannel 'senseai/face_mesh/events' streaming Float64List or List<double>
///   where each event is a flattened list of [x1,y1,x2,y2,...] normalized 0..1.

class FaceMeshPlatform {
  static const MethodChannel _method = MethodChannel('senseai/face_mesh');
  static const EventChannel _events = EventChannel('senseai/face_mesh/events');

  Stream<List<double>>? _landmarkStream;

  /// Start the native face-mesh process (camera frames processed on native side).
  Future<void> start() async {
    try {
      await _method.invokeMethod('start');
    } catch (e) {
      // no-op: native not implemented
    }
  }

  /// Stop the native face-mesh processing.
  Future<void> stop() async {
    try {
      await _method.invokeMethod('stop');
    } catch (e) {}
  }

  /// Stream of flattened landmark lists [x1,y1,x2,y2,...]
  Stream<List<double>> get landmarksStream {
    _landmarkStream ??= _events.receiveBroadcastStream().map((event) {
      // event may be List<dynamic> or Float64List
      if (event is List) {
        return event.map((e) => (e as num).toDouble()).toList();
      }
      if (event is Float64List) {
        return event.toList();
      }
      return <double>[];
    });
    return _landmarkStream!;
  }
}

final faceMesh = FaceMeshPlatform();
