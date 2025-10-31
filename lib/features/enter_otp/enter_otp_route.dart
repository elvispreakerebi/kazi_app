import 'package:flutter/widgets.dart';
import 'presentation/enter_otp_page.dart';

class EnterOtpRoute {
  static const String path = '/enter-otp';

  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final email = args['email'] as String? ?? '';
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => EnterOtpPage(email: email),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
