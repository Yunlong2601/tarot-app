import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_scope.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../../core/analytics.dart';
import '../../core/reading_service.dart';
import '../../data/spreads.dart';
import '../reading/keepsake.dart';
import 'insights.dart';

/// Premium: "What the cards keep telling you", a short letter about the cards
/// that kept appearing this month. Written once a month from card counts
/// only, then kept on the phone.
Future<void> openMonthlyLetter(BuildContext context, MonthRecap recap) async {
  final writer = AppScope.of(context).readingService;
  final now = DateTime.now();
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final key = 'monthly_letter_${month}_${I18n.code}';
  logEvent('monthly_letter', {'month': month});
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _LetterSheet(
      month: monthLabel(now),
      load: () async {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString(key);
        if (saved != null) return saved;
        if (writer is! LetterWriter) {
          throw ReadingException(
            ReadingErrorKind.failed,
            tr(
              'Your letter could not be written right now. Please try again later.',
            ),
          );
        }
        final letter = await (writer as LetterWriter).monthlyLetter(
          month: month,
          readings: recap.readings,
          cards: [
            for (final (card, n) in recap.topCards) (id: card.id, count: n),
          ],
          groups: recap.groups,
        );
        await prefs.setString(key, letter);
        return letter;
      },
    ),
  );
}

class _LetterSheet extends StatefulWidget {
  const _LetterSheet({required this.month, required this.load});
  final String month;
  final Future<String> Function() load;

  @override
  State<_LetterSheet> createState() => _LetterSheetState();
}

class _LetterSheetState extends State<_LetterSheet> {
  late final Future<String> _letter = widget.load();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('What the cards keep telling you'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _letter,
              builder: (context, snap) {
                if (snap.hasError) {
                  final e = snap.error;
                  return Text(
                    e is ReadingException
                        ? e.message
                        : tr(
                            'Your letter could not be written right now. Please try again later.',
                          ),
                    style: const TextStyle(color: AppColors.textMuted),
                  );
                }
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      snap.data!,
                      key: const ValueKey('monthly-letter-text'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => openKeepsake(
                        context,
                        title: tr('What the cards keep telling you'),
                        subtitle: widget.month,
                        parts: [(heading: null, text: snap.data!)],
                        fileName: 'shentarot-letter',
                      ),
                      icon: const Icon(Icons.download_outlined),
                      label: Text(tr('Save as PDF or image')),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
