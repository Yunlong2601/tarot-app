import 'spreads.dart';

export 'spreads.dart';

enum Arcana { major, minor }

enum Suit { wands, cups, swords, pentacles }

/// Richer, original card knowledge (assets/cards/knowledge.json). Available for
/// the 22 Major Arcana so far; other cards fall back to the short meanings.
class CardKnowledge {
  const CardKnowledge({
    required this.essence,
    required this.imagery,
    required this.why,
    required this.uprightCore,
    required this.light,
    required this.shadow,
    required this.uprightQuestion,
    required this.reversedCore,
    required this.modes,
    required this.reversedQuestion,
  });

  factory CardKnowledge.fromJson(Map<String, dynamic> j) {
    final up = j['upright'] as Map<String, dynamic>;
    final rev = j['reversed'] as Map<String, dynamic>;
    return CardKnowledge(
      essence: j['essence'] as String,
      imagery: j['imagery'] as String,
      why: j['why'] as String,
      uprightCore: up['core'] as String,
      light: up['light'] as String,
      shadow: up['shadow'] as String,
      uprightQuestion: up['question'] as String,
      reversedCore: rev['core'] as String,
      modes: List<String>.from(rev['modes'] as List),
      reversedQuestion: rev['question'] as String,
    );
  }

  final String essence;
  final String imagery;
  final String why;
  final String uprightCore;
  final String light;
  final String shadow;
  final String uprightQuestion;
  final String reversedCore;
  final List<String> modes;
  final String reversedQuestion;
}

class TarotCard {
  const TarotCard({
    required this.id,
    required this.name,
    required this.arcana,
    required this.keywords,
    required this.upright,
    required this.reversed,
    this.suit,
    this.number,
    this.element,
    this.association,
    this.knowledge,
  });

  factory TarotCard.fromJson(
    Map<String, dynamic> j, [
    CardKnowledge? knowledge,
  ]) => TarotCard(
    knowledge: knowledge,
    id: j['id'] as String,
    name: j['name'] as String,
    arcana: Arcana.values.byName(j['arcana'] as String),
    suit: j['suit'] == null ? null : Suit.values.byName(j['suit'] as String),
    number: j['number'] as int?,
    element: j['element'] as String?,
    association: j['association'] as String?,
    keywords: List<String>.from(j['keywords'] as List),
    upright: j['upright'] as String,
    reversed: j['reversed'] as String,
  );

  final String id;
  final String name;
  final Arcana arcana;
  final Suit? suit;
  final int? number;
  final String? element;

  /// Traditional astrological/elemental association (Major Arcana only).
  final String? association;
  final List<String> keywords;
  final String upright;
  final String reversed;

  /// Richer knowledge when written (Major Arcana first); null otherwise.
  final CardKnowledge? knowledge;

  /// Bundled art path. May be missing until public-domain art is added.
  String get artAsset => 'assets/cards/art/$id.jpg';
}

class DrawnCard {
  const DrawnCard({required this.card, required this.reversed});
  final TarotCard card;
  final bool reversed;
}

class Reading {
  const Reading({
    required this.id,
    required this.createdAt,
    required this.spread,
    required this.cards,
    required this.interpretation,
    this.question,
    this.note,
  });

  final String id;
  final DateTime createdAt;
  final SpreadType spread;
  final List<DrawnCard> cards;
  final String interpretation;
  final String? question;

  /// The user's own journal note about this reading (Premium).
  final String? note;

  Reading withNote(String? note) => Reading(
    id: id,
    createdAt: createdAt,
    spread: spread,
    cards: cards,
    interpretation: interpretation,
    question: question,
    note: note == null || note.trim().isEmpty ? null : note.trim(),
  );
}
