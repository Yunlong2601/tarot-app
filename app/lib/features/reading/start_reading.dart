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
  var text = mockInterpretation;
  if (!simulated) {
    final result = await _interpret(context, state, spread, cards, q);
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
  context.push('/reading/$id');
}

Future<ReadingResult?> _interpret(
  BuildContext context,
  AppState state,
  SpreadType spread,
  List<DrawnCard> cards,
  String question,
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
    );
  } on ReadingException catch (e) {
    failure = e;
  } finally {
    nav.pop(); // close the spinner
  }
  if (failure != null && context.mounted) {
    if (failure.kind == ReadingErrorKind.premiumRequired ||
        failure.kind == ReadingErrorKind.dailyLimit) {
      context.push('/paywall');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
  return result;
}
