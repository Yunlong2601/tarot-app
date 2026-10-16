import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/cards_browser.dart';

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

class _SpreadInfo {
  const _SpreadInfo(this.type, this.blurb, this.positions);
  final SpreadType type;
  final String blurb;
  final String positions;
}

const _spreads = [
  _SpreadInfo(
    SpreadType.single,
    'A quick answer or a card for the day.',
    'One card',
  ),
  _SpreadInfo(
    SpreadType.threeCard,
    'A simple story: where you were, where you are, where you are heading.',
    'Past · Present · Future',
  ),
  _SpreadInfo(
    SpreadType.celticCross,
    'A deep look at a situation from many sides.',
    'Present · Challenge · Foundation · Recent past · Possible outcome · Near future · Your attitude · External influences · Hopes and fears · Outcome',
  ),
];

class _SpreadsList extends StatelessWidget {
  const _SpreadsList();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final s in _spreads)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: _Layout(count: s.type.cardCount),
              title: Text(s.type.label),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${s.blurb}\n${s.positions}',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
              trailing: Text(
                s.type.isPremium && !state.isPremium ? 'Premium' : 'Free',
                style: TextStyle(
                  color: s.type.isPremium && !state.isPremium
                      ? AppColors.gold
                      : Colors.greenAccent,
                ),
              ),
              onTap: () {
                if (s.type.isPremium && !state.isPremium) {
                  context.push('/paywall');
                } else {
                  state.selectSpread(s.type);
                  context.go('/read');
                }
              },
            ),
          ),
      ],
    );
  }
}

/// Tiny schematic of how many cards the spread uses.
class _Layout extends StatelessWidget {
  const _Layout({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Container(
              width: count > 3 ? 10 : 14,
              height: count > 3 ? 16 : 22,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold, width: 1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
