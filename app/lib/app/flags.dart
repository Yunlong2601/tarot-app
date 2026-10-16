/// Build-time switches for unfinished features. Not const so tests can flip them.
library;

/// The demo sign-in screen (no real accounts yet). Off for launch: a sign-in
/// button that signs nobody in would confuse users and store reviewers.
/// Build with `--dart-define=SIGNIN_DEMO=true` to show it.
bool signInDemoEnabled = const bool.fromEnvironment('SIGNIN_DEMO');
