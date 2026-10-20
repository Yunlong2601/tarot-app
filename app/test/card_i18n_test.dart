import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/i18n.dart';
import 'package:shentarot/data/deck.dart';

void main() {
  final deck = Deck.fromJsonString(
    File(Deck.assetPath).readAsStringSync(),
    File(Deck.knowledgePath).readAsStringSync(),
  );
  final fool = deck.byId('major_00_fool')!;

  tearDown(() => I18n.setForTest('en', const {}));

  test('English shows the deck text and the long card pages', () {
    I18n.setForTest('en', const {});
    expect(fool.name, 'The Fool');
    expect(fool.knowledge, isNotNull);
  });

  test('another language shows translated text, English as fallback', () {
    I18n.setForTest('ja', const {}, {
      'major_00_fool': {
        'name': '愚者',
        'keywords': ['始まり', '自由さ', '信頼'],
        'upright': 'U',
        'reversed': 'R',
      },
    });
    expect(fool.name, '愚者');
    expect(fool.englishName, 'The Fool');
    expect(fool.keywords.first, '始まり');
    expect(fool.upright, 'U');
    // The long pages are English-only, so they are hidden.
    expect(fool.knowledge, isNull);
    // Untranslated cards fall back to English; search finds both names.
    expect(deck.byId('major_01_magician')!.name, 'The Magician');
    expect(deck.search('愚者').single.id, 'major_00_fool');
    expect(deck.search('fool').single.id, 'major_00_fool');
  });
}
