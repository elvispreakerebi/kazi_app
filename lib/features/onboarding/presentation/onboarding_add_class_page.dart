import 'package:flutter/material.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_button.dart';
import '../../../components/language_popover.dart';
import '../../../components/add_class_container.dart';
import '../../../components/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;
import '../../../providers/class_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/error_alert.dart';

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
  final Set<int> _loadingDeleteIndexes = {};
  String? _submitError;

  void _syncControllers(List<Map<String, dynamic>> classes) {
    for (var c in _nameCtrls) {
      c.dispose();
    }
    for (var c in _gradeCtrls) {
      c.dispose();
    }
    _nameCtrls.clear();
    _gradeCtrls.clear();
    _classObjs = [];
    for (final c in classes) {
      _nameCtrls.add(TextEditingController(text: c['name'] ?? ''));
      _gradeCtrls.add(TextEditingController(text: c['gradeLevel'] ?? ''));
      _classObjs.add({
        'id': c['id'] ?? c['_id'], // Map both possible backend id keys
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
    Future.microtask(() async {
      await ref.read(classProvider.notifier).fetchClasses();
      final fresh = ref.read(classProvider).classes;
      setState(() {
        _syncControllers(fresh);
        _initialized = true;
      });
    });
  }

  void _refreshClassesFromProvider() {
    final latest = ref.read(classProvider).classes;
    setState(() {
      _syncControllers(latest);
    });
  }

  void _handleContinue() async {
    setState(() {
      _submitError = null;
    });
    final currentProviderClasses = ref.read(classProvider).classes;
    final toAdd = <Map<String, dynamic>>[];
    final toEdit = <Map<String, dynamic>>[];
    bool hasAtLeastOne = false;
    for (var i = 0; i < _nameCtrls.length; i++) {
      final local = {
        'id': _classObjs[i]['id'] ?? _classObjs[i]['_id'],
        'name': _nameCtrls[i].text.trim(),
        'gradeLevel': _gradeCtrls[i].text.trim(),
        if (_classObjs[i]['academicYear'] != null)
          'academicYear': _classObjs[i]['academicYear'],
      };
      if (local['name'].isNotEmpty && local['gradeLevel'].isNotEmpty) {
        hasAtLeastOne = true;
      }
      if (local['id'] == null || (local['id'] as String).isEmpty) {
        if (local['name'].isNotEmpty && local['gradeLevel'].isNotEmpty) {
          toAdd.add(local);
        }
      } else {
        final prev = currentProviderClasses.firstWhere(
          (c) => (c['id'] ?? c['_id']).toString() == local['id'].toString(),
          orElse: () => <String, dynamic>{},
        );
        if (prev.isNotEmpty &&
            (prev['name'] != local['name'] ||
                prev['gradeLevel'] != local['gradeLevel'] ||
                prev['academicYear'] != local['academicYear'])) {
          toEdit.add(local);
        }
      }
    }
    if (!hasAtLeastOne) {
      setState(() {
        _submitError = 'Please provide at least one class with name and grade.';
      });
      return;
    }
    if (toAdd.isNotEmpty) {
      await ref.read(classProvider.notifier).addClasses(toAdd, context);
    }
    for (final cls in toEdit) {
      await ref.read(classProvider.notifier).editClass(cls, context);
    }
    _refreshClassesFromProvider();
    Navigator.of(context).pushReplacementNamed(
      '/onboarding-add-subject',
      arguments: {'classes': ref.read(classProvider).classes},
    );
  }

  void _handleDelete(int idx) async {
    final id = _classObjs[idx]['id'];
    setState(() {
      _loadingDeleteIndexes.add(idx);
    });
    if (id != null && id.toString().isNotEmpty) {
      await ref
          .read(classProvider.notifier)
          .deleteClass(id.toString(), context);
      _refreshClassesFromProvider();
    } else {
      _removeClass(idx);
    }
    setState(() {
      _loadingDeleteIndexes.remove(idx);
    });
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

  bool get _isAnyRowDeleting => _loadingDeleteIndexes.isNotEmpty;

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
    for (final c in _nameCtrls) {
      c.dispose();
    }
    for (final c in _gradeCtrls) {
      c.dispose();
    }
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
              progress: 1 / 2, // step 1 of 2
              progressText: 'step_1_of_2'.tr(),
            ),
            if (_submitError != null && _submitError!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ErrorAlert(message: _submitError!),
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
                            onDelete: idx == 0
                                ? null
                                : () => _handleDelete(idx),
                            isDeleting: _loadingDeleteIndexes.contains(idx),
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
                          !ref.watch(classProvider).isLoading &&
                          !_isAnyRowDeleting
                      ? _handleContinue
                      : null,
                  height: 48,
                  borderRadius: AppTheme.radiusFull,
                  icon: ref.watch(classProvider).isLoading
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
