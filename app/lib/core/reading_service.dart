import '../data/models.dart';

enum ReadingErrorKind {
  notConfigured,
  network,
  dailyLimit,
  premiumRequired,
  declined,
  failed,

  /// The user's text suggested a crisis; the message is a fixed care message.
  crisis,
}

class ReadingException implements Exception {
  const ReadingException(this.kind, this.message);
  final ReadingErrorKind kind;
  final String message;

  @override
  String toString() => message;
}

class ReadingResult {
  const ReadingResult({required this.text, required this.disclaimer});
  final String text;
  final String disclaimer;
}

/// Gets the AI interpretation for drawn cards. The app never holds an LLM
/// key; the real implementation talks to the Cloudflare Worker.
abstract class ReadingService {
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    String? impression,
  });

  /// Premium: answers a follow-up question about an earlier reading. The
  /// backend stores nothing, so the earlier [reading] text is sent as context.
  Future<ReadingResult> followUp({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    required String reading,
    required String followUp,
  });
}

/// Used when no backend URL was provided at build time
/// (`--dart-define=API_BASE_URL=https://...`).
class UnconfiguredReadingService implements ReadingService {
  const UnconfiguredReadingService();

  @override
  Future<ReadingResult> interpret({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    String? impression,
  }) => throw const ReadingException(
    ReadingErrorKind.notConfigured,
    'The reading service is not set up yet.',
  );

  @override
  Future<ReadingResult> followUp({
    required SpreadType spread,
    required List<DrawnCard> cards,
    String? question,
    required String reading,
    required String followUp,
  }) => throw const ReadingException(
    ReadingErrorKind.notConfigured,
    'The reading service is not set up yet.',
  );
}

String spreadWireName(SpreadType s) => s.wire;
