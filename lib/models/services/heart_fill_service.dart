import 'dart:async';

/// A tiny timer-based ticker for “heart filling”.
/// - Call [start] with an [onTick] callback.
/// - Each tick occurs every [tickDuration].
/// - Call [pause] (or [dispose]) to stop.

class HeartFillService {
  HeartFillService({this.tickDuration = const Duration(seconds: 1)});

  final Duration tickDuration;
  Timer? _timer;

  bool get isRunning => _timer != null;

  /// Starts periodic ticks.
  void start(void Function() onTick) {
    if (_timer != null) return;
    _timer = Timer.periodic(tickDuration, (_) => onTick());
  }

  /// Stops ticking. Safe to call multiple times.
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  /// Alias for [pause].
  void dispose() => pause();
}
