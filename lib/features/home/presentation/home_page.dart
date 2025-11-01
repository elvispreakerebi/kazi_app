import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/app_theme.dart';
import '../../../components/bottom_nav_bar.dart';
import '../../../components/overview_cards.dart';
import '../../../components/create_lesson_plan_card.dart';
import '../../../providers/class_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherOverviewProvider.notifier).fetchTeacherOverviewCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(teacherOverviewProvider);
    String classes = (overview.classesCount).toString();
    String subjects = (overview.subjectsCount).toString();
    String lessonPlans = (overview.lessonPlansCount).toString();
    bool hasError = overview.error != null;
    bool isLoading = overview.isLoading;
    if (hasError || isLoading) {
      // On error/empty/loading: always show zeros
      classes = subjects = lessonPlans = '0';
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
                    // Greeting section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning, Julius',
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
                    // Create lesson plan card
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
