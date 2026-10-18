import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/features/reading/reading_problem.dart';

void main() {
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );
    return ctx;
  }

  testWidgets('offline: says so, keeps the cards, retries', (tester) async {
    final ctx = await pumpHost(tester);
    var retried = 0;
    showReadingProblem(
      ctx,
      const ReadingException(ReadingErrorKind.network, 'No connection.'),
      onRetry: () => retried++,
    );
    await tester.pumpAndSettle();
    expect(find.text('Can\'t reach the reader'), findsOneWidget);
    expect(
      find.text('Your cards and question are kept, so you can try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(retried, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('busy: no Retry without a callback', (tester) async {
    final ctx = await pumpHost(tester);
    showReadingProblem(
      ctx,
      const ReadingException(ReadingErrorKind.failed, 'Busy.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('The reader is busy'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });
}
