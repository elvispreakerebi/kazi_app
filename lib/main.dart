import 'package:flutter/material.dart';
import 'package:kazi_app/app/router.dart';

void main() => runApp(const KaziApp());

class KaziApp extends StatelessWidget {
  const KaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi',
      theme: ThemeData(fontFamily: 'Inter'),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: SplashRoute.path,
    return MaterialApp(
      title: 'Kazi App',
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
