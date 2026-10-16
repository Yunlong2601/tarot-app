import 'package:flutter/material.dart';

/// Placeholder. Phase G supplies the lawyer-reviewed policy text, hosted at a
/// public URL (the stores require a URL as well as in-app access).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final String doc;

  @override
  Widget build(BuildContext context) {
    final title = switch (doc) {
      'privacy' => 'Privacy Policy',
      'terms' => 'Terms of Use',
      _ => 'Disclaimer',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
            'Draft placeholder. The reviewed text is added in Phase G.\n\n'
            'Veilscan is for entertainment and self-reflection only. It does '
            'not provide medical, legal, financial or life-or-death predictions.'),
      ),
    );
  }
}
