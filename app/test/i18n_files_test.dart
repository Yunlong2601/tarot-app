import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/app/i18n.dart';

/// Every language file covers the same texts, with the same placeholders.
void main() {
  Map<String, String> load(String code) =>
      (jsonDecode(File('assets/i18n/$code.json').readAsStringSync())
              as Map<String, dynamic>)
          .cast<String, String>();

  final codes = I18n.languages.keys.where((c) => c != 'en').toList();
  final reference = load(codes.first);
  final placeholder = RegExp(r'\{\d\}');
  List<String> slots(String s) =>
      placeholder.allMatches(s).map((m) => m[0]!).toList()..sort();

  for (final code in codes) {
    test('$code has every text and its placeholders', () {
      final strings = load(code);
      expect(strings.keys.toSet(), reference.keys.toSet());
      for (final e in strings.entries) {
        expect(e.value.trim(), isNotEmpty, reason: e.key);
        expect(slots(e.value), slots(e.key), reason: e.key);
      }
    });
  }
}
