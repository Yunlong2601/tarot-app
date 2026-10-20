import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shentarot/app/app_scope.dart';
import 'package:shentarot/app/app_state.dart';
import 'package:shentarot/app/brand.dart';
import 'package:shentarot/core/creator_service.dart';
import 'package:shentarot/data/deck.dart';
import 'package:shentarot/features/creator/creator_screen.dart';

class _FakeCreator implements CreatorBackend {
  final posts = <CreatorPost>[];
  final sent = <String>[];
  CreatorException? failWith;

  @override
  Future<CreatorOverview> mine() async =>
      CreatorOverview(posts: List.of(posts.reversed));

  @override
  Future<int> submit({
    required String url,
    required Uint8List screenshot,
  }) async {
    if (failWith != null) throw failWith!;
    sent.add('$url/${screenshot.length}');
    posts.add(
      CreatorPost(
        id: posts.length + 1,
        platform: 'tiktok',
        date: '2026-10-17',
        status: 'pending',
      ),
    );
    return 10;
  }
}

void main() {
  brandAnimations = false;
  final deck = Deck.fromJsonString(File(Deck.assetPath).readAsStringSync());
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<_FakeCreator> open(
    WidgetTester t, {
    Uint8List? picked,
    _FakeCreator? api,
  }) async {
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 2.75;
    addTearDown(t.view.reset);
    final fake = api ?? _FakeCreator();
    final state = AppState(deck: deck, onboarded: true, creatorApi: fake);
    await t.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(
          home: CreatorScreen(pickScreenshot: () async => picked),
        ),
      ),
    );
    await t.pumpAndSettle();
    return fake;
  }

  Finder sendButton() => find.widgetWithText(FilledButton, 'Send my post');

  testWidgets('shows the rules from the program', (t) async {
    await open(t);
    expect(find.text('Post it. Get credits.'), findsOneWidget);
    expect(find.textContaining('#shentarot'), findsWidgets);
    expect(find.textContaining('10 credits'), findsOneWidget);
    expect(find.textContaining('50 likes'), findsOneWidget);
    expect(find.text('No posts yet.'), findsOneWidget);
  });

  testWidgets('the button needs a link and a screenshot', (t) async {
    await open(t, picked: Uint8List.fromList([1, 2, 3]));
    expect(t.widget<FilledButton>(sendButton()).onPressed, isNull);
    await t.enterText(find.byType(TextField), 'https://tiktok.com/@a/video/1');
    await t.pump();
    expect(t.widget<FilledButton>(sendButton()).onPressed, isNull);
    await t.tap(find.text('Choose screenshot'));
    await t.pumpAndSettle();
    expect(find.textContaining('Screenshot chosen'), findsOneWidget);
    expect(t.widget<FilledButton>(sendButton()).onPressed, isNotNull);
  });

  testWidgets('sending adds credits and lists the post as waiting', (t) async {
    final fake = await open(t, picked: Uint8List.fromList([1, 2, 3, 4]));
    await t.enterText(
      find.byType(TextField),
      ' https://tiktok.com/@a/video/1 ',
    );
    await t.tap(find.text('Choose screenshot'));
    await t.pumpAndSettle();
    await t.tap(sendButton());
    await t.pumpAndSettle();
    expect(fake.sent, ['https://tiktok.com/@a/video/1/4']);
    expect(find.text('Thank you! 10 credits added.'), findsOneWidget);
    expect(find.textContaining('tiktok · 2026-10-17'), findsOneWidget);
    expect(find.textContaining('waiting for 50 likes'), findsOneWidget);
    expect(t.widget<FilledButton>(sendButton()).onPressed, isNull); // cleared
  });

  testWidgets('a refused post shows the reason', (t) async {
    final fake = _FakeCreator()
      ..failWith = const CreatorException('One post a day earns credits.');
    await open(t, picked: Uint8List.fromList([1, 2, 3]), api: fake);
    await t.enterText(find.byType(TextField), 'https://tiktok.com/@a/video/1');
    await t.tap(find.text('Choose screenshot'));
    await t.pumpAndSettle();
    await t.tap(sendButton());
    await t.pumpAndSettle();
    expect(find.text('One post a day earns credits.'), findsOneWidget);
    expect(fake.sent, isEmpty);
  });

  testWidgets('a screenshot over 1 MB is refused before sending', (t) async {
    await open(t, picked: Uint8List(1000001));
    await t.enterText(find.byType(TextField), 'https://tiktok.com/@a/video/1');
    await t.tap(find.text('Choose screenshot'));
    await t.pumpAndSettle();
    expect(find.textContaining('over 1 MB'), findsOneWidget);
    expect(t.widget<FilledButton>(sendButton()).onPressed, isNull);
  });

  testWidgets('verified posts show the likes and the free month', (t) async {
    final fake = _FakeCreator()
      ..posts.add(
        const CreatorPost(
          id: 1,
          platform: 'instagram',
          date: '2026-10-10',
          status: 'verified',
          likes: 61,
          monthGranted: true,
        ),
      );
    await open(t, api: fake);
    expect(
      find.textContaining('Verified (61 likes): free month added'),
      findsOneWidget,
    );
  });
}
