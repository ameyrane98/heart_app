import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/heart_view_model.dart';
import 'ui/screens/heart_screen.dart';

class HeartApp extends StatelessWidget {
  const HeartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HeartViewModel()..init(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HeartScreen(),
      ),
    );
  }
}
