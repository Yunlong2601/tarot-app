import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
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
                          const Text(
                            'SHENTAROT',
                            style: TextStyle(
                              letterSpacing: 4,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
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
                                  onMain: () => context.push(
                                    photo ? '/photo' : '/digital',
                                  ),
                                  onSwap: () => state.setReadMode(
                                    photo ? ReadMode.digital : ReadMode.photo,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () => _pickSpread(context, state),
                                  icon: const Icon(
                                    Icons.dashboard_customize_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Spread: ${state.selectedSpread.label}',
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

  Future<void> _pickSpread(BuildContext context, AppState state) async {
    final chosen = await showModalBottomSheet<SpreadType>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose a spread',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            for (final s in SpreadType.values)
              ListTile(
                title: Text(s.label),
                subtitle: Text(
                  '${s.cardCount} card${s.cardCount == 1 ? '' : 's'}',
                ),
                trailing: s.isPremium && !state.isPremium
                    ? const Icon(Icons.lock_outline)
                    : (s == state.selectedSpread
                          ? const Icon(Icons.check)
                          : null),
                onTap: () => Navigator.pop(ctx, s),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !context.mounted) return;
    if (chosen.isPremium && !state.isPremium) {
      context.push('/paywall');
    } else {
      state.selectSpread(chosen);
    }
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
                        color: const Color(0xFF1B1408),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF1B1408),
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
              icon: const Icon(Icons.swap_horiz, color: Color(0xFF1B1408)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ],
        ),
      ),
    );
  }
}
