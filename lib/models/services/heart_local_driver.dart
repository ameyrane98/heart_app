// lib/model/drivers/heart_local_driver.dart
import 'package:heart_app/models/heart.dart';
import 'local_storage.dart';

class HeartLocalDriver {
  final LocalStorage storage;
  HeartLocalDriver(this.storage);

  Future<Heart> load() async {
    final r = await storage.read();
    return Heart(
      capacity: r.capacity,
      progress: r.progress,
      step: r.capacity * 0.10, // 10% per tick
    );
  }

  Future<void> save(Heart heart, {required int stateIndex}) {
    return storage.write(
      progress: heart.progress,
      capacity: heart.capacity,
      stateIndex: stateIndex,
    );
  }

  Future<void> clear() => storage.clear();

  Future<int?> loadStateIndex() async {
    final r = await storage.read();
    return r.stateIndex;
  }
}
