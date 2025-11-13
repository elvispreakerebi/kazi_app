import 'package:flutter/material.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../components/language_popover.dart';

class OnboardingProfileCompletePage extends StatelessWidget {
  const OnboardingProfileCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: logo left, language popover right, NO back arrow.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/Kazi-Logo.png', height: 32),
                  LanguagePopover(parentContext: context),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/end.png',
                  fit: BoxFit.cover,
                  height: 230,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Congratulations! You are all set',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      height: 28 / 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your teaching profile is ready. Head to your dashboard to start planning lessons, managing classes, and tracking student progress.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                      height: 28 / 16,
                    ),
                  ),
                  const SizedBox(height: 36),
                  AppButton(
                    text: 'Go to dashboard',
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    borderRadius: AppTheme.radiusFull,
                    height: 48,
                  ),
                ],
              ),
            ),
            // Spacer
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
