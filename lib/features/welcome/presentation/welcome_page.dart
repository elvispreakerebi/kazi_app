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
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppPageHeader(showLogo: true, actions: const [LanguagePopover()]),
            const SizedBox(height: 32),
            // Main content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/welcome.png',
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
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
                            onPressed: () {
                              // TODO: Implement navigation to login
                            },
                            variant: ButtonVariant.primary,
                            borderRadius: AppTheme.radiusFull,
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            text: 'create_account'.tr(),
                            onPressed: () {
                              // TODO: Implement navigation to signup
                            },
                            variant: ButtonVariant.secondary,
                            borderRadius: AppTheme.radiusFull,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
