import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:veilscan/features/scan/recognition/preprocess.dart';
import 'package:veilscan/features/scan/recognition/scan_logic.dart';

List<double> _scores(Map<int, double> set, int n) =>
    [for (var i = 0; i < n; i++) set[i] ?? 0.0];

void main() {
  const ids = ['a', 'b', 'c', 'd'];

  group('decideScan', () {
    test('confident upright', () {
      final d = decideScan(ids, _scores({1: 0.95}, 4), _scores({1: 0.02}, 4));
      expect(d, isA<ConfidentScan>());
      final g = (d as ConfidentScan).guess;
      expect(g.cardId, 'b');
      expect(g.reversed, isFalse);
    });

    test('confident reversed when the rotated pass wins', () {
      final d = decideScan(ids, _scores({2: 0.03}, 4), _scores({2: 0.92}, 4));
      final g = (d as ConfidentScan).guess;
      expect(g.cardId, 'c');
      expect(g.reversed, isTrue);
    });

    test('low score is uncertain with top 3', () {
      final d = decideScan(ids,
          _scores({0: 0.5, 1: 0.3, 2: 0.1}, 4), _scores({}, 4));
      expect(d, isA<UncertainScan>());
      expect((d as UncertainScan).topGuesses.map((g) => g.cardId),
          ['a', 'b', 'c']);
    });

    test('small lead over runner-up is uncertain', () {
      final d = decideScan(ids,
          _scores({0: 0.85, 1: 0.80}, 4), _scores({}, 4));
      expect(d, isA<UncertainScan>());
    });

    test('ambiguous orientation is uncertain', () {
      final d = decideScan(ids,
          _scores({0: 0.88}, 4), _scores({0: 0.80}, 4));
      expect(d, isA<UncertainScan>());
    });

    test('mismatched lengths throw', () {
      expect(() => decideScan(ids, [0.1], [0.1]), throwsArgumentError);
    });
  });

  group('guideCrop', () {
    test('portrait photo: 78% of height, card aspect, centred', () {
      final box = guideCrop(1000, 1000);
      expect(box.height, 780);
      expect(box.width, 468);
      expect(box.left, (1000 - 468) ~/ 2);
      expect(box.top, (1000 - 780) ~/ 2);
    });

    test('narrow photo is limited to 90% of width', () {
      final box = guideCrop(300, 1000);
      expect(box.width, 270);
      expect(box.height, 450);
    });
  });

  group('ScanSession', () {
    test('collects cards, rejects duplicates, completes', () {
      final s = ScanSession(2);
      expect(s.add('x', reversed: false), isTrue);
      expect(s.add('x', reversed: true), isFalse);
      expect(s.isComplete, isFalse);
      expect(s.add('y', reversed: true), isTrue);
      expect(s.isComplete, isTrue);
      expect(s.add('z', reversed: false), isFalse);
    });

    test('undo removes the last card', () {
      final s = ScanSession(3)
        ..add('x', reversed: false)
        ..add('y', reversed: false)
        ..undo();
      expect(s.cards.map((c) => c.cardId), ['x']);
      expect(s.nextIndex, 2);
    });
  });

  group('preprocessForModel', () {
    Uint8List photo() {
      final image = img.Image(width: 600, height: 800);
      for (final p in image) {
        p
          ..r = p.x % 256
          ..g = p.y % 256
          ..b = (p.x + p.y) % 256;
      }
      return Uint8List.fromList(img.encodeJpg(image));
    }

    test('produces model-sized tensors in 0..255', () {
      final input = preprocessForModel(photo());
      expect(input.upright.length, modelInputLength);
      expect(input.rotated.length, modelInputLength);
      expect(input.upright.every((v) => v >= 0 && v <= 255), isTrue);
    });

    test('rotated is an exact 180 degree turn of upright', () {
      final input = preprocessForModel(photo());
      final up = input.upright;
      final rot = input.rotated;
      const px = modelWidth * modelHeight;
      for (final i in [0, 1, 777, px - 2, px - 1]) {
        final j = px - 1 - i;
        expect(rot.sublist(i * 3, i * 3 + 3), up.sublist(j * 3, j * 3 + 3));
      }
      expect(rotate180(rot), up);
    });

    test('garbage bytes throw FormatException', () {
      expect(() => preprocessForModel(Uint8List.fromList([1, 2, 3])),
          throwsFormatException);
    });
  });
}
