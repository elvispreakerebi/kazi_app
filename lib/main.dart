import 'package:flutter/material.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'core/constants/backend.dart';
import 'app/router.dart';
import 'features/splash/splash_route.dart';

late ConvexClient convexClient;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  convexClient = await ConvexClient.init(
    deploymentUrl: convexBackend,
    clientId: "kazi-app-v1.0-demo1",
  );
  print('Connected to Convex backend!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi',
      theme: ThemeData(fontFamily: 'Inter'),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: SplashRoute.path,
      debugShowCheckedModeBanner: false,
    );
  }
}
