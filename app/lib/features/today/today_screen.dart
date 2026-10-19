import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/app_state.dart';
import '../../app/brand.dart';
import '../../app/i18n.dart';
import '../../app/theme.dart';
import '../guide/today_section.dart';
import '../paywall/annual_upgrade_card.dart';

/// The Today tab, the daily home: Card of the Day, your journey, a reading
/// to look back on, and quick ways into a photo or digital reading.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: BrandLockup(),
            ),
            if (state.dueRevisit case final due?) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: AppColors.gold),
                  title: Text(tr('Look back at last week\'s reading')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/reading/${due.id}'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const TodaySection(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    onPressed: () => startPhotoReading(context),
                    icon: const Icon(Icons.camera),
                    label: Text(tr('Scan card')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    onPressed: () => context.go('/read'),
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(tr('Draw digitally')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              state.creditLine,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const AnnualUpgradeCard(),
          ],
        ),
      ),
    );
  }
}

/// The middle Scan button and other shortcuts: a reading with your own cards.
void startPhotoReading(BuildContext context) {
  AppScope.of(context).setReadMode(ReadMode.photo);
  context.push('/ask');
}
