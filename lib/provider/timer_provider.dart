import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lab_manager/model/countdown_timer.dart';

class TimerProvider extends ChangeNotifier {
  final List<CountdownTimer> timers = [];
  Timer? _ticker;

  void addTimer(String label, Duration duration) {
    timers.add(CountdownTimer(label: label, duration: duration));
    notifyListeners();
  }

  void stopTimer(int index) {
    if (index >= 0 && index < timers.length) {
      timers[index].isRunning = false;
      _ticker?.cancel();
      _ticker = null; // Clear the reference
      notifyListeners();
    }
  }

  void startTimer(int index) {
    final timer = timers[index];

    // Ensure the timer is not already running
    if (timer.isRunning) return;

    // Calculate endTime based on the remaining time
    timer.endTime = DateTime.now().add(timer.remaining);
    timer.isRunning = true;

    // Cancel any existing ticker
    _ticker?.cancel();
    _ticker = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final newRemaining = timer.endTime!.difference(now);

      if (newRemaining <= Duration.zero) {
        timer.remaining = Duration.zero;
        timer.isRunning = false;
        _ticker?.cancel();
        _ticker = null; // Clear the reference
        _playAlarm(); // Play alarm when the timer finishes
      } else {
        timer.remaining = newRemaining;
      }

      notifyListeners();
    });
  }

  void resetTimer(int index) {
    if (index >= 0 && index < timers.length) {
      stopTimer(index);
      timers[index].reset();
      notifyListeners();
    }
  }

  void tick() {
    for (var timer in timers) {
      if (timer.isRunning && timer.remaining > Duration.zero) {
        timer.remaining -= Duration(seconds: 1);
        if (timer.remaining <= Duration.zero) {
          timer.remaining = Duration.zero;
          timer.isRunning = false;
          _playAlarm(); // alarm when finished
        }
      }
    }
    notifyListeners();
  }

  void _playAlarm() {
    // You'll need to integrate an audio package like `audioplayers`
    print("⏰ Timer done! Play alarm sound here");
  }
}
