import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/class_card.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingAddSubjectPage extends StatelessWidget {
  const OnboardingAddSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    // TODO: Wire to real backend list of classes from previous step
    final classes = const [
      {'name': 'P3 Class', 'subjectCount': 0},
      {'name': 'P6 Class', 'subjectCount': 0},
      {'name': 'P5 Class', 'subjectCount': 0},
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              showLogo: true,
              parentContext: context,
              actions: [LanguagePopover(parentContext: context)],
              progress: 2 / 6,
              progressText: 'step_2_of_6'.tr(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'onboarding_add_subject_title'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'onboarding_add_subject_desc'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.inputDescription,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Classes list
                    ...classes.map(
                      (c) => ClassCard(
                        className: c['name'] as String,
                        subjectCount: c['subjectCount'] as int,
                        onAdd: () {
                          // TODO: open subject selection dialog
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!keyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: AppButton(
                  text: 'continue'.tr(),
                  onPressed: () {},
                  height: 48,
                  borderRadius: AppTheme.radiusFull,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
