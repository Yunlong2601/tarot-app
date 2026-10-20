import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../app/i18n.dart';

/// Manual fallback: pick a card when recognition is unsure. Pops the chosen
/// card id.
class CardPickerScreen extends StatefulWidget {
  const CardPickerScreen({super.key});

  @override
  State<CardPickerScreen> createState() => _CardPickerScreenState();
}

class _CardPickerScreenState extends State<CardPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cards = AppScope.of(context).deck.search(_query);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Pick a card'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: tr('Search name or keyword'),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final c in cards)
                  ListTile(
                    title: Text(c.name),
                    subtitle: Text(c.keywords.join(', ')),
                    onTap: () => context.pop(c.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
