import 'package:flutter/material.dart';
import 'presentation/subject_page.dart';

class SubjectRoute {
  static const String path = '/subject';

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final subjectId = args['subjectId'] as String? ?? '';
    final subjectName = args['subjectName'] as String? ?? '';
    final classId = args['classId'] as String? ?? '';
    final fromHome = args['fromHome'] as bool? ?? false; // Track if coming from home

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => SubjectPage(
        subjectId: subjectId,
        subjectName: subjectName,
        classId: classId,
        fromHome: fromHome,
      ),
    );
  }
}
