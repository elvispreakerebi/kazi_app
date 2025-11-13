import 'package:flutter/material.dart';
import 'presentation/lesson_plans_page.dart';

class LessonPlansRoute {
  static const String path = '/lesson-plans';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const LessonPlansPage(),
    );
  }
}
