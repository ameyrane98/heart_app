// lib/app.dart
import 'package:flutter/material.dart';
import 'ui/screens/heart_screen.dart';

class HeartApp extends StatelessWidget {
  const HeartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HeartScreen(),
    );
  }
}
