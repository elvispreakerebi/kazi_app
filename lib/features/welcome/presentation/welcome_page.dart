import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_button.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(localeProvider); // ensures this rebuilds when locale changes
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppPageHeader(
              showLogo: true,
              parentContext: context,
              actions: [LanguagePopover(parentContext: context)],
            ),
            const SizedBox(height: 32),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/welcome.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'welcome_title'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        AppButton(
                          text: 'login'.tr(),
                          onPressed: () {},
                          variant: ButtonVariant.primary,
                          borderRadius: AppTheme.radiusFull,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'create_account'.tr(),
                          onPressed: () {},
                          variant: ButtonVariant.secondary,
                          borderRadius: AppTheme.radiusFull,
                        ),
                      ],
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
