import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/heart_view_model.dart';

class HeartScreen extends StatelessWidget {
  const HeartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HeartViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('Heart App')),
      body: Center(
        child: Column(
          children: [
            Text(
              '${vm.progress.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // center buttons horizontally
              children: [
                ElevatedButton(
                  onPressed: vm.state == HeartState.completed
                      ? null
                      : vm.toggleStartPause,
                  child: Text(
                    vm.state == HeartState.progressing
                        ? 'Pause ❤️'
                        : vm.state == HeartState.paused
                        ? 'Resume ❤️'
                        : 'Start ❤️', // covers empty,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(onPressed: vm.clear, child: const Text("Clear")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
