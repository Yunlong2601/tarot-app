import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

enum CardFilter { all, major, wands, cups, swords, pentacles }

extension CardFilterLabel on CardFilter {
  String get label => switch (this) {
    CardFilter.all => 'All',
    CardFilter.major => 'Major',
    CardFilter.wands => 'Wands',
    CardFilter.cups => 'Cups',
    CardFilter.swords => 'Swords',
    CardFilter.pentacles => 'Pentacles',
  };

  bool matches(TarotCard c) => switch (this) {
    CardFilter.all => true,
    CardFilter.major => c.arcana == Arcana.major,
    CardFilter.wands => c.suit == Suit.wands,
    CardFilter.cups => c.suit == Suit.cups,
    CardFilter.swords => c.suit == Suit.swords,
    CardFilter.pentacles => c.suit == Suit.pentacles,
  };
}

/// The 78-card Rider-Waite-Smith deck, loaded once from `cards.json`.
class Deck {
  Deck(this.cards) : _byId = {for (final c in cards) c.id: c};

  static const assetPath = 'assets/cards/cards.json';
  static const expectedSize = 78;

  factory Deck.fromJsonString(String source) {
    final root = jsonDecode(source) as Map<String, dynamic>;
    final cards = [
      for (final j in root['cards'] as List)
        TarotCard.fromJson(j as Map<String, dynamic>),
    ];
    if (cards.length != expectedSize) {
      throw FormatException(
        'Expected $expectedSize cards, got ${cards.length}',
      );
    }
    return Deck(cards);
  }

  static Future<Deck> load([AssetBundle? bundle]) async =>
      Deck.fromJsonString(await (bundle ?? rootBundle).loadString(assetPath));

  final List<TarotCard> cards;
  final Map<String, TarotCard> _byId;

  TarotCard? byId(String id) => _byId[id];

  /// Case-insensitive match on name or keyword, within [filter].
  List<TarotCard> search(String query, {CardFilter filter = CardFilter.all}) {
    final q = query.trim().toLowerCase();
    return [
      for (final c in cards)
        if (filter.matches(c) &&
            (q.isEmpty ||
                c.name.toLowerCase().contains(q) ||
                c.keywords.any((k) => k.toLowerCase().contains(q))))
          c,
    ];
  }
}
