import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_theme.dart';
import 'class_list_item.dart';
import '../providers/class_provider.dart';

class ClassesBottomSheet extends ConsumerStatefulWidget {
  const ClassesBottomSheet({super.key});

  @override
  ConsumerState<ClassesBottomSheet> createState() => _ClassesBottomSheetState();
}

class _ClassesBottomSheetState extends ConsumerState<ClassesBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Refresh classes when bottom sheet is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classProvider.notifier).fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(classProvider);

    return AppBottomSheet(
      title: 'Classes',
      body: Column(
        children: [
          if (classState.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (classState.error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Error loading classes: ${classState.error}',
                style: const TextStyle(color: AppTheme.destructive),
              ),
            )
          else if (classState.classes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No classes found',
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
                  ...classState.classes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final classData = entry.value;
                    final className = classData['name']?.toString() ?? '';
                    final subjectCount =
                        (classData['subjectCount'] as int?) ?? 0;

                    return Column(
                      children: [
                        ClassListItem(
                          className: className,
                          subjectCount: subjectCount,
                          onTap: () {
                            // TODO: Navigate to class details or subjects page
                            Navigator.of(context).pop();
                          },
                        ),
                        if (index < classState.classes.length - 1)
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
      footer: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Close',
              variant: ButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(),
              height: 48,
              borderRadius: AppTheme.radiusFull,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: 'Add class',
              variant: ButtonVariant.primary,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/onboarding-add-class');
              },
              height: 48,
              borderRadius: AppTheme.radiusFull,
            ),
          ),
        ],
      ),
    );
  }
}

