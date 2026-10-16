import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// Shows the bundled legal text (`assets/legal/*.txt`, generated from the
/// drafts in `docs/`). The stores also need the same text at a public URL.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final String doc;

  @override
  Widget build(BuildContext context) {
    final (title, file) = switch (doc) {
      'privacy' => ('Privacy Policy', 'privacy'),
      'terms' => ('Terms of Use', 'terms'),
      _ => ('Disclaimer', 'disclaimer'),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/legal/$file.txt'),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'For entertainment and self-reflection only. This text could not be loaded.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SelectableText(snap.data!),
          );
        },
      ),
    );
  }
}
