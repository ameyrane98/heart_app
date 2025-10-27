// lib/viewmodels/heart_view_model.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/heart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HeartState { empty, progressing, paused, completed }

class HeartViewModel extends ChangeNotifier {
  final Heart _heart;
  HeartState _state = HeartState.empty;
  Timer? _timer;

  double get progress => _heart.progress;
  HeartState get state => _state;

  // Keys for SharedPreferences
  static const _progressKey = 'heart_progress';
  static const _stateKey = 'heart_state';

  HeartViewModel({required double capacity})
    : assert(capacity > 0),
      _heart = Heart(
        capacity: capacity,
        progress: 0,
        step: capacity * 0.10, // 10% per tick
      ) {
    _loadSavedState(); //  Restore progress/state on startup
  }

  double get percent {
    final cap = _heart.capacity;
    if (cap <= 0) return 0; // extra guard (shouldn’t happen)
    return (_heart.progress / cap) * 100;
  }

  //  Persistence Helpers

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProgress = prefs.getDouble(_progressKey) ?? 0;
    final savedStateIndex = prefs.getInt(_stateKey) ?? 0;

    _heart.progress = savedProgress;
    _state = HeartState.values[savedStateIndex];

    notifyListeners();

    // Auto-resume if app was closed mid-filling
    if (_state == HeartState.progressing) start();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_progressKey, _heart.progress);
    await prefs.setInt(_stateKey, _state.index);
  }

  // Heart Logic

  Future<void> start() async {
    if (_timer != null || _state == HeartState.completed) return;

    _state = HeartState.progressing;
    await _saveState();
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      _heart.progress += _heart.step;

      if (_heart.progress >= _heart.capacity) {
        finish();
      } else {
        await _saveState();
        notifyListeners();
      }
    });
  }

  void toggleStartPause() {
    if (_state == HeartState.completed) return;

    if (_timer != null) {
      // Pause
      _timer?.cancel();
      _timer = null;
      _state = _heart.progress > 0 ? HeartState.paused : HeartState.empty;
      _saveState();
      notifyListeners();
    } else {
      // Start
      start();
    }
  }

  void finish() {
    _timer?.cancel();
    _timer = null;
    _heart.progress = _heart.capacity;
    _state = HeartState.completed;
    _saveState();
    notifyListeners();
  }

  void clear() {
    _timer?.cancel();
    _timer = null;
    _heart.progress = 0;
    _state = HeartState.empty;
    _saveState();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
