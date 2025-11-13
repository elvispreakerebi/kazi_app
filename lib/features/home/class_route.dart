import 'package:flutter/material.dart';
import 'presentation/class_page.dart';

class ClassRoute {
  static const String path = '/class';

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final classId = args['classId'] as String? ?? '';
    final className = args['className'] as String? ?? '';

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => ClassPage(
        classId: classId,
        className: className,
      ),
    );
  }
}
