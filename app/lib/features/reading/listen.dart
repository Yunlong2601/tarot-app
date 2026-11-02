import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../app/app_scope.dart';
import '../../app/i18n.dart';
import '../../core/analytics.dart';
import '../../data/models.dart';
import '../paywall/out_of_credits.dart';
import 'reading_sections.dart';

/// What is read aloud: the overview, each card with its position, the
/// question to reflect on and the small step. "Why" notes are left out.
String spokenReading(Reading r) {
  final sections = parseReading(r.interpretation);
  if (sections == null) return _plain(r.interpretation);
  final positions = r.spread.positionsFrom(r.createdAt);
  final parts = <String>[];
  for (final s in sections) {
    switch (s.kind) {
      case SectionKind.overview:
      case SectionKind.reflect:
      case SectionKind.step:
        parts.add('${tr(s.title)}. ${_plain(s.body)}');
      case SectionKind.card:
        final i = s.cardIndex!;
        final head = i < r.cards.length && i < positions.length
            ? '${positions[i]}. ${cardLabel(r.cards[i].card.name, r.cards[i].reversed)}'
            : s.title;
        parts.add('$head. ${_plain(s.body)}');
      case SectionKind.other:
        break;
    }
  }
  return parts.join('\n\n');
}

String _plain(String t) => t.replaceAll(RegExp(r'[*_#>`]'), '').trim();

/// The device voice for the app language. Speech is made on the phone:
/// nothing is sent anywhere.
String speechLanguage(String code) => switch (code) {
  'zh_Hans' => 'zh-CN',
  'zh_Hant' => 'zh-TW',
  'pt' => 'pt-BR',
  'en' => 'en-US',
  'ar' => 'ar-SA',
  _ => code,
};

class _Voice {
  _Voice._();
  static final instance = _Voice._();
  FlutterTts? _tts;
  final speaking = ValueNotifier<String?>(null);

  Future<void> speak(String readingId, String text) async {
    final tts = _tts ??= FlutterTts()
      ..setCompletionHandler(() => speaking.value = null)
      ..setCancelHandler(() => speaking.value = null)
      ..setErrorHandler((_) => speaking.value = null);
    await tts.stop();
    await tts.setLanguage(speechLanguage(I18n.code));
    await tts.setSpeechRate(0.45);
    await tts.awaitSpeakCompletion(false);
    speaking.value = readingId;
    await tts.speak(text);
  }

  Future<void> stop() async {
    speaking.value = null;
    await _tts?.stop();
  }
}

/// Listen to the reading, read aloud by the phone's own voice (Premium).
class ListenButton extends StatefulWidget {
  const ListenButton({super.key, required this.reading});
  final Reading reading;

  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton> {
  @override
  void dispose() {
    // Leaving the reading stops the voice.
    if (_Voice.instance.speaking.value == widget.reading.id) {
      _Voice.instance.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
    valueListenable: _Voice.instance.speaking,
    builder: (context, id, _) {
      final on = id == widget.reading.id;
      return IconButton(
        tooltip: on ? tr('Stop listening') : tr('Listen to your reading'),
        icon: Icon(on ? Icons.stop_circle_outlined : Icons.headphones_outlined),
        onPressed: () async {
          if (on) {
            await _Voice.instance.stop();
            return;
          }
          final state = AppScope.of(context);
          if (!state.isPremium) {
            logEvent('listen', {'locked': true});
            openPaywall(context);
            return;
          }
          logEvent('listen', {'locked': false});
          try {
            await _Voice.instance.speak(
              widget.reading.id,
              spokenReading(widget.reading),
            );
          } catch (e) {
            _Voice.instance.speaking.value = null;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Could not read this aloud on this phone')),
                ),
              );
            }
          }
        },
      );
    },
  );
}
