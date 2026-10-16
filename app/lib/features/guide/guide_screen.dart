import 'package:flutter/material.dart';

import 'today_section.dart';

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
      'One card is a quick answer. Three cards show past, present and future. The Celtic Cross uses ten cards for a deeper look. Every spread is free, one AI reading a day.',
    ),
    (
      Icons.edit_note,
      'Ask a clear question',
      'Open questions work best, like "What should I focus on this week?". Leave it blank for a general reading. Please keep personal details out of your question.',
    ),
    (
      Icons.chat_bubble_outline,
      'Follow-ups and journal',
      'Anyone can add private journal notes to a reading. Premium adds follow-up questions, a clarifier card and a look back a week later. Your history and notes stay on your phone.',
    ),
    (
      Icons.notifications_outlined,
      'A daily reminder',
      'Turn it on under You > Reminders. It is a notification on your phone, skipped on days you have already drawn your card; nothing is sent to a server.',
    ),
  ];

  static const _lessons = [
    (
      '1. What tarot is (and is not)',
      'Tarot is a deck of 78 picture cards used as a mirror for your own thinking. It is not a crystal ball. A good reading helps you notice what you already half know, and gives you words and questions to take away. ShenTarot treats every card as a prompt for reflection, never as a promise about the future.',
      'Pick a card and write one sentence about how it makes you feel.',
    ),
    (
      '2. Meet the deck',
      'The deck has two parts. The 22 Major Arcana are big life themes, from The Fool to The World. The 56 Minor Arcana are everyday matters, in four suits of 14 cards: Ace to Ten, then Page, Knight, Queen and King.',
      'Sort five cards from the Library into Major or Minor, then by suit.',
    ),
    (
      '3. Look before you read',
      'Four steps work for any card. See: what is in the picture? Feel: what is your first reaction? Name: what might that stand for? Ask: what does it say about my question? Start with your own eyes and use the written meaning second.',
      'Do these four steps with today\'s Card of the Day before opening its meaning.',
    ),
    (
      '4. The Major Arcana journey',
      'The Majors are often read as a story with three acts. Cards 1 to 7 are about building a self: skill, intuition, nurture, structure, belonging, choice and drive. Cards 8 to 14 turn inward: courage, solitude, cycles, fairness, pause, endings and balance. Cards 15 to 21 face what binds you and then integrate it. The Fool, number 0, is the traveller through all of it.',
      'Find your last drawn Major and say which act it belongs to.',
    ),
    (
      '5. The four suits',
      'Wands are Fire: drive and creativity. Cups are Water: feelings and relationships. Swords are Air: thoughts, speech and truth. Pentacles are Earth: work, money, body and home. Some traditions swap Wands and Swords; ShenTarot uses Wands for Fire and Swords for Air.',
      'Look at a card without reading its name and guess its suit from the picture.',
    ),
    (
      '6. Numbers 1 to 10',
      'In each suit the number tells the stage of the story: 1 a seed, 2 a choice, 3 growth, 4 stability, 5 friction, 6 relief, 7 a test, 8 movement, 9 near the end, 10 completion. Combine number and suit: the Five of Cups is friction in the world of feelings. This is a common way to read numbers, not the only one.',
      'Read the Five of Swords using only its number and suit, then check the card page.',
    ),
    (
      '7. Court cards',
      'Pages, Knights, Queens and Kings can be a person in your life, a side of you, or an approach to take. Page: a learner. Knight: someone in motion. Queen: the suit lived from the inside. King: the suit applied in the world. Let your question decide which fits.',
      'Draw a court card and decide: a person, a part of me, or an approach?',
    ),
    (
      '8. Reversed cards',
      'A reversed card is not bad news. It is another angle on the same theme. It may be blocked, turned inward, too much or too little, or fading. Many readers skip reversals altogether, and you can turn them off in You > Reversed cards.',
      'Read one card upright, then imagine it reversed. What changes?',
    ),
    (
      '9. Asking good questions',
      'Open questions give richer readings than yes or no ones. Stay on your own side of the story: ask what you can understand or do, not what another person thinks. Instead of "Will I get the job?" try "What should I keep in mind about this interview?" Cards cannot answer "when" questions well.',
      'Rewrite one question you have, so it starts with "What" or "How".',
    ),
    (
      '10. Spreads',
      'A spread gives each card a role. One card is a quick theme. Three cards can tell a story: where it began, where it stands, where it is heading. The Celtic Cross uses ten positions for a deep look: read the core first, then the roots and the aim, then the past and the near future, then the last four cards from the bottom up.',
      'Lay out a three-card spread and say what each position asks.',
    ),
    (
      '11. Reading cards together',
      'Meaning grows from relationships. Notice repeats: the same number or suit appearing again is the loudest signal. Many Major cards suggest big themes; mostly Minors point to everyday matters. A missing suit can say something too. Read cards in order as a story: what the first sets up and what the last answers.',
      'Draw two cards and say them in one sentence.',
    ),
    (
      '12. Keeping a journal',
      'Write down the date, your question, the cards and your first reaction. Come back a week later and add what actually happened. Over time you learn which readings helped and which you over-read. Premium members can add private notes to every reading, and they stay on your phone.',
      'Save a reading and add one line about how it feels now.',
    ),
  ];

  static const _myths = [
    (
      '"There are bad cards."',
      'Hard cards point to difficulty, change or limits. They are about growth and awareness, not doom.',
    ),
    (
      '"Death means death."',
      'It almost never does. It is read as an ending and a change.',
    ),
    (
      '"Reversed always means negative."',
      'It is another angle on the card, often softer or more private.',
    ),
    (
      '"Tarot can answer yes or no."',
      'It can start a conversation about your question; it cannot settle a fact.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TodaySection(),
          const SizedBox(height: 20),
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
            'Learn tarot in 12 short lessons',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final (title, body, practice) in _lessons)
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
                  const SizedBox(height: 8),
                  Text(
                    'Try it: $practice',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Myths and worries',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final (myth, answer) in _myths)
            Card(
              child: ExpansionTile(
                title: Text(myth),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedAlignment: Alignment.centerLeft,
                children: [
                  Text(
                    answer,
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
