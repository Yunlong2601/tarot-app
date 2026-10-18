import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/birth_cards.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';

/// Birth cards and this year's card from a birthday. Free, worked out on the
/// phone; the date is not saved or sent anywhere.
class BirthCardScreen extends StatefulWidget {
  const BirthCardScreen({super.key});

  @override
  State<BirthCardScreen> createState() => _BirthCardScreenState();
}

class _BirthCardScreenState extends State<BirthCardScreen> {
  DateTime? _birthday;

  Future<void> _pick() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Your birthday',
    );
    if (d != null) setState(() => _birthday = d);
  }

  TarotCard? _major(BuildContext context, int n) =>
      AppScope.of(context).deck.cards
          .where((c) => c.arcana == Arcana.major && c.number == n)
          .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final b = _birthday;
    final year = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: const Text('Birth cards')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Your birth cards', style: t.headlineSmall),
          const SizedBox(height: 6),
          const Text(
            'A traditional numerology method: add your birth month, day and '
            'year, then add the digits until you reach a Major Arcana card. '
            'They describe themes you may grow into, not a fixed fate.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.cake_outlined),
            label: Text(
              b == null
                  ? 'Enter your birthday'
                  : MaterialLocalizations.of(context).formatMediumDate(b),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Worked out on your phone. Your birthday is not saved or sent.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          if (b != null) ...[
            const SizedBox(height: 24),
            _CardRow(
              title: 'Birth cards',
              cards: [
                for (final n in birthCardNumbers(b.year, b.month, b.day))
                  ?_major(context, n),
              ],
            ),
            const SizedBox(height: 24),
            _CardRow(
              title: 'Your card for $year',
              cards: [?_major(context, yearCardNumber(b.month, b.day, year))],
            ),
          ],
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.title, required this.cards});
  final String title;
  final List<TarotCard> cards;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: AppColors.gold),
      ),
      const SizedBox(height: 8),
      for (final c in cards)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CardArt(card: c, width: 40),
          title: Text(c.name),
          subtitle: Text(
            c.knowledge?.essence ?? c.keywords.join(', '),
            style: const TextStyle(color: AppColors.textMuted),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/card/${c.id}'),
        ),
    ],
  );
}
