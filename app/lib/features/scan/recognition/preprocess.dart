import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'scan_logic.dart';

const modelWidth = 224;
const modelHeight = 320;
const modelChannels = 3;
const modelInputLength = modelWidth * modelHeight * modelChannels;

/// The model input: the guide crop, NHWC, RGB, values 0..255 (float32),
/// flattened. (Reversed cards are recognised by the model itself.)
class ModelInput {
  const ModelInput(this.tensor);
  final Float32List tensor;
}

/// Decodes, crops to the guide frame and resizes. Heavy; call
/// [preprocessOffUi] from the UI isolate.
ModelInput preprocessForModel(Uint8List jpegBytes) {
  final decoded = img.decodeImage(jpegBytes);
  if (decoded == null) throw const FormatException('Could not decode photo');
  final photo = img.bakeOrientation(decoded);
  final box = guideCrop(photo.width, photo.height);
  final cropped = img.copyCrop(
    photo,
    x: box.left,
    y: box.top,
    width: box.width,
    height: box.height,
  );
  final resized = img.copyResize(
    cropped,
    width: modelWidth,
    height: modelHeight,
    interpolation: img.Interpolation.average,
  );

  final tensor = Float32List(modelInputLength);
  var o = 0;
  for (final p in resized) {
    tensor[o++] = p.r.toDouble();
    tensor[o++] = p.g.toDouble();
    tensor[o++] = p.b.toDouble();
  }
  return ModelInput(tensor);
}

Future<ModelInput> preprocessOffUi(Uint8List jpegBytes) =>
    Isolate.run(() => preprocessForModel(jpegBytes));
