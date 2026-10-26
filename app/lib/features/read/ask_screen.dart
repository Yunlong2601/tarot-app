import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import 'question_nudge.dart';
import 'reader_voice.dart';
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
                  const ReaderSigil(),
                  const SizedBox(height: 20),
                  ReaderLine(
                    tr('Take a breath. Let the noise of the day settle.'),
                  ),
                  ReaderLine(
                    tr('What would you like to ask the cards?'),
                    delay: 0.35,
                  ),
                  if (sent == null) ...[
                    const SizedBox(height: 14),
                    ReaderLine(
                      tr(
                        'An open question works best. You can also leave it blank for a general reading.',
                      ),
                      delay: 0.7,
                      muted: true,
                    ),
                    const SizedBox(height: 16),
                    for (final s in _starters.map(tr))
                      ReaderWhisper(
                        text: '${s.trim()}...',
                        onTap: () => _useStarter(s),
                      ),
                  ] else ...[
                    const SizedBox(height: 20),
                    UserLine(
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
              // With very large text the composer scrolls inside itself
              // rather than pushing the conversation off screen.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: _Composer(
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The reader's answer to the question: writes in, holds a beat, moves on.
class _Reply extends StatelessWidget {
  const _Reply({required this.text, required this.onDone});
  final String text;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    if (readerCalm(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onDone());
      return ReaderLine(text);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      onEnd: onDone,
      builder: (_, _, child) => child!,
      child: ReaderLine(text),
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
              style: const TextStyle(fontSize: 13, color: AppColors.gold),
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
                    fontSize: 17,
                    color: Color(0xFF8F8A80),
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
