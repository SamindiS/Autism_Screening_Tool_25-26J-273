/// GazeTracker Service
///
/// This service handles:
/// 1. Camera initialization and frame capture
/// 2. ML Kit face detection to extract landmarks
/// 3. Eye landmark extraction for gaze prediction
/// 4. Real-time gaze coordinate estimation

import 'dart:async';
import 'dart:ui';
import 'dart:math' show Point;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Represents extracted eye landmarks for gaze prediction
class EyeLandmarks {
  /// Left eye contour points (normalized 0-1)
  final List<Offset> leftEyeContour;

  /// Right eye contour points (normalized 0-1)
  final List<Offset> rightEyeContour;

  /// Left eye center (normalized 0-1)
  final Offset leftEyeCenter;

  /// Right eye center (normalized 0-1)
  final Offset rightEyeCenter;

  /// Left iris/pupil position (normalized 0-1) - estimated from eye contour
  final Offset? leftIrisCenter;

  /// Right iris/pupil position (normalized 0-1) - estimated from eye contour
  final Offset? rightIrisCenter;

  /// Face bounding box (normalized 0-1)
  final Rect faceBounds;

  /// Head rotation angles
  final double? headEulerAngleX; // pitch (up/down)
  final double? headEulerAngleY; // yaw (left/right)
  final double? headEulerAngleZ; // roll (tilt)

  /// Eye open probability (0-1)
  final double? leftEyeOpenProb;
  final double? rightEyeOpenProb;

  /// Timestamp
  final DateTime timestamp;

  EyeLandmarks({
    required this.leftEyeContour,
    required this.rightEyeContour,
    required this.leftEyeCenter,
    required this.rightEyeCenter,
    this.leftIrisCenter,
    this.rightIrisCenter,
    required this.faceBounds,
    this.headEulerAngleX,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    this.leftEyeOpenProb,
    this.rightEyeOpenProb,
    required this.timestamp,
  });

  /// Convert eye landmarks to a flat list for ML model input
  /// Returns 32 floats:
  /// - left eye center (2), right eye center (2)
  /// - left eye contour (8 points = 16), right eye contour (8 points = 16 - simplified)
  /// - head angles (3)
  /// Total: 2 + 2 + 6 + 6 + 3 = 19 floats (we'll pad to 32)
  List<double> toModelInput() {
    final List<double> input = [];

    // Eye centers (4 values)
    input.add(leftEyeCenter.dx);
    input.add(leftEyeCenter.dy);
    input.add(rightEyeCenter.dx);
    input.add(rightEyeCenter.dy);

    // Simplified left eye contour - take 4 key points (8 values)
    final leftKeys = _getKeyPoints(leftEyeContour, 4);
    for (final p in leftKeys) {
      input.add(p.dx);
      input.add(p.dy);
    }

    // Simplified right eye contour - take 4 key points (8 values)
    final rightKeys = _getKeyPoints(rightEyeContour, 4);
    for (final p in rightKeys) {
      input.add(p.dx);
      input.add(p.dy);
    }

    // Head angles (3 values)
    input.add(headEulerAngleX ?? 0.0);
    input.add(headEulerAngleY ?? 0.0);
    input.add(headEulerAngleZ ?? 0.0);

    // Face bounds center (2 values)
    input.add(faceBounds.center.dx);
    input.add(faceBounds.center.dy);

    // Pad to 32 values
    while (input.length < 32) {
      input.add(0.0);
    }

    return input.sublist(0, 32);
  }

  List<Offset> _getKeyPoints(List<Offset> contour, int count) {
    if (contour.isEmpty) return List.filled(count, Offset.zero);
    if (contour.length <= count) {
      return [...contour, ...List.filled(count - contour.length, contour.last)];
    }
    final step = contour.length / count;
    return List.generate(count, (i) => contour[(i * step).floor()]);
  }

