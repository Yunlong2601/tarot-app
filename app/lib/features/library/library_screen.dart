import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/cards_browser.dart';
import '../spreads/spread_layout.dart';

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
      appBar: AppBar(title: const Text('Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('Spreads')),
                  ButtonSegment(value: true, label: Text('Cards')),
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
  SpreadCategory _category = SpreadCategory.love;

  String _badge(AppState state, SpreadType t) {
    if (t.isFree) return 'FREE';
    if (state.isPremium) return 'Premium';
    return state.trialUsed ? 'Premium' : 'Free trial reading';
  }

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
                                  t.def.blurb,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _badge(state, t),
                                  style: TextStyle(
                                    color:
                                        t.isFree ||
                                            (!state.isPremium &&
                                                !state.trialUsed)
                                        ? Colors.greenAccent
                                        : AppColors.gold,
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
