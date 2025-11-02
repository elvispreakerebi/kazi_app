import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/app_theme.dart';
import '../../../components/bottom_nav_bar.dart';
import '../../../components/overview_cards.dart';
import '../../../components/create_lesson_plan_card.dart';
import '../../../components/classes_bottom_sheet.dart';
import '../../../components/subjects_bottom_sheet.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/teacher_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch classes when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classProvider.notifier).fetchClasses();
    });
  }

  void _showClassesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ClassesBottomSheet(),
    );
  }

  void _showSubjectsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubjectsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacher = ref.watch(teacherProvider);
    final isLoading = teacher.isLoading;
    final hasError = teacher.error != null;
    final firstName = teacher.firstName ?? '';
    final classes = teacher.classesCount?.toString() ?? '0';
    final subjects = teacher.subjectsCount?.toString() ?? '0';
    final lessonPlans = teacher.lessonPlansCount?.toString() ?? '0';

    String greetingText() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good morning';
      } else if (hour < 17) {
        return 'Good afternoon';
      } else {
        return 'Good evening';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/Kazi-Logo.png',
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greetingText()}, $firstName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Quick overview for today',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textDark.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator()),
                        OverviewCards(
                          topCards: [
                            OverviewCardData(
                              icon: Icons.school_outlined,
                              title: 'Classes',
                              value: classes,
                            ),
                            OverviewCardData(
                              icon: Icons.menu_book_outlined,
                              title: 'Subjects',
                              value: subjects,
                            ),
                          ],
                          fullWidthCard: OverviewCardData(
                            icon: Icons.menu_book,
                            title: 'Lesson plans',
                            value: lessonPlans,
                          ),
                          onClassesTap: () => _showClassesBottomSheet(context),
                          onSubjectsTap: () =>
                              _showSubjectsBottomSheet(context),
                        ),
                        if (hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Error loading overview. Showing 0s.',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CreateLessonPlanCard(
                      onTap: () {
                        // Navigate or trigger lesson plan creation
                      },
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
            // Implement navigation
          },
        ),
      ),
    );
  }
}
