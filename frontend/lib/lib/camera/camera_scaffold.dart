import 'package:flutter/material.dart';
import '../landmarks/face_mesh_platform.dart';

/// A lightweight camera scaffold that subscribes to the native face-mesh landmarks
/// if available and renders a small overlay of landmark points. Native implementation
/// must provide the platform channel (see `landmarks/face_mesh_platform.dart`).
/// Camera scaffold placeholder. In a real app this would show a CameraPreview
/// and return frames for model inference. Here it's a lightweight UI stub.
class CameraScaffold extends StatelessWidget {
  const CameraScaffold({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
      child: StreamBuilder<List<double>>(
        stream: faceMesh.landmarksStream,
        builder: (context, snap) {
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
                child: Icon(Icons.camera_alt, size: 36, color: Colors.grey));
          }
          final landmarks = snap.data!;
          return CustomPaint(
            painter: _LandmarkPainter(landmarks),
          );
        },
      ),
    );
  }
}

class _LandmarkPainter extends CustomPainter {
  final List<double> landmarks; // flattened [x1,y1,...]
  _LandmarkPainter(this.landmarks);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;
    for (var i = 0; i + 1 < landmarks.length; i += 2) {
      final x = landmarks[i] * size.width;
      final y = landmarks[i + 1] * size.height;
      canvas.drawCircle(Offset(x, y), 3.0, paint);
      // limit to first 40 points to avoid clutter
      if (i > 80) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
