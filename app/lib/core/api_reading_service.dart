import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import 'reading_service.dart';

/// Talks to the Cloudflare Worker (`backend/`). Sends only the card IDs,
/// orientation, spread and the optional question, plus an anonymous install ID.
class ApiReadingService implements ReadingService {
  ApiReadingService(this.baseUrl, {HttpClient Function()? clientFactory})
      : _newClient = clientFactory ?? HttpClient.new;

  final String baseUrl;
  final HttpClient Function() _newClient;
  String? _token;

  static const _installKey = 'install_id';

  /// Also the RevenueCat app user ID (Phase E).
  Future<String> installId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_installKey);
    if (id == null) {
      id = _uuidV4();
      await prefs.setString(_installKey, id);
    }
    return id;
  }

  @override
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
  }) async {
    final body = {
      'spread': spreadWireName(spread),
      'cards': [
        for (final c in cards) {'id': c.card.id, 'reversed': c.reversed},
      ],
      if (question != null && question.trim().isNotEmpty) 'question': question,
    };
    var res = await _post('/v1/reading', body, auth: true);
    if (res.status == 401) {
      _token = null;
      res = await _post('/v1/reading', body, auth: true);
    }
    return _toResult(res);
  }

  ReadingResult _toResult(_Response res) {
    if (res.status == 200) {
      final j = res.json;
      return ReadingResult(
          text: j['reading'] as String, disclaimer: j['disclaimer'] as String);
    }
    final error = res.json['error'];
    throw switch ((res.status, error)) {
      (429, 'daily_limit') => const ReadingException(
          ReadingErrorKind.dailyLimit, 'You have used today\'s free reading.'),
      (402, _) => const ReadingException(ReadingErrorKind.premiumRequired,
          'This spread is part of Premium.'),
      (422, _) => const ReadingException(ReadingErrorKind.declined,
          'A reading could not be made for this question. Try rewording it.'),
      (429, _) || (503, _) => const ReadingException(ReadingErrorKind.failed,
          'The service is busy. Please try again in a minute.'),
      _ => const ReadingException(
          ReadingErrorKind.failed, 'Something went wrong. Please try again.'),
    };
  }

  Future<_Response> _post(String path, Map<String, Object?> body,
      {required bool auth}) async {
    final client = _newClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final headers = <String, String>{};
      if (auth) headers['authorization'] = 'Bearer ${await _ensureToken()}';
      final req = await client.postUrl(Uri.parse('$baseUrl$path'));
      req.headers.contentType = ContentType.json;
      headers.forEach(req.headers.set);
      req.add(utf8.encode(jsonEncode(body)));
      final resp = await req.close().timeout(const Duration(seconds: 60));
      final text = await resp.transform(utf8.decoder).join();
      Map<String, dynamic> json = {};
      try {
        json = jsonDecode(text) as Map<String, dynamic>;
      } catch (_) {}
      return _Response(resp.statusCode, json);
    } on SocketException {
      throw const ReadingException(ReadingErrorKind.network,
          'No connection. Check your internet and try again.');
    } on HttpException {
      throw const ReadingException(ReadingErrorKind.network,
          'No connection. Check your internet and try again.');
    } finally {
      client.close();
    }
  }

  Future<String> _ensureToken() async {
    final existing = _token;
    if (existing != null) return existing;
    final res =
        await _post('/v1/install', {'installId': await installId()}, auth: false);
    final token = res.json['token'];
    if (res.status != 200 || token is! String) {
      throw const ReadingException(ReadingErrorKind.failed,
          'Something went wrong. Please try again.');
    }
    return _token = token;
  }
}

class _Response {
  _Response(this.status, this.json);
  final int status;
  final Map<String, dynamic> json;
}

String _uuidV4() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String h(int from, int to) =>
      b.sublist(from, to).map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h(0, 4)}-${h(4, 6)}-${h(6, 8)}-${h(8, 10)}-${h(10, 16)}';
}
