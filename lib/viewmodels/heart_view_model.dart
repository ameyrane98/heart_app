// lib/viewmodels/heart_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/heart.dart';
import '../models/repository/heart_repository.dart';
import '../models/services/heart_fill_service.dart';

enum HeartState { empty, progressing, paused, completed }

class HeartViewModel extends ChangeNotifier {
  final HeartRepository repo;
  final HeartFillService filler;

  late Heart _heart;
  HeartState _state = HeartState.empty;

  HeartViewModel({required this.repo, required this.filler}) {
    _init();
  }

  double get progress => _heart.progress;
  HeartState get state => _state;

  double get percent =>
      _heart.capacity <= 0 ? 0 : (_heart.progress / _heart.capacity) * 100.0;

  Future<void> _init() async {
    _heart = await repo.load();
    if (_heart.progress <= 0) _state = HeartState.empty;
    notifyListeners();
  }

  Future<void> start() async {
    if (filler.isRunning || _state == HeartState.completed) return;

    _state = HeartState.progressing;
    await repo.save(_heart, stateIndex: _state.index);
    notifyListeners();

    filler.start(() async {
      _heart = _heart.copyWith(progress: _heart.progress + _heart.step);
      if (_heart.progress >= _heart.capacity) {
        finish();
      } else {
        await repo.save(_heart, stateIndex: _state.index);
        notifyListeners();
      }
    });
  }

  void toggleStartPause() {
    if (_state == HeartState.completed) return;

    if (filler.isRunning) {
      filler.pause();
      _state = _heart.progress > 0 ? HeartState.paused : HeartState.empty;
      repo.save(_heart, stateIndex: _state.index);
      notifyListeners();
    } else {
      start();
    }
  }

  void finish() {
    filler.pause();
    _heart = _heart.copyWith(progress: _heart.capacity);
    _state = HeartState.completed;
    repo.save(_heart, stateIndex: _state.index);
    notifyListeners();
  }

  void clear() {
    filler.pause();
    _heart = _heart.copyWith(progress: 0);
    _state = HeartState.empty;
    repo.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    filler.dispose();
    super.dispose();
  }
}
