import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
import '../paywall/annual_upgrade_card.dart';
import 'hero_background.dart';

/// The landing screen (Read tab): artwork, tagline and one big button that
/// either scans a physical deck ("Photo reading") or draws cards on screen
/// ("Digital card reading"). The arrows swap the mode.
class ReadHomeScreen extends StatelessWidget {
  const ReadHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final photo = state.readMode == ReadMode.photo;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HeroBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandLockup(),
                          const Spacer(),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Hold the cards.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'We explain them.',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _ModeButton(
                                  photo: photo,
                                  onMain: () => context.push('/ask'),
                                  onSwap: () => state.setReadMode(
                                    photo ? ReadMode.digital : ReadMode.photo,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () => context.push('/daily'),
                                  icon: const Icon(
                                    Icons.wb_sunny_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    state.dailyCardIfDrawn == null
                                        ? 'Card of the Day (free)'
                                        : "Today's card: ${state.dailyCardIfDrawn!.card.name}",
                                  ),
                                ),
                                if (state.dueRevisit case final due?)
                                  TextButton.icon(
                                    onPressed: () =>
                                        context.push('/reading/${due.id}'),
                                    icon: const Icon(Icons.history, size: 18),
                                    label: const Text(
                                      'Look back at last week\'s reading',
                                    ),
                                  ),
                                Text(
                                  state.isPremium
                                      ? 'Premium: unlimited readings'
                                      : state.canReadForFree
                                      ? '1 free reading left today'
                                      : 'Free reading used. Come back tomorrow or go Premium.',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const AnnualUpgradeCard(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.photo,
    required this.onMain,
    required this.onSwap,
  });
  final bool photo;
  final VoidCallback onMain;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final label = photo ? 'Photo reading' : 'Digital card reading';
    return Material(
      color: AppColors.gold,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: InkWell(
                onTap: onMain,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        photo ? Icons.center_focus_strong : Icons.auto_awesome,
                        color: AppColors.onGold,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.onGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0x33000000)),
            IconButton(
              tooltip: photo
                  ? 'Switch to digital card reading'
                  : 'Switch to photo reading',
              onPressed: onSwap,
              icon: const Icon(Icons.swap_horiz, color: AppColors.onGold),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ],
        ),
      ),
    );
  }
}
