import 'dart:typed_data';

import '../app/i18n.dart';

/// Creator program: anyone can post about ShenTarot with #shentarot, then submit
/// the post link and a screenshot. Every attempt earns credits at once; a post
/// with 50 likes, once checked, earns one free month of Premium.
class CreatorRules {
  const CreatorRules({
    this.creditsPerPost = 10,
    this.likesForMonth = 50,
    this.maxPerDay = 1,
    this.maxPerMonth = 8,
  });

  factory CreatorRules.fromJson(Map<String, dynamic> j) => CreatorRules(
    creditsPerPost: (j['creditsPerPost'] as num?)?.toInt() ?? 10,
    likesForMonth: (j['likesForMonth'] as num?)?.toInt() ?? 50,
    maxPerDay: (j['maxPerDay'] as num?)?.toInt() ?? 1,
    maxPerMonth: (j['maxPerMonth'] as num?)?.toInt() ?? 8,
  );

  final int creditsPerPost;
  final int likesForMonth;
  final int maxPerDay;
  final int maxPerMonth;
}

class CreatorPost {
  const CreatorPost({
    required this.id,
    required this.platform,
    required this.date,
    required this.status,
    this.likes,
    this.monthGranted = false,
  });

  factory CreatorPost.fromJson(Map<String, dynamic> j) => CreatorPost(
    id: (j['id'] as num).toInt(),
    platform: j['platform'] as String? ?? '',
    date: j['date'] as String? ?? '',
    status: j['status'] as String? ?? 'pending',
    likes: (j['likes'] as num?)?.toInt(),
    monthGranted: j['monthGranted'] == true,
  );

  final int id;
  final String platform;
  final String date;

  /// "pending", "verified" or "rejected".
  final String status;
  final int? likes;
  final bool monthGranted;
}

class CreatorOverview {
  const CreatorOverview({
    this.posts = const [],
    this.rules = const CreatorRules(),
  });
  final List<CreatorPost> posts;
  final CreatorRules rules;
}

class CreatorException implements Exception {
  const CreatorException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class CreatorBackend {
  /// My submissions and the program rules.
  Future<CreatorOverview> mine();

  /// Sends the post link and screenshot; returns the credits added.
  /// Throws [CreatorException] with a plain-language reason.
  Future<int> submit({required String url, required Uint8List screenshot});
}

class UnconfiguredCreatorBackend implements CreatorBackend {
  const UnconfiguredCreatorBackend();
  @override
  Future<CreatorOverview> mine() async => const CreatorOverview();
  @override
  Future<int> submit({required String url, required Uint8List screenshot}) =>
      throw CreatorException(tr('The creator program is not available yet.'));
}
