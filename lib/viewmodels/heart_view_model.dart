// lib/viewmodels/heart_view_model.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/heart.dart';

enum HeartState { empty, progressing, paused, completed }

class HeartViewModel extends ChangeNotifier {
  final Heart _heart; // <-- not late
  HeartState _state = HeartState.empty;
  Timer? _timer;

  // Build the Heart *before* anything else can run
  HeartViewModel({required double capacity})
    : assert(capacity > 0),
      _heart = Heart(
        capacity: capacity,
        progress: 0,
        step: capacity * 0.10, // 10% per tick
      );

  double get progress => _heart.progress;
  double get percent {
    final cap = _heart.capacity;
    if (cap <= 0) return 0; // extra guard (shouldn’t happen)
    return (_heart.progress / cap) * 100;
  }

  HeartState get state => _state;

  Future<void> start() async {
    if (_timer != null || _state == HeartState.completed) return;

    _state = HeartState.progressing;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _heart.progress += _heart.step;

      if (_heart.progress >= _heart.capacity) {
        finish();
      } else {
        notifyListeners();
      }
    });
  }

  void toggleStartPause() {
    if (_state == HeartState.completed) return;

    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      _state = _heart.progress > 0 ? HeartState.paused : HeartState.empty;
      notifyListeners();
    } else {
      start();
    }
  }

  void finish() {
    _timer?.cancel();
    _timer = null;
    _heart.progress = _heart.capacity;
    _state = HeartState.completed;
    notifyListeners();
  }

  void clear() {
    _timer?.cancel();
    _timer = null;
    _heart.progress = 0;
    _state = HeartState.empty;
    notifyListeners();
  }
}
