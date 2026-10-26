import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/brand.dart';
import '../../app/theme.dart';
import 'question_nudge.dart';
import '../../app/i18n.dart';
import '../../app/motion.dart';

/// Step 1 of a reading: the question, asked as a quiet conversation with the
/// reader instead of a form. The reader is labelled as AI. Optional, but a good
/// question makes a better reading. If [skipPicker] is set the spread was
/// already chosen in the Library, so we go straight to drawing.
class AskScreen extends StatefulWidget {
  const AskScreen({super.key, this.skipPicker = false});
  final bool skipPicker;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _seeded = false;
  String? _nudge;

  /// The question once sent: shown as the user's line, answered by the reader,
  /// then the reading moves on.
  String? _sent;

  static const _starters = [
    'What do I need to understand about ',
    'What is helping and what is in the way with ',
    'How can I approach ',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seeded) {
      _seeded = true;
      _controller.text = AppScope.of(context).draftQuestion;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final n = questionNudge(_controller.text);
      setState(() => _nudge = n);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sent != null) return;
    if (looksOffTopic(_controller.text)) {
      final ask = await showAppDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr('Let\'s ask the cards about you')),
          content: Text(
            tr(
              'This looks like a question about the app or something outside your life. The cards read best on your own situation, for example "What can I do to feel more settled at work?"',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('Ask anyway')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('Edit my question')),
            ),
          ],
        ),
      );
      if (ask != true || !mounted) return;
    }
    if (!mounted) return;
    AppScope.of(context).setDraftQuestion(_controller.text);
    _focus.unfocus();
    // The reader answers in a line, then the reading moves on (see _Reply).
    setState(() => _sent = _controller.text.trim());
  }

  void _goOn() {
    if (!mounted || _sent == null) return;
    final state = AppScope.of(context);
    if (widget.skipPicker) {
      context.push(state.readMode.name == 'photo' ? '/photo' : '/digital');
    } else {
      context.push('/spreads');
    }
    // Back from the next step finds the conversation ready to edit again.
    setState(() => _sent = null);
  }

  void _useStarter(String s) {
    _controller.text = s;
    _controller.selection = TextSelection.collapsed(offset: s.length);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final sent = _sent;
    final len = _controller.text.characters.length;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Your question'))),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  const _ReaderSigil(),
                  const SizedBox(height: 20),
                  _ReaderLine(
                    tr('Take a breath. Let the noise of the day settle.'),
                  ),
                  _ReaderLine(
                    tr('What would you like to ask the cards?'),
                    delay: 0.35,
                  ),
                  if (sent == null) ...[
                    const SizedBox(height: 14),
                    _ReaderLine(
                      tr(
                        'An open question works best. You can also leave it blank for a general reading.',
                      ),
                      delay: 0.7,
                      muted: true,
                    ),
                    const SizedBox(height: 16),
                    for (final s in _starters.map(tr))
                      _Whisper(
                        text: '${s.trim()}...',
                        onTap: () => _useStarter(s),
                      ),
                  ] else ...[
                    const SizedBox(height: 20),
                    _UserLine(
                      sent.isEmpty ? tr('A general reading, please.') : sent,
                    ),
                    const SizedBox(height: 20),
                    _Reply(
                      text: tr('The cards are listening. Let us lay them out.'),
                      onDone: _goOn,
                    ),
                  ],
                ],
              ),
            ),
            if (sent == null)
              _Composer(
                controller: _controller,
                focus: _focus,
                length: len,
                nudge: _nudge,
                onSend: _send,
                onSkip: () {
                  _controller.clear();
                  _send();
                },
              ),
          ],
        ),
      ),
    );
  }
}

bool _calm(BuildContext context) =>
    !brandAnimations || MediaQuery.disableAnimationsOf(context);

/// A small candle-lit mark with an honest label: the reader is AI.
class _ReaderSigil extends StatelessWidget {
  const _ReaderSigil();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.goldDeep, width: 0.8),
          gradient: RadialGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.28),
              AppColors.background.withValues(alpha: 0),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: const BrandMark(size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('The reader'),
              style: const TextStyle(
                fontFamily: displayFont,
                fontFamilyFallback: displayFallback,
                fontSize: 18,
                color: AppColors.gold,
              ),
            ),
            Text(
              tr('AI · for reflection, not prediction'),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    ],
  );
}

