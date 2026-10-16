import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenscan/core/api_reading_service.dart';
import 'package:shenscan/core/reading_service.dart';
import 'package:shenscan/data/deck.dart';
import 'package:shenscan/data/models.dart';

void main() {
  late HttpServer server;
  late List<Map<String, Object?>> seen;
  late int readingStatus;
  late Map<String, Object?> readingBody;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    seen = [];
    readingStatus = 200;
    readingBody = {'reading': 'A reading.', 'disclaimer': 'Entertainment only.'};
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final body = jsonDecode(await utf8.decoder.bind(req).join());
      seen.add({
        'path': req.uri.path,
        'auth': req.headers.value('authorization'),
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
    final deck =
        Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
    return [DrawnCard(card: deck.cards.first, reversed: true)];
  }

  test('installs, then requests a reading with only ids and the question',
      () async {
    final svc = ApiReadingService('http://127.0.0.1:${server.port}');
    final r = await svc.interpret(
        spread: SpreadType.single, cards: await cards(), question: 'Hello?');
    expect(r.text, 'A reading.');
    expect(seen.map((s) => s['path']), ['/v1/install', '/v1/reading']);
    expect(seen[1]['auth'], 'Bearer tok');
    expect(seen[1]['body'], {
      'spread': 'single',
      'cards': [
        {'id': 'major_00_fool', 'reversed': true}
      ],
      'question': 'Hello?',
    });
  });

  test('maps daily limit and premium errors', () async {
    final svc = ApiReadingService('http://127.0.0.1:${server.port}');
    readingStatus = 429;
    readingBody = {'error': 'daily_limit'};
    await expectLater(
        svc.interpret(spread: SpreadType.single, cards: await cards()),
        throwsA(isA<ReadingException>()
            .having((e) => e.kind, 'kind', ReadingErrorKind.dailyLimit)));
    readingStatus = 402;
    readingBody = {'error': 'premium_required'};
    await expectLater(
        svc.interpret(spread: SpreadType.single, cards: await cards()),
        throwsA(isA<ReadingException>()
            .having((e) => e.kind, 'kind', ReadingErrorKind.premiumRequired)));
  });

  test('unconfigured service refuses instead of inventing a reading', () {
    expect(
        () => const UnconfiguredReadingService()
            .interpret(spread: SpreadType.single, cards: const []),
        throwsA(isA<ReadingException>()));
  });
}
