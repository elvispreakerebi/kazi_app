import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_button.dart';
import '../../../components/language_popover.dart';
import '../../../components/add_class_container.dart';
import '../../../components/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;

class OnboardingAddClassPage extends StatefulWidget {
  const OnboardingAddClassPage({super.key});
  @override
  State<OnboardingAddClassPage> createState() => _OnboardingAddClassPageState();
}

class _OnboardingAddClassPageState extends State<OnboardingAddClassPage> {
  final List<TextEditingController> _nameCtrls = [TextEditingController()];
  final List<TextEditingController> _gradeCtrls = [TextEditingController()];

  void _addClass() {
    setState(() {
      _nameCtrls.add(TextEditingController());
      _gradeCtrls.add(TextEditingController());
    });
  }

  void _removeClass(int idx) {
    setState(() {
      _nameCtrls[idx].dispose();
      _gradeCtrls[idx].dispose();
      _nameCtrls.removeAt(idx);
      _gradeCtrls.removeAt(idx);
    });
  }

  Widget _backButton(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS || Platform.isIOS;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/onboarding-welcome');
        },
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
          child: Icon(
            isIOS ? Icons.chevron_left : Icons.arrow_back,
            color: AppTheme.textDark,
            size: isIOS ? 22 : 24,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _nameCtrls) c.dispose();
    for (final c in _gradeCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: _backButton(context),
              showLogo: true,
              parentContext: context,
              actions: [LanguagePopover(parentContext: context)],
              progress: 0.25,
              progressText: 'step_1_of_4'.tr(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text block
                    Text(
                      'onboarding_add_class_title'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'onboarding_add_class_desc'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.inputDescription,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Class containers
                    Column(
                      children: List.generate(
                        _nameCtrls.length,
                        (idx) => Padding(
                          padding: EdgeInsets.only(
                            bottom: idx == _nameCtrls.length - 1 ? 0 : 24,
                          ),
                          child: AddClassContainer(
                            classIndex: idx,
                            firstClass: idx == 0,
                            nameController: _nameCtrls[idx],
                            gradeController: _gradeCtrls[idx],
                            onDelete: idx == 0 ? null : () => _removeClass(idx),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Add another class: custom outlined not full-width button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _addClass,
                          icon: const Icon(
                            Icons.add,
                            size: 22,
                            color: AppTheme.primary,
                          ),
                          label: Text(
                            'onboarding_add_another_class'.tr(),
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            side: const BorderSide(
                              color: AppTheme.outline,
                              width: 1,
                            ),
                            backgroundColor: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: keyboardVisible ? 24 : 90),
                  ],
                ),
              ),
            ),
            // Fixed bottom bar
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
