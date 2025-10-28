// lib/models/heart.dart
class Heart {
  final double capacity;
  final double progress;
  final double step;

  const Heart({
    required this.capacity,
    required this.progress,
    required this.step,
  });
  // double? is a null safety feature
  Heart copyWith({double? capacity, double? progress, double? step}) {
    return Heart(
      capacity:
          capacity ??
          this.capacity, // x ?? y i-> If x is not null, use x; else use y.
      progress: progress ?? this.progress,
      step: step ?? this.step,
    );
  }

  double get percent =>
      capacity <= 0 ? 0 : (progress / capacity * 100).clamp(0, 100);

  bool isFull() => progress >= capacity;
}
