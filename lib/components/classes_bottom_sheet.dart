import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_theme.dart';
import 'class_list_item.dart';
import 'empty_state_illustration.dart';
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
    final isEmpty = !classState.isLoading && 
                     classState.error == null && 
                     classState.classes.isEmpty;

    return AppBottomSheet(
      title: isEmpty ? 'Select class' : 'Classes',
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
                    "You've added no class yet. Click button below to add a class",
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
                    text: 'Add class',
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/new-class');
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
                            final classId = classData['id']?.toString() ?? 
                                           classData['_id']?.toString() ?? '';
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed(
                              '/class',
                              arguments: {
                                'classId': classId,
                                'className': className,
                              },
                            );
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
      footer: isEmpty
          ? null
          : Row(
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
                      Navigator.of(context).pushNamed('/new-class');
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

