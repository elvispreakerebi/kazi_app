import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../components/app_page_header.dart';
import '../../../components/app_button.dart';
import '../../../components/app_theme.dart';
import '../../../components/app_input.dart';
import '../../../components/select_class_bottom_sheet.dart';
import '../../../components/select_subject_bottom_sheet.dart';
import '../../../providers/lesson_plans_provider.dart';
import '../../../providers/teacher_provider.dart';

class NewLessonPlanPage extends ConsumerStatefulWidget {
  const NewLessonPlanPage({super.key});

  @override
  ConsumerState<NewLessonPlanPage> createState() => _NewLessonPlanPageState();
}

class _NewLessonPlanPageState extends ConsumerState<NewLessonPlanPage> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  
  String? _selectedClassId;
  String? _selectedClassName;
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  bool _isCreating = false;

  @override
  void dispose() {
    _topicController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }

  void _showSelectClassSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SelectClassBottomSheet(
          onSelect: (classId, className) {
            setState(() {
              _selectedClassId = classId;
              _selectedClassName = className;
              // Reset subject when class changes
              _selectedSubjectId = null;
              _selectedSubjectName = null;
            });
          },
        );
      },
    );
  }

  void _showSelectSubjectSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SelectSubjectBottomSheet(
          classId: _selectedClassId, // Filter by class if one is selected
          onSelect: (subjectId, subjectName, classId, className) {
            setState(() {
              _selectedSubjectId = subjectId;
              _selectedSubjectName = subjectName;
              // Update classId and className if not already set
              if (_selectedClassId == null || _selectedClassId != classId) {
                _selectedClassId = classId;
                _selectedClassName = className;
              }
            });
          },
        );
      },
    );
  }

  Future<void> _createLessonPlan() async {
    final topic = _topicController.text.trim();
    final objective = _objectiveController.text.trim();

    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the topic')),
      );
      return;
    }

    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class')),
      );
      return;
    }

    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final lessonPlanId = await ref
          .read(lessonPlansProvider.notifier)
          .createLessonPlan(
            classId: _selectedClassId!,
            subjectId: _selectedSubjectId!,
            topic: topic,
            objective: objective.isEmpty ? null : objective,
          );
      
      // Refresh teacher overview counts
      await ref
          .read(teacherProvider.notifier)
          .fetchTeacherDetailsAndCounts();

      if (!mounted) return;

      // Navigate to lesson plan detail page
      if (lessonPlanId.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(
          '/lesson-plan',
          arguments: {
            'lessonPlanId': lessonPlanId,
            'fromNewLessonPlan': true, // Indicate coming from new lesson plan page
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson plan created successfully'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCreating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating lesson plan: $e')),
      );
    }
  }

  Widget _backButton(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS || Platform.isIOS;
    
    // Check if we came from lesson plans page
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fromLessonPlansPage = routeArgs?['fromLessonPlansPage'] == true;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (fromLessonPlansPage) {
            // If coming from lesson plans page, go back to lesson plans page
            Navigator.of(context).popUntil(
              (route) => route.isFirst || route.settings.name == '/lesson-plans',
            );
          } else {
            // Otherwise, just pop normally
            Navigator.of(context).pop();
          }
        },
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

  @override
  Widget build(BuildContext context) {
    // Get class name from route arguments if available
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final classNameFromArgs = routeArgs?['className']?.toString();
    
    // Use className from args if no class is selected yet
    final displayClassName = _selectedClassName ?? classNameFromArgs ?? 'Select class';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: _backButton(context),
              title: 'New lesson plan',
              showLogo: false,
              parentContext: context,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (classNameFromArgs != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Enter details below to create a new lesson plan for $classNameFromArgs',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.addClassContainerBg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showSelectClassSheet,
                            child: AbsorbPointer(
                              child: AppInput(
                                label: 'Class',
                                description: displayClassName,
                                controller: TextEditingController(
                                  text: _selectedClassName ?? classNameFromArgs ?? '',
                                ),
                                readOnly: true,
                                prefixIcon: const Icon(
                                  Icons.school_outlined,
                                  color: AppTheme.inputDescription,
                                  size: 16,
                                ),
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppTheme.inputDescription,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: _showSelectSubjectSheet,
                            child: AbsorbPointer(
                              child: AppInput(
                                label: 'Subject',
                                description: _selectedSubjectName ?? 'select subject for lesson plan',
                                controller: TextEditingController(
                                  text: _selectedSubjectName ?? '',
                                ),
                                readOnly: true,
                                prefixIcon: const Icon(
                                  Icons.menu_book_outlined,
                                  color: AppTheme.inputDescription,
                                  size: 16,
                                ),
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppTheme.inputDescription,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Topic',
                            description: 'The topic for this lesson',
                            controller: _topicController,
                            prefixIcon: const Icon(
                              Icons.menu_book_outlined,
                              color: AppTheme.inputDescription,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            label: 'Objective',
                            description: 'Enter lesson plan objective',
                            controller: _objectiveController,
                            maxLines: 3,
                            minLines: 3,
                            prefixIcon: const Icon(
                              Icons.flag_outlined,
                              color: AppTheme.inputDescription,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom action button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white),
              child: AppButton(
                text: _isCreating ? 'Generating...' : 'Generate with AI',
                onPressed: _isCreating ? null : _createLessonPlan,
                variant: ButtonVariant.primary,
                borderRadius: 22,
                height: 48,
                expanded: true,
                icon: _isCreating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
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