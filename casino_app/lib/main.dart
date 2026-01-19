import 'package:flutter/material.dart';
import 'package:casino_app/home_screen.dart';

void main() {
  runApp(const CasinoApp());
}

class CasinoApp extends StatelessWidget {
  const CasinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casino Entertainment',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
