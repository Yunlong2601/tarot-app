import 'package:flutter/material.dart';

import '../../app/motion.dart';
import '../../app/i18n.dart';

/// Asks which way up a manually picked card is. Null if dismissed.
Future<bool?> askOrientation(BuildContext context) => showAppDialog<bool>(
  context: context,
  builder: (ctx) => SimpleDialog(
    title: Text(tr('Which way up?')),
    children: [
      SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, false),
        child: Text(tr('Upright')),
      ),
      SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, true),
        child: Text(tr('Reversed')),
      ),
    ],
  ),
);
