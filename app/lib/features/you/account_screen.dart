import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/account_service.dart';
import '../../app/motion.dart';
import '../../app/i18n.dart';

/// Optional account: sign in with Google or Apple so Premium follows you to
/// another phone. Sign out and Delete account live here too.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on AccountException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast(tr('Something went wrong. Please try again.'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _delete() async {
    final store = Platform.isIOS ? tr('the App Store') : tr('Google Play');
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('Delete your account?')),
        content: Text(
          tr(
            tr(
              'This permanently deletes your ShenTarot account and its usage records on our server. Readings on this phone are kept; you can remove them with Delete all my data.\n\nAn active subscription is not cancelled by this. Cancel it in {0} first if you no longer want it.',
            ),
            [store],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(tr('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(tr('Delete account')),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() async {
      await AppScope.of(context).deleteAccount();
      _toast(tr('Your account was deleted.'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final account = state.account;
    const muted = TextStyle(color: AppColors.textMuted);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Account'))),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (account == null) ...[
              Text(
                tr('Sign in (optional)'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  tr(
                    'Sign in to keep Premium when you change or add a phone. You can use ShenTarot fully without an account.',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  tr(
                    'We do not store your name or email. Your readings and journal stay on this phone either way.',
                  ),
                ),
                style: muted,
              ),
              const SizedBox(height: 24),
              for (final p in state.accountProviders) ...[
                FilledButton.icon(
                  onPressed: () => _run(() async {
                    final router = GoRouter.of(context);
                    if (await state.signIn(p)) {
                      _toast(tr('Signed in with {0}', [p.label]));
                      // Let the router finish its refresh from the state
                      // change first, or it would restore this page.
                      await WidgetsBinding.instance.endOfFrame;
                      if (router.canPop()) router.pop();
                    }
                  }),
                  icon: Icon(
                    p == AccountProvider.apple
                        ? Icons.apple
                        : Icons.account_circle_outlined,
                  ),
                  label: Text(tr('Continue with {0}', [p.label])),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(tr('Continue without an account')),
              ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_user, color: AppColors.gold),
                title: Text(tr('Signed in with {0}', [account.provider.label])),
                subtitle: Text(tr('Premium follows this account')),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _run(state.signOut),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(tr('Sign out')),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: Text(tr('Delete account')),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
