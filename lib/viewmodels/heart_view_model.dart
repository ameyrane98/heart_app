import 'package:flutter/foundation.dart';
import '../models/heart.dart';

enum HeartState { empty, progressing, completed }

class HeartViewModel extends ChangeNotifier {
  late Heart _heart;
  HeartState _state = HeartState.empty;

  // getters for the UI
  double get progress => _heart.progress;
  String get status => _heart.status();
  HeartState get state => _state;

  void init() {
    _heart = Heart(progress: 0, step: 10);
  }
}
