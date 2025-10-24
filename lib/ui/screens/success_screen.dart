import 'package:flutter/material.dart';
import 'package:heart_app/ui/screens/heart_screen.dart';
import 'package:provider/provider.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Heart App')),
      body: Center(
        child: Column(
          children: [
            Text(
              'Success',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HeartScreen()),
                );
              },
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
