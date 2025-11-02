import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../components/app_page_header.dart';
import '../../../components/app_popover_menu.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../components/subject_card_item.dart';
import '../../../components/app_bottom_sheet.dart';
import '../../../components/app_input.dart';
import '../../../providers/subjects_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../shared/services/api_service.dart';
import '../../../components/empty_state_illustration.dart';

class ClassPage extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const ClassPage({super.key, required this.classId, required this.className});

  @override
  ConsumerState<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends ConsumerState<ClassPage> {
  List<TextEditingController> _subjectCtrls = [];
  String? _currentClassName;
  String? _currentGradeLevel;

  @override
  void initState() {
    super.initState();
    // Fetch subjects and class details when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).fetchSubjectsForClass(widget.classId);
      _fetchClassDetails();
    });
  }

  Future<void> _fetchClassDetails() async {
    try {
      final classData = await ApiService().getClassById(widget.classId);
      setState(() {
        _currentClassName = classData['name']?.toString() ?? widget.className;
        _currentGradeLevel = classData['gradeLevel']?.toString() ?? '';
      });
    } catch (e) {
      // Fallback to widget.className if fetch fails
      setState(() {
        _currentClassName = widget.className;
        _currentGradeLevel = '';
      });
    }
  }

  void _showEditClassSheet(BuildContext context) async {
    // Fetch latest class details
    await _fetchClassDetails();

    final nameController = TextEditingController(
      text: _currentClassName ?? widget.className,
    );
    final gradeLevelController = TextEditingController(
      text: _currentGradeLevel ?? '',
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _EditClassBottomSheetContent(
          nameController: nameController,
          gradeLevelController: gradeLevelController,
          classId: widget.classId,
          onSuccess: (name, gradeLevel) {
            // Use WidgetsBinding to ensure we're in a safe frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentClassName = name;
                  _currentGradeLevel = gradeLevel;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class updated successfully')),
                );
              }
            });
          },
        );
      },
    );

    // Don't dispose controllers - let them be garbage collected
    // The widgets will naturally detach when the bottom sheet closes
  }

  void _showDeleteClassSheet(BuildContext context) {
    bool deleteLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerCtx, modalSetState) {
            return AppBottomSheet(
              title: 'Delete class',
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
                        text: widget.className,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text:
                            ', doing so means all data belonging to this class will no longer exist. Are you sure about this?',
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
                              .read(classProvider.notifier)
                              .deleteClass(widget.classId, context);
                          // Refresh teacher overview counts
                          await ref
                              .read(teacherProvider.notifier)
                              .fetchTeacherDetailsAndCounts();
                          if (mounted) {
                            Navigator.of(sheetContext).pop();
                            Navigator.of(context).pop(); // Go back to home page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Class deleted successfully'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting class: $e'),
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

  void _showAddSubjectsSheet(BuildContext context) async {
    // Always fetch subjects first, so provider state is fresh for this class
    try {
      await ref
          .read(subjectsProvider.notifier)
          .fetchSubjectsForClass(widget.classId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching subjects: $e')));
        return;
      }
    }

    List<Map<String, dynamic>> subjects = List<Map<String, dynamic>>.from(
      ref.read(subjectsProvider).subjectsByClassId[widget.classId] ?? [],
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
            final isLoading =
                subjState.isLoadingByClassId[widget.classId] == true;
            subjects = subjState.subjectsByClassId[widget.classId] ?? [];
            final subCountText = isLoading
                ? "Loading subjects..."
                : "${subjects.length} subjects";
            return StatefulBuilder(
              builder: (innerCtx, modalSetState) {
                return AppBottomSheet(
                  title: 'Add subjects to ${widget.className}',
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
                                                            widget.classId,
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
                                        .updateSubject(
                                          widget.classId,
                                          id,
                                          name,
                                        ),
                                  );
                                }
                              } else {
                                if (name.isNotEmpty) {
                                  tasks.add(
                                    ref
                                        .read(subjectsProvider.notifier)
                                        .addSubjects(widget.classId, [
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
                                  .fetchSubjectsForClass(widget.classId);
                              // Refresh teacher overview counts
                              await ref
                                  .read(teacherProvider.notifier)
                                  .fetchTeacherDetailsAndCounts();
                              if (mounted) Navigator.of(sheetContext).pop();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Subjects saved successfully',
                                    ),
                                  ),
                                );
                              }
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

  Widget _backButton(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS || Platform.isIOS;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
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
        AppPopoverMenuItem.title('Class actions'),
        AppPopoverMenuItem(
          label: 'Add subject',
          icon: Icons.add,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showAddSubjectsSheet(context);
          },
        ),
        AppPopoverMenuItem(
          label: 'Edit class',
          icon: Icons.edit_outlined,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showEditClassSheet(context);
          },
        ),
        AppPopoverMenuItem(
          label: 'Delete class',
          icon: Icons.delete_outline,
          isDestructive: true,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            _showDeleteClassSheet(context);
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
    final subjectsState = ref.watch(subjectsProvider);
    final subjects = subjectsState.subjectsByClassId[widget.classId] ?? [];
    final isLoading = subjectsState.isLoadingByClassId[widget.classId] ?? false;
    final error = subjectsState.errorByClassId[widget.classId];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: _backButton(context),
              title: _currentClassName ?? widget.className,
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
                    // Subjects heading
                    const Text(
                      'Subjects',
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
                          'Error loading subjects: $error',
                          style: const TextStyle(color: AppTheme.destructive),
                        ),
                      )
                    else if (subjects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            const EmptyStateIllustration(size: 64),
                            const SizedBox(height: 32),
                            const Text(
                              "You've added no subject yet. Click button below to add a subject",
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
                              text: 'Add subject',
                              variant: ButtonVariant.primary,
                              onPressed: () {
                                _showAddSubjectsSheet(context);
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
                          ...subjects.asMap().entries.map((entry) {
                            final index = entry.key;
                            final subject = entry.value;
                            final subjectName =
                                subject['name']?.toString() ?? '';
                            // TODO: Fetch lesson plan count for each subject
                            final lessonPlanCount = 0; // Placeholder

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < subjects.length - 1 ? 8 : 0,
                              ),
                              child: SubjectCardItem(
                                subjectName: subjectName,
                                lessonPlanCount: lessonPlanCount,
                                onTap: () {
                                  // TODO: Navigate to subject details page
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

class _EditClassBottomSheetContent extends ConsumerStatefulWidget {
  final TextEditingController nameController;
  final TextEditingController gradeLevelController;
  final String classId;
  final void Function(String name, String gradeLevel) onSuccess;

  const _EditClassBottomSheetContent({
    required this.nameController,
    required this.gradeLevelController,
    required this.classId,
    required this.onSuccess,
  });

  @override
  ConsumerState<_EditClassBottomSheetContent> createState() =>
      _EditClassBottomSheetContentState();
}

class _EditClassBottomSheetContentState
    extends ConsumerState<_EditClassBottomSheetContent> {
  bool _saveLoading = false;

  @override
  void dispose() {
    // Controllers are managed by parent, don't dispose here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Edit class',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInput(
                  label: 'Class name',
                  description: 'E.g P5 Class or Primary 5 Class',
                  controller: widget.nameController,
                  prefixIcon: const Icon(
                    Icons.school_outlined,
                    color: AppTheme.inputDescription,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 20),
                AppInput(
                  label: 'Grade level',
                  description: 'E.g P5 or Primary 5',
                  controller: widget.gradeLevelController,
                  prefixIcon: const Icon(
                    Icons.layers_outlined,
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
              text: _saveLoading ? "Saving..." : "Save",
              onPressed: () async {
                if (_saveLoading) return;
                final name = widget.nameController.text.trim();
                final gradeLevel = widget.gradeLevelController.text.trim();

                if (name.isEmpty || gradeLevel.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                if (!mounted) return;
                setState(() {
                  _saveLoading = true;
                });

                try {
                  await ref.read(classProvider.notifier).editClass({
                    'id': widget.classId,
                    'name': name,
                    'gradeLevel': gradeLevel,
                  }, context);
                  // Refresh teacher overview counts
                  await ref
                      .read(teacherProvider.notifier)
                      .fetchTeacherDetailsAndCounts();

                  if (!mounted) return;

                  // Close bottom sheet first
                  Navigator.of(context).pop();

                  // Call success callback after sheet is closed
                  // Use a small delay to ensure the navigation is complete
                  Future.delayed(const Duration(milliseconds: 100), () {
                    widget.onSuccess(name, gradeLevel);
                  });
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _saveLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating class: $e')),
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
