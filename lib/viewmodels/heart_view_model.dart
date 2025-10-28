// lib/viewmodels/heart_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:heart_app/models/heart.dart';
import 'package:heart_app/models/repository/heart_repository.dart';
import 'package:heart_app/models/services/heart_fill_service.dart';

enum HeartState { empty, progressing, paused, completed }

class HeartViewModel extends ChangeNotifier {
  final HeartRepository repo;
  final HeartFillService filler;

  Heart _heart = const Heart(capacity: 100, progress: 0, step: 10);
  HeartState _state = HeartState.empty;
  bool _loading = true;

  HeartViewModel({required this.repo, required this.filler}) {
    _init();
  }

  bool get loading => _loading;
  double get progress => _heart.progress;
  HeartState get state => _state;
  double get capacity => _heart.capacity;

  double get percent =>
      _heart.capacity <= 0 ? 0 : (_heart.progress / _heart.capacity) * 100.0;

  Future<void> _init() async {
    try {
      // Load last saved heart
      final loaded = await repo.load();
      _heart = loaded;

      // Restore UI state from storage if available; otherwise derive
      final savedIndex = await repo.loadStateIndex();
      if (savedIndex != null &&
          savedIndex >= 0 &&
          savedIndex < HeartState.values.length) {
        _state = HeartState.values[savedIndex];
      } else if (_heart.progress >= _heart.capacity) {
        _state = HeartState.completed;
      } else if (_heart.progress > 0) {
        _state = HeartState.paused;
      } else {
        _state = HeartState.empty;
      }

      // FIXED BUG: App reopened after being killed mid-fill showed “Tap to pause ❤️”
      // because the last saved state was `progressing`, even though the timer stopped.
      // Since we don’t implement auto-resume, that’s misleading.
      // On cold start, if saved state == progressing but filler isn’t running,
      // we now reset it to `paused` (or `empty` if progress == 0).
      // This ensures the UI text correctly shows “Tap to resume 💜” instead of “Tap to pause ❤️”.
      if (_state == HeartState.progressing) {
        _state = _heart.progress > 0 ? HeartState.paused : HeartState.empty;
        await repo.save(_heart, stateIndex: _state.index);
        // AutoResume 🔁
        // start();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> start() async {
    if (filler.isRunning || _state == HeartState.completed) return;

    _state = HeartState.progressing;
    await repo.save(_heart, stateIndex: _state.index);
    notifyListeners();

    filler.start(() async {
      _heart = _heart.copyWith(progress: _heart.progress + _heart.step);
      if (_heart.progress >= _heart.capacity) {
        await finish();
      } else {
        await repo.save(_heart, stateIndex: _state.index);
        notifyListeners();
      }
    });
  }

  Future<void> toggleStartPause() async {
    if (_state == HeartState.completed) return;

    if (filler.isRunning) {
      filler.pause();
      _state = _heart.progress > 0 ? HeartState.paused : HeartState.empty;
      await repo.save(_heart, stateIndex: _state.index);
      notifyListeners();
    } else {
      await start();
    }
  }

  Future<void> finish() async {
    filler.pause();
    _heart = _heart.copyWith(progress: _heart.capacity);
    _state = HeartState.completed;
    await repo.save(_heart, stateIndex: _state.index);
    notifyListeners();
  }

  Future<void> clear() async {
    filler.pause();
    _heart = _heart.copyWith(progress: 0);
    _state = HeartState.empty;
    await repo.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    filler.dispose();
    super.dispose();
  }
}
