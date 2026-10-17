import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/reading_service.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';
import '../spreads/spread_layout.dart';
import '../scan/orientation_dialog.dart';
import 'reading_sections.dart';
import 'report_reading.dart';

import 'dart:math';

import '../../app/motion.dart';
import '../../app/i18n.dart';

class _AskDialog extends StatefulWidget {
  const _AskDialog();

  @override
  State<_AskDialog> createState() => _AskDialogState();
}

class _AskDialogState extends State<_AskDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(tr('Ask a follow-up')),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 300,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: tr('What would you like to explore?'),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr('Cancel')),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text.trim()),
        child: Text(tr('Ask')),
      ),
    ],
  );
}

/// Follow-up questions about this reading (Premium). Answers are shown here
/// for this visit only; they are not saved (save what matters in the journal).
class _FollowUps extends StatefulWidget {
  const _FollowUps({required this.reading});
  final Reading reading;

  @override
  State<_FollowUps> createState() => _FollowUpsState();
}

class _FollowUpsState extends State<_FollowUps> {
  final List<(String, String)> _thread = [];
  bool _busy = false;

  static const clarifierPrompt =
      'I drew a clarifier card. What does it add to this reading?';

  Future<void> _ask() async {
    final text = await showAppDialog<String>(
      context: context,
      builder: (_) => const _AskDialog(),
    );
    if (text == null || text.isEmpty || !mounted) return;
    await _send(text, text);
  }

  /// One extra card to shed light on the reading: drawn on screen, or picked
  /// from the user's own deck. Never a card already in the reading.
  Future<void> _clarify() async {
    final how = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(tr('Draw a clarifier card')),
              subtitle: Text(
                tr('One more card to shed light on this reading.'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.style_outlined),
              title: Text(tr('Draw one for me')),
              onTap: () => Navigator.pop(ctx, 'draw'),
            ),
            ListTile(
              leading: const Icon(Icons.back_hand_outlined),
              title: Text(tr('I drew one from my deck')),
              onTap: () => Navigator.pop(ctx, 'pick'),
            ),
          ],
        ),
      ),
    );
    if (how == null || !mounted) return;
    final state = AppScope.of(context);
    final used = {for (final c in widget.reading.cards) c.card.id};
    DrawnCard? card;
    if (how == 'draw') {
      final pool = state.deck.cards.where((c) => !used.contains(c.id)).toList();
      final rng = Random();
      card = DrawnCard(
        card: pool[rng.nextInt(pool.length)],
        reversed: state.readReversed && rng.nextDouble() < 0.25,
      );
    } else {
      final id = await context.push<String>('/pick');
      if (id == null || !mounted) return;
      if (used.contains(id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('That card is already in this reading.'))),
        );
        return;
      }
      final reversed = await askOrientation(context);
      if (reversed == null || !mounted) return;
      card = DrawnCard(card: state.deck.byId(id)!, reversed: reversed);
    }
    final label = tr('Clarifier: {0}{1}', [
      card.card.name,
      card.reversed ? ' (reversed)' : '',
    ]);
    await _send(clarifierPrompt, label, clarifier: card);
  }

  Future<void> _send(String text, String label, {DrawnCard? clarifier}) async {
    final state = AppScope.of(context);
    final r = widget.reading;
    setState(() => _busy = true);
    try {
      final result = await state.readingService.followUp(
        spread: r.spread,
        cards: r.cards,
        question: r.question,
        reading: r.interpretation,
        followUp: text,
        clarifier: clarifier,
      );
      if (mounted) setState(() => _thread.add((label, result.text)));
      state.refreshCredits();
    } on ReadingException catch (e) {
      if (!mounted) return;
      if (e.kind == ReadingErrorKind.premiumRequired) {
        context.push('/paywall');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (q, a) in _thread) ...[
          Text(
            '“$q”',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(a),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: _busy
              ? null
              : (state.isPremium || state.hasCredits
                    ? _ask
                    : () => context.push('/paywall')),
          icon: Icon(
            state.isPremium || state.hasCredits
                ? Icons.chat_bubble_outline
                : Icons.lock_outline,
          ),
          label: Text(
            _busy
                ? tr('Thinking...')
                : state.isPremium
                ? tr('Ask a follow-up')
                : state.hasCredits
                ? tr('Ask a follow-up (1 credit)')
                : tr('Ask a follow-up (Premium)'),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy
              ? null
              : (state.isPremium || state.hasCredits
                    ? _clarify
                    : () => context.push('/paywall')),
          icon: Icon(
            state.isPremium || state.hasCredits
                ? Icons.add_card_outlined
                : Icons.lock_outline,
          ),
          label: Text(
            state.isPremium
                ? tr('Draw a clarifier card')
                : state.hasCredits
                ? tr('Draw a clarifier card (1 credit)')
                : tr('Draw a clarifier card (Premium)'),
          ),
        ),
      ],
    );
  }
}

/// Journal note: free for everyone, kept on this phone.
class _Journal extends StatefulWidget {
  const _Journal({required this.reading});
  final Reading reading;

  @override
  State<_Journal> createState() => _JournalState();
}

