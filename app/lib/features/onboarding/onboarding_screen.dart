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
      'Scan your cards',
      'Hold a physical tarot card up to your camera. Veilscan recognises it on your device. Photos are never saved or uploaded.',
    ),
    (
      Icons.auto_awesome,
      'Reflect on a reading',
      'Get a thoughtful interpretation of your cards and your question. A fresh free reading every day.',
    ),
    (
      Icons.verified_user_outlined,
      'For reflection only',
      'Veilscan is for entertainment and self-reflection. It does not predict the future or give medical, legal or financial advice.',
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
                              Icon(p.$1, size: 96, color: AppColors.gold),
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
