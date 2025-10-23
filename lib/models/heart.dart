class Heart {
  double progress;
  final double step;

  Heart({required this.progress, required this.step});

  Future<void> fillHeart() async {
    while (progress < 100) {
      await Future.delayed(const Duration(seconds: 2));
      progress += step;
      if (progress > 100) progress = 100;
      print('Heart filled to $progress%');
    }

    print('Heart is full ❤️');
  }

  bool isfull() => progress >= 100;

  String status() => isfull() ? 'Full ❤️' : 'Filling...';
}
