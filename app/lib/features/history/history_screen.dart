import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/spreads.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.history;
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: items.isEmpty
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
          : ListView.separated(
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
                      title: Text(r.cards.map((c) => c.card.name).join(', ')),
                      subtitle: Text(
                        '${r.spread.label} · ${d.day}/${d.month}/${d.year}',
                      ),
                      leading: r.note == null
                          ? null
                          : const Icon(Icons.edit_note, color: AppColors.gold),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/reading/${r.id}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
