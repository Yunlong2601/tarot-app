import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// App translations, gettext style: the English text is the key, so English
/// needs no file and a missing translation falls back to English.
/// Files: `assets/i18n/<code>.json` = {"English text": "translation", ...}.
/// Placeholders are `{0}`, `{1}`, ... filled from [tr]'s `args`.
class I18n {
  I18n._();

  /// Codes match the asset file names. Order is the order in Settings.
  static const languages = <String, String>{
    'en': 'English',
    'zh_Hans': '简体中文',
    'zh_Hant': '繁體中文',
    'ja': '日本語',
    'ko': '한국어',
    'es': 'Español',
    'pt': 'Português',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'id': 'Bahasa Indonesia',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'ar': 'العربية',
  };

  /// English name sent to the server so the AI writes in this language.
  static const englishNames = <String, String>{
    'en': 'English',
    'zh_Hans': 'Simplified Chinese',
    'zh_Hant': 'Traditional Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'es': 'Spanish',
    'pt': 'Portuguese',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'ru': 'Russian',
    'tr': 'Turkish',
    'id': 'Indonesian',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'ar': 'Arabic',
  };

  static String _code = 'en';

  /// Changes when the language changes; the app rebuilds on it.
  static final ValueNotifier<String> current = ValueNotifier('en');
  static Map<String, String> _strings = const {};
  static Map<String, dynamic> _cards = const {};

  static String get code => _code;

  static Locale get locale => localeFor(_code);

  static Locale localeFor(String code) => switch (code) {
    'zh_Hans' => const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
    ),
    'zh_Hant' => const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
    ),
    _ => Locale(code),
  };

  static List<Locale> get supportedLocales => [
    for (final c in languages.keys) localeFor(c),
  ];

  /// Best supported language for the phone's locale.
  static String codeForDevice(Locale l) {
    if (l.languageCode == 'zh') {
      final hant =
          l.scriptCode == 'Hant' ||
          const {'TW', 'HK', 'MO'}.contains(l.countryCode);
      return hant ? 'zh_Hant' : 'zh_Hans';
    }
    return languages.containsKey(l.languageCode) ? l.languageCode : 'en';
  }

  /// Loads a language. Unknown codes and missing files fall back to English.
  static Future<void> load(String code) async {
    if (!languages.containsKey(code) || code == 'en') {
      _code = 'en';
      _strings = const {};
      _cards = const {};
      current.value = _code;
      return;
    }
    try {
      final raw = await rootBundle.loadString('assets/i18n/$code.json');
      _strings = (jsonDecode(raw) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as String),
      );
      _code = code;
    } catch (_) {
      _code = 'en';
      _strings = const {};
    }
    try {
      _cards = _code == 'en'
          ? const {}
          : jsonDecode(
              await rootBundle.loadString('assets/i18n/cards/$_code.json'),
            ) as Map<String, dynamic>;
    } catch (_) {
      _cards = const {};
    }
    current.value = _code;
  }

  /// For tests.
  static void setForTest(
    String code,
    Map<String, String> strings, [
    Map<String, dynamic> cards = const {},
  ]) {
    _code = code;
    _strings = strings;
    _cards = cards;
  }

  /// A translated card field ('name', 'upright', 'reversed'), or null.
  static String? cardText(String id, String field) {
    final c = _cards[id];
    return c is Map ? c[field] as String? : null;
  }

  /// Translated card keywords, or null.
  static List<String>? cardKeywords(String id) {
    final c = _cards[id];
    final k = c is Map ? c['keywords'] : null;
    return k is List ? k.cast<String>() : null;
  }

  static String translate(String english, [List<Object?> args = const []]) {
    var s = _strings[english];
    if (s == null || s.isEmpty) s = english;
    for (var i = 0; i < args.length; i++) {
      s = s!.replaceAll('{$i}', '${args[i]}');
    }
    return s!;
  }
}

/// Translates [english] into the app language; `{0}`... are replaced by [args].
String tr(String english, [List<Object?> args = const []]) =>
    I18n.translate(english, args);

/// A card name with "(reversed)" in the app language when it is upside down.
String cardLabel(String name, bool reversed) =>
    reversed ? tr('{0} (reversed)', [name]) : name;
