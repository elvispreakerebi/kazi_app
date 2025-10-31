import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/language_popover.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingWelcomePage extends StatelessWidget {
  final String name;
  const OnboardingWelcomePage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              showLogo: true,
              parentContext: context,
              actions: [LanguagePopover(parentContext: context)],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Celebratory emoji
                    Text(
                      'onboarding_celebration'.tr(),
                      style: const TextStyle(fontSize: 38),
                    ),
                    const SizedBox(height: 16),
                    // Welcome headline
                    Text(
                      'onboarding_welcome_header'.tr(namedArgs: {'name': name}),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subheader/supporting text
                    Text(
                      'onboarding_welcome_desc'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.inputDescription,
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Button section
                    AppButton(
                      text: 'onboarding_start_setup'.tr(),
                      onPressed: () {},
                      height: 48,
                      borderRadius: AppTheme.radiusFull,
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'onboarding_do_later'.tr(),
                      onPressed: () {},
                      height: 48,
                      borderRadius: AppTheme.radiusFull,
                      variant: ButtonVariant.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
