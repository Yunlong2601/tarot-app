enum Arcana { major, minor }

enum Suit { wands, cups, swords, pentacles }

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
  });

  factory TarotCard.fromJson(Map<String, dynamic> j) => TarotCard(
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

  /// Bundled art path. May be missing until public-domain art is added.
  String get artAsset => 'assets/cards/art/$id.jpg';
}

enum SpreadType { single, threeCard, celticCross }

extension SpreadTypeInfo on SpreadType {
  String get label => switch (this) {
        SpreadType.single => 'Single card',
        SpreadType.threeCard => 'Three cards',
        SpreadType.celticCross => 'Celtic Cross',
      };
  int get cardCount => switch (this) {
        SpreadType.single => 1,
        SpreadType.threeCard => 3,
        SpreadType.celticCross => 10,
      };
  bool get isPremium => this != SpreadType.single;
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
