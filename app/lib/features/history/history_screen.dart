import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../data/models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.history;
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: items.isEmpty
          ? const Center(
              child: Text('No readings yet',
                  style: TextStyle(color: AppColors.textMuted)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = items[i];
                final d = r.createdAt;
                return Card(
                  child: ListTile(
                    title: Text(r.cards.map((c) => c.card.name).join(', ')),
                    subtitle: Text(
                        '${r.spread.label} · ${d.day}/${d.month}/${d.year}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/reading/${r.id}'),
                  ),
                );
              },
            ),
    );
  }
}
