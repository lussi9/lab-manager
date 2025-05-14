class CountdownTimer {
  String label;
  Duration duration;
  Duration remaining;
  bool isRunning;
  DateTime? endTime;

  CountdownTimer({required this.label,
  required this.duration})
      : isRunning = true,
        remaining  = duration;

  void reset() {
    remaining = duration;
    endTime =  DateTime.now().add(duration);
  }
}
