import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../data/models.dart';
import 'analytics.dart';
import 'app_attest.dart';
import 'install_id.dart';
import 'account_service.dart';
import 'credit_service.dart';
import 'creator_service.dart';
import 'referral_service.dart';
import 'reading_service.dart';
import 'user_key_store.dart';
import '../app/i18n.dart';

/// Talks to the Cloudflare Worker (`backend/`). Sends only the card IDs,
/// orientation, spread and the optional question, plus an anonymous install ID.
class ApiReadingService
    implements
        ReadingService,
        AccountBackend,
        ReferralBackend,
        CreditBackend,
        CreatorBackend,
        SpreadIdentifier,
        EventSink {
  ApiReadingService(
    this.baseUrl, {
    HttpClient Function()? clientFactory,
    this.userKey,
    this.focus,
    DeviceProof? deviceProof,
    this.retryDelay = const Duration(seconds: 2),
  }) : _newClient = clientFactory ?? HttpClient.new,
       _proof = deviceProof ?? AppAttest();

  final String baseUrl;

  /// Pause before retrying a reading that failed upstream.
  final Duration retryDelay;

  /// Premium own-key mode: the key goes in headers to our server, which passes
  /// it to the provider for this one call and never stores or logs it.
  final Future<UserKey?> Function()? userKey;

  /// The user's onboarding answers (life area, feeling), sent with readings.
  final Map<String, String>? Function()? focus;
  final HttpClient Function() _newClient;
  final DeviceProof _proof;
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
      'lang': I18n.code,
      'focus': ?focus?.call(),
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
      'lang': I18n.code,
    }, 'answer');
  }

  @override
  Future<String> signIn(
    AccountProvider provider,
    String idToken, {
    String? authorizationCode,
  }) async {
    final res = await _post('/v1/account/signin', {
      'provider': provider.wire,
      'idToken': idToken,
      'authorizationCode': ?authorizationCode,
    }, auth: true);
    final id = res.json['accountId'];
    if (res.status == 200 && id is String) return id;
    throw AccountException(switch (res.json['error']) {
      'accounts_not_configured' => tr('Accounts are not available yet.'),
      'invalid_token' => tr(
        'Sign-in could not be confirmed. Please try again.',
      ),
      'rate_limited' => tr('Too many attempts. Please wait a minute.'),
      _ => tr('Sign-in failed. Please try again.'),
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
      throw AccountException(
        tr('The account could not be deleted. Please try again.'),
      );
    }
  }

  @override
  Future<CreditStatus> status() async {
    final res = await _post('/v1/credits/me', const {}, auth: true);
    if (res.status != 200) {
      return const CreditStatus(balance: 0, dailyAmount: 0);
    }
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
  Future<CreatorOverview> mine() async {
    final res = await _post('/v1/creator/mine', const {}, auth: true);
    if (res.status != 200) return const CreatorOverview();
    return CreatorOverview(
      posts: [
        for (final p in (res.json['posts'] as List? ?? const []))
          CreatorPost.fromJson(p as Map<String, dynamic>),
      ],
      rules: res.json['rules'] is Map<String, dynamic>
          ? CreatorRules.fromJson(res.json['rules'] as Map<String, dynamic>)
          : const CreatorRules(),
    );
  }

  @override
  Future<int> submit({
    required String url,
    required Uint8List screenshot,
  }) async {
    final res = await _post('/v1/creator/submit', {
      'url': url,
      'screenshot': base64Encode(screenshot),
    }, auth: true);
    if (res.status == 200) return (res.json['credits'] as num?)?.toInt() ?? 0;
    throw CreatorException(switch (res.json['error']) {
      'invalid_link' => tr(
        'That is not a link to a post on TikTok, Instagram, YouTube, Xiaohongshu, Reddit, X, Facebook or Threads.',
      ),
      'invalid_screenshot' => tr(
        'The screenshot could not be used. Choose a PNG or JPEG under 1 MB.',
      ),
      'duplicate_link' => tr('You already sent this post.'),
      'daily_limit' => tr('One post a day earns credits. Come back tomorrow.'),
      'monthly_limit' => tr('You have reached this month\'s limit of posts.'),
      'rate_limited' => tr('Too many tries. Wait a minute and try again.'),
      _ => tr('The creator program is not available right now.'),
    });
  }

  @override
  Future<ReferralInfo> me() async {
    final res = await _post('/v1/referral/me', const {}, auth: true);
    if (res.status != 200) {
      throw ReferralException(tr('Invites are not available right now.'));
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
      'unknown_code' => tr('That code was not found. Check it and try again.'),
      'own_code' => tr(
        'That is your own code. Share it with a friend instead.',
      ),
      'already_referred' => 'A friend\'s code is already used on this phone.',
      'no_codes_left' => tr(
        'Friend offers are out right now. Please try later.',
      ),
      'rate_limited' => tr('Too many tries. Please wait a minute.'),
      _ => tr('The code could not be used. Please try again.'),
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
    // A passing upstream hiccup (the server refunds the credit on these):
    // try once more before showing the user an error.
    if (_isTransient(res, textKey)) {
      await Future<void>.delayed(retryDelay);
      res = await _post(path, body, auth: true);
    }
    return _toResult(res, textKey);
  }

  /// Server errors other than "busy" (502, 504, an unreadable reply) are
  /// usually a one-off upstream failure worth one quiet retry.
  static bool _isTransient(_Response res, String textKey) {
    if (res.status == 200) {
      final j = res.json;
      return j[textKey] is! String &&
          j['crisis'] != true &&
          j['off_topic'] != true;
    }
    return res.status >= 500 && res.status != 503;
  }

  ReadingResult _toResult(_Response res, String textKey) {
    if (res.status == 200) {
      final j = res.json;
      if (j['crisis'] == true) {
        throw ReadingException(ReadingErrorKind.crisis, j['message'] as String);
      }
      if (j['off_topic'] == true) {
        throw ReadingException(
          ReadingErrorKind.offTopic,
          j['message'] as String,
        );
      }
      return ReadingResult(
        text: j[textKey] as String,
        disclaimer: j['disclaimer'] as String,
      );
    }
    final error = res.json['error'];
    throw switch ((res.status, error)) {
      (429, 'daily_limit') => ReadingException(
        ReadingErrorKind.dailyLimit,
        tr('You have used today\'s free reading.'),
      ),
      (400, 'invalid_user_key' || 'user_key_rejected') => ReadingException(
        ReadingErrorKind.userKey,
        tr('Your AI key was not accepted. Check it in You > Your own AI key.'),
      ),
      (402, _) => ReadingException(
        ReadingErrorKind.premiumRequired,
        tr('This is part of Premium.'),
      ),
      (422, _) => const ReadingException(
        ReadingErrorKind.declined,
        'A reading could not be made for this question. Try rewording it.',
      ),
      (429, _) || (503, _) => ReadingException(
        ReadingErrorKind.failed,
        tr('The service is busy. Please try again in a minute.'),
      ),
      _ => ReadingException(
        ReadingErrorKind.failed,
        tr('Something went wrong. Please try again.'),
      ),
    };
  }

  @override
  Future<void> sendEvents(
    String variant,
    List<Map<String, Object?>> events,
  ) async {
    await _post('/v1/events', {
      'variant': variant,
      'events': events,
    }, auth: true);
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
      throw ReadingException(
        ReadingErrorKind.network,
        tr('No connection. Check your internet and try again.'),
      );
    } on HttpException {
      throw ReadingException(
        ReadingErrorKind.network,
        tr('No connection. Check your internet and try again.'),
      );
    } on TimeoutException {
      throw ReadingException(
        ReadingErrorKind.failed,
        tr(
          'The reader took too long to answer. Check your connection and try again.',
        ),
      );
    } finally {
      client.close();
    }
  }

  @override
  Future<SpreadScan> identifySpread(List<int> jpegBytes) async {
    var res = await _post('/v1/scan/spread', {
      'image': base64Encode(jpegBytes),
      'mediaType': 'image/jpeg',
    }, auth: true);
    if (res.status == 401) {
      _token = null;
      res = await _post('/v1/scan/spread', {
        'image': base64Encode(jpegBytes),
        'mediaType': 'image/jpeg',
      }, auth: true);
    }
    if (res.status == 429 && res.json['error'] == 'daily_limit') {
      throw ReadingException(
        ReadingErrorKind.dailyLimit,
        tr(
          'You have used today\'s spread photos. Scan one card at a time, or pick the cards.',
        ),
      );
    }
    if (res.status != 200) {
      throw ReadingException(
        ReadingErrorKind.failed,
        tr('The service is busy. Please try again in a minute.'),
      );
    }
    final list = (res.json['cards'] as List? ?? const []);
    return SpreadScan([
      for (final c in list)
        if (c is Map && c['id'] is String)
          (id: c['id'] as String, reversed: c['reversed'] == true),
    ], unsure: res.json['unsure'] == true);
  }

  Future<String> _ensureToken() async {
    final existing = _token;
    if (existing != null) return existing;
    final installId = await loadInstallId();
    // With App Attest (iPhone) the server gets proof of a genuine app on a
    // real device. If the proof is refused, try once with a new key, then
    // without proof (accepted while the server still allows it).
    _Response? res;
    for (final attempt in const ['proof', 'fresh', 'none']) {
      if (attempt == 'fresh') await _proof.reset();
      final proof = attempt == 'none' ? null : await _deviceProof(installId);
      if (attempt != 'none' && proof == null && res != null) continue;
      res = await _post('/v1/install', {
        'installId': installId,
        ...?proof,
      }, auth: false);
      if (res.status == 200 && proof != null) await _proof.accepted();
      if (res.status != 403) break;
    }
    final token = res!.json['token'];
    if (res.status != 200 || token is! String) {
      throw ReadingException(
        ReadingErrorKind.failed,
        tr('Something went wrong. Please try again.'),
      );
    }
    return _token = token;
  }

  /// Device proof fields for the install request, or null without one.
  Future<Map<String, String>?> _deviceProof(String installId) async {
    if (!await _proof.supported) return null;
    try {
      final res = await _post('/v1/install/challenge', const {}, auth: false);
      final challenge = res.json['challenge'];
      if (res.status != 200 || challenge is! String) return null;
      return await _proof.proofFor(installId, challenge);
    } on ReadingException {
      rethrow;
    } catch (_) {
      return null;
    }
  }
}

class _Response {
  _Response(this.status, this.json);
  final int status;
  final Map<String, dynamic> json;
}
