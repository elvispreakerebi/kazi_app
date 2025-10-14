import 'package:flutter/material.dart';

void main() => runApp(const KaziApp());

class KaziApp extends StatelessWidget {
  const KaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kazi App',
      home: const Scaffold(
        body: Center(
          child: Text(
            'Kazi App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
