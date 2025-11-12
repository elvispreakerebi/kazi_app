import 'package:flutter/material.dart';
import 'onboarding_screen1.dart';

void main() => runApp(const KaziApp());

class KaziApp extends StatelessWidget {
  const KaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi App',
      home: const OnboardingScreen1(),
      debugShowCheckedModeBanner: false,
    );
  }
}
