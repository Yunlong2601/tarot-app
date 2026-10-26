import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/theme.dart';
import 'today_section.dart';
import '../../app/i18n.dart';

/// Teaches how to use the app, plus a short tarot course for beginners.
/// Layout: today's card, quick ways to start, how-to tiles (tap for details),
/// a 12-lesson course with progress kept on this phone, and common myths.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key, this.embedded = false});

  /// Inside the Learn tab: no app bar, and no Today or Start a reading
  /// sections (those have their own tabs).
  final bool embedded;

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  static const _doneKey = 'guide_lessons_done';
  Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _loadDone();
  }

  Future<void> _loadDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_doneKey) ?? const [];
      if (mounted) setState(() => _done = list.map(int.parse).toSet());
    } catch (_) {
      // Progress is a convenience; the Guide works without it.
    }
  }

  Future<void> _toggleDone(int i) async {
    setState(() => _done.contains(i) ? _done.remove(i) : _done.add(i));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_doneKey, _done.map((e) => '$e').toList());
    } catch (_) {}
  }

  static const _howTo = [
    (
      Icons.center_focus_strong,
      'Scan a card',
      'Tap the gold Scan button in the middle of the tab bar. For one card, hold it inside the gold frame in good light; that photo is read on your phone and never saved or uploaded. For a bigger spread you can take one photo of all the cards instead, which is sent once to name them and then deleted. Always check the cards ShenTarot shows before your reading.',
    ),
    (
      Icons.search,
      'If the scan is unsure',
      'You will see the best guesses. Tap the right one, or choose Pick a card manually and search by name. You can always undo the last card.',
    ),
    (
      Icons.auto_awesome,
      'No deck with you?',
      'Open the Draw tab and tap Digital card reading. Think of your question, then tap each face-down card to turn it over.',
    ),
    (
      Icons.dashboard_customize_outlined,
      'Pick a spread',
      'One card is a quick answer. Three cards show past, present and future. The Celtic Cross uses ten cards for a deeper look. One and three-card spreads are open to everyone, and each reading uses 1 credit; the 5, 7 and 10-card spreads are part of Premium, with one free try.',
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
      'Turn it on under You > Settings > Reminders. It is a notification on your phone, skipped on days you have already drawn your card; nothing is sent to a server.',
    ),
  ];

  static const _lessons = [
    (
      'What tarot is (and is not)',
      'Tarot is a deck of 78 picture cards used as a mirror for your own thinking. It is not a crystal ball. A good reading helps you notice what you already half know, and gives you words and questions to take away. ShenTarot treats every card as a prompt for reflection, never as a promise about the future.',
      'Pick a card and write one sentence about how it makes you feel.',
    ),
    (
      'Meet the deck',
      'The deck has two parts. The 22 Major Arcana are big life themes, from The Fool to The World. The 56 Minor Arcana are everyday matters, in four suits of 14 cards: Ace to Ten, then Page, Knight, Queen and King.',
      'Sort five cards from the Library into Major or Minor, then by suit.',
    ),
    (
      'Look before you read',
      'Four steps work for any card. See: what is in the picture? Feel: what is your first reaction? Name: what might that stand for? Ask: what does it say about my question? Start with your own eyes and use the written meaning second.',
      'Do these four steps with today\'s Card of the Day before opening its meaning.',
    ),
    (
      'The Major Arcana journey',
      'The Majors are often read as a story with three acts. Cards 1 to 7 are about building a self: skill, intuition, nurture, structure, belonging, choice and drive. Cards 8 to 14 turn inward: courage, solitude, cycles, fairness, pause, endings and balance. Cards 15 to 21 face what binds you and then integrate it. The Fool, number 0, is the traveller through all of it.',
      'Find your last drawn Major and say which act it belongs to.',
    ),
    (
      'The four suits',
      'Wands are Fire: drive and creativity. Cups are Water: feelings and relationships. Swords are Air: thoughts, speech and truth. Pentacles are Earth: work, money, body and home. Some traditions swap Wands and Swords; ShenTarot uses Wands for Fire and Swords for Air.',
      'Look at a card without reading its name and guess its suit from the picture.',
    ),
    (
      'Numbers 1 to 10',
      'In each suit the number tells the stage of the story: 1 a seed, 2 a choice, 3 growth, 4 stability, 5 friction, 6 relief, 7 a test, 8 movement, 9 near the end, 10 completion. Combine number and suit: the Five of Cups is friction in the world of feelings. This is a common way to read numbers, not the only one.',
      'Read the Five of Swords using only its number and suit, then check the card page.',
    ),
    (
      'Court cards',
      'Pages, Knights, Queens and Kings can be a person in your life, a side of you, or an approach to take. Page: a learner. Knight: someone in motion. Queen: the suit lived from the inside. King: the suit applied in the world. Let your question decide which fits.',
      'Draw a court card and decide: a person, a part of me, or an approach?',
    ),
    (
      'Reversed cards',
      'A reversed card is not bad news. It is another angle on the same theme. It may be blocked, turned inward, too much or too little, or fading. Many readers skip reversals altogether, and you can turn them off in You > Settings > Reading settings.',
      'Read one card upright, then imagine it reversed. What changes?',
    ),
    (
      'Asking good questions',
      'Open questions give richer readings than yes or no ones. Stay on your own side of the story: ask what you can understand or do, not what another person thinks. Instead of "Will I get the job?" try "What should I keep in mind about this interview?" Cards cannot answer "when" questions well.',
      'Rewrite one question you have, so it starts with "What" or "How".',
    ),
    (
      'Spreads',
      'A spread gives each card a role. One card is a quick theme. Three cards can tell a story: where it began, where it stands, where it is heading. The Celtic Cross uses ten positions for a deep look: read the core first, then the roots and the aim, then the past and the near future, then the last four cards from the bottom up.',
      'Lay out a three-card spread and say what each position asks.',
    ),
    (
      'Reading cards together',
      'Meaning grows from relationships. Notice repeats: the same number or suit appearing again is the loudest signal. Many Major cards suggest big themes; mostly Minors point to everyday matters. A missing suit can say something too. Read cards in order as a story: what the first sets up and what the last answers.',
      'Draw two cards and say them in one sentence.',
    ),
    (
      'Keeping a journal',
      'Write down the date, your question, the cards and your first reaction. Come back a week later and add what actually happened. Over time you learn which readings helped and which you over-read. You can add a private note to every reading, and notes stay on your phone.',
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

  void _startReading(BuildContext context, ReadMode mode) {
    AppScope.of(context).setReadMode(mode);
    context.push('/ask');
  }

  /// Where each how-to tile can take you, so the guide is also a shortcut.
  (String, VoidCallback)? _howToAction(BuildContext context, int i) =>
      switch (i) {
        0 => (
          'Start a photo reading',
          () => _startReading(context, ReadMode.photo),
        ),
        1 => null,
        2 => (
          'Start a digital reading',
          () => _startReading(context, ReadMode.digital),
        ),
        3 => (
          'See the spreads',
          () => _startReading(context, ReadMode.digital),
        ),
        4 => ('Ask a question', () => context.push('/ask')),
        5 => ('Open your readings', () => context.push('/history')),
        6 => ('Set a reminder', () => context.push('/settings/reminders')),
        _ => null,
      };

  Future<void> _showSheet(
    BuildContext context, {
    required Widget leading,
    required String title,
    required List<Widget> body,
    List<Widget> actions = const [],
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheet) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(sheet).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...body,
            if (actions.isNotEmpty) const SizedBox(height: 20),
            ...actions,
          ],
        ),
      ),
    );
  }

  void _openHowTo(BuildContext context, int i) {
    final (icon, title0, body0) = _howTo[i];
    final title = tr(title0);
    final body = tr(body0);
    final action = _howToAction(context, i);
    _showSheet(
      context,
      leading: _IconBadge(icon),
      title: title,
      body: [Text(body, style: const TextStyle(height: 1.5))],
      actions: [
        if (action != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              action.$2();
            },
            child: Text(tr(action.$1)),
          ),
      ],
    );
  }

  void _openLesson(BuildContext context, int i) {
    final (title0, body0, practice0) = _lessons[i];
    final title = tr(title0);
    final body = tr(body0);
    final practice = tr(practice0);
    _showSheet(
      context,
      leading: _LessonNumber(i + 1, done: _done.contains(i)),
      title: title,
      body: [
        Text(body, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.goldTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('TRY IT'),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(practice, style: const TextStyle(height: 1.4)),
            ],
          ),
        ),
      ],
      actions: [
        StatefulBuilder(
          builder: (_, setSheet) => FilledButton.icon(
            onPressed: () {
              _toggleDone(i);
              setSheet(() {});
            },
            icon: Icon(
              _done.contains(i) ? Icons.check_circle : Icons.circle_outlined,
            ),
            label: Text(tr(_done.contains(i) ? 'Done' : 'Mark as done')),
          ),
        ),
        if (i + 1 < _lessons.length) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _openLesson(context, i + 1);
            },
            child: Text(tr('Next: {0}', [tr(_lessons[i + 1].$1)])),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget header(String title, [String? subtitle]) => Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(tr(title), style: t.titleLarge)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ],
      ),
    );

    Widget pairs(List<Widget> tiles) => Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < tiles.length
                        ? tiles[i + 1]
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    final doneCount = _done.where((i) => i < _lessons.length).length;

    final list = ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (!widget.embedded) ...[
          const TodaySection(),
          header('Start a reading'),
          pairs([
            _Tile(
              icon: Icons.center_focus_strong,
              title: tr('Photo reading'),
              subtitle: tr('Scan your own cards'),
              onTap: () => _startReading(context, ReadMode.photo),
            ),
            _Tile(
              icon: Icons.auto_awesome,
              title: tr('Digital reading'),
              subtitle: tr('No deck needed'),
              onTap: () => _startReading(context, ReadMode.digital),
            ),
            _Tile(
              icon: Icons.wb_sunny_outlined,
              title: tr('Card of the Day'),
              subtitle: tr('Free, every day'),
              onTap: () => context.push('/daily'),
            ),
            _Tile(
              icon: Icons.style_outlined,
              title: tr('All 78 cards'),
              subtitle: tr('Meanings and art'),
              onTap: () => context.go('/learn'),
            ),
          ]),
        ],
        header('How ShenTarot works', tr('Tap a topic for the details.')),
        pairs([
          for (var i = 0; i < _howTo.length; i++)
            _Tile(
              icon: _howTo[i].$1,
              title: tr(_howTo[i].$2),
              onTap: () => _openHowTo(context, i),
            ),
        ]),
        header(
          'Learn tarot',
          tr('12 short lessons. {0} of {1} done.', [
            doneCount,
            _lessons.length,
          ]),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: doneCount / _lessons.length,
            minHeight: 6,
            color: AppColors.gold,
            backgroundColor: AppColors.goldTint,
            semanticsLabel: tr('Lessons done'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < _lessons.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 64),
                ListTile(
                  minVerticalPadding: 12,
                  leading: _LessonNumber(i + 1, done: _done.contains(i)),
                  title: Text(tr(_lessons[i].$1)),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => _openLesson(context, i),
                ),
              ],
            ],
          ),
        ),
        header('Myths and worries'),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < _myths.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(tr(_myths[i].$1)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedAlignment: Alignment.centerLeft,
                  children: [
                    Text(
                      tr(_myths[i].$2),
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!widget.embedded) ...[
          const SizedBox(height: 20),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => context.go('/learn'),
            child: Text(tr('Browse all 78 cards')),
          ),
        ],
      ],
    );
    if (widget.embedded) return list;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Guide'))),
      body: list,
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppColors.goldTint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: AppColors.gold, size: 22),
  );
}

class _LessonNumber extends StatelessWidget {
  const _LessonNumber(this.n, {required this.done});
  final int n;
  final bool done;

  @override
  Widget build(BuildContext context) => Semantics(
    label: done ? tr('Lesson {0}, done', [n]) : tr('Lesson {0}', [n]),
    excludeSemantics: true,
    child: Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.gold : Colors.transparent,
        border: Border.all(color: AppColors.gold),
      ),
      child: done
          ? const Icon(Icons.check, size: 18, color: AppColors.onGold)
          : Text(
              '$n',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(icon),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
