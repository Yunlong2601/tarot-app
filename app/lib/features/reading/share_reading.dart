import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/share_service.dart';
import '../../data/models.dart';

/// Share a reading as a web page. Nothing leaves the phone until the user
/// taps Create link; the question is left off unless they switch it on.
Future<void> shareReading(BuildContext context, Reading reading) async {
  final state = AppScope.of(context);
  final existing = state.sharedUrl(reading.id);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => existing == null
        ? _CreateLinkSheet(reading: reading)
        : _SharedSheet(reading: reading, url: existing),
  );
}

void _toast(BuildContext context, String m) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

Future<void> _openShareSheet(BuildContext context, Reading r, String url) =>
    SharePlus.instance.share(
      ShareParams(
        text: 'My tarot reading from ShenTarot: $url',
        subject: r.spread.label,
      ),
    );

class _CreateLinkSheet extends StatefulWidget {
  const _CreateLinkSheet({required this.reading});
  final Reading reading;

  @override
  State<_CreateLinkSheet> createState() => _CreateLinkSheetState();
}

class _CreateLinkSheetState extends State<_CreateLinkSheet> {
  bool _withQuestion = false;
  bool _busy = false;

  Future<void> _create() async {
    final state = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final url = await state.shareLink(
        widget.reading,
        includeQuestion: _withQuestion,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await _openShareSheet(context, widget.reading, url);
    } on ShareException catch (e) {
      if (mounted) _toast(context, e.message);
    } on Exception {
      if (mounted) _toast(context, 'Could not make a link. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.reading.question;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this reading',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Creates a web page with your cards and this reading that anyone '
              'with the link can open. It is kept for a year unless you remove '
              'it, and search engines are asked not to list it. Your name and '
              'your journal notes are never included.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            if (q != null) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show my question'),
                subtitle: Text(
                  '“$q”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                value: _withQuestion,
                onChanged: (v) => setState(() => _withQuestion = v),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _create,
                icon: const Icon(Icons.link),
                label: Text(
                  _busy ? 'Creating link...' : 'Create link and share',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedSheet extends StatefulWidget {
  const _SharedSheet({required this.reading, required this.url});
  final Reading reading;
  final String url;

  @override
  State<_SharedSheet> createState() => _SharedSheetState();
}

class _SharedSheetState extends State<_SharedSheet> {
  bool _busy = false;

  Future<void> _stop() async {
    final state = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await state.stopSharing(widget.reading.id);
      if (!mounted) return;
      Navigator.pop(context);
      _toast(context, 'The link no longer works.');
    } on ShareException catch (e) {
      if (mounted) _toast(context, e.message);
    } on Exception {
      if (mounted) {
        _toast(context, 'Could not remove the link. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This reading is shared',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SelectableText(
            widget.url,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () => _openShareSheet(context, widget.reading, widget.url),
              icon: const Icon(Icons.ios_share),
              label: const Text('Share link'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _stop,
              icon: const Icon(Icons.link_off),
              label: const Text('Stop sharing'),
            ),
          ),
        ],
      ),
    ),
  );
}
