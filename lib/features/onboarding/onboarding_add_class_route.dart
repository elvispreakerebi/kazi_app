import 'package:flutter/widgets.dart';
import 'presentation/onboarding_add_class_page.dart';

class OnboardingAddClassRoute {
  static const String path = '/onboarding-add-class';

  static Route<dynamic> route(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => const OnboardingAddClassPage(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
