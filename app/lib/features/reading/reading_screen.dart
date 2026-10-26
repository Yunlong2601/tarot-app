import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/brand.dart';
import '../../app/ritual_loader.dart';
import '../../app/theme.dart';
import '../../core/reading_service.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';
import '../spreads/spread_layout.dart';
import '../read/reader_voice.dart';
import '../scan/orientation_dialog.dart';
import 'reading_sections.dart';
import 'report_reading.dart';
import 'share_card.dart';
import 'reading_problem.dart';

import 'dart:math';

import '../../app/motion.dart';
import '../../app/i18n.dart';

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

  final _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _ask([String? preset]) async {
    final text = (preset ?? _composer.text).trim();
    if (text.isEmpty || _busy) return;
    FocusScope.of(context).unfocus();
    _composer.clear();
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
    final label = tr('Clarifier: {0}', [
      cardLabel(card.card.name, card.reversed),
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
      } else if (e.kind == ReadingErrorKind.network ||
          e.kind == ReadingErrorKind.failed) {
        showReadingProblem(
          context,
          e,
          onRetry: () => _send(text, label, clarifier: clarifier),
        );
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
    final open = state.isPremium || state.hasCredits;
    final cost = state.isPremium ? '' : tr('1 credit');
    final first = widget.reading.cards.isEmpty
        ? null
        : widget.reading.cards.first.card.name;
    final ideas = [
      tr('What should I watch out for?'),
      tr('What can I do about this this week?'),
      if (first != null) tr('Tell me more about {0}.', [first]),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.hairline)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                tr('Ask the reader'),
                style: const TextStyle(
                  fontFamily: displayFont,
                  fontFamilyFallback: displayFallback,
                  fontSize: 18,
                  color: AppColors.gold,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.hairline)),
          ],
        ),
        Center(
          child: Text(
            tr('AI · for reflection, not prediction'),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 16),
        for (final (q, a) in _thread) ...[
          UserLine(q),
          const SizedBox(height: 14),
          ReaderLine(a, body: true),
          const SizedBox(height: 22),
        ],
        if (_busy) ...[
          Row(
            children: [
              const RitualLoader(size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  first == null
                      ? tr('The reader is reflecting...')
                      : tr('Reading {0} against your question...', [first]),
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF8F8A80),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (!open)
          ReaderWhisper(
            icon: Icons.lock_outline,
            text: tr('Ask a follow-up (Premium)'),
            onTap: () => context.push('/paywall'),
          )
        else if (!_busy) ...[
          if (_thread.isEmpty)
            for (final idea in ideas)
              ReaderWhisper(
                text: idea,
                // Fills the line instead of sending: asking costs a credit.
                onTap: () {
                  _composer.text = idea;
                  _composer.selection = TextSelection.collapsed(
                    offset: idea.length,
                  );
                },
              ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('followup-input'),
                  controller: _composer,
                  maxLength: 300,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 17, height: 1.35),
                  decoration: InputDecoration(
                    hintText: tr('Ask the reader more...'),
                    hintStyle: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF8F8A80),
                    ),
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.hairline),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.hairline),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.goldDeep),
                    ),
                    counter: const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: const ValueKey('followup-send'),
                tooltip: tr('Ask'),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.onGold,
                  minimumSize: const Size(44, 44),
                ),
                onPressed: () => _ask(),
                icon: const Icon(Icons.north),
              ),
            ],
          ),
          if (cost.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tr('Each question uses {0}.', [cost]),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 10),
          ReaderWhisper(
            icon: Icons.add_card_outlined,
            text: state.isPremium
                ? tr('Draw a clarifier card')
                : tr('Draw a clarifier card (1 credit)'),
            onTap: _clarify,
          ),
        ],
        if (!open)
          ReaderWhisper(
            icon: Icons.lock_outline,
            text: tr('Draw a clarifier card (Premium)'),
            onTap: () => context.push('/paywall'),
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
        const SizedBox(height: 20),
        Text(
          tr('Your journal'),
          style: const TextStyle(
            fontFamily: displayFont,
            fontFamilyFallback: displayFallback,
            fontSize: 18,
            color: AppColors.gold,
          ),
        ),
        Text(
          tr('Private, kept on this phone. The reader never sees it.'),
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        // Ruled like a notebook page: writing on lines, not in a box.
        DecoratedBox(
          decoration: const BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: AppColors.goldDeep, width: 0.8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14),
            child: TextField(
              key: const ValueKey('journal-input'),
              controller: _controller,
              minLines: 3,
              maxLines: 10,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 17, height: 1.55),
              decoration: InputDecoration(
                hintText: tr('What did you notice in these cards?'),
                hintStyle: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF8F8A80),
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counter: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: () {
              state.setNote(widget.reading.id, _controller.text);
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(tr('Note saved'))));
            },
            icon: const Icon(Icons.edit_note, size: 20),
            label: Text(tr('Save note')),
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
            tooltip: tr('Share your reading'),
            icon: const Icon(Icons.ios_share),
            onPressed: () => shareReading(context, reading),
          ),
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
      body: _ReadingBody(
        reading: reading,
        head: [
          if (reading.cards.length >= 5)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: SpreadLayoutView(
                  type: reading.spread,
                  // Press and hold a card to see which position it sits in.
                  slotBuilder: (i, w, h) => Tooltip(
                    triggerMode: TooltipTriggerMode.longPress,
                    message:
                        '${i + 1}. ${reading.spread.positions[i]} · ${cardLabel(reading.cards[i].card.name, reading.cards[i].reversed)}',
                    child: InkWell(
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
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ],
        tail: [
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
  const _ReadingText(this.reading, {this.cardKeys = const {}});
  final Reading reading;

  /// One key per card section, so the pinned strip knows which is on screen.
  final Map<int, GlobalKey> cardKeys;

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
        for (final (i, s) in sections.indexed)
          _FadeIn(
            index: i,
            child: switch (s.kind) {
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
              SectionKind.card => KeyedSubtree(
                key: cardKeys[s.cardIndex],
                child: panel(_CardSection(reading, s)),
              ),
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
                                ? const TextStyle(fontWeight: FontWeight.w500)
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
          ),
      ],
    );
  }
}

/// Sections of a reading arrive one after another, softly, instead of all at
/// once. Skipped when the user asked for less motion.
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!brandAnimations || MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    final delay = (index * 0.12).clamp(0.0, 0.6);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (delay * 1000).round()),
      curve: Interval(delay / (0.42 + delay), 1, curve: Curves.easeOut),
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: c),
      ),
      child: child,
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
                    '${i + 1} · ${position.toUpperCase()}',
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
            Text(s.why!, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ],
    );
  }
}

