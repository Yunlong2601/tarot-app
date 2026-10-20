import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Own-key mode is off for launch: the You tab hides it unless the app is
/// built with `--dart-define=OWN_KEY=true`. The code and backend stay in place.
/// Not const so tests can turn it on.
bool ownKeyEnabled = const bool.fromEnvironment('OWN_KEY');

/// AI providers a Premium user can bring their own key for.
enum AiProvider { anthropic, openai }

extension AiProviderInfo on AiProvider {
  String get wire => name;
  String get label => switch (this) {
    AiProvider.anthropic => 'Anthropic (Claude)',
    AiProvider.openai => 'OpenAI (ChatGPT)',
  };
  String get keyHint => switch (this) {
    AiProvider.anthropic => 'sk-ant-...',
    AiProvider.openai => 'sk-...',
  };
}

class UserKey {
  const UserKey(this.provider, this.key);
  final AiProvider provider;
  final String key;
}

/// Same shape check as the backend (`backend/src/route.ts`).
bool looksLikeKey(AiProvider p, String key) => switch (p) {
  AiProvider.anthropic => RegExp(r'^sk-ant-[A-Za-z0-9_-]{20,250}$'),
  AiProvider.openai => RegExp(r'^sk-[A-Za-z0-9_-]{20,250}$'),
}.hasMatch(key);

/// Where the user's own AI key lives: only on this phone. Never in
/// SharedPreferences, history, logs or backups.
abstract class UserKeyStore {
  Future<UserKey?> read();
  Future<void> save(UserKey key);
  Future<void> clear();
}

class MemoryUserKeyStore implements UserKeyStore {
  UserKey? _key;
  @override
  Future<UserKey?> read() async => _key;
  @override
  Future<void> save(UserKey key) async => _key = key;
  @override
  Future<void> clear() async => _key = null;
}

/// iOS Keychain (this device only, not synced to iCloud) / Android Keystore.
class SecureUserKeyStore implements UserKeyStore {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static const _kProvider = 'own_ai_provider';
  static const _kKey = 'own_ai_key';

  @override
  Future<UserKey?> read() async {
    try {
      final p = await _storage.read(key: _kProvider);
      final k = await _storage.read(key: _kKey);
      if (p == null || k == null) return null;
      final provider = AiProvider.values.where((v) => v.wire == p).firstOrNull;
      return provider == null ? null : UserKey(provider, k);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(UserKey key) async {
    await _storage.write(key: _kProvider, value: key.provider.wire);
    await _storage.write(key: _kKey, value: key.key);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kProvider);
    await _storage.delete(key: _kKey);
  }
}
