import 'dart:convert';
import 'dart:io';

import '../data/models.dart';
import 'install_id.dart';
import 'account_service.dart';
import 'credit_service.dart';
import 'referral_service.dart';
import 'reading_service.dart';
import 'user_key_store.dart';

/// Talks to the Cloudflare Worker (`backend/`). Sends only the card IDs,
/// orientation, spread and the optional question, plus an anonymous install ID.
class ApiReadingService
    implements ReadingService, AccountBackend, ReferralBackend, CreditBackend {
  ApiReadingService(
    this.baseUrl, {
    HttpClient Function()? clientFactory,
    this.userKey,
  }) : _newClient = clientFactory ?? HttpClient.new;

  final String baseUrl;

  /// Premium own-key mode: the key goes in headers to our server, which passes
  /// it to the provider for this one call and never stores or logs it.
  final Future<UserKey?> Function()? userKey;
  final HttpClient Function() _newClient;
  String? _token;

  @override
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    String? impression,
  }) async {
    final body = {
      'spread': spreadWireName(spread),
      'cards': [
        for (final c in cards) {'id': c.card.id, 'reversed': c.reversed},
      ],
      if (question != null && question.trim().isNotEmpty) 'question': question,
      if (impression != null && impression.trim().isNotEmpty)
        'impression': impression.trim(),
    };
    return _send('/v1/reading', body, 'reading');
  }

  @override
  Future<ReadingResult> followUp({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    required String reading,
    required String followUp,
    DrawnCard? clarifier,
  }) {
    return _send('/v1/followup', {
      'spread': spreadWireName(spread),
      'cards': [
        for (final c in cards) {'id': c.card.id, 'reversed': c.reversed},
      ],
      if (question != null && question.trim().isNotEmpty) 'question': question,
      'reading': reading,
      'followup': followUp,
      if (clarifier != null)
        'clarifier': {'id': clarifier.card.id, 'reversed': clarifier.reversed},
    }, 'answer');
  }

  @override
  Future<String> signIn(AccountProvider provider, String idToken) async {
    final res = await _post('/v1/account/signin', {
      'provider': provider.wire,
      'idToken': idToken,
    }, auth: true);
    final id = res.json['accountId'];
    if (res.status == 200 && id is String) return id;
    throw AccountException(switch (res.json['error']) {
      'accounts_not_configured' => 'Accounts are not available yet.',
      'invalid_token' => 'Sign-in could not be confirmed. Please try again.',
      'rate_limited' => 'Too many attempts. Please wait a minute.',
      _ => 'Sign-in failed. Please try again.',
    });
  }

  @override
  Future<void> signOut() async {
    await _post('/v1/account/signout', const {}, auth: true);
  }

  @override
  Future<void> deleteAccount() async {
    final res = await _post('/v1/account/delete', const {}, auth: true);
    if (res.status != 200) {
      throw const AccountException(
        'The account could not be deleted. Please try again.',
      );
    }
  }

  @override
  Future<CreditStatus> status() async {
    final res = await _post('/v1/credits/me', const {}, auth: true);
    if (res.status != 200) return const CreditStatus(balance: 0, dailyAmount: 0);
    final daily = res.json['daily'];
    return CreditStatus(
      balance: (res.json['balance'] as num?)?.toInt() ?? 0,
      dailyAmount: daily is Map ? (daily['amount'] as num?)?.toInt() ?? 0 : 0,
      monthlyAmount: daily is Map
          ? (daily['monthlyAmount'] as num?)?.toInt() ?? 0
          : 0,
    );
  }

  @override
  Future<int> claimDaily() async {
    final res = await _post('/v1/credits/daily', const {}, auth: true);
    return res.status == 200 ? (res.json['granted'] as num?)?.toInt() ?? 0 : 0;
  }

  @override
  Future<ReferralInfo> me() async {
    final res = await _post('/v1/referral/me', const {}, auth: true);
    if (res.status != 200) {
      throw const ReferralException('Invites are not available right now.');
    }
    return ReferralInfo.fromJson(res.json);
  }

  @override
  Future<ReferralOffer> redeem(String code, String platform) async {
    final res = await _post('/v1/referral/redeem', {
      'code': code,
      'platform': platform,
    }, auth: true);
    if (res.status == 200) {
      return ReferralOffer(
        appleOfferCode: res.json['appleOfferCode'] as String?,
        playOfferTag: res.json['offer'] as String?,
      );
    }
    throw ReferralException(switch (res.json['error']) {
      'unknown_code' => 'That code was not found. Check it and try again.',
      'own_code' => 'That is your own code. Share it with a friend instead.',
      'already_referred' => 'A friend\'s code is already used on this phone.',
      'no_codes_left' => 'Friend offers are out right now. Please try later.',
      'rate_limited' => 'Too many tries. Please wait a minute.',
      _ => 'The code could not be used. Please try again.',
    });
  }

  Future<ReadingResult> _send(
    String path,
    Map<String, Object?> body,
    String textKey,
  ) async {
    var res = await _post(path, body, auth: true);
    if (res.status == 401) {
      _token = null;
      res = await _post(path, body, auth: true);
    }
    return _toResult(res, textKey);
  }

  ReadingResult _toResult(_Response res, String textKey) {
    if (res.status == 200) {
      final j = res.json;
      if (j['crisis'] == true) {
        throw ReadingException(ReadingErrorKind.crisis, j['message'] as String);
      }
      return ReadingResult(
        text: j[textKey] as String,
        disclaimer: j['disclaimer'] as String,
      );
    }
    final error = res.json['error'];
    throw switch ((res.status, error)) {
      (429, 'daily_limit') => const ReadingException(
        ReadingErrorKind.dailyLimit,
        'You have used today\'s free reading.',
      ),
      (400, 'invalid_user_key' || 'user_key_rejected') =>
        const ReadingException(
          ReadingErrorKind.userKey,
          'Your AI key was not accepted. Check it in You > Your own AI key.',
        ),
      (402, _) => const ReadingException(
        ReadingErrorKind.premiumRequired,
        'This is part of Premium.',
      ),
      (422, _) => const ReadingException(
        ReadingErrorKind.declined,
        'A reading could not be made for this question. Try rewording it.',
      ),
      (429, _) || (503, _) => const ReadingException(
        ReadingErrorKind.failed,
        'The service is busy. Please try again in a minute.',
      ),
      _ => const ReadingException(
        ReadingErrorKind.failed,
        'Something went wrong. Please try again.',
      ),
    };
  }

  Future<_Response> _post(
    String path,
    Map<String, Object?> body, {
    required bool auth,
  }) async {
    final client = _newClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final headers = <String, String>{};
      if (auth) {
        headers['authorization'] = 'Bearer ${await _ensureToken()}';
        final own = await userKey?.call();
        if (own != null) {
          headers['x-user-provider'] = own.provider.wire;
          headers['x-user-key'] = own.key;
        }
      }
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
      throw const ReadingException(
        ReadingErrorKind.network,
        'No connection. Check your internet and try again.',
      );
    } on HttpException {
      throw const ReadingException(
        ReadingErrorKind.network,
        'No connection. Check your internet and try again.',
      );
    } finally {
      client.close();
    }
  }

  Future<String> _ensureToken() async {
    final existing = _token;
    if (existing != null) return existing;
    final res = await _post('/v1/install', {
      'installId': await loadInstallId(),
    }, auth: false);
    final token = res.json['token'];
    if (res.status != 200 || token is! String) {
      throw const ReadingException(
        ReadingErrorKind.failed,
        'Something went wrong. Please try again.',
      );
    }
    return _token = token;
  }
}

class _Response {
  _Response(this.status, this.json);
  final int status;
  final Map<String, dynamic> json;
}
