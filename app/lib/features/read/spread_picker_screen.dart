import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../paywall/out_of_credits.dart';
import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/spreads.dart';
import '../spreads/spread_layout.dart';
import '../../app/i18n.dart';

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
      appBar: AppBar(title: Text(tr('Select a Spread'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                q.isEmpty ? tr('General reading (no question)') : q,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Every spread by name, so none is hidden behind a swipe.
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _spreads.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final t = _spreads[i];
                final lock = !state.isPremium && !t.isFree;
                return ChoiceChip(
                  label: Text('${t.label} · ${t.cardCount}'),
                  avatar: lock
                      ? const Icon(Icons.lock_outline, size: 16)
                      : null,
                  selected: i == _index,
                  showCheckmark: false,
                  onSelected: (_) => _page.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
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
                  child: Align(
                    alignment: Alignment.topCenter,
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
                                Chip(label: Text(tr('Recommended'))),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                t.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.cardCount == 1
                                    ? tr('1 card')
                                    : tr('{0} cards', [t.cardCount]),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.blurb,
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
                              if (state.usesTrial(t))
                                Row(
                                  children: [
                                    Icon(
                                      Icons.card_giftcard,
                                      size: 18,
                                      color: AppColors.gold,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tr(
                                          tr(
                                            'Uses your one-time free premium reading',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(
              label: tr('Spread {0} of {1}', [_index + 1, _spreads.length]),
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _spreads.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppColors.gold
                            : AppColors.textMuted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: FilledButton(
              onPressed: () {
                if (!state.canStart(chosen) || locked) {
                  openPaywall(context, PaywallReason.lockedSpread);
                  return;
                }
                state.selectSpread(chosen);
                context.push(
                  state.readMode == ReadMode.photo ? '/photo' : '/digital',
                );
              },
              child: Text(
                locked
                    ? tr('Unlock with Premium')
                    : state.usesTrial(chosen)
                    ? tr('Start free reading')
                    : tr('Start reading'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
