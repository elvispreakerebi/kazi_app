import 'package:flutter/material.dart';
import 'presentation/onboarding_add_class_page.dart';

class OnboardingAddClassRoute {
  static const String path = '/onboarding-add-class';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const OnboardingAddClassPage(),
    );
  }
}
