import 'package:flutter/widgets.dart';
import 'presentation/login_page.dart';

class LoginRoute {
  static const String path = '/login';

  static Route<dynamic> route(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => const LoginPage(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