/// One line from the reader: serif, with a fine gold rule in the margin. It
/// writes itself in like ink, unless the user asked for less motion.
class _ReaderLine extends StatelessWidget {
  const _ReaderLine(this.text, {this.delay = 0, this.muted = false});
  final String text;
  final double delay;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: displayFont,
      fontFamilyFallback: displayFallback,
      fontSize: muted ? 15 : 21,
      height: 1.35,
      fontStyle: muted ? FontStyle.normal : FontStyle.italic,
      color: muted ? AppColors.textMuted : const Color(0xFFF2EEE3),
    );
    Widget line(String shown) => Container(
      padding: const EdgeInsetsDirectional.only(start: 14, bottom: 6, top: 2),
      decoration: const BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: AppColors.goldDeep, width: 0.8),
        ),
      ),
      child: Stack(
        children: [
          // The full text keeps the line's height steady while it writes in.
          Opacity(opacity: 0, child: Text(text, style: style)),
          Text(shown, style: style),
        ],
      ),
    );
    if (_calm(context)) {
      return Semantics(
        label: text,
        child: ExcludeSemantics(child: line(text)),
      );
    }
    final ms = 450 + text.length * 14;
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: ms + (delay * 1000).round()),
          builder: (_, v, _) {
            final start = delay * 1000 / (ms + delay * 1000);
            final p = ((v - start) / (1 - start)).clamp(0.0, 1.0);
            final n = (text.length * Curves.easeOut.transform(p)).round();
            return line(text.substring(0, math.min(n, text.length)));
          },
        ),
      ),
    );
  }
}

/// A suggested opening, offered quietly rather than as a button.
class _Whisper extends StatelessWidget {
  const _Whisper({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 14, color: AppColors.goldDeep),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: displayFont,
                  fontFamilyFallback: displayFallback,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The user's question once sent: set right, in quotation marks.
class _UserLine extends StatelessWidget {
  const _UserLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Container(
        padding: const EdgeInsetsDirectional.only(end: 14, top: 2, bottom: 6),
        decoration: const BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(color: AppColors.textMuted, width: 0.8),
          ),
        ),
        child: Text(
          '“$text”',
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 17, height: 1.4),
        ),
      ),
    ),
  );
}

/// The reader's answer to the question: writes in, holds a beat, moves on.
class _Reply extends StatelessWidget {
  const _Reply({required this.text, required this.onDone});
  final String text;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    if (_calm(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onDone());
      return _ReaderLine(text);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      onEnd: onDone,
      builder: (_, _, child) => child!,
      child: _ReaderLine(text),
    );
  }
}

/// The composer: one hairline to write on, the send mark beside it, and the
/// way to skip the question. The character count appears only near the limit.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.length,
    required this.nudge,
    required this.onSend,
    required this.onSkip,
  });
  final TextEditingController controller;
  final FocusNode focus;
  final int length;
  final String? nudge;
  final VoidCallback onSend;
  final VoidCallback onSkip;

  static const _max = 300;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
    decoration: const BoxDecoration(
      color: AppColors.background,
      border: Border(top: BorderSide(color: AppColors.hairline, width: 0.6)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nudge != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 8),
            child: Text(
              nudge!,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.gold,
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focus,
                maxLength: _max,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 17, height: 1.35),
                decoration: InputDecoration(
                  hintText: tr('Ask the cards...'),
                  hintStyle: const TextStyle(
                    fontFamily: displayFont,
                    fontFamilyFallback: displayFallback,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.goldDeep),
                  ),
                  // Shown only near the limit, never blocking typing; no space
                  // is kept for it otherwise.
                  counter: length >= _max - 45
                      ? Text(
                          '$length/$_max',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: IconButton.filled(
                key: const ValueKey('ask-send'),
                tooltip: tr('Next'),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.onGold,
                  minimumSize: const Size(46, 46),
                ),
                onPressed: onSend,
                icon: const Icon(Icons.north),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                tr('Please keep personal details out of your question.'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
            TextButton(
              onPressed: onSkip,
              child: Text(tr('Skip: general reading')),
            ),
          ],
        ),
      ],
    ),
  );
}
