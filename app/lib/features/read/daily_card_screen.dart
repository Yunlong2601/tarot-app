import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../reading/start_reading.dart';
import 'flip_card.dart';

/// Card of the Day: free, drawn on the phone, explained from stored card text
/// (no AI call, no cost). "Go deeper" starts a one-card reading with it.
class DailyCardScreen extends StatefulWidget {
  const DailyCardScreen({super.key});

  @override
  State<DailyCardScreen> createState() => _DailyCardScreenState();
}

class _DailyCardScreenState extends State<DailyCardScreen> {
  bool _flipped = false;
  DrawnCard? _card;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_card == null) {
      final state = AppScope.of(context);
      _card = state.drawDailyCard(null, false);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => state.notifyChanged(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawn = _card!;
    final card = drawn.card;
    final k = card.knowledge;
    final t = Theme.of(context).textTheme;
    final meaning = drawn.reversed
        ? (k?.reversedCore ?? card.reversed)
        : (k?.uprightCore ?? card.upright);
    final question = k == null
        ? null
        : (drawn.reversed ? k.reversedQuestion : k.uprightQuestion);
    return Scaffold(
      appBar: AppBar(title: const Text('Card of the Day')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: FlipCard(
              drawn: drawn,
              flipped: _flipped,
              onTap: () => setState(() => _flipped = true),
            ),
          ),
          const SizedBox(height: 16),
          if (!_flipped)
            const Text(
              'Take a breath, then tap the card to turn it over.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            )
          else ...[
            Text(
              '${card.name}${drawn.reversed ? ' (reversed)' : ''}',
              textAlign: TextAlign.center,
              style: t.headlineSmall,
            ),
            if (k != null) ...[
              const SizedBox(height: 6),
              Text(
                k.essence,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.gold),
              ),
            ],
            const SizedBox(height: 16),
            Text(meaning),
            if (k != null && !drawn.reversed) ...[
              const SizedBox(height: 8),
              Text(
                'Light: ${k.light}.  Shadow: ${k.shadow}.',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
            if (k != null && drawn.reversed) ...[
              const SizedBox(height: 8),
              for (final m in k.modes)
                Text(
                  '• $m',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
            ],
            if (question != null) ...[
              const SizedBox(height: 16),
              Text(
                'To reflect on today: $question',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [for (final w in card.keywords) Chip(label: Text(w))],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => startReading(
                context,
                spread: SpreadType.single,
                cards: [drawn],
              ),
              child: const Text('Go deeper: reading for this card'),
            ),
            TextButton(
              onPressed: () => context.push('/card/${card.id}'),
              child: const Text('Learn about this card'),
            ),
          ],
        ],
      ),
    );
  }
}
