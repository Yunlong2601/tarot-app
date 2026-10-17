import 'dart:ui' show Offset;

/// The spread catalog. Keep in sync with backend/src/spreads.ts (same wire ids
/// and position labels). Positions are about the reader's own situation, never
/// about what another person thinks or feels.
enum SpreadCategory { classics, love, career, growth }

extension SpreadCategoryLabel on SpreadCategory {
  String get label => switch (this) {
    SpreadCategory.love => 'Love',
    SpreadCategory.career => 'Career',
    SpreadCategory.growth => 'Growth',
    SpreadCategory.classics => 'Classics',
  };
}

/// Names of the first three values are stored in saved readings: do not rename.
enum SpreadType {
  single,
  threeCard,
  threeDecision,
  fiveCross,
  horseshoe,
  celticCross,
  loveConnection,
  loveBring,
  loveReconnect,
  loveReady,
  careerPath,
  careerStrengths,
  threeHhh,
  growthShadowLight,
}

class SpreadDef {
  const SpreadDef({
    required this.wire,
    required this.name,
    required this.category,
    required this.blurb,
    required this.positions,
    required this.layout,
  });

  final String wire;
  final String name;
  final SpreadCategory category;

  /// One line: the question this spread helps with.
  final String blurb;
  final List<String> positions;

  /// Where each position sits, in a 0..1 box (x right, y down).
  final List<Offset> layout;
}

const _row3 = [Offset(0.18, 0.5), Offset(0.5, 0.5), Offset(0.82, 0.5)];
const _cross5 = [
  Offset(0.16, 0.5),
  Offset(0.5, 0.5),
  Offset(0.84, 0.5),
  Offset(0.5, 0.12),
  Offset(0.5, 0.88),
];
const _arc7 = [
  Offset(0.08, 0.88),
  Offset(0.22, 0.56),
  Offset(0.36, 0.28),
  Offset(0.5, 0.12),
  Offset(0.64, 0.28),
  Offset(0.78, 0.56),
  Offset(0.92, 0.88),
];
const _celtic10 = [
  Offset(0.24, 0.5),
  Offset(0.24, 0.5),
  Offset(0.24, 0.86),
  Offset(0.06, 0.5),
  Offset(0.24, 0.14),
  Offset(0.42, 0.5),
  Offset(0.8, 0.88),
  Offset(0.8, 0.63),
  Offset(0.8, 0.38),
  Offset(0.8, 0.13),
];

