import 'package:flutter/material.dart';
import 'presentation/lesson_plan_page.dart';

class LessonPlanRoute {
  static const String path = '/lesson-plan';

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final lessonPlanId = args['lessonPlanId'] as String? ?? '';

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => LessonPlanPage(
        lessonPlanId: lessonPlanId,
      ),
    );
  }
}
