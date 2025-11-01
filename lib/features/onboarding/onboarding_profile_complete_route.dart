import 'package:flutter/material.dart';
import 'presentation/onboarding_profile_complete_page.dart';

class OnboardingProfileCompleteRoute {
  static const String path = '/onboarding-profile-complete';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const OnboardingProfileCompletePage(),
      settings: settings,
    );
  }
}
