import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

/// Teaches how to use the app, plus a short tarot primer for beginners.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const _howTo = [
    (
      Icons.center_focus_strong,
      'Scan a card',
      'On the Read tab choose Photo reading. Hold one card inside the gold frame, in good light, and tap Scan card. Your photo is read on your phone and is never saved or uploaded. Confirm the card ShenTarot shows, and say if it is upright or reversed.',
    ),
    (
      Icons.search,
      'If the scan is unsure',
      'You will see the best guesses. Tap the right one, or choose Pick a card manually and search by name. You can always undo the last card.',
    ),
    (
      Icons.auto_awesome,
      'No deck with you?',
      'Tap the arrows next to the main button to switch to Digital card reading. Think of your question, then tap each face-down card to turn it over.',
    ),
    (
      Icons.dashboard_customize_outlined,
      'Pick a spread',
      'One card is a quick answer. Three cards show past, present and future. The Celtic Cross uses ten cards for a deeper look. Spreads of more than one card are Premium.',
    ),
    (
      Icons.edit_note,
      'Ask a clear question',
      'Open questions work best, like "What should I focus on this week?". Leave it blank for a general reading. Please keep personal details out of your question.',
    ),
    (
      Icons.chat_bubble_outline,
      'Follow-ups and journal',
      'Premium members can ask follow-up questions about a reading and add private journal notes. Your history and notes stay on your phone.',
    ),
    (
      Icons.notifications_outlined,
      'A daily reminder',
      'Turn it on under You > Daily card reminder. It is a notification on your phone; nothing is sent to a server.',
    ),
  ];

  static const _basics = [
    (
      'Major and Minor Arcana',
      'A tarot deck has 78 cards. The 22 Major Arcana cards (The Fool to The World) stand for big life themes. The 56 Minor Arcana cards are everyday matters, split into four suits.',
    ),
    (
      'The four suits',
      'Wands: energy, ambition and action. Cups: feelings and relationships. Swords: thoughts, truth and conflict. Pentacles: work, money and the practical world.',
    ),
    (
      'Upright and reversed',
      'A card that appears upside-down is "reversed". It often points to the same theme turned inward, blocked or in need of attention. It is not automatically bad.',
    ),
    (
      'How to read the result',
      'Treat a reading as a prompt for reflection, not a prediction. Ask what the cards bring to mind and how it fits your situation. ShenTarot is for entertainment and self-reflection only.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How to use ShenTarot',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final (icon, title, body) in _howTo)
            Card(
              child: ExpansionTile(
                leading: Icon(icon, color: AppColors.gold),
                title: Text(title),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Text(
                    body,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Tarot basics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final (title, body) in _basics)
            Card(
              child: ExpansionTile(
                title: Text(title),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Text(
                    body,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/library'),
            child: const Text('Browse all 78 cards'),
          ),
        ],
      ),
    );
  }
}
