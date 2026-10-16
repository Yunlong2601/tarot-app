import 'package:flutter/material.dart';

/// Asks which way up a manually picked card is. Null if dismissed.
Future<bool?> askOrientation(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (ctx) => SimpleDialog(
    title: const Text('Which way up?'),
    children: [
      SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, false),
        child: const Text('Upright'),
      ),
      SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, true),
        child: const Text('Reversed'),
      ),
    ],
  ),
);
