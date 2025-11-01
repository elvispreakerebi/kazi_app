import 'package:flutter/material.dart';
import 'presentation/onboarding_add_scheme_of_work_page.dart';

class OnboardingAddSchemeOfWorkRoute {
  static const String path = '/onboarding-add-scheme-of-work';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const OnboardingAddSchemeOfWorkPage(),
    );
  }
}
