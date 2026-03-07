import 'package:flutter/material.dart';

import '../games/butterfly_chase/butterfly_chase_screen.dart';
import '../tflite/gaze_model.dart';
import '../tflite/tflite_scaffold.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';


class CalibrationScreen extends StatefulWidget {
  final String testId;
  const CalibrationScreen({required this.testId, super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int step = 0;
  Map<String, dynamic> calib = {};
  final List<List<double>> _preds = [];
  final List<List<double>> _trues = [];
  final TFLiteScaffold _tflite = TFLiteScaffold();

  @override
  void initState() {
    super.initState();
    _tflite.loadModel();
  }

  void _next() async {
    final targets = [
      [0.1, 0.1],
      [0.9, 0.1],
      [0.5, 0.9]
    ];
    final tpos = targets[step % targets.length];
    final pred = await _tflite.predictGaze();
    _preds.add(pred);
    _trues.add([tpos[0], tpos[1]]);
    setState(() {
      step += 1;
    });
    if (step >= targets.length) {
      try {
        final calib = GazeCalibrator.fitAffine(_preds, _trues);
        appCalibrator.setCalibration(calib);
      } catch (e) {
        // ignore, use identity
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ButterflyChaseScreen(testId: widget.testId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dotPositions = [
      const Alignment(-0.8, -0.8),
      const Alignment(0.8, -0.8),
      const Alignment(0.0, 0.8),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.calibrationTitle ?? 'Calibration'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const LanguageSelector(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppLocalizations.of(context)?.lookAtTheDot ?? "Look at the dot"} ${step + 1}/3',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: dotPositions[step % dotPositions.length],
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: Text(step < 2 ? (AppLocalizations.of(context)?.nextButton ?? 'Next') : (AppLocalizations.of(context)?.startGames ?? 'Start Games')),
            ),
          ),
        ],
      ),
    );
  }
}
