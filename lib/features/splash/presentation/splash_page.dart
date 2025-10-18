import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    final start = DateTime.now();
    String nextRoute = '/welcome';
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt');
      if (jwt != null && jwt.isNotEmpty) {
        ApiService().setToken(jwt);
        try {
          final profile = await ApiService().fetchUserProfile();
          if (profile['id'] != null || profile['email'] != null) {
            nextRoute = '/home';
          }
        } catch (e) {
          // Invalid token or network error; nextRoute remains '/welcome'
        }
      }
    } catch (_) {
      // SharedPreferences error or anything else: go to welcome
    }
    final elapsed = DateTime.now().difference(start);
    final remaining = const Duration(seconds: 4) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
