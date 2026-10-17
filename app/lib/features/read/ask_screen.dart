import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import 'question_nudge.dart';
import '../../app/i18n.dart';

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
      appBar: AppBar(title: Text(tr('Your question'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(tr('What is on your mind?'), style: t.headlineSmall),
          const SizedBox(height: 6),
          Text(
            tr(
              tr(
                'An open question works best. You can also leave it blank for a general reading.',
              ),
            ),
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLength: 300,
            maxLines: 4,
            autofocus: false,
            decoration: InputDecoration(
              hintText: tr('Type your question'),
              border: const OutlineInputBorder(),
              helperText: _nudge,
              helperMaxLines: 3,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final s in _starters.map(tr))
                ActionChip(
                  label: Text('${s.trim()}...'),
                  onPressed: () {
                    _controller.text = s;
                    _controller.selection = TextSelection.collapsed(
                      offset: s.length,
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _next, child: Text(tr('Next'))),
          TextButton(
            onPressed: () {
              _controller.clear();
              _next();
            },
            child: Text(tr('Skip: general reading')),
          ),
          const SizedBox(height: 8),
          Text(
            tr('Please keep personal details out of your question.'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
