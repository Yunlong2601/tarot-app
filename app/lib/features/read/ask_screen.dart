import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import 'question_nudge.dart';

/// Step 1 of a reading: the question. Optional, but a good question makes a
/// better reading. If [skipPicker] is set the spread was already chosen in the
/// Library, so we go straight to drawing.
class AskScreen extends StatefulWidget {
  const AskScreen({super.key, this.skipPicker = false});
  final bool skipPicker;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _controller = TextEditingController();
  bool _seeded = false;
  String? _nudge;
  int _topic = 0;

  static const _starters = [
    'What do I need to understand about ',
    'What is helping and what is in the way with ',
    'How can I approach ',
  ];

  /// Example questions per topic: tap one to fill the box (and edit it).
  static const _samples = <(String, List<String>)>[
    (
      'Love',
      [
        'Will my ex come back?',
        'Where does my relationship stand?',
        'When will I find love?',
      ],
    ),
    (
      'Career',
      [
        'Should I take this job offer?',
        'What is holding me back at work?',
        'What could I explore next in my career?',
      ],
    ),
    (
      'Daily',
      [
        'What do I need to focus on today?',
        'What energy should I bring to this week?',
      ],
    ),
    (
      'Choices',
      [
        'Should I move to a new city?',
        'What do I need to know before I decide?',
      ],
    ),
    (
      'Growth',
      [
        'What lesson do I keep repeating?',
        'What am I not seeing about myself?',
      ],
    ),
  ];

  void _fill(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
  }

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
      if (n != _nudge) setState(() => _nudge = n);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final state = AppScope.of(context);
    state.setDraftQuestion(_controller.text);
    if (widget.skipPicker) {
      context.push(state.readMode.name == 'photo' ? '/photo' : '/digital');
    } else {
      context.push('/spreads');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Your question')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('What is on your mind?', style: t.headlineSmall),
          const SizedBox(height: 6),
          const Text(
            'An open question works best. You can also leave it blank for a general reading.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLength: 300,
            maxLines: 4,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Type your question',
              border: const OutlineInputBorder(),
              helperText: _nudge,
              helperMaxLines: 3,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final s in _starters)
                ActionChip(
                  label: Text('${s.trim()}...'),
                  onPressed: () => _fill(s),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _next, child: const Text('Next')),
          TextButton(
            onPressed: () {
              _controller.clear();
              _next();
            },
            child: const Text('Skip: general reading'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please keep personal details out of your question.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Text('Need ideas?', style: t.titleSmall),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (i, (topic, _)) in _samples.indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(topic),
                      selected: i == _topic,
                      onSelected: (_) => setState(() => _topic = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (final q in _samples[_topic].$2)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: AppColors.gold,
              ),
              title: Text(q),
              onTap: () => _fill(q),
            ),
        ],
      ),
    );
  }
}
