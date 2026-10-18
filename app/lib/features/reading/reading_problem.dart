import 'package:flutter/material.dart';

import '../../app/i18n.dart';
import '../../app/motion.dart';
import '../../app/theme.dart';
import '../../core/reading_service.dart';

/// A clear dialog when a reading or follow-up could not be made because the
/// phone is offline or the server is slow or busy. Says what happened, that
/// the cards and question are kept, and offers Retry when [onRetry] is given.
Future<void> showReadingProblem(
  BuildContext context,
  ReadingException failure, {
  VoidCallback? onRetry,
}) {
  final offline = failure.kind == ReadingErrorKind.network;
  return showAppDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(
        offline ? Icons.wifi_off_rounded : Icons.hourglass_bottom_rounded,
        color: AppColors.gold,
      ),
      title: Text(
        offline ? tr('Can\'t reach the reader') : tr('The reader is busy'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(failure.message),
          const SizedBox(height: 12),
          Text(
            tr('Your cards and question are kept, so you can try again.'),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(tr('Close')),
        ),
        if (onRetry != null)
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () {
              Navigator.pop(ctx);
              onRetry();
            },
            child: Text(tr('Retry')),
          ),
      ],
    ),
  );
}
