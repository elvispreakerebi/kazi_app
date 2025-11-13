import 'package:flutter/material.dart';
import 'presentation/new_class_page.dart';

class NewClassRoute {
  static const String path = '/new-class';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const NewClassPage(),
    );
  }
}

