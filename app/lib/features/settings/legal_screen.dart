import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../app/i18n.dart';

/// Shows the bundled legal text (`assets/legal/*.txt`, generated from the
/// drafts in `docs/`). The stores also need the same text at a public URL.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final String doc;

  @override
  Widget build(BuildContext context) {
    final (title, file) = switch (doc) {
      'privacy' => (tr('Privacy Policy'), 'privacy'),
      'terms' => (tr('Terms of Use'), 'terms'),
      _ => (tr('Disclaimer'), 'disclaimer'),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/legal/$file.txt'),
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                tr(
                  tr(
                    'For entertainment and self-reflection only. This text could not be loaded.',
                  ),
                ),
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (doc == 'terms') const _DisclaimerCard(),
                SelectableText(snap.data!),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The entertainment-only disclaimer, shown at the top of the Terms of Use.
class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: rootBundle.loadString('assets/legal/disclaimer.txt'),
    builder: (context, snap) => Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Disclaimer'),
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              snap.data ?? tr('For entertainment and self-reflection only.'),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    ),
  );
}
