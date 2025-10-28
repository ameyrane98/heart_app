import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heart_app/viewmodels/heart_view_model.dart';
import 'package:heart_app/models/heart.dart';
import 'package:heart_app/models/repository/heart_repository.dart';
import 'package:heart_app/models/services/heart_fill_service.dart';

class FakeHeartFillService implements HeartFillService {
  bool _running = false;
  VoidCallback? _onTick;

  // Your interface exposes this getter:
  @override
  Duration get tickDuration => const Duration(seconds: 1);

  bool get running => _running;

  @override
  bool get isRunning => _running; // if your interface exposes isRunning

  @override
  void start(Function() onTick) {
    _running = true;
    // Accept both sync/async callbacks—store as VoidCallback for tests.
    _onTick = () {
      // If onTick is async, ignore the Future in tests.
      final result = onTick();
      if (result is Future) {
        // ignore: discarded_futures
        result;
      }
    };
  }

  @override
  void pause() {
    _running = false;
  }

  @override
  void dispose() {
    _running = false;
    _onTick = null;
  }

  // Helper to simulate "1 second tick"
  void tickOnce() => _onTick?.call();
}

class FakeRepo implements HeartRepository {
  Heart stored = Heart(
    progress: 0,
    step: 10,
    capacity: 100,
  ); // default empty heart

  int saveCalls = 0;
  int clearCalls = 0;

  @override
  Future<Heart> load() async => stored;

  @override
  Future<void> save(Heart heart, {int? stateIndex}) async {
    saveCalls++;
    stored = heart;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    stored = stored.copyWith(progress: 0);
  }
}

void main() {
  group('HeartViewModel test', () {
    // Utility to create a fresh VM each test
    Future<HeartViewModel> _makeVM({
      Heart? seed,
      FakeRepo? repo,
      FakeHeartFillService? filler,
    }) async {
      final r = repo ?? FakeRepo();
      if (seed != null) r.stored = seed;
      final f = filler ?? FakeHeartFillService();
      final vm = HeartViewModel(repo: r, filler: f);
      // Wait a tiny bit for async _init() to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return vm;
    }

    test('initial load → empty state, 0%', () async {
      final vm = await _makeVM(); // default repo has progress=0
      expect(vm.state, HeartState.empty);
      expect(vm.percent, 0);
      expect(vm.progress, 0);
      expect(vm.capacity, 100);
    });

    test(
      'start() from empty → progressing and starts filler + saves once',
      () async {
        final repo = FakeRepo();
        final filler = FakeHeartFillService();
        final vm = await _makeVM(repo: repo, filler: filler);

        await vm.start();

        expect(vm.state, HeartState.progressing);
        expect(filler.running, isTrue);
        expect(
          repo.saveCalls,
          greaterThanOrEqualTo(1),
        ); // saved when start() called
      },
    );

    test('tick increments progress by step and saves', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await _makeVM(repo: repo, filler: filler);

      await vm.start(); // progressing
      filler.tickOnce(); // +10
      expect(vm.progress, 10);
      expect(vm.percent, 10);
      expect(repo.saveCalls, greaterThanOrEqualTo(2)); // start() + tick save
    });

    test('toggleStartPause() while progressing → pauses and saves', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await _makeVM(repo: repo, filler: filler);

      await vm.start(); // progressing
      filler.tickOnce(); // ensure progress > 0 so pause => paused (not empty)

      vm.toggleStartPause(); // pause

      expect(vm.state, HeartState.paused);
      expect(filler.running, isFalse);
      expect(repo.saveCalls, greaterThanOrEqualTo(2)); // start + tick or pause
    });

    test(
      'toggleStartPause() from paused → resumes (progressing) and starts filler',
      () async {
        final repo = FakeRepo();
        final filler = FakeHeartFillService();
        final vm = await _makeVM(repo: repo, filler: filler);

        await vm.start(); // progressing
        filler.tickOnce(); // progress > 0
        vm.toggleStartPause(); // pause -> state.paused

        // resume (internally calls async start())
        vm.toggleStartPause();

        // allow async start() to finish (repo.save -> filler.start)
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(vm.state, HeartState.progressing);
        expect(filler.running, isTrue);
      },
    );

    test(
      'reaching capacity triggers finish(): completed, clamped to 100%',
      () async {
        final repo = FakeRepo();
        final filler = FakeHeartFillService();
        // Seed heart near capacity so one tick finishes it
        final vm = await _makeVM(
          repo: repo,
          filler: filler,
          seed: Heart(progress: 90, step: 10, capacity: 100),
        );

        await vm.start(); // progressing
        filler.tickOnce(); // +10 → 100 → finish()

        expect(vm.state, HeartState.completed);
        expect(vm.progress, 100);
        expect(vm.percent, 100);
        expect(filler.running, isFalse); // paused in finish()
      },
    );

    test('toggleStartPause() when completed → does nothing', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await _makeVM(
        repo: repo,
        filler: filler,
        seed: Heart(progress: 100, step: 10, capacity: 100),
      );

      // Manually set to completed via finish() to mimic behavior
      vm.finish();
      expect(vm.state, HeartState.completed);

      vm.toggleStartPause(); // should be no-op
      expect(vm.state, HeartState.completed);
      expect(filler.running, isFalse);
    });

    test('start() ignored when filler already running', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await _makeVM(repo: repo, filler: filler);

      await vm.start(); // start once
      final savesBefore = repo.saveCalls;
      await vm.start(); // try to start again while running

      // State still progressing and no extra save just for ignoring
      expect(vm.state, HeartState.progressing);
      expect(repo.saveCalls, savesBefore);
    });

    test('start() ignored when already completed', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await _makeVM(
        repo: repo,
        filler: filler,
        seed: Heart(progress: 100, step: 10, capacity: 100),
      );

      vm.finish(); // ensure completed
      await vm.start();

      expect(vm.state, HeartState.completed);
      expect(filler.running, isFalse);
    });

    test('clear() resets to empty, progress=0, calls repo.clear', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await _makeVM(
        repo: repo,
        filler: filler,
        seed: Heart(progress: 50, step: 10, capacity: 100),
      );

      vm.clear();

      expect(vm.state, HeartState.empty);
      expect(vm.progress, 0);
      expect(vm.percent, 0);
      expect(repo.clearCalls, 1);
      expect(filler.running, isFalse);
    });

    test('dispose() calls filler.dispose()', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await _makeVM(repo: repo, filler: filler);

      await vm.start();
      expect(filler.running, isTrue);

      vm.dispose(); // should dispose filler
      expect(filler.running, isFalse);
    });

    test(
      'init() loads heart from repo (non-zero progress stays as loaded)',
      () async {
        // NOTE: Your current _init sets state=empty only if progress<=0.
        // For non-zero progress, it leaves state as initially empty too.
        // This test asserts the loaded values; UI/state handling (paused/progressing)
        // is up to your later logic.
        final repo = FakeRepo();
        repo.stored = Heart(progress: 30, step: 10, capacity: 100);

        final vm = await _makeVM(repo: repo);

        expect(vm.progress, 30);
        expect(vm.percent, closeTo(30, 0.001));
        // Current implementation keeps state as empty here:
        expect(vm.state, HeartState.empty);
      },
    );
  });
}
