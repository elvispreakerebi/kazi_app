import 'package:flutter/widgets.dart';
import 'presentation/create_account_page.dart';

class CreateAccountRoute {
  static const String path = '/create-account';

  static Route<dynamic> route(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => const CreateAccountPage(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
