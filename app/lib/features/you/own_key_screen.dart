import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/user_key_store.dart';
import '../../app/i18n.dart';

/// Premium: use your own Anthropic or OpenAI key for unlimited readings. The
/// key stays in this phone's secure storage and is sent only with readings.
class OwnKeyScreen extends StatefulWidget {
  const OwnKeyScreen({super.key});

  @override
  State<OwnKeyScreen> createState() => _OwnKeyScreenState();
}

class _OwnKeyScreenState extends State<OwnKeyScreen> {
  final _controller = TextEditingController();
  AiProvider _provider = AiProvider.anthropic;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _controller.text.trim();
    if (!looksLikeKey(_provider, key)) {
      setState(
        () => _error = tr(
          'That does not look like a {0} key (it should start with {1}).',
          [_provider.label, _provider.keyHint.replaceAll('...', '')],
        ),
      );
      return;
    }
    await AppScope.of(context).setOwnKey(UserKey(_provider, key));
    _controller.clear();
    if (!mounted) return;
    setState(() => _error = null);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(tr('Key saved on this phone'))));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    const muted = TextStyle(color: AppColors.textMuted);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Your own AI key'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            tr(
              tr(
                'Premium members can use their own Anthropic or OpenAI API key. Readings made with your key have no daily limit, and the AI provider bills your account for them.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              tr(
                'Your key is stored only on this phone, in its secure storage. It is sent with each reading to our server, which passes it to the provider for that one request. We never save or log it. All the usual reading rules still apply.',
              ),
            ),
            style: muted,
          ),
          const SizedBox(height: 20),
          if (!state.isPremium)
            FilledButton.icon(
              onPressed: () => context.push('/paywall'),
              icon: const Icon(Icons.lock_outline),
              label: Text(tr('Available with Premium')),
            )
          else if (state.ownKeyProvider != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.key, color: AppColors.gold),
              title: Text(
                tr('Using your {0} key', [state.ownKeyProvider!.label]),
              ),
              subtitle: Text(tr('Unlimited readings while Premium is active')),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: state.removeOwnKey,
              child: Text(tr('Remove key')),
            ),
          ] else ...[
            SegmentedButton<AiProvider>(
              segments: [
                for (final p in AiProvider.values)
                  ButtonSegment(value: p, label: Text(p.label)),
              ],
              selected: {_provider},
              onSelectionChanged: (s) => setState(() => _provider = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              decoration: InputDecoration(
                labelText: tr('API key'),
                hintText: _provider.keyHint,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _save, child: Text(tr('Save key'))),
            const SizedBox(height: 12),
            Text(
              tr(
                tr(
                  'Set a spending limit in your provider account. Remove the key here, or with Delete all my data, at any time.',
                ),
              ),
              style: muted,
            ),
          ],
        ],
      ),
    );
  }
}
