import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_scope.dart';
import '../../app/i18n.dart';
import '../../app/motion.dart';
import '../../app/theme.dart';
import '../../core/reading_service.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';
import '../reading/reading_problem.dart';

/// Takes one photo with the camera; null if cancelled. Replaced in tests.
typedef SpreadPhotoTaker = Future<Uint8List?> Function();

Future<Uint8List?> _takePhoto() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 80,
  );
  return file?.readAsBytes();
}

const _consentKey = 'spread_photo_consent';

/// One photo of the whole laid-out spread: the server names the cards, the
/// user checks them, and the confirmed cards are returned (null if cancelled).
Future<List<DrawnCard>?> scanWholeSpread(
  BuildContext context,
  SpreadType spread, {
  SpreadPhotoTaker takePhoto = _takePhoto,
}) async {
  final state = AppScope.of(context);
  final api = state.readingService;
  if (api is! SpreadIdentifier) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('The reading service is not set up yet.'))),
    );
    return null;
  }
  if (!await _askConsent(context)) return null;
  final photo = await takePhoto();
  if (photo == null || !context.mounted) return null;
  final nav = Navigator.of(context, rootNavigator: true);
  showAppDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(tr('Reading card...')),
            ],
          ),
        ),
      ),
    ),
  );
  SpreadScan? scan;
  ReadingException? failure;
  try {
    scan = await (api as SpreadIdentifier).identifySpread(photo);
  } on ReadingException catch (e) {
    failure = e;
  } catch (_) {
    failure = ReadingException(
      ReadingErrorKind.failed,
      tr('Something went wrong. Please try again.'),
    );
  } finally {
    nav.pop();
  }
  if (!context.mounted) return null;
  if (failure != null) {
    await showReadingProblem(context, failure);
    return null;
  }
  final deck = state.deck;
  final found = [
    for (final c in scan!.cards)
      if (deck.byId(c.id) case final card?)
        DrawnCard(card: card, reversed: c.reversed),
  ];
  return Navigator.of(context).push<List<DrawnCard>>(
    MaterialPageRoute(
      builder: (_) => CheckCardsScreen(
        spread: spread,
        initial: found,
        unsure: scan!.unsure || found.length != spread.cardCount,
      ),
    ),
  );
}

/// Asked once: the spread photo leaves the phone, unlike the single-card scan.
Future<bool> _askConsent(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_consentKey) == true) return true;
  if (!context.mounted) return false;
  final ok = await showAppDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.camera, color: AppColors.gold),
      title: Text(tr('Photo of the whole spread')),
      content: Text(
        tr(
          'To name the cards, this photo is sent to our server and to our AI provider (Anthropic) once, then deleted. It is never stored or used for anything else. Single-card scans stay on your phone.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr('Not now')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr('Continue')),
        ),
      ],
    ),
  );
  if (ok == true) await prefs.setBool(_consentKey, true);
  return ok == true;
}

/// Check the cards found in the photo: flip, change, remove or add, in order.
class CheckCardsScreen extends StatefulWidget {
  const CheckCardsScreen({
    super.key,
    required this.spread,
    required this.initial,
    required this.unsure,
  });
  final SpreadType spread;
  final List<DrawnCard> initial;
  final bool unsure;

  @override
  State<CheckCardsScreen> createState() => _CheckCardsScreenState();
}

class _CheckCardsScreenState extends State<CheckCardsScreen> {
  late final List<DrawnCard> _cards = [...widget.initial];

  Future<void> _change(int? index) async {
    final id = await context.push<String>('/pick');
    if (id == null || !mounted) return;
    final deck = AppScope.of(context).deck;
    if (_cards.indexed.any((e) => e.$2.card.id == id && e.$1 != index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('That card is already in this reading.'))),
      );
      return;
    }
    final card = DrawnCard(card: deck.byId(id)!, reversed: false);
    setState(() {
      if (index == null) {
        _cards.add(card);
      } else {
        _cards[index] = DrawnCard(
          card: card.card,
          reversed: _cards[index].reversed,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final need = widget.spread.cardCount;
    final ready = _cards.length == need;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Check your cards'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.unsure
                ? tr(
                    'Some cards could not be read clearly. Check each one, then continue.',
                  )
                : tr('Check each card and whether it is upside down.'),
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            tr('{0} of {1} cards', [_cards.length, need]),
            style: const TextStyle(color: AppColors.gold),
          ),
          const SizedBox(height: 12),
          for (final (i, c) in _cards.indexed)
            Card(
              child: ListTile(
                leading: SizedBox(
                  width: 36,
                  child: CardArt(card: c.card, reversed: c.reversed, width: 36),
                ),
                title: Text(
                  '${i + 1}. ${i < widget.spread.positions.length ? widget.spread.positions[i] : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                subtitle: Text(
                  cardLabel(c.card.name, c.reversed),
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: c.reversed ? tr('Upright') : tr('Reversed'),
                      icon: const Icon(Icons.screen_rotation_alt),
                      onPressed: () => setState(
                        () => _cards[i] = DrawnCard(
                          card: c.card,
                          reversed: !c.reversed,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: tr('Not this card'),
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _change(i),
                    ),
                    IconButton(
                      tooltip: tr('Delete'),
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _cards.removeAt(i)),
                    ),
                  ],
                ),
              ),
            ),
          if (_cards.length < need)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => _change(null),
              icon: const Icon(Icons.add),
              label: Text(tr('Pick a card')),
            ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: ready ? () => Navigator.pop(context, _cards) : null,
            child: Text(tr('Get my reading')),
          ),
        ],
      ),
    );
  }
}
