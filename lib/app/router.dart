import 'package:flutter/material.dart';
import 'package:kazi_app/features/splash/splash_route.dart';
import 'package:kazi_app/features/welcome/welcome_route.dart';
import 'package:kazi_app/features/create_account/create_account_route.dart';
import 'package:kazi_app/features/enter_otp/enter_otp_route.dart';
import 'package:kazi_app/features/login/login_route.dart';
import 'package:kazi_app/features/onboarding/onboarding_welcome_route.dart';
import 'package:kazi_app/features/onboarding/onboarding_add_class_route.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashRoute.path:
        return SplashRoute.route(settings);
      case WelcomeRoute.path:
        return WelcomeRoute.route(settings);
      case CreateAccountRoute.path:
        return CreateAccountRoute.route(settings);
      case EnterOtpRoute.path:
        return EnterOtpRoute.route(settings);
      case LoginRoute.path:
        return LoginRoute.route(settings);
      case OnboardingWelcomeRoute.path:
        return OnboardingWelcomeRoute.route(settings);
      case OnboardingAddClassRoute.path:
        return OnboardingAddClassRoute.route(settings);
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
