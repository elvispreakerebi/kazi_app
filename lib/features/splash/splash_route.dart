import 'package:flutter/widgets.dart';
import 'presentation/splash_page.dart';

class SplashRoute {
  static const String path = '/';

  static Route<dynamic> route(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => const SplashPage(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}


