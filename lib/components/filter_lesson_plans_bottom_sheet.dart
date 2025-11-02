import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_theme.dart';
import 'subject_list_item.dart';
import 'class_list_item.dart';
import '../providers/subjects_provider.dart';
import '../providers/class_provider.dart';

class FilterLessonPlansBottomSheet extends ConsumerStatefulWidget {
  final String? selectedSubjectId;
  final String? selectedClassId;
  final Function(String? subjectId, String? classId) onFilterChanged;

  const FilterLessonPlansBottomSheet({
    super.key,
    this.selectedSubjectId,
    this.selectedClassId,
    required this.onFilterChanged,
  });

  @override
  ConsumerState<FilterLessonPlansBottomSheet> createState() =>
      _FilterLessonPlansBottomSheetState();
}

class _FilterLessonPlansBottomSheetState
    extends ConsumerState<FilterLessonPlansBottomSheet> {
  String? _selectedSubjectId;
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.selectedSubjectId;
    _selectedClassId = widget.selectedClassId;
    // Fetch data when bottom sheet is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).fetchAllSubjectsWithClassNames();
      ref.read(classProvider.notifier).fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);
    final classState = ref.watch(classProvider);

    // Get unique subjects from all subjects
    final allSubjects = subjectsState.allSubjectsWithClassNames;
    final uniqueSubjects = <String, Map<String, dynamic>>{};
    for (final subject in allSubjects) {
      final subjectId =
          subject['id']?.toString() ?? subject['_id']?.toString() ?? '';
      if (subjectId.isNotEmpty && !uniqueSubjects.containsKey(subjectId)) {
        uniqueSubjects[subjectId] = subject;
      }
    }

    // Filter subjects by selected class if class is selected
    final filteredSubjects = _selectedClassId != null
        ? uniqueSubjects.values
            .where((s) =>
                (s['classId']?.toString() ?? '') == _selectedClassId)
            .toList()
        : uniqueSubjects.values.toList();

    return AppBottomSheet(
      title: 'Filter lesson plans',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class filter section
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Class',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (classState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (classState.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading classes: ${classState.error}',
                      style: const TextStyle(color: AppTheme.destructive),
                    ),
                  )
                else if (classState.classes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No classes found',
                      style: TextStyle(color: AppTheme.inputDescription),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.addClassContainerBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        // "All classes" option
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedClassId = null;
                                // Clear subject if it's not in any class
                                if (_selectedSubjectId != null) {
                                  final selectedSubject = allSubjects.firstWhere(
                                    (s) =>
                                        (s['id']?.toString() ??
                                            s['_id']?.toString() ??
                                            '') ==
                                        _selectedSubjectId,
                                    orElse: () => {},
                                  );
                                  if (selectedSubject.isEmpty ||
                                      (selectedSubject['classId']?.toString() ??
                                          '') !=
                                          _selectedClassId) {
                                    _selectedSubjectId = null;
                                  }
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedClassId == null
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 20,
                                    color: _selectedClassId == null
                                        ? AppTheme.primary
                                        : AppTheme.inputDescription,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'All classes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ...classState.classes.map((classData) {
                          final className = classData['name']?.toString() ?? '';
                          final subjectCount =
                              (classData['subjectCount'] as int?) ?? 0;
                          final classId = classData['id']?.toString() ??
                              classData['_id']?.toString() ?? '';

                          return Column(
                            children: [
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppTheme.outline,
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedClassId = classId;
                                      // Clear subject if it's not in this class
                                      if (_selectedSubjectId != null) {
                                        final selectedSubject = allSubjects
                                            .firstWhere(
                                          (s) =>
                                              (s['id']?.toString() ??
                                                  s['_id']?.toString() ??
                                                  '') ==
                                              _selectedSubjectId,
                                          orElse: () => {},
                                        );
                                        if (selectedSubject.isEmpty ||
                                            (selectedSubject['classId']
                                                    ?.toString() ??
                                                '') !=
                                                classId) {
                                          _selectedSubjectId = null;
                                        }
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _selectedClassId == classId
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          size: 20,
                                          color: _selectedClassId == classId
                                              ? AppTheme.primary
                                              : AppTheme.inputDescription,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClassListItem(
                                            className: className,
                                            subjectCount: subjectCount,
                                            onTap: null, // Disable tap on item, handled by parent
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Subject filter section
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subject',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (subjectsState.isLoadingAllSubjects)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (subjectsState.errorAllSubjects != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading subjects: ${subjectsState.errorAllSubjects}',
                      style: const TextStyle(color: AppTheme.destructive),
                    ),
                  )
                else if (filteredSubjects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No subjects found',
                      style: TextStyle(color: AppTheme.inputDescription),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.addClassContainerBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        // "All subjects" option
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSubjectId = null;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedSubjectId == null
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 20,
                                    color: _selectedSubjectId == null
                                        ? AppTheme.primary
                                        : AppTheme.inputDescription,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'All subjects',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ...filteredSubjects.map((subjectData) {
                          final subjectName =
                              subjectData['name']?.toString() ?? '';
                          final className =
                              subjectData['className']?.toString() ?? '';
                          final subjectId = subjectData['id']?.toString() ??
                              subjectData['_id']?.toString() ?? '';

                          return Column(
                            children: [
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppTheme.outline,
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedSubjectId = subjectId;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _selectedSubjectId == subjectId
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          size: 20,
                                          color: _selectedSubjectId == subjectId
                                              ? AppTheme.primary
                                              : AppTheme.inputDescription,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: SubjectListItem(
                                            subjectName: subjectName,
                                            className: className,
                                            onTap: null, // Disable tap on item, handled by parent
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
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
              text: 'Clear filters',
              onPressed: () {
                setState(() {
                  _selectedSubjectId = null;
                  _selectedClassId = null;
                });
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
              text: 'Apply filters',
              onPressed: () {
                widget.onFilterChanged(_selectedSubjectId, _selectedClassId);
                Navigator.of(context).pop();
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
