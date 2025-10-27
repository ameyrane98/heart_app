import 'package:flutter/material.dart';
import 'package:heart_app/ui/screens/success_screen.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/heart_view_model.dart';

// Keep these so you can switch renderers easily:
import '../widgets/heart_painter_twoIcon+ClipRect.dart'; // HeartFillWidget (two Icons + ClipRect)
import '../widgets/_LiquidHeartChartState.dart'; // Liquid-style heart (animated)
import '../widgets/HeartPathFill_ClipPathHeart.dart'; // Path-based ClipPath approach
import '../widgets/HeartPainterFill.dart'; // CustomPainter pro look

class HeartScreen extends StatelessWidget {
  const HeartScreen({super.key});

  // Consistent colors with SuccessScreen
  static const Color _navy = Color(0xFF184A6B);
  static const Color _blue = Color(0xFF2F73C6);
  static const Color _grayDisabled = Color(0xFFDADADA);

  String _titleFor(HeartState s) {
    switch (s) {
      case HeartState.empty:
        return 'Empty';
      case HeartState.progressing:
      case HeartState.paused:
        return 'Filling';
      case HeartState.completed:
        return 'Filled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HeartViewModel>();
    final canGoNext = vm.state == HeartState.completed;
    final showClear = vm.state == HeartState.completed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _navy,
        title: Text(
          _titleFor(vm.state),
          style: TextStyle(color: Colors.white),
        ), // consistent with SuccessScreen
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ======== CHOOSE ONE HEART RENDERER (keep comments to switch) ========
              // Wrap the heart with GestureDetector to Start/Pause on tap.
              GestureDetector(
                onTap: vm.state == HeartState.completed
                    ? null // no-op once filled
                    : () {
                        vm.toggleStartPause();
                      },
                behavior: HitTestBehavior.translucent,
                child: Semantics(
                  button: true,
                  label: vm.state == HeartState.progressing
                      ? 'Pause filling'
                      : 'Start filling',

                  // 1) CustomPainter + gradient (most polished)
                  // child: HeartPainterFill(
                  //   percent: vm.percent, // 0..100 from your ViewModel
                  //   size: 240,
                  //   gradient: const LinearGradient(
                  //     begin: Alignment.bottomCenter,
                  //     end: Alignment.topCenter,
                  //     colors: [
                  //       Color(0xFF2B0A5A),
                  //       Color(0xFF3F0D82),
                  //     ], // deep→purple
                  //   ),
                  //   backgroundColor: Color(0xFFE7E7E7),
                  //   borderColor: Color(0xFF2B0A5A),
                  //   borderWidth: 4,
                  //   shadowElevation: 8, // set 0 to disable
                  //   showGloss: false,
                  // ),

                  // 2) Simple two-Icon overlay + ClipRect (fastest to toggle)
                  child: HeartFillWidget(percent: vm.percent, size: 240),

                  // 3) Liquid heart (animated fill)
                  // child: const LiquidHeartChart(
                  //   size: 240,
                  //   duration: Duration(seconds: 4),
                  //   backgroundColor: Color(0x33808080),
                  //   fillColor: Color(0xFF3F0D82),
                  //   borderColor: Color(0xFF2B0A5A),
                  //   borderWidth: 4,
                  //   showPercentText: false, // keep text below to match mock
                  // ),

                  // 4) /// A simple heart fill using ClipPath + Path (no third-party animation).
                  /// - [percent]: 0..100
                  /// - [size]: square extent of the heart area
                  /// - [backgroundColor]: color of empty area inside the heart
                  /// - [fillColor]: color of the filled portion
                  /// - [borderColor]/[borderWidth]: outline on top
                  // child: HeartFillWidget2(percent: vm.percent, size: 240),
                ),
              ),

              const SizedBox(height: 16),

              // Percent BELOW the heart (per mock)
              Text(
                '${vm.percent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                vm.state == HeartState.progressing
                    ? 'Tap to pause ❤️'
                    : vm.state == HeartState.paused ||
                          vm.state == HeartState.empty
                    ? 'Tap to start filling 💜'
                    : 'Heart filled 💯',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              // ======== BOTTOM BUTTONS (consistent with SuccessScreen) ========
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // (Start button removed) — heart tap controls start/pause now.

                    // Clear (only visible when filled, like the mock)
                    if (showClear)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            disabledBackgroundColor: _grayDisabled,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          onPressed: vm.clear,
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    if (showClear) const SizedBox(height: 12),

                    // Next (enabled only when filled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          disabledBackgroundColor: _grayDisabled,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: canGoNext
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
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
