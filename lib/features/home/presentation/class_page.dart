import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../components/app_page_header.dart';
import '../../../components/app_popover_menu.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../components/subject_card_item.dart';
import '../../../providers/subjects_provider.dart';

class ClassPage extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const ClassPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends ConsumerState<ClassPage> {
  @override
  void initState() {
    super.initState();
    // Fetch subjects for this class when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectsProvider.notifier).fetchSubjectsForClass(widget.classId);
    });
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
            // TODO: Implement add subject logic
          },
        ),
        AppPopoverMenuItem(
          label: 'Edit class',
          icon: Icons.edit_outlined,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            // TODO: Implement edit class logic
          },
        ),
        AppPopoverMenuItem(
          label: 'Delete class',
          icon: Icons.delete_outline,
          isDestructive: true,
          onTap: (ctx) {
            Navigator.of(ctx).pop(); // Close popover
            // TODO: Implement delete class logic
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
        child: Icon(
          Icons.more_vert,
          color: AppTheme.textDark,
          size: 24,
        ),
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
              title: widget.className,
              showLogo: false,
              parentContext: context,
              actions: [
                _buildPopoverMenu(context),
              ],
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
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No subjects added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.inputDescription,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ...subjects.asMap().entries.map((entry) {
                            final index = entry.key;
                            final subject = entry.value;
                            final subjectName = subject['name']?.toString() ?? '';
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
            // Add subject button at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                text: 'Add subject',
                variant: ButtonVariant.primary,
                onPressed: () {
                  // TODO: Show add subject bottom sheet or navigate
                },
                height: 48,
                borderRadius: AppTheme.radiusFull,
                icon: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
