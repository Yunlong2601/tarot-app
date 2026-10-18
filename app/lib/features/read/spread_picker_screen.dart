import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/spreads.dart';
import '../spreads/spread_layout.dart';

/// Step 2: choose a spread. The best match for the question comes first and is
/// marked Recommended. Swipe sideways to see the others.
class SpreadPickerScreen extends StatefulWidget {
  const SpreadPickerScreen({super.key});

  @override
  State<SpreadPickerScreen> createState() => _SpreadPickerScreenState();
}

class _SpreadPickerScreenState extends State<SpreadPickerScreen> {
  late final List<SpreadType> _spreads = spreadsFor(
    AppScope.of(context).draftQuestion,
  );
  late final _page = PageController(viewportFraction: 0.88);
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final chosen = _spreads[_index];
    final q = state.draftQuestion;
    final locked = !state.isPremium && !chosen.isFree && state.trialUsed;
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Spread')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                q.isEmpty ? 'General reading (no question)' : q,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _page,
              itemCount: _spreads.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final t = _spreads[i];
                final recommended = i == 0 && q.trim().isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: i == _index
                            ? AppColors.gold
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recommended) ...[
                              const Chip(label: Text('Recommended')),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              t.label,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t.cardCount} card${t.cardCount == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.def.blurb,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: SizedBox(
                                width: 250,
                                child: SpreadLayoutView(type: t),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.menu_book_outlined,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    t.def.source,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (state.usesTrial(t))
                              const Row(
                                children: [
                                  Icon(
                                    Icons.card_giftcard,
                                    size: 18,
                                    color: AppColors.gold,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Uses your one-time free premium reading',
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton(
              onPressed: () {
                if (!state.canStart(chosen) || locked) {
                  context.push('/paywall');
                  return;
                }
                state.selectSpread(chosen);
                context.push(
                  state.readMode == ReadMode.photo ? '/photo' : '/digital',
                );
              },
              child: Text(
                locked
                    ? 'Unlock with Premium'
                    : state.usesTrial(chosen)
                    ? 'Start free reading'
                    : 'Start reading',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
