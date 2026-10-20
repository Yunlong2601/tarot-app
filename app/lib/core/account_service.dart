import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../app/i18n.dart';

/// Optional accounts. Signing in is never required: readings, scanning and
/// history all work without an account.
enum AccountProvider { google, apple }

extension AccountProviderInfo on AccountProvider {
  String get wire => name;
  String get label => switch (this) {
    AccountProvider.google => 'Google',
    AccountProvider.apple => 'Apple',
  };
}

class Account {
  const Account(this.id, this.provider);
  final String id;
  final AccountProvider provider;
}

class AccountException implements Exception {
  const AccountException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The Google OAuth **web** client id (the ID token's audience, which the
/// server checks). Given at build time; empty = Google sign-in off.
const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Sign in with Apple waits for Apple Developer enrollment. Not so tests
/// can turn it on.
bool appleSignInEnabled = bool.fromEnvironment('APPLE_SIGNIN');

/// Sign-in buttons to show on this platform. On iOS, Google is only offered
/// together with Sign in with Apple (App Review guideline 4.8; verify current
/// wording), so iOS shows nothing until Apple sign-in is on.
List<AccountProvider> availableProviders({bool? isIOS, String? googleId}) {
  final ios = isIOS ?? Platform.isIOS;
  final google = (googleId ?? googleServerClientId).isNotEmpty;
  if (ios) {
    if (!appleSignInEnabled) return [];
    return [AccountProvider.apple, if (google) AccountProvider.google];
  }
  return [if (google) AccountProvider.google];
}

/// Gets an ID token from Google or Apple on the device. Returns null if the
/// user cancelled.
abstract class SignInProvider {
  Future<String?> idToken(AccountProvider provider);

  /// Apple's one-time authorization code from the last [idToken] call (Apple
  /// only). The server trades it for a token it revokes if the account is deleted.
  String? get authorizationCode;
  Future<void> signOut();
}

class PlatformSignIn implements SignInProvider {
  bool _googleReady = false;

  @override
  String? authorizationCode;

  @override
  Future<String?> idToken(AccountProvider provider) async {
    authorizationCode = null;
    switch (provider) {
      case AccountProvider.google:
        if (!_googleReady) {
          await GoogleSignIn.instance.initialize(
            serverClientId: googleServerClientId,
          );
          _googleReady = true;
        }
        try {
          final account = await GoogleSignIn.instance.authenticate();
          return account.authentication.idToken;
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) return null;
          throw AccountException(
            tr('Google sign-in failed ({0}).', [e.code.name]),
          );
        }
      case AccountProvider.apple:
        try {
          // No name or email is requested; we only need the user id.
          final c = await SignInWithApple.getAppleIDCredential(scopes: []);
          authorizationCode = c.authorizationCode;
          return c.identityToken;
        } on SignInWithAppleAuthorizationException catch (e) {
          if (e.code == AuthorizationErrorCode.canceled) return null;
          throw AccountException(tr('Apple sign-in failed.'));
        }
    }
  }

  @override
  Future<void> signOut() async {
    if (_googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
  }
}

/// The server side of accounts (implemented by the API client).
abstract class AccountBackend {
  /// Returns our account id.
  Future<String> signIn(
    AccountProvider provider,
    String idToken, {
    String? authorizationCode,
  });
  Future<void> signOut();
  Future<void> deleteAccount();
}

class UnconfiguredAccountBackend implements AccountBackend {
  const UnconfiguredAccountBackend();
  static AccountException get _e =>
      AccountException(tr('Accounts are not available yet.'));
  @override
  Future<String> signIn(
    AccountProvider provider,
    String idToken, {
    String? authorizationCode,
  }) => throw _e;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() => throw _e;
}
