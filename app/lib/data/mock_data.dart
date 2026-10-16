import 'deck.dart';
import 'models.dart';

const mockInterpretation =
    'This is a placeholder reading. In Phase D the app sends your cards and '
    'question to a secure backend, which returns a reflective interpretation. '
    'For entertainment and self-reflection only.';

/// Phase A/B mock history built from the real deck.
List<Reading> buildMockHistory(Deck deck) {
  TarotCard c(String id) => deck.byId(id)!;
  return [
    Reading(
      id: 'r1',
      createdAt: DateTime(2026, 10, 14, 8, 30),
      spread: SpreadType.single,
      cards: [DrawnCard(card: c('major_17_star'), reversed: false)],
      interpretation: mockInterpretation,
      question: 'What should I focus on this week?',
    ),
    Reading(
      id: 'r2',
      createdAt: DateTime(2026, 10, 12, 21, 5),
      spread: SpreadType.threeCard,
      cards: [
        DrawnCard(card: c('major_00_fool'), reversed: false),
        DrawnCard(card: c('swords_ten'), reversed: true),
        DrawnCard(card: c('cups_ace'), reversed: false),
      ],
      interpretation: mockInterpretation,
    ),
  ];
}
