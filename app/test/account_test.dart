import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/core/account_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/main.dart';

class _FakeSignIn implements SignInProvider {
  String? token = 'id-token';
  int signOuts = 0;
  @override
  Future<String?> idToken(AccountProvider provider) async => token;
  @override
  Future<void> signOut() async => signOuts++;
}

class _FakeBackend implements AccountBackend {
  final calls = <String>[];
  @override
  Future<String> signIn(AccountProvider provider, String idToken) async {
    calls.add('signin:${provider.wire}:$idToken');
    return 'acct-1';
  }

  @override
  Future<void> signOut() async => calls.add('signout');
  @override
  Future<void> deleteAccount() async => calls.add('delete');
}

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('iOS shows no sign-in until Apple is on; Google alone on Android', () {
    appleSignInEnabled = false;
    expect(availableProviders(isIOS: true, googleId: 'x'), isEmpty);
    expect(availableProviders(isIOS: false, googleId: 'x'), [
      AccountProvider.google,
    ]);
    expect(availableProviders(isIOS: false, googleId: ''), isEmpty);
    appleSignInEnabled = true;
    addTearDown(() => appleSignInEnabled = false);
    expect(availableProviders(isIOS: true, googleId: 'x'), [
      AccountProvider.apple,
      AccountProvider.google,
    ]);
  });

  test('sign in, persist, sign out', () async {
    final backend = _FakeBackend();
    final signIn = _FakeSignIn();
    final s = AppState(
      deck: deck,
      accountApi: backend,
      signIn: signIn,
      accountProviders: const [AccountProvider.google],
    );
    expect(await s.signIn(AccountProvider.google), isTrue);
    expect(s.account!.id, 'acct-1');
    expect(backend.calls, ['signin:google:id-token']);
    final reloaded = AppState(deck: deck);
    await reloaded.loadPersisted();
    expect(reloaded.account?.id, 'acct-1');
    await s.signOut();
    expect(s.account, isNull);
    expect(signIn.signOuts, 1);
    signIn.token = null; // user cancelled
    expect(await s.signIn(AccountProvider.google), isFalse);
    expect(s.account, isNull);
  });

  testWidgets('hidden when no sign-in is configured', (t) async {
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ShenTarotApp(
        initialState: AppState(
          deck: deck,
          onboarded: true,
          accountProviders: const [],
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('sign in from the You tab, then delete the account', (t) async {
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    final backend = _FakeBackend();
    final s = AppState(
      deck: deck,
      onboarded: true,
      accountApi: backend,
      signIn: _FakeSignIn(),
      accountProviders: const [AccountProvider.google],
    );
    await t.pumpWidget(ShenTarotApp(initialState: s));
    await t.pumpAndSettle();
    await t.tap(find.text('You').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Sign in'));
    await t.pumpAndSettle();
    expect(find.text('Continue without an account'), findsOneWidget);
    await t.tap(find.text('Continue with Google'));
    await t.pumpAndSettle();
    expect(find.text('Signed in with Google'), findsWidgets);
    await t.tap(find.text('Delete account'));
    await t.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    await t.tap(find.text('Delete account').last);
    await t.pumpAndSettle();
    expect(backend.calls.last, 'delete');
    expect(s.account, isNull);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
