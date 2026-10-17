import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared motion: dialogs pop in (scale + fade over a soft blur), and modal
/// screens (paywall, thank-you, card of the day) rise from the bottom.
/// Everything turns into a plain fade when the phone asks for reduced motion.

bool _reduced(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// Drop-in for [showDialog] with the app's pop-up effect.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, _, _) => SafeArea(child: Builder(builder: builder)),
    transitionBuilder: (ctx, anim, _, child) {
      final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      if (_reduced(ctx)) return FadeTransition(opacity: fade, child: child);
      final scale = Tween<double>(begin: 0.88, end: 1).animate(
        CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        ),
      );
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6 * anim.value,
          sigmaY: 6 * anim.value,
        ),
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}

/// A full-screen modal page that slides up and fades in.
CustomTransitionPage<void> modalPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        if (_reduced(context)) {
          return FadeTransition(opacity: curved, child: child);
        }
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
