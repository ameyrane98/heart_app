// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di.dart';
import 'viewmodels/heart_view_model.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();

  runApp(
    ChangeNotifierProvider(
      create: (_) => sl<HeartViewModel>(),
      child: const HeartApp(),
    ),
  );
}
