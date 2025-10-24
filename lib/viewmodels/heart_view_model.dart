import 'package:flutter/foundation.dart';
import '../models/heart.dart';
import 'dart:async';

enum HeartState { empty, progressing, paused, completed }

class HeartViewModel extends ChangeNotifier {
  late Heart _heart;
  HeartState _state = HeartState.empty;

  // getters for the UI
  double get progress => _heart.progress;
  String get status => _heart.status();
  HeartState get state => _state;

  Timer? _timer;
  void init() {
    _heart = Heart(progress: 0, step: 10);
  }

  HeartViewModel() : _heart = Heart(progress: 0, step: 10);

  Future<void> start() async {
    // don’t start again if already ticking or finished
    if (_timer != null || _state == HeartState.completed) return;

    _state = HeartState.progressing;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_heart.progress >= 100) {
        finish();
        return;
      }

      _heart.progress += _heart.step;
      if (_heart.progress > 100) _heart.progress = 100;

      if (_heart.progress >= 100) {
        finish();
      } else {
        notifyListeners();
      }
    });
  }

  void finish() {
    _timer?.cancel(); // stop the timer if it’s running
    _timer = null; // reset timer reference
    _heart.progress = 100; // clamp to 100%
    _state = HeartState.completed;
    notifyListeners(); // tell the UI to refresh
  }

  void clear() {
    _timer?.cancel(); // stop the timer if it’s running
    _timer = null; // reset timer reference
    _heart.progress = 0; // clamp to 100%
    _state = HeartState.empty;
    notifyListeners(); // tell the UI to refresh
  }

  void toggleStartPause() {
    if (_state == HeartState.completed) return; // ignore when full

    // pause if currently running
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      _state = _heart.progress > 0 ? HeartState.paused : HeartState.empty;
      notifyListeners();
      return;
    }

    // otherwise start filling
    start();
  }
}
