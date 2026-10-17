import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

const _installKey = 'install_id';

/// Anonymous random ID for this install. Used by the backend (hashed) and as
/// the RevenueCat app user ID, so there are no accounts.
Future<String> loadInstallId() async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString(_installKey);
  if (id == null) {
    id = uuidV4();
    await prefs.setString(_installKey, id);
  }
  return id;
}

String uuidV4([Random? random]) {
  final r = random ?? Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String h(int from, int to) => b
      .sublist(from, to)
      .map((x) => x.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${h(0, 4)}-${h(4, 6)}-${h(6, 8)}-${h(8, 10)}-${h(10, 16)}';
}