/// The reading page: the spread and question, then a strip of the drawn cards
/// that pins under the app bar while the reading scrolls. The card you are
/// reading about is lit; tap a card to jump to its section.
class _ReadingBody extends StatefulWidget {
  const _ReadingBody({
    required this.reading,
    required this.head,
    required this.tail,
  });
  final Reading reading;
  final List<Widget> head;
  final List<Widget> tail;

  @override
  State<_ReadingBody> createState() => _ReadingBodyState();
}

class _ReadingBodyState extends State<_ReadingBody> {
  final _scroll = ScrollController();
  final _stripKey = GlobalKey();
  late final Map<int, GlobalKey> _keys = {
    for (var i = 0; i < widget.reading.cards.length; i++) i: GlobalKey(),
  };
  final _active = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_track);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _active.dispose();
    super.dispose();
  }

  /// The active card is the last section whose top has passed under the strip.
  void _track() {
    final strip = _stripKey.currentContext?.findRenderObject() as RenderBox?;
    if (strip == null || !strip.attached) return;
    final line = strip.localToGlobal(Offset(0, strip.size.height)).dy + 48;
    var active = 0;
    for (final e in _keys.entries) {
      final box = e.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= line) active = e.key;
    }
    _active.value = active;
  }

  void _jumpTo(int i) {
    final ctx = _keys[i]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSections =
        parseReading(widget.reading.interpretation)
            ?.any((s) => s.kind == SectionKind.card) ??
        false;
    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          sliver: SliverList.list(children: widget.head),
        ),
        if (hasSections && widget.reading.cards.length > 1)
          PinnedHeaderSliver(
            child: _SpreadStrip(
              key: _stripKey,
              reading: widget.reading,
              active: _active,
              onTap: _jumpTo,
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          sliver: SliverList.list(
            children: [
              _ReadingText(widget.reading, cardKeys: _keys),
              ...widget.tail,
            ],
          ),
        ),
      ],
    );
  }
}

/// Numbered thumbnails of the drawn cards on a hairline, like the plates
/// listed at the head of a chapter.
class _SpreadStrip extends StatelessWidget {
  const _SpreadStrip({
    super.key,
    required this.reading,
    required this.active,
    required this.onTap,
  });
  final Reading reading;
  final ValueListenable<int> active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 72,
          child: ValueListenableBuilder<int>(
            valueListenable: active,
            builder: (context, a, _) => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reading.cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final d = reading.cards[i];
                final on = i == a;
                return Semantics(
                  button: true,
                  selected: on,
                  label:
                      '${i + 1}. ${reading.spread.positions[i]}: ${cardLabel(d.card.name, d.reversed)}',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: on ? 1 : 0.55,
                      child: Column(
                        children: [
                          CardArt(
                            card: d.card,
                            reversed: d.reversed,
                            width: 28,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${i + 1}',
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              fontFamily: displayFont,
                              fontFamilyFallback: displayFallback,
                              fontSize: 12,
                              color: on ? AppColors.gold : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Divider(height: 1, thickness: 0.6, color: AppColors.goldDeep),
      ],
    ),
  );
}