  Map<String, dynamic> toJson() => {
        'leftEyeCenter': {'x': leftEyeCenter.dx, 'y': leftEyeCenter.dy},
        'rightEyeCenter': {'x': rightEyeCenter.dx, 'y': rightEyeCenter.dy},
        'leftEyeContour':
            leftEyeContour.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        'rightEyeContour':
            rightEyeContour.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        'faceBounds': {
          'left': faceBounds.left,
          'top': faceBounds.top,
          'right': faceBounds.right,
          'bottom': faceBounds.bottom
        },
        'headEulerAngleX': headEulerAngleX,
        'headEulerAngleY': headEulerAngleY,
        'headEulerAngleZ': headEulerAngleZ,
        'timestamp': timestamp.toIso8601String(),
        'modelInput': toModelInput(),
      };
}

/// Callback for when eye landmarks are detected
typedef OnEyeLandmarksDetected = void Function(EyeLandmarks landmarks);

/// Callback for when gaze position is predicted
typedef OnGazePredicted = void Function(Offset gazePoint);

/// Main GazeTracker service
class GazeTracker {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isProcessing = false;
  bool _isInitialized = false;

  /// Debug counter for iris detection logging
  int _irisDebugCounter = 0;

  /// Stream controller for eye landmarks
  final _landmarksController = StreamController<EyeLandmarks>.broadcast();
  Stream<EyeLandmarks> get landmarksStream => _landmarksController.stream;

  /// Stream controller for gaze predictions
  final _gazeController = StreamController<Offset>.broadcast();
  Stream<Offset> get gazeStream => _gazeController.stream;

  /// Image size for normalization
  Size _imageSize = Size.zero;

  /// Get camera controller for preview
  CameraController? get cameraController => _cameraController;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the gaze tracker
  ///
  /// This sets up:
  /// 1. Front camera for face capture
  /// 2. ML Kit face detector with contour detection enabled
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Get available cameras
    final cameras = await availableCameras();

