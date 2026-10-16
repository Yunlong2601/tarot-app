import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'preprocess.dart';

const modelAsset = 'assets/models/tarot_classifier.tflite';

/// Probability that the card is upright / reversed, each in cards.json order.
class RecognizerScores {
  const RecognizerScores(this.upright, this.reversed);
  final List<double> upright;
  final List<double> reversed;
}

abstract class CardRecognizer {
  Future<RecognizerScores> recognize(ModelInput input);
  void close();
}

/// Loads `assets/models/tarot_classifier.tflite`. Contract (docs/phase-c-design.md):
/// input float32 [1,320,224,3] RGB 0..255, output softmax over 2 x [classCount]
/// (first half: card upright, second half: card reversed).
/// Returns null when the model is missing or has the wrong shape, so the UI
/// can fall back to the manual picker.
///
/// NOT yet verified on a real iOS or Android device, and no trained model
/// exists yet.
class TfliteRecognizer implements CardRecognizer {
  TfliteRecognizer._(this._interpreter, this._classCount);

  final Interpreter _interpreter;
  final int _classCount;

  static Future<TfliteRecognizer?> load({required int classCount}) async {
    try {
      final interpreter = await Interpreter.fromAsset(modelAsset);
      final inShape = interpreter.getInputTensor(0).shape;
      final outShape = interpreter.getOutputTensor(0).shape;
      final ok =
          listEquals(inShape, [1, modelHeight, modelWidth, modelChannels]) &&
          listEquals(outShape, [1, classCount * 2]);
      if (!ok) {
        interpreter.close();
        return null;
      }
      return TfliteRecognizer._(interpreter, classCount);
    } catch (_) {
      return null;
    }
  }

  List<double> _run(Float32List input) {
    final output = List.filled(
      _classCount * 2,
      0.0,
    ).reshape([1, _classCount * 2]);
    _interpreter.run(
      input.reshape([1, modelHeight, modelWidth, modelChannels]),
      output,
    );
    return List<double>.from(output.first as List);
  }

  @override
  Future<RecognizerScores> recognize(ModelInput input) async {
    final all = _run(input.tensor);
    return RecognizerScores(
      all.sublist(0, _classCount),
      all.sublist(_classCount),
    );
  }

  @override
  void close() => _interpreter.close();
}
