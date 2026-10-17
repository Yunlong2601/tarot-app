import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/account_service.dart';
import '../../app/motion.dart';

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
      _toast('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _delete() async {
    final store = Platform.isIOS ? 'the App Store' : 'Google Play';
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete your account?'),
        content: Text(
          'This permanently deletes your ShenTarot account and its usage '
          'records on our server. Readings on this phone are kept; you can '
          'remove them with Delete all my data.\n\nAn active subscription is '
          'not cancelled by this. Cancel it in $store first if you no longer '
          'want it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() async {
      await AppScope.of(context).deleteAccount();
      _toast('Your account was deleted.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final account = state.account;
    const muted = TextStyle(color: AppColors.textMuted);
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (account == null) ...[
              Text(
                'Sign in (optional)',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to keep Premium when you change or add a phone. '
                'You can use ShenTarot fully without an account.',
              ),
              const SizedBox(height: 8),
              const Text(
                'We do not store your name or email. Your readings and journal '
                'stay on this phone either way.',
                style: muted,
              ),
              const SizedBox(height: 24),
              for (final p in state.accountProviders) ...[
                FilledButton.icon(
                  onPressed: () => _run(() async {
                    final router = GoRouter.of(context);
                    if (await state.signIn(p)) {
                      _toast('Signed in with ${p.label}');
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
                  label: Text('Continue with ${p.label}'),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Continue without an account'),
              ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.verified_user, color: AppColors.gold),
                title: Text('Signed in with ${account.provider.label}'),
                subtitle: const Text('Premium follows this account'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _run(state.signOut),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Sign out'),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Delete account'),
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
