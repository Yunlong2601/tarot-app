import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

/// DEMO ONLY. Shows the planned sign-in design. Nothing here signs anyone in:
/// ShenTarot has no accounts yet (see PROGRESS.md). The page can always be
/// closed or skipped. Before release, either build real sign-in (needs Sign in
/// with Apple, in-app account deletion and a privacy policy update) or remove
/// the entry point in the You tab.
class SignInDemoScreen extends StatefulWidget {
  const SignInDemoScreen({super.key});

  @override
  State<SignInDemoScreen> createState() => _SignInDemoScreenState();
}

class _SignInDemoScreenState extends State<SignInDemoScreen> {
  bool _signUp = false;
  bool _hide = true;

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Accounts are coming later. You can use ShenTarot without one.',
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _signUp ? 'Create your account' : 'Welcome back',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Demo screen: accounts are not available yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _soon,
            icon: const Icon(Icons.apple),
            label: const Text('Continue with Apple'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _soon,
            icon: const Text(
              'G',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            label: const Text('Continue with Google'),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'or with email',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: false, label: Text('Sign In')),
              ButtonSegment(value: true, label: Text('Sign Up')),
            ],
            selected: {_signUp},
            onSelectionChanged: (s) => setState(() => _signUp = s.first),
          ),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.mail_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: _hide,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _hide ? 'Show password' : 'Hide password',
                icon: Icon(
                  _hide
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _soon,
            child: Text(_signUp ? 'Sign Up' : 'Sign In'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }
}
