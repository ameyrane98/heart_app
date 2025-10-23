import 'package:flutter/material.dart';

class HeartScreen extends StatelessWidget {
  const HeartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Heart App')),
      body: Center(child: Text('Heart Demo')),
    );
  }
}
