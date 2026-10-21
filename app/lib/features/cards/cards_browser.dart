import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_scope.dart';
import '../../data/deck.dart';
import 'card_art.dart';

/// The 78-card browser (search, filters, grid). Used inside the Library tab.
class CardsBrowser extends StatefulWidget {
  const CardsBrowser({super.key});

  @override
  State<CardsBrowser> createState() => _CardsBrowserState();
}

class _CardsBrowserState extends State<CardsBrowser> {
  String _query = '';
  CardFilter _filter = CardFilter.all;

  @override
  Widget build(BuildContext context) {
    final cards = AppScope.of(context).deck.search(_query, filter: _filter);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search name or keyword',
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final f in CardFilter.values)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  child: ChoiceChip(
                    label: Text(f.label),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: cards.isEmpty
              ? const Center(child: Text('No cards match'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  // Tile height = art (160) + gap + two lines of name text, which
                  // grows with the user's text size.
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    mainAxisExtent:
                        160 +
                        6 +
                        2 * MediaQuery.textScalerOf(context).scale(12) * 1.5 +
                        2,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, i) {
                    final c = cards[i];
                    return InkWell(
                      onTap: () => context.push('/card/${c.id}'),
                      child: Column(
                        children: [
                          CardArt(card: c, width: 100),
                          const SizedBox(height: 6),
                          Text(
                            c.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
