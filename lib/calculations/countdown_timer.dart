import 'dart:async';
class CountdownTimer {
  String label;
  Duration duration;
  Duration remaining;
  bool isRunning;
  DateTime? endTime;
  Timer? timer;

  CountdownTimer({required this.duration, required this.label})
      : remaining = duration,
        isRunning = false;
}
