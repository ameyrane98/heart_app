// lib/model/repository/heart_repository.dart
import 'package:heart_app/models/heart.dart';

abstract class HeartRepository {
  Future<Heart> load();
  Future<void> save(Heart heart, {required int stateIndex});
  Future<void> clear();
  Future<int?> loadStateIndex();
}
