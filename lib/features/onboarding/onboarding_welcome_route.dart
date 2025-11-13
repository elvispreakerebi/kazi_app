import 'package:flutter/widgets.dart';
import 'presentation/onboarding_welcome_page.dart';

class OnboardingWelcomeRoute {
  static const String path = '/onboarding-welcome';

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final name = args['name'] as String? ?? '';
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => OnboardingWelcomePage(name: name),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
