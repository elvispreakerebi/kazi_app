import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_button.dart';
import '../../../components/language_popover.dart';
import '../../../components/add_class_container.dart';
import '../../../components/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;
import '../../../providers/onboarding_class_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingAddClassPage extends ConsumerStatefulWidget {
  const OnboardingAddClassPage({super.key});
  @override
  ConsumerState<OnboardingAddClassPage> createState() =>
      _OnboardingAddClassPageState();
}

class _OnboardingAddClassPageState
    extends ConsumerState<OnboardingAddClassPage> {
  final List<TextEditingController> _nameCtrls = [];
  final List<TextEditingController> _gradeCtrls = [];
  bool _initialized = false;

  List<Map<String, dynamic>> _classObjs = [];

  void _syncControllers(List<Map<String, dynamic>> classes) {
    _nameCtrls.forEach((c) => c.dispose());
    _gradeCtrls.forEach((c) => c.dispose());
    _nameCtrls.clear();
    _gradeCtrls.clear();
    _classObjs = [];
    for (final c in classes) {
      _nameCtrls.add(TextEditingController(text: c['name'] ?? ''));
      _gradeCtrls.add(TextEditingController(text: c['gradeLevel'] ?? ''));
      _classObjs.add({
        'id': c['id'],
        'name': c['name'] ?? '',
        'gradeLevel': c['gradeLevel'] ?? '',
        if (c['academicYear'] != null) 'academicYear': c['academicYear'],
      });
    }
    if (_nameCtrls.isEmpty) {
      _nameCtrls.add(TextEditingController());
      _gradeCtrls.add(TextEditingController());
      _classObjs.add({'id': null, 'name': '', 'gradeLevel': ''});
    }
  }

  void _addClass() {
    setState(() {
      _nameCtrls.add(TextEditingController());
      _gradeCtrls.add(TextEditingController());
      _classObjs.add({'id': null, 'name': '', 'gradeLevel': ''});
    });
  }

  void _removeClass(int idx) {
    setState(() {
      _nameCtrls[idx].dispose();
      _gradeCtrls[idx].dispose();
      _nameCtrls.removeAt(idx);
      _gradeCtrls.removeAt(idx);
      _classObjs.removeAt(idx);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final provider = ref.read(onboardingClassProvider.notifier);
    List<Map<String, dynamic>> baseClasses;
    if (routeArgs != null && routeArgs['classes'] is List) {
      baseClasses = (routeArgs['classes'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      Future.microtask(() {
        provider.setClasses(baseClasses);
      });
    } else {
      baseClasses = provider.getClasses();
    }
    _syncControllers(baseClasses);
    _initialized = true;
  }

  void _handleContinue() async {
    final notifier = ref.read(onboardingClassProvider.notifier);
    // Gather latest input values and always preserve 'id'.
    final inputClasses = List.generate(_nameCtrls.length, (i) {
      // Always use map from _classObjs (which always has id, even after user edit)
      return {
        'id': _classObjs[i]['id'],
        'name': _nameCtrls[i].text.trim(),
        'gradeLevel': _gradeCtrls[i].text.trim(),
        if (_classObjs[i]['academicYear'] != null)
          'academicYear': _classObjs[i]['academicYear'],
      };
    });
    final result = await notifier.submitClasses(inputClasses, context);
    if (result != null && result is List) {
      // If addClass returned new backend ids for new classes, update local objects accordingly
      // If edit only, IDs are unchanged
      List<Map<String, dynamic>> updated = List.generate(_nameCtrls.length, (
        i,
      ) {
        final original = inputClasses[i];
        // Try to find the backend match by name/gradeLevel or keep id if preexisting
        final backend = result.firstWhere(
          (r) =>
              (r['name'] == original['name'] &&
                  r['gradeLevel'] == original['gradeLevel']) &&
              r['id'] != null,
          orElse: () => null,
        );
        return {
          'id': backend != null && backend['id'] != null
              ? backend['id']
              : original['id'],
          'name': original['name'],
          'gradeLevel': original['gradeLevel'],
          if (original['academicYear'] != null)
            'academicYear': original['academicYear'],
        };
      });
      notifier.setClasses(updated);
      _classObjs = updated;
      Navigator.of(context).pushReplacementNamed(
        '/onboarding-add-subject',
        arguments: {'classes': updated},
      );
    }
  }

  bool get _canContinue {
    for (var i = 0; i < _nameCtrls.length; i++) {
      if (_nameCtrls[i].text.trim().isNotEmpty &&
          _gradeCtrls[i].text.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
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
              progress: 1 / 4, // step 1 of 4
              progressText: 'step_1_of_4'.tr(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            if (!keyboardVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: AppButton(
                  text: 'continue'.tr(),
                  onPressed:
                      _canContinue &&
                          !ref.watch(onboardingClassProvider).isLoading
                      ? _handleContinue
                      : null,
                  height: 48,
                  borderRadius: AppTheme.radiusFull,
                  icon: ref.watch(onboardingClassProvider).isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