class _JournalState extends State<_Journal> {
  late final _controller = TextEditingController(text: widget.reading.note);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          maxLines: 4,
          maxLength: 1000,
          decoration: InputDecoration(
            labelText: tr('Your journal note'),
            border: OutlineInputBorder(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {
              state.setNote(widget.reading.id, _controller.text);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(tr('Note saved'))));
            },
            child: Text(tr('Save note')),
          ),
        ),
      ],
    );
  }
}

/// About a week later (Premium): "how did this turn out?" Shows the saved
/// answer once written; hidden when dismissed or not due yet.
class _Revisit extends StatefulWidget {
  const _Revisit({required this.reading});
  final Reading reading;

  @override
  State<_Revisit> createState() => _RevisitState();
}

class _RevisitState extends State<_Revisit> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final r = widget.reading;
    final saved = r.revisit;
    if (saved != null && saved.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Looking back'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(saved),
          ],
        ),
      );
    }
    if (!state.revisitDue(r)) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Looking back'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              tr(
                tr(
                  'About a week has passed. How did this turn out, and did the reading help you think it through?',
                ),
              ),
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: tr('Since then...')),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => state.setRevisit(r.id, ''),
                  child: Text(tr('Not now')),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) return;
                    state.setRevisit(r.id, _controller.text);
                  },
                  child: Text(tr('Save')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key, required this.readingId});
  final String readingId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final reading = state.history.where((r) => r.id == readingId).firstOrNull;
    if (reading == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(tr('Reading not found'))),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(reading.spread.label),
        actions: [
          IconButton(
            tooltip: tr('Report a problem with this reading'),
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => reportReading(context, reading),
          ),
          IconButton(
            tooltip: tr('Delete reading'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showAppDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(tr('Delete this reading?')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(tr('Cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(tr('Delete')),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                state.deleteReading(reading.id);
                context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (reading.cards.length >= 5)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: SpreadLayoutView(
                  type: reading.spread,
                  slotBuilder: (i, w, h) => InkWell(
                    onTap: () =>
                        context.push('/card/${reading.cards[i].card.id}'),
                    child: CardArt(
                      card: reading.cards[i].card,
                      reversed: reading.cards[i].reversed,
                      width: w,
                    ),
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final (i, d) in reading.cards.indexed)
                  InkWell(
                    onTap: () => context.push('/card/${d.card.id}'),
                    child: Column(
                      children: [
                        CardArt(card: d.card, reversed: d.reversed, width: 90),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 96,
                          child: Text(
                            reading.spread.positions[i],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          if (reading.question != null) ...[
            const SizedBox(height: 20),
            Text(
              '“${reading.question}”',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 20),
          _ReadingText(reading),
          const SizedBox(height: 20),
          _FollowUps(reading: reading),
          const SizedBox(height: 12),
          _Journal(reading: reading),
          _Revisit(reading: reading),
        ],
      ),
    );
  }
}

/// Lays the reading out by section: the summary first, one panel per card
/// (with its art and a "Why this card" note to expand), then the question to
/// reflect on and a small step. Plain older readings show as text.
class _ReadingText extends StatelessWidget {
  const _ReadingText(this.reading);
  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final sections = parseReading(reading.interpretation);
    if (sections == null) return Text(reading.interpretation);
    final t = Theme.of(context).textTheme;
    final heading = t.titleMedium?.copyWith(color: AppColors.gold);
    Widget panel(Widget child, {bool highlight = false}) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.goldTint : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.goldDeep : const Color(0xFF2A2822),
        ),
      ),
      child: child,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in sections)
          switch (s.kind) {
            SectionKind.overview => panel(
              highlight: true,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: heading),
                  const SizedBox(height: 6),
                  Text(s.body, style: t.bodyLarge),
                ],
              ),
            ),
            SectionKind.card => panel(_CardSection(reading, s)),
            SectionKind.reflect || SectionKind.step => panel(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    s.kind == SectionKind.reflect
                        ? Icons.lightbulb_outline
                        : Icons.directions_walk,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: heading),
                        const SizedBox(height: 4),
                        Text(
                          s.body,
                          style: s.kind == SectionKind.reflect
                              ? const TextStyle(fontStyle: FontStyle.italic)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SectionKind.other => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s.title.isNotEmpty) Text(s.title, style: heading),
                  Text(s.body),
                ],
              ),
            ),
          },
      ],
    );
  }
}

class _CardSection extends StatefulWidget {
  const _CardSection(this.reading, this.section);
  final Reading reading;
  final ReadingSection section;

  @override
  State<_CardSection> createState() => _CardSectionState();
}

class _CardSectionState extends State<_CardSection> {
  bool _why = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    final i = s.cardIndex!;
    final drawn = i < widget.reading.cards.length
        ? widget.reading.cards[i]
        : null;
    final colon = s.title.indexOf(':');
    final position = s.title.substring(0, colon).trim();
    final name = s.title.substring(colon + 1).trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (drawn != null) ...[
              CardArt(card: drawn.card, reversed: drawn.reversed, width: 48),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    position.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(s.body),
        if (s.why != null && s.why!.isNotEmpty) ...[
          TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => setState(() => _why = !_why),
            icon: Icon(_why ? Icons.expand_less : Icons.expand_more, size: 18),
            label: Text(tr('Why this card')),
          ),
          if (_why)
            Text(
              s.why!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ],
    );
  }
}
