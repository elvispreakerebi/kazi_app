import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_bottom_sheet.dart';
import 'app_theme.dart';
import 'class_list_item.dart';
import 'empty_state_illustration.dart';
import '../providers/class_provider.dart';

class SelectClassBottomSheet extends ConsumerStatefulWidget {
  final Function(String classId, String className) onSelect;
  
  const SelectClassBottomSheet({
    super.key,
    required this.onSelect,
  });

  @override
  ConsumerState<SelectClassBottomSheet> createState() => _SelectClassBottomSheetState();
}

class _SelectClassBottomSheetState extends ConsumerState<SelectClassBottomSheet> {
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
      title: 'Select class',
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
                    final classId = classData['id']?.toString() ?? 
                                   classData['_id']?.toString() ?? '';

                    return Column(
                      children: [
                        ClassListItem(
                          className: className,
                          subjectCount: subjectCount,
                          onTap: () {
                            if (classId.isNotEmpty) {
                              Navigator.of(context).pop();
                              widget.onSelect(classId, className);
                            }
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
    );
  }
}
