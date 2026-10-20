import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models.dart';
import '../../app/i18n.dart';

/// Where problem reports go. Public support address (see the legal pages).
const reportEmail = 'shenyunlongbusiness@gmail.com';

/// Lets the user flag an AI-written reading that is offensive, harmful,
/// inaccurate or odd. Google Play expects apps with AI-generated content to
/// offer an in-app way to report it. The report is an email the user sees and
/// sends themselves; the app attaches only the card names and the reason, not
/// the question or the reading text, unless the user adds them.
Future<void> reportReading(BuildContext context, Reading reading) async {
  final reason = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              tr('What is wrong with this reading?'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          for (final r in [
            tr('Offensive or harmful'),
            tr('Inaccurate or makes no sense'),
            tr('Gives advice it should not'),
            tr('Something else'),
          ])
            ListTile(title: Text(r), onTap: () => Navigator.pop(ctx, r)),
        ],
      ),
    ),
  );
  if (reason == null || !context.mounted) return;
  final cards = reading.cards
      .map((c) => '${c.card.name}${c.reversed ? ' (reversed)' : ''}')
      .join(', ');
  final uri = Uri(
    scheme: 'mailto',
    path: reportEmail,
    queryParameters: {
      'subject': 'ShenTarot reading report: $reason',
      'body':
          'Reason: $reason\n'
          'Spread: ${reading.spread.label}\n'
          'Cards: $cards\n\n'
          'Add anything else you want us to know (you can paste the part of '
          'the reading that bothered you):\n',
    },
  );
  final ok = await launchUrl(uri);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr('No email app found. Write to {0} instead.', [reportEmail]),
        ),
      ),
    );
  }
}
