import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/core/api_reading_service.dart';
import 'package:shentarot/core/reading_service.dart';
import 'package:shentarot/core/user_key_store.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';

void main() {
  late HttpServer server;
  late List<Map<String, Object?>> seen;
  late int readingStatus;
  late Map<String, Object?> readingBody;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    seen = [];
    readingStatus = 200;
    readingBody = {
      'reading': 'A reading.',
      'disclaimer': 'Entertainment only.',
    };
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final body = jsonDecode(await utf8.decoder.bind(req).join());
      seen.add({
        'path': req.uri.path,
        'auth': req.headers.value('authorization'),
        'provider': req.headers.value('x-user-provider'),
        'key': req.headers.value('x-user-key'),
        'body': body,
      });
      final isInstall = req.uri.path == '/v1/install';
      req.response
        ..statusCode = isInstall ? 200 : readingStatus
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(isInstall ? {'token': 'tok'} : readingBody));
      await req.response.close();
    });
  });

  tearDown(() => server.close(force: true));

  Future<List<DrawnCard>> cards() async {
    final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
    return [DrawnCard(card: deck.cards.first, reversed: true)];
  }

  test(
    'installs, then requests a reading with only ids and the question',
    () async {
      final svc = ApiReadingService('http://127.0.0.1:${server.port}');
      final r = await svc.interpret(
        spread: SpreadType.single,
        cards: await cards(),
        question: 'Hello?',
      );
      expect(r.text, 'A reading.');
      expect(seen.map((s) => s['path']), ['/v1/install', '/v1/reading']);
      expect(seen[1]['auth'], 'Bearer tok');
      expect(seen[1]['body'], {
        'spread': 'single',
        'cards': [
          {'id': 'major_00_fool', 'reversed': true},
        ],
        'question': 'Hello?',
      });
    },
  );

  test('sends the look-first impression only when there is one', () async {
    final svc = ApiReadingService('http://127.0.0.1:${server.port}');
    await svc.interpret(
      spread: SpreadType.single,
      cards: await cards(),
      impression: '  a bright sun  ',
    );
    expect((seen.last['body'] as Map)['impression'], 'a bright sun');
    await svc.interpret(
      spread: SpreadType.single,
      cards: await cards(),
      impression: '',
    );
    expect((seen.last['body'] as Map).containsKey('impression'), isFalse);
  });

  test('sends a clarifier card with a follow-up', () async {
    final svc = ApiReadingService('http://127.0.0.1:${server.port}');
    readingBody = {'answer': 'More.', 'disclaimer': 'd'};
    final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
    await svc.followUp(
      spread: SpreadType.single,
      cards: await cards(),
      reading: 'A reading.',
      followUp: 'What does it add?',
      clarifier: DrawnCard(card: deck.byId('cups_ace')!, reversed: true),
    );
    expect((seen.last['body'] as Map)['clarifier'], {
      'id': 'cups_ace',
      'reversed': true,
    });
  });

  test('own key goes in headers only when provided', () async {
    final key = 'sk-ant-${'k' * 40}';
    UserKey? own;
    final svc = ApiReadingService(
      'http://127.0.0.1:${server.port}',
      userKey: () async => own,
    );
    await svc.interpret(spread: SpreadType.single, cards: await cards());
    expect(seen.last['key'], isNull);
    own = UserKey(AiProvider.anthropic, key);
    await svc.interpret(spread: SpreadType.single, cards: await cards());
    expect(seen.last['provider'], 'anthropic');
    expect(seen.last['key'], key);
    expect(jsonEncode(seen.last['body']), isNot(contains(key)));
  });

  test('a rejected own key gets its own error', () async {
    final svc = ApiReadingService('http://127.0.0.1:${server.port}');
    readingStatus = 400;
    readingBody = {'error': 'user_key_rejected'};
    await expectLater(
      svc.interpret(spread: SpreadType.single, cards: await cards()),
      throwsA(
        isA<ReadingException>().having(
          (e) => e.kind,
          'kind',
          ReadingErrorKind.userKey,
        ),
      ),
    );
  });

  test('maps daily limit and premium errors', () async {
    final svc = ApiReadingService('http://127.0.0.1:${server.port}');
    readingStatus = 429;
    readingBody = {'error': 'daily_limit'};
    await expectLater(
      svc.interpret(spread: SpreadType.single, cards: await cards()),
      throwsA(
        isA<ReadingException>().having(
          (e) => e.kind,
          'kind',
          ReadingErrorKind.dailyLimit,
        ),
      ),
    );
    readingStatus = 402;
    readingBody = {'error': 'premium_required'};
    await expectLater(
      svc.interpret(spread: SpreadType.single, cards: await cards()),
      throwsA(
        isA<ReadingException>().having(
          (e) => e.kind,
          'kind',
          ReadingErrorKind.premiumRequired,
        ),
      ),
    );
  });

  test('unconfigured service refuses instead of inventing a reading', () {
    expect(
      () => const UnconfiguredReadingService().interpret(
        spread: SpreadType.single,
        cards: const [],
      ),
      throwsA(isA<ReadingException>()),
    );
  });
}
