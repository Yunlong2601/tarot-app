import 'dart:io';

import 'package:flutter/services.dart';

/// A recent App Store purchase that can be sent to Apple's refund sheet.
typedef RecentPurchase = ({String id, String productId, DateTime date});

/// Apple's own "Request a refund" sheet (StoreKit, iOS 15+). Apple reviews
/// and decides every request; the app never promises a refund.
class RefundService {
  const RefundService();
  static const _channel = MethodChannel('shentarot/refund');

  bool get isSupported => Platform.isIOS;

  /// Purchases from the last 90 days, newest first.
  Future<List<RecentPurchase>> recentPurchases() async {
    final list = await _channel.invokeListMethod<Map>('recentPurchases') ?? [];
    return [
      for (final m in list)
        (
          id: m['id'] as String,
          productId: m['productId'] as String,
          date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        ),
    ];
  }

  /// Opens Apple's sheet for [id]. True if the request was sent to Apple.
  Future<bool> request(String id) async =>
      await _channel.invokeMethod<String>('requestRefund', {'id': id}) ==
      'success';
}
