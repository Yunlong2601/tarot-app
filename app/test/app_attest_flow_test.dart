import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/core/api_reading_service.dart';
import 'package:shentarot/core/app_attest.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/data/models.dart';

/// Stands in for App Attest on the phone.
class FakeProof implements DeviceProof {
  FakeProof({this.canProve = true});
  final bool canProve;
  int resets = 0;
  int accepts = 0;
  int made = 0;

  @override
  Future<bool> get supported async => canProve;

  @override
  Future<Map<String, String>?> proofFor(
    String installId,
    String challenge,
  ) async {
    made++;
    return {
      'keyId': 'key$resets',
      'challenge': challenge,
      resets == 0 ? 'assertion' : 'attestation': 'proof-$made',
    };
  }

  @override
  Future<void> accepted() async => accepts++;

  @override
  Future<void> reset() async => resets++;
}

void main() {
  late HttpServer server;
  late List<(String, Map<String, Object?>)> seen;
  late List<int> installStatuses;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    seen = [];
    installStatuses = [200];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final body = jsonDecode(
        await utf8.decoder.bind(req).join(),
      ) as Map<String, Object?>;
      seen.add((req.uri.path, body));
      final (status, json) = switch (req.uri.path) {
        '/v1/install/challenge' => (200, {'challenge': 'ch${seen.length}'}),
        '/v1/install' => (
          installStatuses.length > 1
              ? installStatuses.removeAt(0)
              : installStatuses.first,
          {'token': 'tok', 'error': 'attestation_failed'},
        ),
        _ => (200, {'reading': 'A reading.', 'disclaimer': 'x'}),
      };
      req.response
        ..statusCode = status
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(json));
      await req.response.close();
    });
  });

  tearDown(() => server.close(force: true));

  Future<void> read(ApiReadingService svc) async {
    final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
    await svc.interpret(
      spread: SpreadType.single,
      cards: [DrawnCard(card: deck.cards.first, reversed: false)],
      question: '',
    );
  }

  test('sends the device proof with a fresh challenge', () async {
    final proof = FakeProof();
    await read(
      ApiReadingService('http://127.0.0.1:${server.port}', deviceProof: proof),
    );
    expect(seen.map((s) => s.$1), [
      '/v1/install/challenge',
      '/v1/install',
      '/v1/reading',
    ]);
    expect(seen[1].$2['challenge'], 'ch1');
    expect(seen[1].$2['assertion'], 'proof-1');
    expect(proof.accepts, 1);
  });

  test(
    'a refused proof is retried with a new key, then without proof',
    () async {
      installStatuses = [403, 403, 200];
      final proof = FakeProof();
      await read(
        ApiReadingService(
          'http://127.0.0.1:${server.port}',
          deviceProof: proof,
        ),
      );
      final installs = seen
          .where((s) => s.$1 == '/v1/install')
          .map((s) => s.$2)
          .toList();
      expect(installs, hasLength(3));
      expect(installs[0].containsKey('assertion'), isTrue);
      expect(installs[1].containsKey('attestation'), isTrue);
      expect(installs[2].keys, ['installId']);
      expect(proof.resets, 1);
      expect(proof.accepts, 0);
    },
  );

  test('phones without App Attest skip the challenge', () async {
    await read(
      ApiReadingService(
        'http://127.0.0.1:${server.port}',
        deviceProof: FakeProof(canProve: false),
      ),
    );
    expect(seen.map((s) => s.$1), ['/v1/install', '/v1/reading']);
  });
}
