import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';

/// Wire values the server accepts (backend/src/validate.ts FOCUS_AREAS).
const focusAreas = ['love', 'work', 'self', 'family', 'decision', 'curious'];
const focusFeelings = ['hopeful', 'stuck', 'uncertain', 'curious'];

String focusAreaLabel(String area) => switch (area) {
  'love' => tr('Love'),
  'work' => tr('Work'),
  'self' => tr('Myself'),
  'family' => tr('Family'),
  'decision' => tr('A decision'),
  _ => tr('Just curious'),
};

String focusFeelingLabel(String feeling) => switch (feeling) {
  'hopeful' => tr('Hopeful'),
  'stuck' => tr('Stuck'),
  'uncertain' => tr('Uncertain'),
  _ => tr('Curious'),
};

/// The area as it reads inside a sentence ("your question about work").
/// Null for "just curious", which is not a topic.
String? focusAreaTopic(String? area) => switch (area) {
  'love' => tr('love'),
  'work' => tr('work'),
  'self' => tr('yourself'),
  'family' => tr('family'),
  'decision' => tr('your decision'),
  _ => null,
};

String? _feelingTopic(String? feeling) => switch (feeling) {
  'hopeful' => tr('hope'),
  'stuck' => tr('feeling stuck'),
  'uncertain' => tr('uncertainty'),
  'curious' => tr('curiosity'),
  _ => null,
};

/// "Focusing your first reading on work and uncertainty." Null when nothing
/// was chosen.
String? focusReflection(String? area, String? feeling) {
  final a = focusAreaTopic(area);
  final f = _feelingTopic(feeling);
  if (a != null && f != null) {
    return tr('Focusing your first reading on {0} and {1}.', [a, f]);
  }
  if (a != null || f != null) {
    return tr('Focusing your first reading on {0}.', [a ?? f!]);
  }
  return null;
}

/// Two optional tap questions (what is on your mind, how it feels), then a
/// short line saying how the first reading will use them. Every step can be
/// skipped. The answers stay on the phone and go only with reading requests.
class FocusQuestions extends StatefulWidget {
  const FocusQuestions({super.key, required this.onDone});

  /// Called with the answers (either may be null) when the flow ends.
  final void Function(String? area, String? feeling) onDone;

  @override
  State<FocusQuestions> createState() => _FocusQuestionsState();
}

class _FocusQuestionsState extends State<FocusQuestions> {
  int _step = 0;
  String? _area;
  String? _feeling;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    if (focusReflection(_area, _feeling) == null) {
      widget.onDone(_area, _feeling);
      return;
    }
    setState(() => _step = 2);
    _timer = Timer(
      const Duration(milliseconds: 2200),
      () => widget.onDone(_area, _feeling),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_step == 2) {
      return Center(
        key: const ValueKey('focus-reflection'),
        child: Text(
          focusReflection(_area, _feeling)!,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.goldLight,
          ),
        ),
      );
    }
    final first = _step == 0;
    final options = first ? focusAreas : focusFeelings;
    final selected = first ? _area : _feeling;
    return Column(
      key: ValueKey('focus-step-$_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    first
                        ? tr('What is on your mind?')
                        : tr('How does it feel right now?'),
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final o in options)
                        ChoiceChip(
                          key: ValueKey('focus-$o'),
                          label: Text(
                            first ? focusAreaLabel(o) : focusFeelingLabel(o),
                          ),
                          selected: selected == o,
                          onSelected: (on) => setState(() {
                            final v = on ? o : null;
                            if (first) {
                              _area = v;
                            } else {
                              _feeling = v;
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr(
                      'Optional. Used only to shape your readings: sent with each reading to our AI provider, never stored by us. Change it any time in Settings.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        FilledButton(
          key: const ValueKey('focus-next'),
          onPressed: selected == null ? null : _next,
          child: Text(tr('Next')),
        ),
        TextButton(
          key: const ValueKey('focus-skip'),
          onPressed: () {
            if (first) {
              _area = null;
            } else {
              _feeling = null;
            }
            _next();
          },
          child: Text(tr('Skip')),
        ),
      ],
    );
  }
}

/// Settings > Reading settings > Your focus: answer the questions again.
class FocusSettingsScreen extends StatelessWidget {
  const FocusSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Your focus'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FocusQuestions(
            onDone: (area, feeling) {
              state.setFocus(area, feeling);
              if (context.mounted) context.pop();
            },
          ),
        ),
      ),
    );
  }
}
