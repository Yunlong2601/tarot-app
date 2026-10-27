import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';

/// Feeds the iOS Card-of-the-Day widget (ios/CardWidget) through the shared
/// App Group. Text arrives already translated, so the widget needs none.
class WidgetBridge {
  static const _channel = MethodChannel('shentarot/widget');

  /// Today's card ([card] null = not drawn yet) and the streak.
  static Future<void> update({
    required String day,
    required TarotCard? card,
    required String theme,
    required int streak,
    required String prompt,
    required String streakLabel,
  }) async {
    if (kIsWeb || !Platform.isIOS) return;
    try {
      String? image;
      if (card != null) {
        final dir = await _channel.invokeMethod<String>('containerPath');
        if (dir != null) {
          final ext = card.artAsset.split('.').last;
          final file = File('$dir/today.$ext');
          final bytes = await rootBundle.load(card.artAsset);
          await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
          image = file.path;
        }
      }
      await _channel.invokeMethod('update', {
        'day': card == null ? '' : day,
        'name': card?.name ?? '',
        'theme': theme,
        'streak': streak,
        'prompt': prompt,
        'streakLabel': streakLabel,
        'image': ?image,
      });
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }
}
