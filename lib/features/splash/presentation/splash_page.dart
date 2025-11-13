import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app.dart'; // for localeProvider

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  Future<void> _startSplashTimer() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    String nextRoute = '/welcome';

    await Future.delayed(const Duration(seconds: 3));

    if (token != null && token.isNotEmpty) {
      ApiService().setToken(token);
      try {
        await ApiService().fetchUserProfile();
        // Check if user has existing data to determine if they should skip onboarding
        try {
          final counts = await ApiService().fetchTeacherOverviewCounts();
          final hasData = (counts['classes'] ?? 0) > 0 ||
              (counts['subjects'] ?? 0) > 0 ||
              (counts['lessonPlans'] ?? 0) > 0;
          if (hasData) {
            nextRoute = '/home'; // User has data, go to home
          } else {
            // New user with no data, check local preference
            final onboardingDone = await prefs.getBool('onboarding_complete') ?? false;
            nextRoute = onboardingDone ? '/home' : '/welcome';
          }
        } catch (_) {
          // If counts API fails, fallback to checking local preference
          final onboardingDone = await prefs.getBool('onboarding_complete') ?? false;
          nextRoute = onboardingDone ? '/home' : '/welcome';
        }
      } catch (_) {
        ApiService().logout(); // Token invalid/expired
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Locale>(localeProvider, (prev, next) {
      if (mounted && prev != null && next != prev) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash-screen-bg.png', fit: BoxFit.cover),
          Center(
            child: Image.asset(
              'assets/images/Kazi-Logo.png',
              width: 180,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