    // Find front camera
    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // Initialize camera controller
    // Using medium resolution for balance between speed and accuracy
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Required for ML Kit on Android
    );

    await _cameraController!.initialize();
    _imageSize = Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );

    // Initialize face detector with contours enabled
    // Contours give us detailed eye shape for better gaze estimation
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true, // Get eye contour points
        enableLandmarks: true, // Get eye center landmarks
        enableClassification: true, // Get eye open probability
        enableTracking: true, // Track face across frames
        performanceMode: FaceDetectorMode.fast, // Optimize for real-time
        minFaceSize: 0.15, // Minimum face size to detect
      ),
    );

    _isInitialized = true;
    debugPrint('GazeTracker initialized: image size $_imageSize');
  }

  /// Start processing camera frames for gaze detection
  Future<void> startTracking() async {
    if (!_isInitialized || _cameraController == null) {
      throw Exception('GazeTracker not initialized. Call initialize() first.');
    }

    // Start image stream
    await _cameraController!.startImageStream(_processImage);
    debugPrint('GazeTracker started tracking');
  }

  /// Stop processing camera frames
  Future<void> stopTracking() async {
    if (_cameraController?.value.isStreamingImages ?? false) {
      await _cameraController!.stopImageStream();
    }
    debugPrint('GazeTracker stopped tracking');
  }

  // Store latest camera image for pixel-based iris detection
  CameraImage? _latestImage;

  /// Process a camera image frame
  Future<void> _processImage(CameraImage image) async {
    // Skip if already processing (avoid backlog)
    if (_isProcessing || _faceDetector == null) return;
    _isProcessing = true;

    // Store for iris detection
    _latestImage = image;

    try {
      // Convert camera image to InputImage for ML Kit
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      // Detect faces
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        // Use the first (largest) face
        final face = faces.first;

        // Extract eye landmarks with pixel-based iris detection
        final landmarks = _extractEyeLandmarks(face, image);
        if (landmarks != null) {
          _landmarksController.add(landmarks);
        }
      } else {
        // No face detected - emit null to signal face lost
        _landmarksController.addError('no_face');
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }

    _isProcessing = false;
  }

  /// Convert CameraImage to InputImage for ML Kit
  InputImage? _convertCameraImage(CameraImage image) {
    // Get camera rotation
    final camera = _cameraController!.description;
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    // Get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    // Create InputImage from bytes
    final plane = image.planes.first;
    final bytes = plane.bytes;

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: plane.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  /// Extract eye landmarks from detected face
  /// Uses pixel-based iris detection from raw camera image
  EyeLandmarks? _extractEyeLandmarks(Face face, CameraImage image) {
    // Get eye contours
    final leftEyeContour = face.contours[FaceContourType.leftEye]?.points ?? [];
    final rightEyeContour =
        face.contours[FaceContourType.rightEye]?.points ?? [];

    if (leftEyeContour.isEmpty && rightEyeContour.isEmpty) {
      return null;
    }

    // Normalize points to 0-1 range
    List<Offset> normalizePoints(List<Point<int>> points) {
      return points
          .map((p) => Offset(
                p.x.toDouble() / _imageSize.width,
                p.y.toDouble() / _imageSize.height,
              ))
          .toList();
    }

    // Calculate eye center from contour
    Offset calculateCenter(List<Point<int>> points) {
      if (points.isEmpty) return Offset.zero;
      double sumX = 0, sumY = 0;
      for (final p in points) {
        sumX += p.x.toDouble();
        sumY += p.y.toDouble();
      }
      return Offset(
        (sumX / points.length) / _imageSize.width,
        (sumY / points.length) / _imageSize.height,
      );
    }

    /// PIXEL-BASED IRIS DETECTION
    ///
    /// The iris/pupil is the DARKEST part of the eye.
    /// By analyzing pixel brightness within the eye region,
    /// we can find the iris center position.
    ///
    /// Returns iris position relative to eye bounds (0-1 range)
    Offset? detectIrisFromPixels(List<Point<int>> eyeContour, CameraImage img) {
      if (eyeContour.isEmpty || eyeContour.length < 4) return null;

      // Get eye bounding box
      int minX = eyeContour[0].x, maxX = eyeContour[0].x;
      int minY = eyeContour[0].y, maxY = eyeContour[0].y;

      for (final p in eyeContour) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }

      final eyeWidth = maxX - minX;
      final eyeHeight = maxY - minY;

      if (eyeWidth < 10 || eyeHeight < 5) return null;

      // Crop to inner region of eye (avoid eyelids/corners)
      // IMPORTANT: Use LESS cropping on Y axis to capture more vertical movement
      // Horizontal: 20% margin each side (use middle 60%)
      // Vertical: 20% margin each side (use middle 60%) - reduced from 30%
      final cropMarginX = (eyeWidth * 0.2).toInt();
      final cropMarginY =
          (eyeHeight * 0.2).toInt(); // Reduced from 0.3 for better Y detection
      final cropMinX = minX + cropMarginX;
      final cropMaxX = maxX - cropMarginX;
      final cropMinY = minY + cropMarginY;
      final cropMaxY = maxY - cropMarginY;

      if (cropMaxX <= cropMinX || cropMaxY <= cropMinY) return null;

      // Get image dimensions
      final imgWidth = img.width;
      final imgHeight = img.height;

      // Ensure bounds are within image
      final safeMinX = cropMinX.clamp(0, imgWidth - 1);
      final safeMaxX = cropMaxX.clamp(0, imgWidth - 1);
      final safeMinY = cropMinY.clamp(0, imgHeight - 1);
      final safeMaxY = cropMaxY.clamp(0, imgHeight - 1);

      if (safeMaxX <= safeMinX || safeMaxY <= safeMinY) return null;

      // For YUV420 format (most common on Android), Y plane contains brightness
      // Lower Y value = darker pixel
      final yPlane = img.planes[0];
      final yBytes = yPlane.bytes;
      final yRowStride = yPlane.bytesPerRow;

      // Find the darkest region (iris/pupil)
      // Use a sliding window approach to find center of darkest area
      double darkestX = 0, darkestY = 0;
      int darkestSum = 255 * 9; // Start with max brightness
      int windowCount = 0;

      // Scan the eye region with a small window
      for (int y = safeMinY + 1; y < safeMaxY - 1; y++) {
        for (int x = safeMinX + 1; x < safeMaxX - 1; x++) {
          // Sum brightness of 3x3 window
          int windowSum = 0;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              final idx = (y + dy) * yRowStride + (x + dx);
              if (idx >= 0 && idx < yBytes.length) {
                windowSum += yBytes[idx];
              }
            }
          }

          // Track darkest window
          if (windowSum < darkestSum) {
            darkestSum = windowSum;
            darkestX = x.toDouble();
            darkestY = y.toDouble();
            windowCount = 1;
          } else if (windowSum == darkestSum) {
            // Average positions of equally dark windows
            darkestX = (darkestX * windowCount + x) / (windowCount + 1);
            darkestY = (darkestY * windowCount + y) / (windowCount + 1);
            windowCount++;
          }
        }
      }

      if (windowCount == 0) return null;

      // Convert to relative position within eye bounds (0-1)
      final relX = (darkestX - minX) / eyeWidth;
      final relY = (darkestY - minY) / eyeHeight;

      // IMPORTANT: Mirror X coordinate for front camera!
      // Front camera image is mirrored, so left in image = right in real world
      // When user looks LEFT, iris moves RIGHT in image, so we need to flip X
      final mirroredX = 1.0 - relX;

      // Debug: print brightness info occasionally
      _irisDebugCounter++;
      if (_irisDebugCounter % 60 == 0) {
        print(
            'IRIS DETECT: eyeW=${eyeWidth}, eyeH=${eyeHeight}, darkestBrightness=${(darkestSum / 9).toInt()}, '
            'rawX=${relX.toStringAsFixed(3)}, mirroredX=${mirroredX.toStringAsFixed(3)}, Y=${relY.toStringAsFixed(3)}');
      }

      return Offset(
        mirroredX.clamp(0.0, 1.0),
        relY.clamp(0.0, 1.0),
      );
    }

    // Get face bounding box normalized
    final bounds = face.boundingBox;
    final normalizedBounds = Rect.fromLTRB(
      bounds.left / _imageSize.width,
      bounds.top / _imageSize.height,
      bounds.right / _imageSize.width,
      bounds.bottom / _imageSize.height,
    );

    // Detect iris position from actual pixel brightness (darkest spot = pupil)
    // NOTE: ML Kit "leftEye" is from camera's perspective (mirrored)
    // So camera's "leftEye" = user's RIGHT eye, camera's "rightEye" = user's LEFT eye
    // We detect from camera perspective but swap for user perspective
    final cameraLeftIris = detectIrisFromPixels(leftEyeContour, image);
    final cameraRightIris = detectIrisFromPixels(rightEyeContour, image);

    // Debug: Log if iris detection is failing
    if (cameraLeftIris == null || cameraRightIris == null) {
      _irisDebugCounter++;
      if (_irisDebugCounter % 30 == 0) {
        print(
            'IRIS DETECT FAILED: leftIris=${cameraLeftIris != null}, rightIris=${cameraRightIris != null}');
        print('  leftEyeContour points: ${leftEyeContour.length}');
        print('  rightEyeContour points: ${rightEyeContour.length}');
      }
    }

    // Swap: user's left eye = camera's right eye (due to mirror)
    final userLeftIris = cameraRightIris;
    final userRightIris = cameraLeftIris;

    return EyeLandmarks(
      leftEyeContour: normalizePoints(leftEyeContour),
      rightEyeContour: normalizePoints(rightEyeContour),
      leftEyeCenter: calculateCenter(leftEyeContour),
      rightEyeCenter: calculateCenter(rightEyeContour),
      leftIrisCenter: userLeftIris, // User's left eye
      rightIrisCenter: userRightIris, // User's right eye
      faceBounds: normalizedBounds,
      headEulerAngleX: face.headEulerAngleX,
      headEulerAngleY: face.headEulerAngleY,
      headEulerAngleZ: face.headEulerAngleZ,
      leftEyeOpenProb: face.leftEyeOpenProbability,
      rightEyeOpenProb: face.rightEyeOpenProbability,
      timestamp: DateTime.now(),
    );
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopTracking();
    await _cameraController?.dispose();
    await _faceDetector?.close();
    await _landmarksController.close();
    await _gazeController.close();
    _isInitialized = false;
    debugPrint('GazeTracker disposed');
  }
}
