import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/spreads.dart';
import 'history_filter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';
  SpreadCategory? _category;
  HistoryPeriod _period = HistoryPeriod.any;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final all = state.history;
    final items = filterHistory(
      all,
      query: _query,
      category: _category,
      period: _period,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: all.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_stories_outlined,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No readings yet',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.go('/read'),
                      child: const Text('Draw your first card'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search cards, questions, notes',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      for (final c in SpreadCategory.values) ...[
                        const SizedBox(width: 6),
                        ChoiceChip(
                          label: Text(c.label),
                          selected: _category == c,
                          onSelected: (_) => setState(() => _category = c),
                        ),
                      ],
                      const SizedBox(width: 12),
                      DropdownButton<HistoryPeriod>(
                        value: _period,
                        underline: const SizedBox.shrink(),
                        items: [
                          for (final p in HistoryPeriod.values)
                            DropdownMenuItem(value: p, child: Text(p.label)),
                        ],
                        onChanged: (p) => setState(() => _period = p!),
                      ),
                    ],
                  ),
                ),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No readings match.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = items[i];
                      final d = r.createdAt;
                      return Dismissible(
                        key: ValueKey(r.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red.shade900,
                          child: const Icon(Icons.delete_outline),
                        ),
                        onDismissed: (_) {
                          state.deleteReading(r.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reading deleted')),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(
                              r.cards.map((c) => c.card.name).join(', '),
                            ),
                            subtitle: Text(
                              '${r.spread.label} · ${MaterialLocalizations.of(context).formatMediumDate(d)}',
                            ),
                            leading: r.note == null
                                ? null
                                : const Icon(
                                    Icons.edit_note,
                                    color: AppColors.gold,
                                  ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/reading/${r.id}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
