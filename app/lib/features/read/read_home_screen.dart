import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
import '../paywall/annual_upgrade_card.dart';
import '../today/today_screen.dart';
import 'hero_background.dart';
import '../../app/i18n.dart';

/// The Draw tab: a digital reading with cards drawn on screen. Scanning your
/// own deck is the middle tab button (and a link here).
class ReadHomeScreen extends StatelessWidget {
  const ReadHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
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
                                  tr('No deck with you?'),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  tr(
                                    'Take a breath and hold your question in mind.',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _DrawButton(
                                  onTap: () {
                                    state.setReadMode(ReadMode.digital);
                                    context.push('/ask');
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () => startPhotoReading(context),
                                  icon: const Icon(Icons.camera, size: 18),
                                  label: Text(tr('Scan your own cards')),
                                ),
                                Text(
                                  state.creditLine,
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

class _DrawButton extends StatelessWidget {
  const _DrawButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 56),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
    ),
    onPressed: onTap,
    icon: const Icon(Icons.auto_awesome),
    label: Text(tr('Digital card reading')),
  );
}