const spreadDefs = <SpreadType, SpreadDef>{
  SpreadType.single: SpreadDef(
    wire: 'single',
    name: 'One-Card Reading',
    category: SpreadCategory.classics,
    blurb: 'One clearly framed question; a single theme to notice.',
    positions: ['The card'],
    layout: [Offset(0.5, 0.5)],
  ),
  SpreadType.threeCard: SpreadDef(
    wire: 'three',
    name: 'Past, Present, Future',
    category: SpreadCategory.classics,
    blurb: 'A concise story of how a situation developed.',
    positions: ['Where it began', 'Where it stands', 'Where it is heading'],
    layout: _row3,
  ),
  SpreadType.threeDecision: SpreadDef(
    wire: 'three_decision',
    name: 'Situation, Challenge, Way Forward',
    category: SpreadCategory.classics,
    blurb: 'Framing a decision: what is going on and how to move.',
    positions: ['The situation', 'The challenge', 'A way forward'],
    layout: _row3,
  ),
  SpreadType.fiveCross: SpreadDef(
    wire: 'five_cross',
    name: 'Five-Card Cross',
    category: SpreadCategory.classics,
    blurb: 'One clearly stated matter, seen from five sides.',
    positions: [
      'What is behind it',
      'The matter itself',
      'What is ahead',
      'What I am reaching for',
      'What grounds me',
    ],
    layout: _cross5,
  ),
  SpreadType.horseshoe: SpreadDef(
    wire: 'horseshoe',
    name: 'Seven-Card Horseshoe',
    category: SpreadCategory.classics,
    blurb: 'A focused situation with several interacting influences.',
    positions: [
      'Past',
      'Present',
      'Hidden influences',
      'Obstacles',
      'Influences around me',
      'Advice',
      'Direction if the pattern continues',
    ],
    layout: _arc7,
  ),
  SpreadType.celticCross: SpreadDef(
    wire: 'celtic',
    name: 'Celtic Cross',
    category: SpreadCategory.classics,
    blurb: 'A complex situation that needs a full map of influences.',
    positions: [
      'The heart of it',
      'What crosses it',
      'Foundation',
      'Recent past',
      'Aim',
      'Near horizon',
      'You',
      'Surroundings',
      'Hopes and fears',
      'Direction',
    ],
    layout: _celtic10,
  ),
  SpreadType.loveConnection: SpreadDef(
    wire: 'love_connection',
    name: 'Love & Relationship',
    category: SpreadCategory.love,
    blurb: 'What is my part in this relationship right now?',
    positions: ['What I bring', 'The connection itself', 'What it asks of me'],
    layout: _row3,
  ),
  SpreadType.loveBring: SpreadDef(
    wire: 'love_bring',
    name: 'What I Bring to This Connection',
    category: SpreadCategory.love,
    blurb: 'What am I bringing into this connection?',
    positions: ['What I bring', 'What I need', 'What I may be avoiding'],
    layout: _row3,
  ),
  SpreadType.loveReconnect: SpreadDef(
    wire: 'love_reconnect',
    name: 'Healing & Reconnection',
    category: SpreadCategory.love,
    blurb: 'What would need to change in me before healthy reconnection?',
    positions: [
      'What ended',
      'What I am still carrying',
      'What I need to understand',
      'What I can change',
      'What is outside my control',
      'What healing could look like',
      'A next step for me',
    ],
    layout: _arc7,
  ),
  SpreadType.loveReady: SpreadDef(
    wire: 'love_ready',
    name: 'Single & New Love',
    category: SpreadCategory.love,
    blurb: 'Am I genuinely ready for a new relationship?',
    positions: [
      'How I feel about love now',
      'What I carry from the past',
      'What I truly want',
      'What may be holding me back',
      'What I can offer',
      'What openness would look like',
      'A step toward it',
    ],
    layout: _arc7,
  ),
  SpreadType.careerPath: SpreadDef(
    wire: 'career_path',
    name: 'Career Path',
    category: SpreadCategory.career,
    blurb: 'Where am I in my work, and what could I explore next?',
    positions: ['Where I am', 'What holds me back', 'What to explore next'],
    layout: _row3,
  ),
  SpreadType.careerStrengths: SpreadDef(
    wire: 'career_strengths',
    name: 'Strengths & Growth',
    category: SpreadCategory.career,
    blurb: 'What are my strengths at work, and what can I develop?',
    positions: [
      'My strength',
      'My challenge',
      'What I can learn',
      'What supports me',
      'A next step',
    ],
    layout: _cross5,
  ),
  SpreadType.threeHhh: SpreadDef(
    wire: 'three_hhh',
    name: 'Head, Heart, Hands',
    category: SpreadCategory.growth,
    blurb: 'What do I think, what do I feel, what will I do?',
    positions: ['What I think', 'What I feel', 'What I will do'],
    layout: _row3,
  ),
  SpreadType.growthShadowLight: SpreadDef(
    wire: 'growth_shadow_light',
    name: 'Shadow & Light',
    category: SpreadCategory.growth,
    blurb: 'A strength, a hidden side, and how to bring them together.',
    positions: ['My light', 'My shadow', 'Bringing them together'],
    layout: _row3,
  ),
};

extension SpreadInfo on SpreadType {
  SpreadDef get def => spreadDefs[this]!;
  String get label => def.name;
  String get wire => def.wire;
  SpreadCategory get category => def.category;
  List<String> get positions => def.positions;
  int get cardCount => def.positions.length;

  /// Spreads of up to 3 cards are free within the daily reading limit; the 5,
  /// 7 and 10-card spreads are Premium, with one free trial reading (owner
  /// decision 2026-10-17). Keep in step with `isFreeSpread` in the backend.
  bool get isFree => cardCount <= 3;
  bool get isPremium => !isFree;
}

/// Spreads in the order shown in the picker, with [recommended] first.
List<SpreadType> spreadsFor(String question) {
  final rec = recommendSpread(question);
  return [rec, ...SpreadType.values.where((s) => s != rec)];
}

/// Picks a spread from a question's wording. A guess, never a rule.
SpreadType recommendSpread(String question) {
  final q = question.toLowerCase();
  bool any(List<String> words) => words.any(q.contains);
  if (any([
    'ex ',
    ' ex',
    'reconcil',
    'get back together',
    'come back',
    'heal',
    'breakup',
    'broke up',
  ])) {
    return SpreadType.loveReconnect;
  }
  if (any(['single', 'dating', 'new love', 'meet someone'])) {
    return SpreadType.loveReady;
  }
  if (any([
    'love',
    'relationship',
    'partner',
    'boyfriend',
    'girlfriend',
    'marriage',
    'crush',
  ])) {
    return SpreadType.loveConnection;
  }
  if (any(['job', 'career', 'work', 'boss', 'promotion', 'study', 'school'])) {
    return SpreadType.careerPath;
  }
  if (any(['decide', 'decision', 'choose', 'choice', 'option', 'whether'])) {
    return SpreadType.threeDecision;
  }
  if (any(['feel', 'anxious', 'stuck', 'confus', 'myself', 'growth'])) {
    return SpreadType.threeHhh;
  }
  return SpreadType.threeCard;
}
