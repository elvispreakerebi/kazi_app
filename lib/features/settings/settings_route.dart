import 'package:flutter/material.dart';
import 'presentation/settings_page.dart';

class SettingsRoute {
  static const String path = '/settings';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const SettingsPage(),
    );
  }
}
