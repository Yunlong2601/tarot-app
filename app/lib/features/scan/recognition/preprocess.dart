import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'scan_logic.dart';

const modelWidth = 224;
const modelHeight = 320;
const modelChannels = 3;
const modelInputLength = modelWidth * modelHeight * modelChannels;

/// The two model inputs: the guide crop and the same crop turned 180 degrees.
/// Layout is NHWC, RGB, values 0..255 (float32), flattened.
class ModelInput {
  const ModelInput(this.upright, this.rotated);
  final Float32List upright;
  final Float32List rotated;
}

/// Decodes, crops to the guide frame and resizes. Heavy; call
/// [preprocessOffUi] from the UI isolate.
ModelInput preprocessForModel(Uint8List jpegBytes) {
  final decoded = img.decodeImage(jpegBytes);
  if (decoded == null) throw const FormatException('Could not decode photo');
  final photo = img.bakeOrientation(decoded);
  final box = guideCrop(photo.width, photo.height);
  final cropped = img.copyCrop(photo,
      x: box.left, y: box.top, width: box.width, height: box.height);
  final resized = img.copyResize(cropped,
      width: modelWidth,
      height: modelHeight,
      interpolation: img.Interpolation.average);

  final upright = Float32List(modelInputLength);
  var o = 0;
  for (final p in resized) {
    upright[o++] = p.r.toDouble();
    upright[o++] = p.g.toDouble();
    upright[o++] = p.b.toDouble();
  }
  return ModelInput(upright, rotate180(upright));
}

/// Exact 180 degree turn of an NHWC tensor: pixel order reversed, channels
/// kept in RGB order.
Float32List rotate180(Float32List input) {
  final out = Float32List(input.length);
  final pixels = input.length ~/ modelChannels;
  for (var i = 0; i < pixels; i++) {
    final src = (pixels - 1 - i) * modelChannels;
    final dst = i * modelChannels;
    out[dst] = input[src];
    out[dst + 1] = input[src + 1];
    out[dst + 2] = input[src + 2];
  }
  return out;
}

Future<ModelInput> preprocessOffUi(Uint8List jpegBytes) =>
    Isolate.run(() => preprocessForModel(jpegBytes));
