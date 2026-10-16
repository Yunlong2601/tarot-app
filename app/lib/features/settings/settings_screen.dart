import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../app/app_scope.dart';
import '../../core/subscription_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    void soon(String what) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$what arrives in a later phase')));
    Future<void> manage() async {
      final url = Uri.parse(await state.subscriptions.manageUrl());
      if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Open Settings > Subscriptions on your device.')));
      }
    }

    Future<void> restore() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final premium = await state.subscriptions.restore();
        if (premium) state.setPremium(true);
        messenger.showSnackBar(SnackBar(
            content: Text(premium
                ? 'Premium restored.'
                : 'No active subscription found for this account.')));
      } on SubscriptionException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(children: [
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
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Daily card reminder'),
          value: false,
          onChanged: (_) => soon('Notifications'),
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
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Disclaimer'),
          subtitle: const Text('For entertainment and self-reflection only'),
          onTap: () => context.push('/legal/disclaimer'),
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
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete')),
                ],
              ),
            );
            if (ok == true) state.deleteAllData();
          },
        ),
        if (kDebugMode && state.isPremium) ListTile(
          leading: const Icon(Icons.bug_report_outlined),
          title: const Text('Dev: turn Premium off'),
          onTap: () => state.setPremium(false),
        ),
      ]),
    );
  }
}
