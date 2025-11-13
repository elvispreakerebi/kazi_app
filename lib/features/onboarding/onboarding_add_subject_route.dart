import 'package:flutter/material.dart';
import 'presentation/onboarding_add_subject_page.dart';

class OnboardingAddSubjectRoute {
  static const String path = '/onboarding-add-subject';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const OnboardingAddSubjectPage(),
    );
  }
}
