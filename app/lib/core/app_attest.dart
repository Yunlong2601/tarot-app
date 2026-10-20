import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Apple App Attest: proves to our server that requests come from this app on
/// a real iPhone, so the free daily readings cannot be farmed by scripts.
/// The key stays in the Secure Enclave; only its id is kept here.
abstract class DeviceProof {
  /// Whether this phone can make a proof at all.
  Future<bool> get supported;

  /// Extra fields for `POST /v1/install`, or null when no proof can be made
  /// (Android, the simulator, older phones). [challenge] is the server's.
  Future<Map<String, String>?> proofFor(String installId, String challenge);

  /// The server accepted the proof made by the last [proofFor].
  Future<void> accepted();

  /// The server refused it: start again with a new key next time.
  Future<void> reset();
}

class AppAttest implements DeviceProof {
  AppAttest({MethodChannel? channel, bool? isIOS})
    : _ch = channel ?? const MethodChannel('shentarot/app_attest'),
      _isIOS = isIOS ?? Platform.isIOS;

  final MethodChannel _ch;
  final bool _isIOS;
  static const _keyIdPref = 'app_attest_key_id';
  static const _attestedPref = 'app_attest_done';
  String? _pendingKeyId;
  bool? _supported;

  @override
  Future<bool> get supported async {
    if (!_isIOS) return false;
    try {
      return _supported ??= await _ch.invokeMethod<bool>('isSupported') == true;
    } on Exception {
      return _supported = false;
    }
  }

  @override
  Future<Map<String, String>?> proofFor(
    String installId,
    String challenge,
  ) async {
    if (!await supported) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientData = Uint8List.fromList(
        utf8.encode('$installId.$challenge'),
      );
      var keyId = prefs.getString(_keyIdPref);
      if (keyId != null && prefs.getBool(_attestedPref) == true) {
        final assertion = await _ch.invokeMethod<String>('generateAssertion', {
          'keyId': keyId,
          'clientData': clientData,
        });
        if (assertion == null) return null;
        _pendingKeyId = keyId;
        return {'keyId': keyId, 'challenge': challenge, 'assertion': assertion};
      }
      keyId ??= await _ch.invokeMethod<String>('generateKey');
      if (keyId == null) return null;
      await prefs.setString(_keyIdPref, keyId);
      await prefs.setBool(_attestedPref, false);
      final attestation = await _ch.invokeMethod<String>('attestKey', {
        'keyId': keyId,
        'clientData': clientData,
      });
      if (attestation == null) return null;
      _pendingKeyId = keyId;
      return {
        'keyId': keyId,
        'challenge': challenge,
        'attestation': attestation,
      };
    } on PlatformException catch (e) {
      // The key was lost (e.g. restored to a new phone): start over next time.
      if (e.code == 'invalid_key') await reset();
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> accepted() async {
    final keyId = _pendingKeyId;
    if (keyId == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keyIdPref) == keyId) {
      await prefs.setBool(_attestedPref, true);
    }
  }

  @override
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIdPref);
    await prefs.remove(_attestedPref);
    _pendingKeyId = null;
  }
}
