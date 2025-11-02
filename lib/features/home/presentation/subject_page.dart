import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../components/app_page_header.dart';
import '../../../components/app_popover_menu.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../components/lesson_plan_card_item.dart';
import '../../../components/app_bottom_sheet.dart';
import '../../../components/app_input.dart';
import '../../../providers/lesson_plans_provider.dart';
import '../../../providers/subjects_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../components/empty_state_illustration.dart';

class SubjectPage extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;
  final String classId;
  final bool fromHome; // Track if coming from home page

  const SubjectPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    this.fromHome = false,
  });

  @override
  ConsumerState<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends ConsumerState<SubjectPage> {
  String? _currentSubjectName;

  @override
  void initState() {
    super.initState();
    _currentSubjectName = widget.subjectName;
    // Fetch lesson plans when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lessonPlansProvider.notifier)
          .fetchLessonPlansForSubject(widget.subjectId);
    });
  }

  void _showEditSubjectSheet(BuildContext context) async {
    final nameController = TextEditingController(
      text: _currentSubjectName ?? widget.subjectName,
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _EditSubjectBottomSheetContent(
          nameController: nameController,
          subjectId: widget.subjectId,
          classId: widget.classId,
          onSuccess: (name) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentSubjectName = name;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subject updated successfully')),
                );
              }
            });
          },
        );
      },
    );
  }

  void _showDeleteSubjectSheet(BuildContext context) {
    bool deleteLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerCtx, modalSetState) {
            return AppBottomSheet(
              title: 'Delete subject',
              body: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textDark,
                      height: 1.75,
                    ),
                    children: [
                      const TextSpan(text: "You're about to delete "),
                      TextSpan(
                        text: widget.subjectName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text:
                            ', doing so means all data belonging to this subject will no longer exist. Are you sure about this?',
                      ),
                    ],
                  ),
                ),
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
                      text: deleteLoading ? "Deleting..." : "Yes, delete",
                      onPressed: () async {
                        if (deleteLoading) return;

                        modalSetState(() {
                          deleteLoading = true;
                        });

                        try {
                          await ref
                              .read(subjectsProvider.notifier)
                              .deleteSubject(widget.classId, widget.subjectId);
                          // Refresh teacher overview counts
                          await ref
                              .read(teacherProvider.notifier)
                              .fetchTeacherDetailsAndCounts();
                          if (mounted) {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(
                              context,
                            ).pop(); // Go back to class page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Subject deleted successfully'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting subject: $e'),
                              ),
                            );
                          }
                        } finally {
                          modalSetState(() {
                            deleteLoading = false;
                          });
                        }
                      },
                      variant: ButtonVariant.destructive,
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
  }

  void _showCreateLessonPlanSheet(BuildContext context) {
    final topicController = TextEditingController();
    final objectiveController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _CreateLessonPlanBottomSheetContent(
          topicController: topicController,
          objectiveController: objectiveController,
          subjectId: widget.subjectId,
          classId: widget.classId,
          onSuccess: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lesson plan created successfully'),
                  ),
                );
              }
            });
          },
        );
      },
    );
  }

  Widget _backButton(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS || Platform.isIOS;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // If coming from home page, pop until we reach home
          // Otherwise, just pop once to go back to class page
          if (widget.fromHome) {
            // Pop until we reach home page (which should be the first route)
            Navigator.of(context).popUntil(
              (route) => route.isFirst || route.settings.name == '/home',
            );
          } else {
            Navigator.of(context).pop();
          }
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

  Widget _buildPopoverMenu(BuildContext context) {
    return AppPopoverMenu(
      items: [
        AppPopoverMenuItem.title('Subject actions'),
        AppPopoverMenuItem(
          label: 'Create lesson plan',
          icon: Icons.add,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showCreateLessonPlanSheet(context);
          },
        ),
        AppPopoverMenuItem(
          label: 'Edit subject',
          icon: Icons.edit_outlined,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showEditSubjectSheet(context);
          },
        ),
        AppPopoverMenuItem(
          label: 'Delete subject',
          icon: Icons.delete_outline,
          isDestructive: true,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showDeleteSubjectSheet(context);
          },
        ),
      ],
      anchor: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.secondary,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.more_vert, color: AppTheme.textDark, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonPlansState = ref.watch(lessonPlansProvider);
    final lessonPlans =
        lessonPlansState.lessonPlansBySubjectId[widget.subjectId] ?? [];
    final isLoading =
        lessonPlansState.isLoadingBySubjectId[widget.subjectId] ?? false;
    final error = lessonPlansState.errorBySubjectId[widget.subjectId];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: _backButton(context),
              title: _currentSubjectName ?? widget.subjectName,
              showLogo: false,
              parentContext: context,
              actions: [_buildPopoverMenu(context)],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson plans heading
                    const Text(
                      'Lesson plans',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Error loading lesson plans: $error',
                          style: const TextStyle(color: AppTheme.destructive),
                        ),
                      )
                    else if (lessonPlans.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            const EmptyStateIllustration(size: 64),
                            const SizedBox(height: 32),
                            const Text(
                              "You've added no lesson plan yet. Click button below to create a lesson plan",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w400,
                                height: 1.75,
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              text: 'Create lesson plan',
                              variant: ButtonVariant.primary,
                              onPressed: () {
                                _showCreateLessonPlanSheet(context);
                              },
                              height: 48,
                              borderRadius: AppTheme.radiusFull,
                              icon: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          ...lessonPlans.asMap().entries.map((entry) {
                            final index = entry.key;
                            final lessonPlan = entry.value;
                            final title = lessonPlan['title']?.toString() ?? '';

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < lessonPlans.length - 1 ? 8 : 0,
                              ),
                              child: LessonPlanCardItem(
                                title: title,
                                onTap: () {
                                  final lessonPlanId =
                                      lessonPlan['id']?.toString() ??
                                      lessonPlan['_id']?.toString() ??
                                      '';
                                  if (lessonPlanId.isNotEmpty) {
                                    Navigator.of(context).pushNamed(
                                      '/lesson-plan',
                                      arguments: {'lessonPlanId': lessonPlanId},
                                    );
                                  }
                                },
                              ),
                            );
                          }),
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

