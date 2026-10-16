/// Build-time switches. Not const so tests can flip them.
library;

/// Tester builds only (`--dart-define=TESTER_MODE=true`), never for the
/// stores: shows a "pretend Premium" switch and the install ID in the You tab,
/// so Premium screens can be tried before subscriptions exist. The server only
/// honours it for install IDs listed in its TESTER_INSTALL_IDS setting.
bool testerMode = const bool.fromEnvironment('TESTER_MODE');
