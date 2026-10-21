import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/creator_service.dart';

/// Chooses a screenshot and returns its bytes, or null if none was chosen.
typedef ScreenshotPicker = Future<Uint8List?> Function();

Future<Uint8List?> _pickFromGallery() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1280,
    maxHeight: 1600,
    imageQuality: 80,
  );
  return file?.readAsBytes();
}

/// Anyone can be a creator: post with #shentarot, send the link and a
/// screenshot, get credits at once; 50 likes earns a free month of Premium.
class CreatorScreen extends StatefulWidget {
  const CreatorScreen({super.key, this.pickScreenshot = _pickFromGallery});

  final ScreenshotPicker pickScreenshot;

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  final _link = TextEditingController();
  Uint8List? _shot;
  CreatorOverview? _overview;
  bool _busy = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_overview == null) _refresh();
  }

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final api = AppScope.of(context).creatorApi;
    try {
      final o = await api.mine();
      if (mounted) setState(() => _overview = o);
    } catch (_) {
      if (mounted) setState(() => _overview = const CreatorOverview());
    }
  }

  Future<void> _choose() async {
    final bytes = await widget.pickScreenshot();
    if (bytes == null || !mounted) return;
    setState(() {
      _shot = bytes;
      _error = bytes.length > 1000000
          ? 'That screenshot is over 1 MB. Choose a smaller one.'
          : null;
    });
  }

  Future<void> _submit() async {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final credits = await state.creatorApi.submit(
        url: _link.text.trim(),
        screenshot: _shot!,
      );
      await state.refreshCredits();
      if (!mounted) return;
      _link.clear();
      setState(() => _shot = null);
      messenger.showSnackBar(
        SnackBar(content: Text('Thank you! $credits credits added.')),
      );
      await _refresh();
    } on CreatorException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool get _ready =>
      !_busy &&
      _link.text.trim().isNotEmpty &&
      _shot != null &&
      _shot!.length <= 1000000;

  String _status(CreatorPost p, CreatorRules r) => switch (p.status) {
    'verified' =>
      p.monthGranted
          ? 'Verified (${p.likes} likes): free month added'
          : 'Verified (${p.likes} likes)',
    'rejected' => 'Not accepted',
    _ => 'Credits added · waiting for ${r.likesForMonth} likes to be checked',
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final muted = const TextStyle(color: AppColors.textMuted);
    final rules = _overview?.rules ?? const CreatorRules();
    return Scaffold(
      appBar: AppBar(title: const Text('Creator program')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Post it. Get credits.', style: t.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Anyone can be a creator. Post about ShenTarot on TikTok, '
            'Instagram, YouTube, Xiaohongshu, Reddit, X, Facebook or Threads '
            'with #shentarot, and add #ad or #gifted. Send us the link and a '
            'screenshot of your post.',
            style: muted,
          ),
          const SizedBox(height: 12),
          _Bullet(
            'Every post you send earns ${rules.creditsPerPost} credits '
            'at once (${rules.maxPerDay} a day, ${rules.maxPerMonth} a month, '
            'each post once).',
          ),
          _Bullet(
            'When your post reaches ${rules.likesForMonth} likes, we '
            'check it and give you 1 free month of Premium (once every 60 '
            'days, up to 6 a year).',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _link,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Link to your post',
              hintText: 'https://www.tiktok.com/…',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _choose,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              _shot == null
                  ? 'Choose screenshot'
                  : 'Screenshot chosen (${(_shot!.length / 1024).round()} KB)',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.gold)),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _ready ? _submit : null,
            child: Text(_busy ? 'Sending…' : 'Send my post'),
          ),
          const SizedBox(height: 24),
          Text('My posts', style: t.titleMedium),
          const SizedBox(height: 4),
          if (_overview == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            )
          else if (_overview!.posts.isEmpty)
            Text('No posts yet.', style: muted)
          else
            for (final p in _overview!.posts)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  p.status == 'verified'
                      ? Icons.verified_outlined
                      : p.status == 'rejected'
                      ? Icons.block
                      : Icons.hourglass_empty,
                  color: p.status == 'verified' ? AppColors.gold : null,
                ),
                title: Text('${p.platform} · ${p.date}'),
                subtitle: Text(_status(p, rules)),
              ),
          const SizedBox(height: 16),
          Text(
            'Small print: rewards are for the post, never for ratings or '
            'reviews. Do not ask for or buy likes; fake likes mean no reward. '
            'We keep your screenshot for 30 days to check it, then delete it, '
            'and keep the link and result. A free subscription counts as '
            'payment, so label your post #ad or #gifted. We may stop or change '
            'the program. Terms apply.',
            style: muted.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2, right: 8),
          child: Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.gold,
          ),
        ),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