class _EditSubjectBottomSheetContent extends ConsumerStatefulWidget {
  final TextEditingController nameController;
  final String subjectId;
  final String classId;
  final void Function(String name) onSuccess;

  const _EditSubjectBottomSheetContent({
    required this.nameController,
    required this.subjectId,
    required this.classId,
    required this.onSuccess,
  });

  @override
  ConsumerState<_EditSubjectBottomSheetContent> createState() =>
      _EditSubjectBottomSheetContentState();
}

class _EditSubjectBottomSheetContentState
    extends ConsumerState<_EditSubjectBottomSheetContent> {
  bool _saveLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Edit subject',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.addClassContainerBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: AppInput(
              label: 'Subject name',
              description: 'E.g Mathematics',
              controller: widget.nameController,
              prefixIcon: const Icon(
                Icons.menu_book_outlined,
                color: AppTheme.inputDescription,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: AppButton(
              text: "Close",
              onPressed: () {
                Navigator.of(context).pop();
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
              text: _saveLoading ? "Saving..." : "Save",
              onPressed: () async {
                if (_saveLoading) return;
                final name = widget.nameController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in the subject name'),
                    ),
                  );
                  return;
                }

                if (!mounted) return;
                setState(() {
                  _saveLoading = true;
                });

                try {
                  await ref
                      .read(subjectsProvider.notifier)
                      .updateSubject(widget.classId, widget.subjectId, name);
                  // Refresh teacher overview counts
                  await ref
                      .read(teacherProvider.notifier)
                      .fetchTeacherDetailsAndCounts();

                  if (!mounted) return;

                  // Close bottom sheet first
                  Navigator.of(context).pop();

                  // Call success callback after sheet is closed
                  Future.delayed(const Duration(milliseconds: 100), () {
                    widget.onSuccess(name);
                  });
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _saveLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating subject: $e')),
                  );
                }
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
  }
}

class _CreateLessonPlanBottomSheetContent extends ConsumerStatefulWidget {
  final TextEditingController topicController;
  final TextEditingController objectiveController;
  final String subjectId;
  final String classId;
  final VoidCallback onSuccess;

  const _CreateLessonPlanBottomSheetContent({
    required this.topicController,
    required this.objectiveController,
    required this.subjectId,
    required this.classId,
    required this.onSuccess,
  });

  @override
  ConsumerState<_CreateLessonPlanBottomSheetContent> createState() =>
      _CreateLessonPlanBottomSheetContentState();
}

class _CreateLessonPlanBottomSheetContentState
    extends ConsumerState<_CreateLessonPlanBottomSheetContent> {
  bool _createLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Create lesson plan',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.addClassContainerBg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                AppInput(
                  label: 'Topic',
                  description:
                      'E.g Punctuation: Using Commas in Complex Sentences',
                  controller: widget.topicController,
                  prefixIcon: const Icon(
                    Icons.menu_book_outlined,
                    color: AppTheme.inputDescription,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 20),
                AppInput(
                  label: 'Objective',
                  description:
                      'E.g Students will be able to use commas correctly in complex sentences',
                  controller: widget.objectiveController,
                  maxLines: 3,
                  minLines: 3,
                  prefixIcon: const Icon(
                    Icons.flag_outlined,
                    color: AppTheme.inputDescription,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: AppButton(
              text: "Close",
              onPressed: () {
                Navigator.of(context).pop();
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
              text: _createLoading ? "Creating..." : "Create",
              onPressed: () async {
                if (_createLoading) return;
                final topic = widget.topicController.text.trim();
                final objective = widget.objectiveController.text.trim();

                if (topic.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in the topic')),
                  );
                  return;
                }

                if (!mounted) return;
                setState(() {
                  _createLoading = true;
                });

                try {
                  final lessonPlanId = await ref
                      .read(lessonPlansProvider.notifier)
                      .createLessonPlan(
                        classId: widget.classId,
                        subjectId: widget.subjectId,
                        topic: topic,
                        objective: objective.isEmpty ? null : objective,
                      );
                  // Refresh teacher overview counts
                  await ref
                      .read(teacherProvider.notifier)
                      .fetchTeacherDetailsAndCounts();

                  if (!mounted) return;

                  // Close bottom sheet first
                  Navigator.of(context).pop();

                  // Navigate to lesson plan detail page
                  if (lessonPlanId.isNotEmpty) {
                    Navigator.of(context).pushNamed(
                      '/lesson-plan',
                      arguments: {'lessonPlanId': lessonPlanId},
                    );
                  } else {
                    // Fallback to success callback if navigation fails
                    Future.delayed(const Duration(milliseconds: 100), () {
                      widget.onSuccess();
                    });
                  }
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _createLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating lesson plan: $e')),
                  );
                }
              },
              variant: ButtonVariant.primary,
              borderRadius: 22,
              height: 48,
              expanded: true,
              icon: _createLoading
                  ? const SizedBox(
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
    );
  }
}
