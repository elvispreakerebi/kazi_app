import 'package:flutter/widgets.dart';
import 'presentation/welcome_page.dart';

class WelcomeRoute {
  static const String path = '/welcome';

  static Route<dynamic> route(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => const WelcomePage(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
