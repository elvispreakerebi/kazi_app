import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/class_card.dart';
import '../../../providers/onboarding_class_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../shared/services/onboarding_prefs.dart';

class OnboardingAddSubjectPage extends ConsumerStatefulWidget {
  const OnboardingAddSubjectPage({super.key});

  @override
  ConsumerState<OnboardingAddSubjectPage> createState() =>
      _OnboardingAddSubjectPageState();
}

class _OnboardingAddSubjectPageState
    extends ConsumerState<OnboardingAddSubjectPage> {
  List<Map<String, dynamic>> _classes = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final provider = ref.read(onboardingClassProvider.notifier);
    if (args != null && args['classes'] is List) {
      _classes = (args['classes'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      Future.microtask(() {
        provider.setClasses(_classes);
      });
    } else {
      _classes = provider.getClasses();
    }
    _initialized = true;
  }

  void _backToClasses() {
    if (!mounted) return;
    Future.microtask(() {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/onboarding-add-class',
          arguments: {
            'classes': _classes
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    // Always pull current classes from provider upon build
    _classes = ref.watch(onboardingClassProvider.notifier).getClasses();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _backToClasses,
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
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Icons.chevron_left
                          : Icons.arrow_back,
                      color: AppTheme.textDark,
                      size: Theme.of(context).platform == TargetPlatform.iOS
                          ? 22
                          : 24,
                    ),
                  ),
                ),
              ),
              showLogo: true,
              parentContext: context,
              actions: [LanguagePopover(parentContext: context)],
              progress: 2 / 4, // step 2 of 4
              progressText: 'step_2_of_4'.tr(),
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
                    // Real classes list
                    ..._classes
                        .where(
                          (c) =>
                              (c['name']?.isNotEmpty ?? false) &&
                              (c['gradeLevel']?.isNotEmpty ?? false),
                        )
                        .map(
                          (c) => ClassCard(
                            className: c['name'] ?? '',
                            subjectCount: 0,
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
                  onPressed: () async {
                    await OnboardingPrefs.setOnboardingComplete(true);
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
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
