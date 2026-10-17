import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/flags.dart';
import '../../core/account_service.dart';
import '../../app/theme.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.onGold,
              child: Icon(Icons.person_outline),
            ),
            title: Text(
              state.account == null
                  ? 'Guest'
                  : 'Signed in with ${state.account!.provider.label}',
            ),
            subtitle: Text(
              state.account == null
                  ? 'No account needed. Your readings stay on this phone.'
                  : 'Your readings stay on this phone.',
            ),
            trailing: state.accountsAvailable
                ? TextButton(
                    onPressed: () => context.push('/account'),
                    child: Text(state.account == null ? 'Sign in' : 'Account'),
                  )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Reading History'),
            onTap: () => context.push('/history'),
          ),
          if (referralsEnabled)
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Invite friends'),
              subtitle: const Text('Free months for you, 50% off for them'),
              onTap: () => context.push('/invite'),
            ),
          if (creatorEnabled && creditsEnabled)
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Creator program'),
              subtitle: const Text(
                'Post with #shentarot: free credits, 50 likes for a free month',
              ),
              onTap: () => context.push('/creator'),
            ),
          section('Premium'),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(state.isPremium ? 'Premium active' : 'Go Premium'),
            onTap: state.isPremium ? null : () => context.push('/paywall'),
          ),
          if (creditsEnabled)
            ListTile(
              leading: const Icon(Icons.toll_outlined),
              title: Text('Credits: ${state.credits}'),
              subtitle: const Text('One credit = a reading or a follow-up'),
              onTap: state.isPremium ? null : () => context.push('/paywall'),
            ),
          section('More'),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text(
              'Reminders, reading settings, subscription, support, privacy',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
