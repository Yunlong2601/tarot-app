import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/subscription_service.dart';

class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    Future<void> manage() async {
      final url = Uri.parse(await state.subscriptions.manageUrl());
      if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Open Settings > Subscriptions on your device.'),
          ),
        );
      }
    }

    Future<void> restore() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final premium = await state.subscriptions.restore();
        if (premium) state.setPremium(true);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              premium
                  ? 'Premium restored.'
                  : 'No active subscription found for this account.',
            ),
          ),
        );
      } on SubscriptionException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
      }
    }

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
            title: const Text('Guest'),
            subtitle: const Text(
              'No account needed. Your readings stay on this phone.',
            ),
            trailing: TextButton(
              onPressed: () => context.push('/signin-demo'),
              child: const Text('Sign in'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Reading History'),
            onTap: () => context.push('/history'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(state.isPremium ? 'Premium active' : 'Go Premium'),
            onTap: state.isPremium ? null : () => context.push('/paywall'),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Manage subscription'),
            onTap: manage,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Purchases'),
            onTap: restore,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_outlined),
            title: const Text('Look first'),
            subtitle: const Text(
              'Note what you see in the cards before the reading',
            ),
            value: state.lookFirst,
            onChanged: state.setLookFirst,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Daily card reminder'),
            subtitle: Text(
              state.reminderEnabled
                  ? 'Every day at ${state.reminderTime.format(context)}'
                  : 'Off',
            ),
            value: state.reminderEnabled,
            onChanged: (on) async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await state.setReminder(on);
              if (!ok && on) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Notifications are off for this app. Turn them on in your phone Settings.',
                    ),
                  ),
                );
              }
            },
          ),
          if (state.reminderEnabled)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Reminder time'),
              subtitle: Text(state.reminderTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: state.reminderTime,
                );
                if (t != null) await state.setReminder(true, time: t);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => context.push('/legal/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Use'),
            onTap: () => context.push('/legal/terms'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete all my data'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete all data?'),
                  content: const Text('This removes your reading history.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (ok == true) await state.deleteAllData();
            },
          ),
          if (kDebugMode && state.isPremium)
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Dev: turn Premium off'),
              onTap: () => state.setPremium(false),
            ),
        ],
      ),
    );
  }
}
