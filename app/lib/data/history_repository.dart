import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'deck.dart';
import 'models.dart';

/// Reading history stored on the device only. Nothing here is uploaded.
abstract class HistoryRepository {
  /// Newest first.
  Future<List<Reading>> load(Deck deck);
  Future<void> add(Reading reading);
  Future<void> setNote(String id, String? note);
  Future<void> delete(String id);
  Future<void> clear();
}

class InMemoryHistoryRepository implements HistoryRepository {
  final Map<String, Reading> _rows = {};

  @override
  Future<List<Reading>> load(Deck deck) async =>
      _rows.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<void> add(Reading r) async => _rows[r.id] = r;

  @override
  Future<void> setNote(String id, String? note) async {
    final r = _rows[id];
    if (r != null) _rows[id] = r.withNote(note);
  }

  @override
  Future<void> delete(String id) async => _rows.remove(id);

  @override
  Future<void> clear() async => _rows.clear();
}

/// SQLite via sqflite. Pass [path] (or `inMemoryDatabasePath`) for tests.
class SqliteHistoryRepository implements HistoryRepository {
  SqliteHistoryRepository({this.path});

  final String? path;
  Database? _db;

  Future<Database> _open() async {
    final existing = _db;
    if (existing != null) return existing;
    final location = path ?? p.join(await getDatabasesPath(), 'shentarot.db');
    return _db = await openDatabase(
      location,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE readings (
          id TEXT PRIMARY KEY,
          created_at INTEGER NOT NULL,
          spread TEXT NOT NULL,
          cards TEXT NOT NULL,
          interpretation TEXT NOT NULL,
          question TEXT,
          note TEXT
        )'''),
    );
  }

  @override
  Future<List<Reading>> load(Deck deck) async {
    final rows = await (await _open()).query(
      'readings',
      orderBy: 'created_at DESC',
    );
    final out = <Reading>[];
    for (final row in rows) {
      final cards = <DrawnCard>[];
      for (final c in jsonDecode(row['cards']! as String) as List) {
        final card = deck.byId((c as Map)['id'] as String);
        if (card != null) {
          cards.add(DrawnCard(card: card, reversed: c['reversed'] as bool));
        }
      }
      if (cards.isEmpty) continue; // unknown cards: skip a corrupt row
      out.add(
        Reading(
          id: row['id']! as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at']! as int,
          ),
          spread: SpreadType.values.byName(row['spread']! as String),
          cards: cards,
          interpretation: row['interpretation']! as String,
          question: row['question'] as String?,
          note: row['note'] as String?,
        ),
      );
    }
    return out;
  }

  @override
  Future<void> add(Reading r) async => (await _open()).insert('readings', {
    'id': r.id,
    'created_at': r.createdAt.millisecondsSinceEpoch,
    'spread': r.spread.name,
    'cards': jsonEncode([
      for (final c in r.cards) {'id': c.card.id, 'reversed': c.reversed},
    ]),
    'interpretation': r.interpretation,
    'question': r.question,
    'note': r.note,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  @override
  Future<void> setNote(String id, String? note) async {
    final clean = note == null || note.trim().isEmpty ? null : note.trim();
    await (await _open()).update(
      'readings',
      {'note': clean},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(String id) async =>
      (await _open()).delete('readings', where: 'id = ?', whereArgs: [id]);

  @override
  Future<void> clear() async => (await _open()).delete('readings');
}
