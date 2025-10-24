import 'package:flutter/material.dart';
import 'package:heart_app/ui/screens/success_screen.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/heart_view_model.dart';
import '../widgets/heart_painter.dart';

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
            HeartFillWidget(percent: vm.progress, size: 200),
            SizedBox(height: 20),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  onPressed: vm.clear,
                  child: const Text(
                    "Clear",
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                  ),
                  onPressed: vm.state == HeartState.completed
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuccessScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
