import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/reading_service.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';
import '../spreads/spread_layout.dart';

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
    title: const Text('Ask a follow-up'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 300,
      maxLines: 3,
      decoration: const InputDecoration(
        hintText: 'What would you like to explore?',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text.trim()),
        child: const Text('Ask'),
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

  Future<void> _ask() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _AskDialog(),
    );
    if (text == null || text.isEmpty || !mounted) return;
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
      );
      if (mounted) setState(() => _thread.add((text, result.text)));
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
              : (state.isPremium ? _ask : () => context.push('/paywall')),
          icon: Icon(
            state.isPremium ? Icons.chat_bubble_outline : Icons.lock_outline,
          ),
          label: Text(
            _busy
                ? 'Thinking...'
                : state.isPremium
                ? 'Ask a follow-up'
                : 'Ask a follow-up (Premium)',
          ),
        ),
      ],
    );
  }
}

/// Journal note: Premium to write, readable by everyone who has one.
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
    if (!state.isPremium) {
      return OutlinedButton.icon(
        onPressed: () => context.push('/paywall'),
        icon: const Icon(Icons.lock_outline),
        label: const Text('Add a journal note (Premium)'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          maxLines: 4,
          maxLength: 1000,
          decoration: const InputDecoration(
            labelText: 'Your journal note',
            border: OutlineInputBorder(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {
              state.setNote(widget.reading.id, _controller.text);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Note saved')));
            },
            child: const Text('Save note'),
          ),
        ),
      ],
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
        body: const Center(child: Text('Reading not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(reading.spread.label),
        actions: [
          IconButton(
            tooltip: 'Delete reading',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete this reading?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete'),
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
          _ReadingText(reading.interpretation),
          const SizedBox(height: 20),
          _FollowUps(reading: reading),
          const SizedBox(height: 12),
          _Journal(reading: reading),
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

/// Shows the reading with its section titles ("In short", the card lines, "To
/// reflect on", "A small step") in the heading style. Older plain readings
/// have no titles and just show as text.
class _ReadingText extends StatelessWidget {
  const _ReadingText(this.text);
  final String text;

  static bool _isTitle(String line) =>
      line.length <= 70 &&
      !line.endsWith('.') &&
      !line.endsWith('?') &&
      !line.startsWith('Why:');

  @override
  Widget build(BuildContext context) {
    final blocks = text.split('\n\n');
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Builder(
              builder: (_) {
                final lines = b.split('\n');
                if (lines.length > 1 && _isTitle(lines.first)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lines.first,
                        style: t.titleMedium?.copyWith(color: AppColors.gold),
                      ),
                      const SizedBox(height: 4),
                      for (final l in lines.skip(1))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            l,
                            style: l.startsWith('Why:')
                                ? const TextStyle(
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  );
                }
                return Text(b);
              },
            ),
          ),
      ],
    );
  }
}
