import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';
import '../cards/card_art.dart';

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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: 1000,
        decoration: const InputDecoration(
            labelText: 'Your journal note', border: OutlineInputBorder()),
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
    ]);
  }
}

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
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Delete')),
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
