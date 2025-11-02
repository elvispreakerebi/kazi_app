import 'package:flutter/material.dart';
import 'presentation/account_page.dart';

class AccountRoute {
  static const String path = '/settings/account';

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => const AccountPage(),
    );
  }
}
