import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/brand.dart';
import '../../app/flags.dart';
import '../../app/theme.dart';
import '../../core/account_service.dart';
import '../collection/collection_screen.dart';
import '../../app/i18n.dart';

/// Days in a row (ending today or yesterday) with at least one reading.
/// The You tab: your profile and progress, Premium, and shortcuts. All
/// settings live on the Settings page.
class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr('You'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _ProfileCard(state),
          const SizedBox(height: 12),
          _PremiumCard(state),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            // Taller tiles at larger text sizes so nothing is cut off.
            childAspectRatio:
                1.35 /
                MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 3.0),
            children: [
              _Tile(
                icon: Icons.history,
                title: tr('Reading History'),
                subtitle: tr('{0} saved', [state.history.length]),
                onTap: () => context.push('/history'),
              ),
              _Tile(
                icon: Icons.style_outlined,
                title: tr('Your deck'),
                subtitle: tr('{0} of {1} cards met', [
                  metCardIds(state).length,
                  state.deck.cards.length,
                ]),
                onTap: () => context.push('/collection'),
              ),
              if (referralsEnabled)
                _Tile(
                  icon: Icons.card_giftcard,
                  title: tr('Invite friends'),
                  subtitle: tr('Free months for you'),
                  onTap: () => context.push('/invite'),
                ),
              if (creatorEnabled && creditsEnabled)
                _Tile(
                  icon: Icons.video_library_outlined,
                  title: tr('Creator program'),
                  subtitle: tr('Post and earn credits'),
                  onTap: () => context.push('/creator'),
                ),
              _Tile(
                icon: Icons.settings_outlined,
                title: tr('Settings'),
                subtitle: tr('Reminders, privacy, help'),
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard(this.state);
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final streak = readingStreak([
      for (final r in state.history) r.createdAt,
    ], DateTime.now());
    final signedIn = state.account != null;
    Widget stat(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: AppColors.gold),
          ),
          Text(
            tr(label),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.goldTint,
                  child: BrandMark(size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signedIn
                            ? tr('Signed in with {0}', [
                                state.account!.provider.label,
                              ])
                            : tr('Guest'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        state.isPremium
                            ? tr('Premium member')
                            : tr('Free plan'),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (state.accountsAvailable)
                  TextButton(
                    onPressed: () => context.push('/account'),
                    child: Text(signedIn ? tr('Account') : tr('Sign in')),
                  ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                stat(
                  '${state.history.length}',
                  state.history.length == 1 ? 'reading' : 'readings',
                ),
                stat('$streak', streak == 1 ? 'day streak' : 'days streak'),
                if (creditsEnabled) stat('${state.credits}', 'credits'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tr('Your readings and notes stay on this phone.'),
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard(this.state);
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final premium = state.isPremium;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/paywall'),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.goldTint, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.goldDeep),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium,
              color: AppColors.gold,
              size: 36,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    premium ? tr('Premium is active') : tr('Go Premium'),
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: AppColors.gold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    premium
                        ? tr('Every spread and 90 to 150 credits a month.')
                        : tr(
                            'Every spread, 90 to 150 credits a month, the clarifier card and a look back.',
                          ),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.gold),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
