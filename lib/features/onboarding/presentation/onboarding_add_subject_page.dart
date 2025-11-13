import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/app_page_header.dart';
import '../../../components/language_popover.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_button.dart';
import '../../../components/class_card.dart';
import '../../../providers/class_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../components/app_input.dart';
import '../../../providers/subjects_provider.dart';
import '../../../components/app_bottom_sheet.dart';
import 'package:kazi_app/features/onboarding/data/onboarding_prefs.dart';

class OnboardingAddSubjectPage extends ConsumerStatefulWidget {
  const OnboardingAddSubjectPage({super.key});
  @override
  ConsumerState<OnboardingAddSubjectPage> createState() =>
      _OnboardingAddSubjectPageState();
}

class _OnboardingAddSubjectPageState
    extends ConsumerState<OnboardingAddSubjectPage> {
  List<TextEditingController> _subjectCtrls = [];

  @override
  void dispose() {
    for (var c in _subjectCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _showAddSubjectsSheet(
    BuildContext context,
    Map<String, dynamic> classObj,
  ) async {
    final classId =
        classObj['id']?.toString() ?? classObj['_id']?.toString() ?? '';
    final className = classObj['name'] ?? '';

    // Always fetch subjects first, so provider state is fresh for this class
    try {
      await ref.read(subjectsProvider.notifier).fetchSubjectsForClass(classId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching subjects: $e')));
        return;
      }
    }

    List<Map<String, dynamic>> subjects = List<Map<String, dynamic>>.from(
      ref.read(subjectsProvider).subjectsByClassId[classId] ?? [],
    );
    _subjectCtrls = subjects.isEmpty
        ? [TextEditingController()]
        : List.generate(
            subjects.length,
            (i) => TextEditingController(text: subjects[i]['name'] ?? ""),
          );

    bool saveLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            // Always retrieve current subjects so our subject list is up to date
            final subjState = ref.watch(subjectsProvider);
            final isLoading = subjState.isLoadingByClassId[classId] == true;
            subjects = subjState.subjectsByClassId[classId] ?? [];
            final subCountText = isLoading
                ? "Loading subjects..."
                : "${subjects.length} subjects";
            return StatefulBuilder(
              builder: (innerCtx, modalSetState) {
                return AppBottomSheet(
                  title: 'Add subjects to $className',
                  subtitle: subCountText,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: List.generate(_subjectCtrls.length, (idx) {
                          final existingSubject = idx < subjects.length
                              ? subjects[idx]
                              : null;
                          final hasDbId =
                              existingSubject != null &&
                              (existingSubject['id'] != null ||
                                  existingSubject['_id'] != null);
                          final subjectId = hasDbId
                              ? (existingSubject['id']?.toString() ??
                                    existingSubject['_id']?.toString())
                              : null;
                          final deleting =
                              subjectId != null &&
                              ref
                                  .watch(subjectsProvider)
                                  .deletingSubjectIds
                                  .contains(subjectId);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: idx != _subjectCtrls.length - 1 ? 16 : 0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: AppInput(
                                    label: 'Subject ${idx + 1} name',
                                    description: 'E.g Mathematics',
                                    controller: _subjectCtrls[idx],
                                    prefixIcon: const Icon(
                                      Icons.menu_book_outlined,
                                      color: Color(0xFF71717A),
                                    ),
                                  ),
                                ),
                                if (idx > 0)
                                  SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: hasDbId
                                          ? deleting
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : IconButton(
                                                    icon: const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                    ),
                                                    onPressed: () async {
                                                      await ref
                                                          .read(
                                                            subjectsProvider
                                                                .notifier,
                                                          )
                                                          .deleteSubject(
                                                            classId,
                                                            subjectId!,
                                                          );
                                                      setState(() {
                                                        _subjectCtrls[idx]
                                                            .dispose();
                                                        _subjectCtrls.removeAt(
                                                          idx,
                                                        );
                                                      });
                                                      modalSetState(() {});
                                                    },
                                                  )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _subjectCtrls[idx].dispose();
                                                  _subjectCtrls.removeAt(idx);
                                                });
                                                modalSetState(() {});
                                              },
                                            ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _subjectCtrls.add(TextEditingController());
                              });
                              modalSetState(() {});
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 22,
                              color: AppTheme.primary,
                            ),
                            label: const Text(
                              'Add another subject',
                              style: TextStyle(
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
                    ],
                  ),
                  footer: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Close",
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                          },
                          variant: ButtonVariant.secondary,
                          borderRadius: 22,
                          height: 48,
                          expanded: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: saveLoading ? "Saving..." : "Save",
                          onPressed: () async {
                            if (saveLoading) return;
                            modalSetState(() {
                              saveLoading = true;
                            });
                            final List<Future> tasks = [];
                            for (int i = 0; i < _subjectCtrls.length; i++) {
                              final name = _subjectCtrls[i].text.trim();
                              final subj = i < subjects.length
                                  ? subjects[i]
                                  : null;
                              if (subj != null) {
                                final existingName = (subj['name'] ?? "")
                                    .toString();
                                final id =
                                    subj['id']?.toString() ??
                                    subj['_id']?.toString();
                                if (name.isNotEmpty &&
                                    name != existingName &&
                                    id != null) {
                                  tasks.add(
                                    ref
                                        .read(subjectsProvider.notifier)
                                        .updateSubject(classId, id, name),
                                  );
                                }
                              } else {
                                if (name.isNotEmpty) {
                                  tasks.add(
                                    ref
                                        .read(subjectsProvider.notifier)
                                        .addSubjects(classId, [
                                          {'name': name},
                                        ]),
                                  );
                                }
                              }
                            }
                            try {
                              await Future.wait(tasks);
                              await ref
                                  .read(subjectsProvider.notifier)
                                  .fetchSubjectsForClass(classId);
                              if (mounted) Navigator.of(sheetContext).pop();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error saving subjects: $e'),
                                  ),
                                );
                              }
                            }
                            modalSetState(() {
                              saveLoading = false;
                            });
                          },
                          variant: ButtonVariant.primary,
                          borderRadius: 22,
                          height: 48,
                          expanded: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always fetch latest classes from backend for onboarding step
    Future.microtask(() => ref.read(classProvider.notifier).fetchClasses());
  }

  void _backToClasses() {
    Future.microtask(() async {
      await ref.read(classProvider.notifier).fetchClasses();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/onboarding-add-class',
          arguments: {'classes': ref.read(classProvider).classes},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final classes = ref.watch(classProvider).classes;
    final subjectsState = ref.watch(subjectsProvider);
    return Scaffold(
      backgroundColor: AppTheme.white,
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
              progress: 2 / 2, // step 2 of 2
              progressText: 'step_2_of_2'.tr(),
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
                    ...classes
                        .where(
                          (c) =>
                              (c['name']?.isNotEmpty ?? false) &&
                              (c['gradeLevel']?.isNotEmpty ?? false),
                        )
                        .map((c) {
                          final classId =
                              c['id']?.toString() ?? c['_id']?.toString() ?? '';
                          final isLoading =
                              subjectsState.isLoadingByClassId[classId] == true;
                          final currentCount =
                              (subjectsState.subjectsByClassId[classId] ?? [])
                                  .length;
                          return ClassCard(
                            className: c['name'] ?? '',
                            subjectCount: isLoading ? -1 : currentCount,
                            onAdd: () {
                              ref
                                  .read(subjectsProvider.notifier)
                                  .fetchSubjectsForClass(classId);
                              _showAddSubjectsSheet(context, c);
                            },
                          );
                        }),
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
                    Navigator.of(
                      context,
                    ).pushReplacementNamed('/onboarding-profile-complete');
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
