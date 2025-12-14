// tiny gaze calibration helper (no external imports required)

/// Lightweight gaze calibration helper.
/// Performs an affine fit mapping predicted gaze (x_pred,y_pred) to screen coords (x_true,y_true).
/// The affine model is: [x_true]   [a b c] [x_pred]
///                     [y_true] = [d e f] [y_pred]
///                                    [ 1    ]

class AffineCalibration {
  // coefficients in row-major: [a,b,c,d,e,f]
  final List<double> coeffs;
  AffineCalibration(this.coeffs);

  List<double> apply(double xPred, double yPred) {
    final a = coeffs[0], b = coeffs[1], c = coeffs[2];
    final d = coeffs[3], e = coeffs[4], f = coeffs[5];
    final x = a * xPred + b * yPred + c;
    final y = d * xPred + e * yPred + f;
    return [x.clamp(0.0, 1.0), y.clamp(0.0, 1.0)];
  }
}

class GazeCalibrator {
  AffineCalibration? _calib;

  void setCalibration(AffineCalibration c) {
    _calib = c;
  }

  AffineCalibration? get calibration => _calib;

  /// Fit affine mapping from lists of predicted -> true points.
  /// preds and trues are lists of [x,y] pairs (normalized 0..1).
  static AffineCalibration fitAffine(
      List<List<double>> preds, List<List<double>> trues) {
    assert(preds.length == trues.length && preds.length >= 3);
    final n = preds.length;
    // Build design matrix X (n x 3): [x_pred, y_pred, 1]
    // Solve for w_x in least squares: X w_x = x_true
    final xt = List.generate(n, (_) => 0.0);
    final yt = List.generate(n, (_) => 0.0);
    final X = List.generate(n, (_) => List.filled(3, 0.0));
    for (var i = 0; i < n; i++) {
      final px = preds[i][0];
      final py = preds[i][1];
      X[i][0] = px;
      X[i][1] = py;
      X[i][2] = 1.0;
      xt[i] = trues[i][0];
      yt[i] = trues[i][1];
    }
    // compute (X^T X) 3x3 and (X^T x_true) 3x1, then invert
    final XtX = List.generate(3, (_) => List.filled(3, 0.0));
    final Xtx = List.filled(3, 0.0);
    final Xty = List.filled(3, 0.0);
    for (var i = 0; i < n; i++) {
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          XtX[r][c] += X[i][r] * X[i][c];
        }
        Xtx[r] += X[i][r] * xt[i];
        Xty[r] += X[i][r] * yt[i];
      }
    }
    final inv = _invert3x3(XtX);
    final wx = List.filled(3, 0.0);
    final wy = List.filled(3, 0.0);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        wx[r] += inv[r][c] * Xtx[c];
        wy[r] += inv[r][c] * Xty[c];
      }
    }
    // coeffs: a,b,c,d,e,f
    return AffineCalibration([wx[0], wx[1], wx[2], wy[0], wy[1], wy[2]]);
  }

  // invert 3x3 matrix
  static List<List<double>> _invert3x3(List<List<double>> m) {
    final a = m[0][0], b = m[0][1], c = m[0][2];
    final d = m[1][0], e = m[1][1], f = m[1][2];
    final g = m[2][0], h = m[2][1], i = m[2][2];
    final A = e * i - f * h;
    final B = -(d * i - f * g);
    final C = d * h - e * g;
    final D = -(b * i - c * h);
    final E = a * i - c * g;
    final F = -(a * h - b * g);
    final G = b * f - c * e;
    final H = -(a * f - c * d);
    final I = a * e - b * d;
    final det = a * A + b * B + c * C;
    if (det.abs() < 1e-12) {
      // fallback to identity
      return [
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0]
      ];
    }
    final invDet = 1.0 / det;
    return [
      [A * invDet, D * invDet, G * invDet],
      [B * invDet, E * invDet, H * invDet],
      [C * invDet, F * invDet, I * invDet]
    ];
  }
}

// global simple calibrator instance used by the app
final GazeCalibrator appCalibrator = GazeCalibrator();
