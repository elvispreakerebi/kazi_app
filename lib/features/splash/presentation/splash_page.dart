import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _controller.forward();
    });
    Future.delayed(const Duration(seconds: 30), _navigateAfterSplash);
  }

  Future<void> _navigateAfterSplash() async {
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
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18CEC8),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash-screen-bg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF18CEC8)),
          ),
          Center(
            child: FadeTransition(
              opacity: _controller,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                ),
                child: Image.asset(
                  'assets/images/Kazi-Logo.png',
                  width: 180,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
