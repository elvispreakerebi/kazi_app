import 'package:flutter/material.dart';
import 'presentation/new_lesson_plan_page.dart';

class NewLessonPlanRoute {
  static const String path = '/new-lesson-plan';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const NewLessonPlanPage(),
    );
  }
}
