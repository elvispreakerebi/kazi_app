import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../components/app_page_header.dart';
import '../../../components/app_theme.dart';
import '../../../components/lesson_plan_card_item.dart';
import '../../../components/empty_state_illustration.dart';
import '../../../components/bottom_nav_bar.dart';
import '../../../components/app_button.dart';
import '../../../components/filter_lesson_plans_bottom_sheet.dart';
import '../../../providers/lesson_plans_provider.dart';

class LessonPlansPage extends ConsumerStatefulWidget {
  const LessonPlansPage({super.key});

  @override
  ConsumerState<LessonPlansPage> createState() => _LessonPlansPageState();
}

class _LessonPlansPageState extends ConsumerState<LessonPlansPage> {
  int _navIndex = 1; // Lesson plans is index 1
  String? _filterSubjectId;
  String? _filterClassId;

  @override
  void initState() {
    super.initState();
    // Fetch lesson plans when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lessonPlansProvider.notifier)
          .fetchAllLessonPlansWithSubjectNames();
    });
  }

  // Refresh lesson plans when returning to this page
  void _refreshLessonPlans() {
    ref
        .read(lessonPlansProvider.notifier)
        .fetchAllLessonPlansWithSubjectNames();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return FilterLessonPlansBottomSheet(
          selectedSubjectId: _filterSubjectId,
          selectedClassId: _filterClassId,
          onFilterChanged: (subjectId, classId) {
            setState(() {
              _filterSubjectId = subjectId;
              _filterClassId = classId;
            });
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredLessonPlans(
    List<Map<String, dynamic>> allLessonPlans,
  ) {
    if (_filterSubjectId == null && _filterClassId == null) {
      return allLessonPlans;
    }

    return allLessonPlans.where((lessonPlan) {
      // If subject filter is set, check subjectId
      if (_filterSubjectId != null) {
        final subjectId = lessonPlan['subjectId']?.toString() ?? '';
        if (subjectId != _filterSubjectId) {
          return false;
        }
      }

      // If class filter is set, check classId
      if (_filterClassId != null) {
        final classId = lessonPlan['classId']?.toString() ?? '';
        if (classId != _filterClassId) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lessonPlansState = ref.watch(lessonPlansProvider);
    final allLessonPlans = lessonPlansState.allLessonPlansWithSubjectNames;
    final filteredLessonPlans = _getFilteredLessonPlans(allLessonPlans);
    final isEmpty =
        !lessonPlansState.isLoading &&
        lessonPlansState.error == null &&
        filteredLessonPlans.isEmpty;

    // Check if filters are active
    final hasActiveFilters = _filterSubjectId != null || _filterClassId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              backButton: null, // No back button for root page
              title: 'lesson_plans'.tr(),
              showLogo: false,
              parentContext: context,
              actions: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showFilterSheet,
                    borderRadius: BorderRadius.circular(100),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasActiveFilters
                            ? AppTheme.primary
                            : AppTheme.secondary,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.filter_list,
                        color: hasActiveFilters
                            ? Colors.white
                            : AppTheme.textDark,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson plans heading
                    Text(
                      'lesson_plans'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (lessonPlansState.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (lessonPlansState.error != null)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'error_loading_lesson_plans'.tr().replaceAll('{error}', lessonPlansState.error.toString()),
                          style: const TextStyle(color: AppTheme.destructive),
                        ),
                      )
                    else if (isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            const EmptyStateIllustration(size: 64),
                            const SizedBox(height: 32),
                            Text(
                              hasActiveFilters
                                  ? 'no_lesson_plans_found_filters'.tr()
                                  : 'no_lesson_plans_yet'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w400,
                                height: 1.75,
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              text: hasActiveFilters
                                  ? 'clear_filters'.tr()
                                  : 'create_lesson_plan'.tr(),
                              variant: ButtonVariant.primary,
                              onPressed: () async {
                                if (hasActiveFilters) {
                                  setState(() {
                                    _filterSubjectId = null;
                                    _filterClassId = null;
                                  });
                                } else {
                                  // Navigate to new lesson plan page and refresh when returning
                                  await Navigator.of(
                                    context,
                                  ).pushNamed('/new-lesson-plan');
                                  // Refresh lesson plans when returning
                                  _refreshLessonPlans();
                                }
                              },
                              height: 48,
                              borderRadius: AppTheme.radiusFull,
                              icon: Icon(
                                hasActiveFilters ? Icons.clear : Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          ...filteredLessonPlans.asMap().entries.map((entry) {
                            final index = entry.key;
                            final lessonPlanData = entry.value;
                            final title =
                                lessonPlanData['title']?.toString() ?? '';
                            final subjectName =
                                lessonPlanData['subjectName']?.toString() ?? '';
                            final lessonPlanId =
                                lessonPlanData['id']?.toString() ??
                                lessonPlanData['_id']?.toString() ??
                                '';

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < filteredLessonPlans.length - 1
                                    ? 8
                                    : 0,
                              ),
                              child: LessonPlanCardItem(
                                title: title,
                                subjectName: subjectName,
                                onTap: () async {
                                  if (lessonPlanId.isNotEmpty) {
                                    // Navigate to lesson plan detail and refresh when returning
                                    await Navigator.of(context).pushNamed(
                                      '/lesson-plan',
                                      arguments: {
                                        'lessonPlanId': lessonPlanId,
                                        'fromLessonPlansPage': true,
                                      },
                                    );
                                    // Refresh lesson plans when returning from detail page
                                    _refreshLessonPlans();
                                  }
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: BottomNavBar(
          currentIndex: _navIndex,
          onTap: (idx) {
            setState(() => _navIndex = idx);
            if (idx == 0) {
              // Navigate to home page
              Navigator.of(context).pushReplacementNamed('/home');
            } else if (idx == 1) {
              // Already on lesson plans page
              Navigator.of(
                context,
              ).popUntil((route) => route.settings.name == '/lesson-plans');
            } else if (idx == 2) {
              // Navigate to settings page
              Navigator.of(context).pushReplacementNamed('/settings');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to new lesson plan page and refresh when returning
          await Navigator.of(context).pushNamed(
            '/new-lesson-plan',
            arguments: {'fromLessonPlansPage': true},
          );
          // Refresh lesson plans when returning from new lesson plan page
          _refreshLessonPlans();
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}
