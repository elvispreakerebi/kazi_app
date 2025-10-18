import 'package:flutter/material.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'core/constants/backend.dart';

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
      title: 'Kazi App',
      home: const Scaffold(
        body: Center(child: Text('Hello App', style: TextStyle(fontSize: 24))),
        backgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
