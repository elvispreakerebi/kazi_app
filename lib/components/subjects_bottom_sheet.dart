import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_theme.dart';
import 'subject_list_item.dart';
import 'empty_state_illustration.dart';
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
    final isEmpty = !subjectsState.isLoadingAllSubjects && 
                     subjectsState.errorAllSubjects == null && 
                     subjectsState.allSubjectsWithClassNames.isEmpty;

    return AppBottomSheet(
      title: isEmpty ? 'Select subject' : 'Subjects',
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
                      Navigator.of(context).pop();
                      // TODO: Navigate to add subject page or show instruction
                      // For now, just close the bottom sheet
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

