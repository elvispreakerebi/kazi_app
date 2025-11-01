import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/class_card.dart';
import '../../../providers/class_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../components/app_button.dart';

MaterialPageRoute onboardingAddSchemeOfWorkRoute(BuildContext context) =>
    MaterialPageRoute(
      builder: (context) => const OnboardingAddSchemeOfWorkPage(),
      settings: const RouteSettings(name: '/onboarding-add-scheme-of-work'),
    );

class OnboardingAddSchemeOfWorkPage extends ConsumerWidget {
  const OnboardingAddSchemeOfWorkPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classProvider).classes;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(
                    context,
                  ).pushReplacementNamed('/onboarding-add-subject'),
                  borderRadius: BorderRadius.circular(100),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.secondary,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textDark,
                      size: 24,
                    ),
                  ),
                ),
              ),
              showLogo: true,
              parentContext: context,
              actions: [LanguagePopover(parentContext: context)],
              progress: 3 / 4,
              progressText: 'step_3_of_4'.tr(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add scheme of work',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For each subject you teach, upload or enter your scheme of work. This helps us align AI-generated lesson plans with your term outline.',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.inputDescription,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...classes.map((c) {
                      return ClassCard(
                        className: c['name'] ?? '',
                        subjectCount: 0,
                        schemeOfWorkCount: 0, // TODO: wire real value later
                        onAdd: () {
                          // TODO: open add/edit scheme-of-work modal
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            if (!keyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: AppButton(
                  text: 'Continue',
                  onPressed: () {
                    // TODO: Implement actual navigation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Continue pressed!')),
                    );
                  },
                  height: 48,
                  borderRadius: AppTheme.radiusFull,
                  variant: ButtonVariant.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
