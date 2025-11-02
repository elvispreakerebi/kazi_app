import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_theme.dart';
import 'subject_list_item.dart';
import '../providers/subjects_provider.dart';

class SubjectsBottomSheet extends ConsumerStatefulWidget {
  const SubjectsBottomSheet({super.key});

  @override
  ConsumerState<SubjectsBottomSheet> createState() => _SubjectsBottomSheetState();
}

class _SubjectsBottomSheetState extends ConsumerState<SubjectsBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Refresh subjects when bottom sheet is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).fetchAllSubjectsWithClassNames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectsState = ref.watch(subjectsProvider);

    return AppBottomSheet(
      title: 'Subjects',
      body: Column(
        children: [
          if (subjectsState.isLoadingAllSubjects)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (subjectsState.errorAllSubjects != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Error loading subjects: ${subjectsState.errorAllSubjects}',
                style: const TextStyle(color: AppTheme.destructive),
              ),
            )
          else if (subjectsState.allSubjectsWithClassNames.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No subjects found',
                style: TextStyle(color: AppTheme.inputDescription),
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
                  ...subjectsState.allSubjectsWithClassNames.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subjectData = entry.value;
                    final subjectName = subjectData['name']?.toString() ?? '';
                    final className = subjectData['className']?.toString() ?? '';

                    return Column(
                      children: [
                        SubjectListItem(
                          subjectName: subjectName,
                          className: className,
                          onTap: () {
                            // TODO: Navigate to subject details if needed
                          },
                        ),
                        if (index < subjectsState.allSubjectsWithClassNames.length - 1)
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

