import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../paywall/out_of_credits.dart';
import 'after_reading.dart';
import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/flags.dart';
import '../../core/reading_service.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../app/motion.dart';
import '../../app/ritual_loader.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import 'reading_problem.dart';

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
    if (creditsEnabled && !state.hasCredits) {
      await showOutOfCredits(context);
    } else {
      openPaywall(context, PaywallReason.lockedSpread);
    }
    return;
  }
  final q = (question ?? '').trim();
  var text = mockInterpretation(spread, cards);
  if (!simulated) {
    String? impression;
    if (state.lookFirst) {
      impression = await _lookFirst(
        context,
        cards,
        state.spendLabel(tr('Read'), spread: spread),
      );
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
    // A credit paid for this reading (unless it was the free try): say so,
    // with what is left.
    final paid = creditsEnabled && !state.usesTrial(spread);
    await state.refreshCredits();
    if (!context.mounted) return;
    if (paid && state.creditsKnown) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('1 credit used · {0} left', [state.credits])),
        ),
      );
    }
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
  router.go('/today');
  router.push('/reading/$id').then((_) {
    final ctx = router.routerDelegate.navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) afterReadingClosed(ctx, state);
  });
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
  showAppDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _Waiting(),
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
  } catch (_) {
    failure = ReadingException(
      ReadingErrorKind.failed,
      tr('Something went wrong. Please try again.'),
    );
  } finally {
    nav.pop(); // close the spinner
  }
  if (failure != null && context.mounted) {
    if (failure.kind == ReadingErrorKind.offTopic) {
      await showOffTopic(context, failure.message);
    } else if (failure.kind == ReadingErrorKind.crisis) {
      await showAppDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr('You are not alone')),
          content: Text(failure!.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('OK')),
            ),
          ],
        ),
      );
    } else if (failure.kind == ReadingErrorKind.dailyLimit && state.isPremium) {
      // Premium already has the paywall's benefits: explain the plan allowance.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'You have used today\'s readings for your plan. Use a credit, or come back after the daily reset (00:00 UTC).',
            ),
          ),
          duration: Duration(seconds: 8),
        ),
      );
    } else if (failure.kind == ReadingErrorKind.dailyLimit &&
        state.guestCouldSignIn) {
      await showSignInNudge(context);
    } else if (failure.kind == ReadingErrorKind.dailyLimit && creditsEnabled) {
      await showOutOfCredits(context);
    } else if (failure.kind == ReadingErrorKind.premiumRequired ||
        failure.kind == ReadingErrorKind.dailyLimit) {
      openPaywall(
        context,
        failure.kind == ReadingErrorKind.premiumRequired
            ? PaywallReason.lockedSpread
            : PaywallReason.outOfCredits,
      );
    } else {
      final canRetry =
          failure.kind == ReadingErrorKind.network ||
          failure.kind == ReadingErrorKind.failed;
      if (canRetry) {
        await showReadingProblem(
          context,
          failure,
          onRetry: () => startReading(
            context,
            spread: spread,
            cards: cards,
            question: question,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }
  return result;
}

/// "Look first": before the reading, a moment to notice the cards yourself.
/// Returns the typed impression ('' if skipped), or null if the user backs out.
Future<String?> _lookFirst(
  BuildContext context,
  List<DrawnCard> cards,
  String readLabel,
) {
  final names = cards.map((c) => cardLabel(c.card.name, c.reversed)).join(', ');
  final controller = TextEditingController();
  return showAppDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('Look first')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(names),
            const SizedBox(height: 12),
            Text(
              tr(
                tr(
                  'Before the reading, what do you notice? A colour, a figure, a feeling. Optional.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: 300,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: tr('I notice...')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(tr('Cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, ''),
          child: Text(tr('Skip')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: Text(readLabel),
        ),
      ],
    ),
  );
}

/// Shown while the reading is written. Readings usually take 5 to 20 seconds;
/// after a while the text says so, so a slow server does not look frozen.
class _Waiting extends StatefulWidget {
  const _Waiting();

  @override
  State<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends State<_Waiting> {
  static const _steps = [
    (Duration.zero, 'Reading your cards...'),
    (Duration(seconds: 8), 'Writing your reading...'),
    (Duration(seconds: 25), 'Still working. This can take up to a minute.'),
  ];
  final _watch = Stopwatch()..start();
  late final Timer _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) => setState(() {}),
  );

  @override
  void initState() {
    super.initState();
    _timer;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = tr(_steps.lastWhere((s) => _watch.elapsed >= s.$1).$2);
    return PopScope(
      canPop: false,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RitualLoader(),
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: Text(text, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The reader's friendly redirect for a question that is not about the user's
/// life. Nothing was charged. Offers example questions to try instead.
Future<void> showOffTopic(BuildContext context, String message) {
  final examples = [
    tr('What do I need to understand about my work right now?'),
    tr('How can I take care of myself this week?'),
    tr('What is helping and what is in the way in my relationship?'),
  ];
  return showAppDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.auto_awesome, color: AppColors.gold),
      title: Text(tr('Let\'s ask the cards about you')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          Text(
            tr('Questions that work well:'),
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          for (final e in examples)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('· $e'),
            ),
          const SizedBox(height: 12),
          Text(
            tr('No reading or credit was used.'),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('OK'))),
      ],
    ),
  );
}

/// A guest used today's free reading: signing in adds another one every day.
/// Premium is the second option; nothing is forced.
Future<void> showSignInNudge(BuildContext context) => showAppDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    icon: const Icon(Icons.auto_awesome, color: AppColors.gold),
    title: Text(tr('Get a second free reading every day')),
    content: Text(
      tr(
        'Guests get 1 free credit a day. Sign in and you get 2, and your Premium follows you to a new phone. Your readings stay on this phone either way.',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(tr('Not now')),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(ctx);
          openPaywall(context, PaywallReason.outOfCredits);
        },
        child: Text(tr('Go Premium')),
      ),
      FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
        onPressed: () {
          Navigator.pop(ctx);
          context.push('/account');
        },
        child: Text(tr('Sign in')),
      ),
    ],
  ),
);
