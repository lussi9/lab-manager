class Timer {
  String label;
  Duration elapsed;
  bool isRunning;
  late Stopwatch stopwatch;

  Timer({required this.label})
      : elapsed = Duration.zero,
        isRunning = false,
        stopwatch = Stopwatch();
}
