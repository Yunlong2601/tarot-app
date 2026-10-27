import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../core/analytics.dart';

/// Why the paywall opened, so its headline can match what the user was doing.
enum PaywallReason { general, outOfCredits, lockedSpread, followUp, recap }

/// Opens the paywall for [reason].
void openPaywall(
  BuildContext context, [
  PaywallReason reason = PaywallReason.general,
]) => context.push('/paywall', extra: reason);

/// Time until the next free credit: daily credits start at 00:00 UTC.
Duration untilNextFreeCredit(DateTime now) {
  final utc = now.toUtc();
  final next = DateTime.utc(utc.year, utc.month, utc.day + 1);
  return next.difference(utc);
}

String _inWords(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h >= 1) return h == 1 ? tr('about 1 hour') : tr('about {0} hours', [h]);
  return m <= 1 ? tr('about a minute') : tr('{0} minutes', [m]);
}

/// Shown instead of dropping a free user straight onto the paywall when their
/// credits run out. Offers the free ways forward first (wait, sign in), then
/// the smallest purchase, then Premium.
Future<void> showOutOfCredits(BuildContext context) {
  final state = AppScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('You are out of credits for now'),
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              tr('Your next free credit arrives in {0}.', [
                _inWords(untilNextFreeCredit(DateTime.now())),
              ]),
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            if (state.guestCouldSignIn)
              _Option(
                icon: Icons.login,
                title: tr('Sign in for 2 free credits a day'),
                subtitle: tr('Free. Your readings stay on this phone.'),
                onTap: () {
                  logEvent('out_of_credits_choice', {'choice': 'sign_in'});
                  Navigator.pop(ctx);
                  context.push('/account');
                },
              ),
            _Option(
              icon: Icons.toll_outlined,
              title: tr('Buy a few credits'),
              subtitle: tr('One-time packs, no subscription.'),
              onTap: () {
                logEvent('out_of_credits_choice', {'choice': 'packs'});
                Navigator.pop(ctx);
                openPaywall(context, PaywallReason.outOfCredits);
              },
            ),
            _Option(
              icon: Icons.workspace_premium_outlined,
              title: tr('Go Premium'),
              subtitle: tr(
                '90 to 150 credits a month and every spread. Cancel anytime.',
              ),
              onTap: () {
                logEvent('out_of_credits_choice', {'choice': 'premium'});
                Navigator.pop(ctx);
                openPaywall(context, PaywallReason.outOfCredits);
              },
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () {
                  logEvent('out_of_credits_choice', {'choice': 'wait'});
                  Navigator.pop(ctx);
                },
                child: Text(tr('I will wait')),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Option extends StatelessWidget {
  const _Option({
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
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: AppColors.gold),
    title: Text(title),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: AppColors.textMuted),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
