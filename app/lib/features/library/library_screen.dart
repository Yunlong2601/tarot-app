import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/cards_browser.dart';
import '../spreads/spread_layout.dart';
import '../../app/i18n.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _showCards = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Library'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: false, label: Text(tr('Spreads'))),
                  ButtonSegment(value: true, label: Text(tr('Cards'))),
                ],
                selected: {_showCards},
                onSelectionChanged: (s) => setState(() => _showCards = s.first),
              ),
            ),
          ),
          Expanded(
            child: _showCards ? const CardsBrowser() : const _SpreadsList(),
          ),
        ],
      ),
    );
  }
}

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
        // Same setting as the Read tab's main button: scan a physical deck or
        // draw on screen. The spread you tap starts in this mode.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<ReadMode>(
              segments: [
                ButtonSegment(
                  value: ReadMode.photo,
                  icon: Icon(Icons.center_focus_strong_outlined),
                  label: Text(tr('Scan my cards')),
                ),
                ButtonSegment(
                  value: ReadMode.digital,
                  icon: Icon(Icons.style_outlined),
                  label: Text(tr('Draw digitally')),
                ),
              ],
              selected: {state.readMode},
              showSelectedIcon: false,
              onSelectionChanged: (m) => state.setReadMode(m.first),
            ),
          ),
        ),
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
                        context.push('/paywall');
                        return;
                      }
                      state.selectSpread(t);
                      context.push('/ask', extra: true);
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
                                  '${t.cardCount} ${t.cardCount == 1 ? 'card' : 'cards'}',
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
