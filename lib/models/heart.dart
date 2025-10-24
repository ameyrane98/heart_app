// lib/models/heart.dart
class Heart {
  double progress; // never null
  final double step; // never null
  final double capacity; // never null

  Heart({
    required this.capacity,
    this.progress = 0, // ✅ default
    required this.step,
  }) : assert(capacity > 0, 'capacity must be > 0'),
       assert(step > 0, 'step must be > 0');

  bool isFull() => progress >= capacity;
  String status() => isFull() ? 'Full ❤️' : 'Filling...';
}
