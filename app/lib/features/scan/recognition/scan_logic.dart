import 'dart:math' as math;

/// Thresholds for deciding whether a scan is confident enough to propose
/// directly. Starting values from docs/phase-c-design.md; tune on held-out
/// photos.
class ScanPolicy {
  const ScanPolicy({
    this.minScore = 0.80,
    this.minLead = 0.25,
    this.minOrientationGap = 0.20,
  });

  final double minScore;
  final double minLead;
  final double minOrientationGap;
}

class CardGuess {
  const CardGuess({
    required this.cardId,
    required this.score,
    required this.reversed,
  });

  final String cardId;
  final double score;
  final bool reversed;
}

sealed class ScanDecision {
  const ScanDecision();
}

/// Confident enough to propose; the user is still asked to confirm.
class ConfidentScan extends ScanDecision {
  const ConfidentScan(this.guess);
  final CardGuess guess;
}

/// Not sure: show the top guesses and the manual picker.
class UncertainScan extends ScanDecision {
  const UncertainScan(this.topGuesses);
  final List<CardGuess> topGuesses;
}

/// [uprightScores] and [rotatedScores] are softmax outputs for the crop and
/// the crop turned 180 degrees, both in [cardIds] order. Per card the better
/// pass wins; the card is reversed if the rotated pass won.
ScanDecision decideScan(
  List<String> cardIds,
  List<double> uprightScores,
  List<double> rotatedScores, [
  ScanPolicy policy = const ScanPolicy(),
]) {
  if (cardIds.length != uprightScores.length ||
      cardIds.length != rotatedScores.length) {
    throw ArgumentError('score lists must match cardIds length');
  }
  if (cardIds.isEmpty) return const UncertainScan([]);

  final guesses = <CardGuess>[
    for (var i = 0; i < cardIds.length; i++)
      CardGuess(
        cardId: cardIds[i],
        score: math.max(uprightScores[i], rotatedScores[i]),
        reversed: rotatedScores[i] > uprightScores[i],
      ),
  ]..sort((a, b) => b.score.compareTo(a.score));

  final top3 = guesses.take(3).toList();
  final best = guesses.first;
  final lead = guesses.length > 1 ? best.score - guesses[1].score : best.score;
  final i = cardIds.indexOf(best.cardId);
  final gap = (uprightScores[i] - rotatedScores[i]).abs();

  if (best.score >= policy.minScore &&
      lead >= policy.minLead &&
      gap >= policy.minOrientationGap) {
    return ConfidentScan(best);
  }
  return UncertainScan(top3);
}

/// Pixel rectangle of the on-screen guide frame, in photo coordinates.
class CropBox {
  const CropBox(this.left, this.top, this.width, this.height);
  final int left;
  final int top;
  final int width;
  final int height;

  @override
  bool operator ==(Object other) =>
      other is CropBox &&
      other.left == left &&
      other.top == top &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(left, top, width, height);

  @override
  String toString() => 'CropBox($left, $top, $width, $height)';
}

/// Card-shaped box (width/height = [aspect]) centred in the photo, up to 78%
/// of the height and 90% of the width. The preview overlay draws the same
/// rectangle as fractions, so what the user lines up is what the model sees.
CropBox guideCrop(int width, int height, {double aspect = 0.6}) {
  var h = height * 0.78;
  var w = h * aspect;
  if (w > width * 0.9) {
    w = width * 0.9;
    h = w / aspect;
  }
  final cw = w.round();
  final ch = h.round();
  return CropBox((width - cw) ~/ 2, (height - ch) ~/ 2, cw, ch);
}

/// Cards collected for one reading. A physical deck has no duplicates, so a
/// repeat is rejected.
class ScanSession {
  ScanSession(this.count) : assert(count > 0);

  final int count;
  final List<({String cardId, bool reversed})> _cards = [];

  List<({String cardId, bool reversed})> get cards => List.unmodifiable(_cards);
  bool get isComplete => _cards.length >= count;
  int get nextIndex => _cards.length + 1;

  /// Returns false (and adds nothing) if the card is already scanned or the
  /// session is full.
  bool add(String cardId, {required bool reversed}) {
    if (isComplete || _cards.any((c) => c.cardId == cardId)) return false;
    _cards.add((cardId: cardId, reversed: reversed));
    return true;
  }

  /// "Not this card": drop the last one.
  void undo() {
    if (_cards.isNotEmpty) _cards.removeLast();
  }
}
