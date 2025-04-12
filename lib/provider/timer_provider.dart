import 'package:flutter/material.dart';
import 'package:lab_manager/model/timer.dart';

class TimerProvider with ChangeNotifier {
  List<Timer> timers = [];

  void addTimer(String label) {
    timers.add(Timer(label: label));
    notifyListeners();
  }

  void startTimer(int index) {
    timers[index].stopwatch.start();
    timers[index].isRunning = true;
    notifyListeners();
  }

  void stopTimer(int index) {
    timers[index].stopwatch.stop();
    timers[index].isRunning = false;
    notifyListeners();
  }

  void resetTimer(int index) {
    timers[index].stopwatch.reset();
    timers[index].elapsed = Duration.zero;
    timers[index].isRunning = false;
    notifyListeners();
  }

  void updateElapsed() {
    for (var timer in timers) {
      if (timer.isRunning) {
        timer.elapsed = timer.stopwatch.elapsed;
      }
    }
    notifyListeners();
  }
}
