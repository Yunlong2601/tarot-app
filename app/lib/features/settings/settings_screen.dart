import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_scope.dart';
import '../../app/flags.dart';
import '../../core/install_id.dart';
import '../../core/user_key_store.dart';
import '../../app/theme.dart';
import '../../core/subscription_service.dart';

const _feedbackEmail = 'shenyunlongbusiness@gmail.com';
const _appStoreId = '6823779463';

/// All settings in one place, so the You tab stays light.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

    Future<void> confirmDeleteData() async {
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
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          section('Subscription'),
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
          section('Preferences'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Reminders'),
            subtitle: Text(
              state.reminderEnabled
                  ? 'Daily at ${state.reminderTime.format(context)}'
                  : 'Off',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/reminders'),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Reading settings'),
            subtitle: const Text('Look first, auto-reveal, reversed cards'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/reading'),
          ),
          if (ownKeyEnabled)
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Your own AI key'),
              subtitle: Text(
                state.usesOwnKey
                    ? 'On: ${state.ownKeyProvider!.label}'
                    : 'Premium: unlimited readings with your key',
              ),
              onTap: () => context.push('/own-key'),
            ),
          section('Support and about'),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Send feedback'),
            subtitle: const Text(_feedbackEmail),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final opened = await launchUrl(
                Uri.parse(
                  'mailto:$_feedbackEmail?subject=ShenTarot%20feedback',
                ),
              ).catchError((_) => false);
              if (!opened) {
                await Clipboard.setData(
                  const ClipboardData(text: _feedbackEmail),
                );
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('No mail app found. Email address copied.'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Rate ShenTarot'),
            // The App Store page always opens; the in-app prompt is often
            // suppressed by iOS (and never shows in TestFlight).
            onTap: () =>
                InAppReview.instance.openStoreListing(appStoreId: _appStoreId),
          ),
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
          section('Account and data'),
          if (state.account != null) ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: state.signOut,
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined),
              title: const Text('Delete account'),
              onTap: () => context.push('/account'),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete all my data'),
            onTap: confirmDeleteData,
          ),
          if (kDebugMode && state.isPremium)
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Dev: turn Premium off'),
              onTap: () => state.setPremium(false),
            ),
          if (testerMode) ...[
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.science_outlined),
              title: const Text('Tester: pretend Premium'),
              subtitle: const Text('Test builds only. Not in the store app.'),
              value: state.isPremium,
              onChanged: state.setTesterPremium,
            ),
            FutureBuilder<String>(
              future: loadInstallId(),
              builder: (context, snap) => ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Tester install ID'),
                subtitle: SelectableText(snap.data ?? '...'),
              ),
            ),
          ],
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snap.hasData
                    ? 'ShenTarot ${snap.data!.version} (${snap.data!.buildNumber})'
                    : 'ShenTarot',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
