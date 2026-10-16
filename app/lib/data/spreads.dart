import 'models.dart';

/// Position labels per spread; keep in sync with backend/src/knowledge.ts.
const spreadPositions = <SpreadType, List<String>>{
  SpreadType.single: ['The card'],
  SpreadType.threeCard: [
    'Where it began',
    'Where it stands',
    'Where it is heading',
  ],
  SpreadType.celticCross: [
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
};
