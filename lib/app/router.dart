import 'package:flutter/material.dart';
import 'package:kazi_app/features/splash/splash_route.dart';
import 'package:kazi_app/features/welcome/welcome_route.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashRoute.path:
        return SplashRoute.route(settings);
      case WelcomeRoute.path:
        return WelcomeRoute.route(settings);
      case '/home':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _HomePlaceholder(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _NotFoundPage(),
        );
    }
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home')));
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Route not found')));
  }
}
