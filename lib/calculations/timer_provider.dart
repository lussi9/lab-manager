import 'package:flutter/material.dart';
import 'package:lab_manager/objects/notification.dart';
import 'countdown_timer.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class TimerProvider extends ChangeNotifier {
  final List<CountdownTimer> _timers = [];
  final AudioPlayer _player = AudioPlayer();

  List<CountdownTimer> get timers => _timers;

  void addTimer(Duration duration, String label) {
    _timers.add(CountdownTimer(label: label, duration: duration));
    notifyListeners();
  }

  void removeTimer(CountdownTimer timer) {
    timer.timer?.cancel();
    _timers.remove(timer);
    notifyListeners();
  }

  void startPauseTimer(CountdownTimer timerModel) {
    if (timerModel.isRunning) {
      timerModel.timer?.cancel();
      timerModel.isRunning = false;
    } else {
      timerModel.isRunning = true;
      timerModel.timer = Timer.periodic(Duration(seconds: 1), (_) {
        if (timerModel.remaining.inSeconds > 0) {
          timerModel.remaining -= Duration(seconds: 1);
        } else {
          timerModel.timer?.cancel();
          timerModel.isRunning = false;
          _player.play(AssetSource('alarm.mp3'));
          NotificationService().showNotification(
            id: 0,
            title: 'Timer Finished',
            body: 'Your timer ${timerModel.label} has finished.',
          );
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void resetTimer(CountdownTimer timerModel) {
    timerModel.timer?.cancel();
    timerModel.remaining = timerModel.duration;
    timerModel.isRunning = false;
    notifyListeners();
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }
}
