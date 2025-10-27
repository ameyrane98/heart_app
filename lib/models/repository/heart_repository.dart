// lib/model/repository/heart_repository.dart
import '../heart.dart';

abstract class HeartRepository {
  Future<Heart> load();
  Future<void> save(Heart heart, {required int stateIndex});
  Future<void> clear();
}
