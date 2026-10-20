import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/brand.dart';
import '../../app/theme.dart';
import '../../app/i18n.dart';

/// Shown right after a purchase or restore: a thank-you, a short gold burst,
/// and what Premium now unlocks, with a way straight into a reading.
class WelcomePremiumScreen extends StatefulWidget {
  const WelcomePremiumScreen({super.key, this.plan, this.restored = false});

  /// Plan title from the store ("Annual", "3 Months", "Monthly"), if known.
  final String? plan;
  final bool restored;

  @override
  State<WelcomePremiumScreen> createState() => _WelcomePremiumScreenState();
}

class _WelcomePremiumScreenState extends State<WelcomePremiumScreen>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  static const _perks = [
    (
      Icons.dashboard_customize_outlined,
      'Every spread',
      'Five-card, seven-card and the ten-card Celtic Cross',
    ),
    (
      Icons.chat_bubble_outline,
      'Follow-up questions',
      'Ask more about any reading',
    ),
    (
      Icons.style_outlined,
      'A clarifier card',
      'Draw one more card when a reading feels unclear',
    ),
    (
      Icons.all_inclusive,
      'Up to 50 readings a day',
      'Read as often as you like',
    ),
    (Icons.history, 'A look back', 'Revisit a reading a week later'),
  ];

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations || !brandAnimations) {
        _c.value = 1;
      } else {
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/read');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final title = widget.restored
        ? tr('Welcome back')
        : tr('Welcome to Premium');
    final thanks = widget.restored
        ? tr('Your Premium is restored on this phone.')
        : tr(
            'Thank you for supporting ShenTarot. Your purchase keeps the readings thoughtful and the app independent.',
          );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                tooltip: tr('Close'),
                icon: const Icon(Icons.close),
                onPressed: _close,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  SizedBox(
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _c,
                      builder: (context, _) {
                        final pop = Curves.elasticOut.transform(
                          (_c.value / 0.6).clamp(0.0, 1.0),
                        );
                        return CustomPaint(
                          painter: _BurstPainter(_c.value),
                          child: Center(
                            child: Transform.scale(
                              scale: 0.4 + 0.6 * pop,
                              child: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.goldTint,
                                  border: Border.all(color: AppColors.gold),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(
                                        alpha: 0.35 * _c.value,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const BrandMark(size: 58),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: t.headlineMedium?.copyWith(color: AppColors.gold),
                    ),
                  ),
                  if (widget.plan != null && !widget.restored) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldTint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tr('{0} plan', [widget.plan]),
                          style: const TextStyle(color: AppColors.gold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    thanks,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr('NOW UNLOCKED'),
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < _perks.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: Icon(_perks[i].$1, color: AppColors.gold),
                            title: Text(tr(_perks[i].$2)),
                            subtitle: Text(
                              tr(_perks[i].$3),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: AppColors.gold,
                              size: 20,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () {
                      final router = GoRouter.of(context);
                      _close();
                      router.push('/ask');
                    },
                    child: Text(tr('Start a Premium reading')),
                  ),
                  TextButton(onPressed: _close, child: Text(tr('Continue'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold sparks flying out from the centre once, then fading.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.p);
  final double p;

  @override
  void paint(Canvas canvas, Size size) {
    if (p <= 0 || p >= 1) return;
    final c = size.center(Offset.zero);
    final rnd = math.Random(7);
    final fade = (1 - p).clamp(0.0, 1.0);
    for (var i = 0; i < 28; i++) {
      final angle = (i / 28) * 2 * math.pi + rnd.nextDouble() * 0.3;
      final speed = 70 + rnd.nextDouble() * 60;
      final d = 40 + speed * Curves.easeOut.transform(p);
      final pos = c + Offset(math.cos(angle) * d, math.sin(angle) * d);
      final r = 1.5 + rnd.nextDouble() * 2.5;
      final paint = Paint()
        ..color = (i.isEven ? AppColors.gold : AppColors.goldLight).withValues(
          alpha: fade,
        );
      if (i % 3 == 0) {
        _star(canvas, pos, r * 2.2, paint);
      } else {
        canvas.drawCircle(pos, r, paint);
      }
    }
  }

  void _star(Canvas canvas, Offset o, double r, Paint paint) {
    final path = Path()
      ..moveTo(o.dx, o.dy - r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.p != p;
}
