/// Build-time switches. Not const so tests can flip them.
library;

import 'package:flutter/foundation.dart';

/// Debug/profile tester builds only (`--dart-define=TESTER_MODE=true`), never for the
/// stores: shows a "pretend Premium" switch and the install ID in the You tab,
/// so Premium screens can be tried before subscriptions exist. The server only
/// honours it for install IDs listed in its TESTER_INSTALL_IDS setting.
/// Debug and profile builds only: `kReleaseMode` forces it off, so a store build
/// can never show the "pretend Premium" switch even if the flag is passed.
bool testerMode = !kReleaseMode && const bool.fromEnvironment('TESTER_MODE');

/// Refer and earn (`--dart-define=REFERRALS=true`). Off until the store offers
/// (App Store offer codes, Play "referral-50" offer) and server keys exist.
bool referralsEnabled = const bool.fromEnvironment('REFERRALS');

/// Creator program (`--dart-define=CREATOR=true`): post with #shentarot, submit
/// the link and a screenshot for credits, 50 likes for a free month. Needs the
/// server's CREATOR_ENABLED, CREDITS_ENABLED and an R2 bucket.
bool creatorEnabled = const bool.fromEnvironment('CREATOR');

/// Reading credits and credit packs (`--dart-define=CREDITS=true`). Off
/// until the consumable product exists in both stores and Qonversion.
bool creditsEnabled = const bool.fromEnvironment('CREDITS');
