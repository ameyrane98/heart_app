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
  Heart copyWith({double? capacity, double? progress, double? step}) {
    return Heart(
      capacity: capacity ?? this.capacity,
      progress: progress ?? this.progress,
      step: step ?? this.step,
    );
  }

  double get percent =>
      capacity <= 0 ? 0 : (progress / capacity * 100).clamp(0, 100);

  bool isFull() => progress >= capacity;
}
