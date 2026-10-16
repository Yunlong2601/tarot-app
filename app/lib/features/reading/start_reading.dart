import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../core/reading_service.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

/// Shared by photo and digital readings: checks the free/Premium rule, asks the
/// backend for the interpretation (with a spinner), saves the reading and opens
/// it. [simulated] readings (debug builds only) skip the backend.
Future<void> startReading(
  BuildContext context, {
  required SpreadType spread,
  required List<DrawnCard> cards,
  String? question,
  bool simulated = false,
}) async {
  final state = AppScope.of(context);
  if (!state.canStart(spread)) {
    context.push('/paywall');
    return;
  }
  final q = (question ?? '').trim();
  var text = mockInterpretation(spread, cards);
  if (!simulated) {
    String? impression;
    if (state.lookFirst) {
      impression = await _lookFirst(context, cards);
      if (!context.mounted) return;
      if (impression == null) return; // backed out
    }
    final result = await _interpret(
      context,
      state,
      spread,
      cards,
      q,
      impression ?? '',
    );
    if (result == null || !context.mounted) return;
    text = result.text;
  }
  final id = 'r${DateTime.now().microsecondsSinceEpoch}';
  state.addReading(
    Reading(
      id: id,
      createdAt: DateTime.now(),
      spread: spread,
      cards: cards,
      interpretation: text,
      question: q.isEmpty ? null : q,
    ),
  );
  // Back from the reading goes to the Read tab, not through the question and
  // spread screens again.
  final router = GoRouter.of(context);
  router.go('/read');
  router.push('/reading/$id');
}

Future<ReadingResult?> _interpret(
  BuildContext context,
  AppState state,
  SpreadType spread,
  List<DrawnCard> cards,
  String question,
  String impression,
) async {
  final nav = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  ReadingException? failure;
  ReadingResult? result;
  try {
    result = await state.readingService.interpret(
      spread: spread,
      cards: cards,
      question: question,
      impression: impression,
    );
  } on ReadingException catch (e) {
    failure = e;
  } finally {
    nav.pop(); // close the spinner
  }
  if (failure != null && context.mounted) {
    if (failure.kind == ReadingErrorKind.crisis) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('You are not alone'),
          content: Text(failure!.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (failure.kind == ReadingErrorKind.premiumRequired ||
        failure.kind == ReadingErrorKind.dailyLimit) {
      context.push('/paywall');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
  return result;
}

/// "Look first": before the reading, a moment to notice the cards yourself.
/// Returns the typed impression ('' if skipped), or null if the user backs out.
Future<String?> _lookFirst(BuildContext context, List<DrawnCard> cards) {
  final names = cards
      .map((c) => '${c.card.name}${c.reversed ? ' (reversed)' : ''}')
      .join(', ');
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Look first'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(names),
            const SizedBox(height: 12),
            const Text(
              'Before the reading, what do you notice? A colour, a figure, a '
              'feeling. Optional.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: 300,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'I notice...'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, ''),
          child: const Text('Skip'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: const Text('Read'),
        ),
      ],
    ),
  );
}
