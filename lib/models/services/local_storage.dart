// lib/model/drivers/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _kProgress = 'heart_progress';
  static const _kCapacity = 'heart_capacity';
  static const _kState = 'heart_state';

  Future<void> write({
    required double progress,
    required double capacity,
    required int stateIndex,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kProgress, progress);
    await p.setDouble(_kCapacity, capacity);
    await p.setInt(_kState, stateIndex);
  }

  Future<({double progress, double capacity, int stateIndex})> read() async {
    final p = await SharedPreferences.getInstance();
    return (
      progress: p.getDouble(_kProgress) ?? 0,
      capacity: p.getDouble(_kCapacity) ?? 100,
      stateIndex: p.getInt(_kState) ?? 0,
    );
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kProgress);
    await p.remove(_kCapacity);
    await p.remove(_kState);
  }
}
