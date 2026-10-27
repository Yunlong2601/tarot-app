import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../paywall/out_of_credits.dart';
import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/cards_browser.dart';
import '../guide/guide_screen.dart';
import '../spreads/spread_layout.dart';
import '../../app/i18n.dart';

/// The Learn tab: the 78 cards, the spreads and the guide (lessons, how-to,
/// myths).
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _LearnPart _part = _LearnPart.cards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Learn'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_LearnPart>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: _LearnPart.cards,
                    label: Text(tr('Cards')),
                  ),
                  ButtonSegment(
                    value: _LearnPart.spreads,
                    label: Text(tr('Spreads')),
                  ),
                  ButtonSegment(
                    value: _LearnPart.guide,
                    label: Text(tr('Guide')),
                  ),
                ],
                selected: {_part},
                onSelectionChanged: (s) => setState(() => _part = s.first),
              ),
            ),
          ),
          Expanded(
            child: switch (_part) {
              _LearnPart.cards => const CardsBrowser(),
              _LearnPart.spreads => const _SpreadsList(),
              _LearnPart.guide => const GuideScreen(embedded: true),
            },
          ),
        ],
      ),
    );
  }
}

enum _LearnPart { cards, spreads, guide }

class _SpreadsList extends StatefulWidget {
  const _SpreadsList();

  @override
  State<_SpreadsList> createState() => _SpreadsListState();
}

class _SpreadsListState extends State<_SpreadsList> {
  SpreadCategory _category = SpreadCategory.classics;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final spreads = [
      for (final t in SpreadType.values)
        if (t.category == _category) t,
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              for (final c in SpreadCategory.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final t in spreads)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (!state.canStart(t)) {
                        openPaywall(context, PaywallReason.lockedSpread);
                        return;
                      }
                      _startSpread(context, state, t);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 72, child: SpreadLayoutView(type: t)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.blurb,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t.cardCount == 1
                                      ? tr('1 card')
                                      : tr('{0} cards', [t.cardCount]),
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A spread from Learn: ask whether to scan your own cards or draw on screen.
Future<void> _startSpread(
  BuildContext context,
  AppState state,
  SpreadType t,
) async {
  final mode = await showModalBottomSheet<ReadMode>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera, color: AppColors.gold),
            title: Text(tr('Scan my cards')),
            onTap: () => Navigator.pop(ctx, ReadMode.photo),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: AppColors.gold),
            title: Text(tr('Draw digitally')),
            onTap: () => Navigator.pop(ctx, ReadMode.digital),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (mode == null || !context.mounted) return;
  state.setReadMode(mode);
  state.selectSpread(t);
  context.push('/ask', extra: true);
}
