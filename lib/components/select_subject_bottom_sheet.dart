import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_theme.dart';
import 'subject_list_item.dart';
import 'empty_state_illustration.dart';
import '../providers/subjects_provider.dart';

class SelectSubjectBottomSheet extends ConsumerStatefulWidget {
  final String? classId; // Optional: filter subjects by class
  final Function(String subjectId, String subjectName, String classId, String className) onSelect;
  
  const SelectSubjectBottomSheet({
    super.key,
    this.classId,
    required this.onSelect,
  });

  @override
  ConsumerState<SelectSubjectBottomSheet> createState() => _SelectSubjectBottomSheetState();
}

class _SelectSubjectBottomSheetState extends ConsumerState<SelectSubjectBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Refresh subjects when bottom sheet is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.classId != null) {
        ref.read(subjectsProvider.notifier).fetchSubjectsForClass(widget.classId!);
      } else {
        ref.read(subjectsProvider.notifier).fetchAllSubjectsWithClassNames();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);
    
    // Determine which data to use based on whether classId is provided
    final List<Map<String, dynamic>> subjects;
    final bool isLoading;
    final String? error;
    
    if (widget.classId != null) {
      subjects = subjectsState.subjectsByClassId[widget.classId] ?? [];
      isLoading = subjectsState.isLoadingByClassId[widget.classId] ?? false;
      error = subjectsState.errorByClassId[widget.classId];
    } else {
      subjects = subjectsState.allSubjectsWithClassNames;
      isLoading = subjectsState.isLoadingAllSubjects;
      error = subjectsState.errorAllSubjects;
    }
    
    final isEmpty = !isLoading && error == null && subjects.isEmpty;

    return AppBottomSheet(
      title: 'Select subject',
      body: Column(
        children: [
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
          else if (isEmpty)
            // Empty state
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const EmptyStateIllustration(size: 64),
                  const SizedBox(height: 32),
                  const Text(
                    "You've added no subject yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w400,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.addClassContainerBg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Column(
                children: [
                  ...subjects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subjectData = entry.value;
                    final subjectName = subjectData['name']?.toString() ?? '';
                    final className = subjectData['className']?.toString() ?? '';
                    final subjectId = subjectData['id']?.toString() ?? 
                                     subjectData['_id']?.toString() ?? '';
                    final classId = subjectData['classId']?.toString() ?? '';

                    return Column(
                      children: [
                        SubjectListItem(
                          subjectName: subjectName,
                          className: className,
                          onTap: () {
                            if (subjectId.isNotEmpty && classId.isNotEmpty) {
                              Navigator.of(context).pop();
                              widget.onSelect(subjectId, subjectName, classId, className);
                            }
                          },
                        ),
                        if (index < subjects.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.outline,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
