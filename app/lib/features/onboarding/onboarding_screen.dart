import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      Icons.center_focus_strong,
      'Hold the cards. We explain them.',
      'Got a tarot deck but not sure what you drew? Hold a card up to your camera and ShenTarot tells you what it is. Photos are never saved or uploaded.',
    ),
    (
      Icons.auto_awesome,
      'Readings that fit your question',
      'Ask what is on your mind and get a thoughtful, plain-language reading of your cards. One free reading every day, and a free taste of the longer spreads.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    for (final p in _pages)
                      Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _PageIcon(icon: p.$1),
                              const SizedBox(height: 32),
                              Text(
                                p.$2,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                p.$3,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    Container(
                      margin: const EdgeInsets.all(4),
                      width: i == _page ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.gold
                            : AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (last) {
                    AppScope.of(context).completeOnboarding();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(last ? 'Get started' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gold ring with a soft glow around the page icon.
class _PageIcon extends StatelessWidget {
  const _PageIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.gold, width: 1.5),
      gradient: const RadialGradient(
        colors: [AppColors.surfaceHigh, AppColors.background],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.25),
          blurRadius: 30,
        ),
      ],
    ),
    child: Icon(icon, size: 52, color: AppColors.gold),
  );
}
