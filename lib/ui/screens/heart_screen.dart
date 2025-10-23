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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Progress: ${vm.progress.toStringAsFixed(0)}%'),
            FilledButton(
              onPressed:
                  (vm.state == HeartState.progressing ||
                      vm.state == HeartState.completed)
                  ? null // disables button while filling or after complete
                  : () => context.read<HeartViewModel>().start(),
              child: const Text('Start'),
            ),
            // Start button will go here in Step 2
          ],
        ),
      ),
    );
  }
}
