// lib/model/repository/heart_repository_impl.dart
import '../heart.dart';
import 'heart_repository.dart';
import '../services/heart_local_driver.dart';

class HeartRepositoryImpl implements HeartRepository {
  final HeartLocalDriver local;
  HeartRepositoryImpl(this.local);

  @override
  Future<Heart> load() => local.load();

  @override
  Future<void> save(Heart heart, {required int stateIndex}) =>
      local.save(heart, stateIndex: stateIndex);

  @override
  Future<void> clear() => local.clear();
}
