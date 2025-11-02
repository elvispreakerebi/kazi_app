import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_theme.dart';
import 'lesson_plan_list_item.dart';
import '../providers/lesson_plans_provider.dart';

class LessonPlansBottomSheet extends ConsumerStatefulWidget {
  const LessonPlansBottomSheet({super.key});

  @override
  ConsumerState<LessonPlansBottomSheet> createState() => _LessonPlansBottomSheetState();
}

class _LessonPlansBottomSheetState extends ConsumerState<LessonPlansBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Refresh lesson plans when bottom sheet is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonPlansProvider.notifier).fetchAllLessonPlansWithSubjectNames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonPlansState = ref.watch(lessonPlansProvider);

    return AppBottomSheet(
      title: 'Lesson plans',
      body: Column(
        children: [
          if (lessonPlansState.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (lessonPlansState.error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Error loading lesson plans: ${lessonPlansState.error}',
                style: const TextStyle(color: AppTheme.destructive),
              ),
            )
          else if (lessonPlansState.allLessonPlansWithSubjectNames.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No lesson plans found',
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
                  ...lessonPlansState.allLessonPlansWithSubjectNames.asMap().entries.map((entry) {
                    final index = entry.key;
                    final lessonPlanData = entry.value;
                    final title = lessonPlanData['title']?.toString() ?? '';
                    final subjectName = lessonPlanData['subjectName']?.toString() ?? '';

                    return Column(
                      children: [
                        LessonPlanListItem(
                          title: title,
                          subjectName: subjectName,
                          onTap: () {
                            // TODO: Navigate to lesson plan details if needed
                          },
                        ),
                        if (index < lessonPlansState.allLessonPlansWithSubjectNames.length - 1)
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

