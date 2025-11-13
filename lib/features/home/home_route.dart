import 'package:flutter/material.dart';
import 'presentation/home_page.dart';

class HomeRoute {
  static const String path = '/home';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const HomePage(),
    );
  }
}
