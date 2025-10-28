import 'package:flutter_test/flutter_test.dart';
import 'package:heart_app/viewmodels/heart_view_model.dart';
import 'package:heart_app/models/heart.dart';
import 'package:heart_app/models/repository/heart_repository.dart';
import 'package:heart_app/models/services/heart_fill_service.dart';

class FakeHeartFillService implements HeartFillService {
  bool _running = false;
  Function()? _onTick;

  @override
  Duration get tickDuration => const Duration(seconds: 1);

  @override
  bool get isRunning => _running;

  @override
  void start(Function() onTick) {
    _running = true;
    _onTick = onTick;
  }

  @override
  void pause() => _running = false;

  @override
  void dispose() {
    _running = false;
    _onTick = null;
  }

  /// Manually simulate “one timer tick”.
  void tickOnce() => _onTick?.call();
}

class FakeRepo implements HeartRepository {
  Heart stored = const Heart(progress: 0, step: 10, capacity: 100);
  int saveCalls = 0;
  int clearCalls = 0;
  int? _stateIndex; // not used by these beginner tests

  @override
  Future<Heart> load() async => stored;

  @override
  Future<void> save(Heart heart, {int? stateIndex}) async {
    saveCalls++;
    stored = heart;
    _stateIndex = stateIndex;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    stored = stored.copyWith(progress: 0);
    _stateIndex = null;
  }

  @override
  Future<int?> loadStateIndex() async => _stateIndex;
}

/// Helper to create a fresh VM per test.
Future<HeartViewModel> makeVM({
  Heart? seed,
  FakeRepo? repo,
  FakeHeartFillService? filler,
}) async {
  final r = repo ?? FakeRepo();
  if (seed != null) r.stored = seed;
  final f = filler ?? FakeHeartFillService();
  final vm = HeartViewModel(repo: r, filler: f);
  // Give _init() a moment to run.
  await Future<void>.delayed(const Duration(milliseconds: 5));
  return vm;
}

void main() {
  group('HeartViewModel (beginner tests)', () {
    test('starts empty at 0%', () async {
      final vm = await makeVM();
      expect(vm.state, HeartState.empty);
      expect(vm.progress, 0);
      expect(vm.percent, 0);
      expect(vm.capacity, 100);
    });

    test('start() → progressing and timer running', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await makeVM(repo: repo, filler: filler);

      await vm.start();

      expect(vm.state, HeartState.progressing);
      expect(filler.isRunning, isTrue);
      expect(repo.saveCalls, greaterThanOrEqualTo(1));
    });

    test('one tick increases progress by step (10%)', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await makeVM(repo: repo, filler: filler);

      await vm.start();
      filler.tickOnce(); // +10

      expect(vm.progress, 10);
      expect(vm.percent, 10);
    });

    test(
      'toggleStartPause() pauses when progressing, resumes when paused',
      () async {
        final repo = FakeRepo();
        final filler = FakeHeartFillService();
        final vm = await makeVM(repo: repo, filler: filler);

        await vm.start(); // progressing
        filler.tickOnce(); // ensure progress > 0

        vm.toggleStartPause(); // pause
        expect(vm.state, HeartState.paused);
        expect(filler.isRunning, isFalse);

        vm.toggleStartPause(); // resume
        // tiny delay to allow async start to persist
        await Future<void>.delayed(const Duration(milliseconds: 5));
        expect(vm.state, HeartState.progressing);
        expect(filler.isRunning, isTrue);
      },
    );

    test('reaching 100% calls finish() → completed state', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await makeVM(
        repo: repo,
        filler: filler,
        seed: const Heart(progress: 90, step: 10, capacity: 100),
      );

      await vm.start();
      filler.tickOnce(); // +10 → 100

      expect(vm.state, HeartState.completed);
      expect(vm.progress, 100);
      expect(vm.percent, 100);
      expect(filler.isRunning, isFalse);
    });

    test('clear() resets to empty with 0%', () async {
      final repo = FakeRepo();
      final filler = FakeHeartFillService();
      final vm = await makeVM(
        repo: repo,
        filler: filler,
        seed: const Heart(progress: 50, step: 10, capacity: 100),
      );

      vm.clear();

      expect(vm.state, HeartState.empty);
      expect(vm.progress, 0);
      expect(vm.percent, 0);
      expect(repo.clearCalls, 1);
      expect(filler.isRunning, isFalse);
    });
  });
}
