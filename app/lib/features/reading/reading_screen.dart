import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key, required this.readingId});
  final String readingId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final reading =
        state.history.where((r) => r.id == readingId).firstOrNull;
    if (reading == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Reading not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(reading.spread.label)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            for (final d in reading.cards)
              InkWell(
                onTap: () => context.push('/card/${d.card.id}'),
                child: CardArt(card: d.card, reversed: d.reversed, width: 90),
              ),
          ]),
          if (reading.question != null) ...[
            const SizedBox(height: 20),
            Text('“${reading.question}”',
                style: const TextStyle(
                    fontStyle: FontStyle.italic, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 20),
          Text(reading.interpretation),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              if (state.isPremium) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Follow-ups arrive in Phase D')));
              } else {
                context.push('/paywall');
              }
            },
            icon: Icon(state.isPremium ? Icons.chat_bubble_outline : Icons.lock_outline),
            label: const Text('Ask a follow-up'),
          ),
          const SizedBox(height: 24),
          const Text(
            'For entertainment and self-reflection only. Not advice.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
