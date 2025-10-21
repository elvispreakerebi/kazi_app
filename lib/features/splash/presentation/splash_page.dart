import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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
        nextRoute = '/home'; // Token is valid; route to home
      } catch (_) {
        ApiService().logout(); // Token invalid/expired
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
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
