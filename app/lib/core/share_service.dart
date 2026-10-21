import '../data/models.dart';

/// A public link to one reading, made only when the user taps Share link.
class ShareLink {
  const ShareLink({required this.token, required this.url, required this.days});
  final String token;
  final String url;

  /// How long the server keeps the page before it expires.
  final int days;
}

class ShareException implements Exception {
  const ShareException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Creates and removes shared reading pages. The question goes up only when
/// [includeQuestion] is true.
abstract class ShareBackend {
  Future<ShareLink> share(Reading reading, {required bool includeQuestion});
  Future<void> unshare(String token);
}

class UnconfiguredShareBackend implements ShareBackend {
  const UnconfiguredShareBackend();

  @override
  Future<ShareLink> share(Reading reading, {required bool includeQuestion}) =>
      throw const ShareException('Sharing is not available in this build.');

  @override
  Future<void> unshare(String token) async {}
}
