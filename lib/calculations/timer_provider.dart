import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lab_manager/calculations/countdown_timer.dart';

class TimerProvider extends ChangeNotifier {
  final List<CountdownTimer> timers = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<int>? _tickerSubscription;

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void addTimer(String label, Duration duration) {
    timers.add(CountdownTimer(label: label, duration: duration));
    notifyListeners();
  }

  void stopTimer(int index) {
    if (index >= 0 && index < timers.length) {
      timers[index].isRunning = false;
      _tickerSubscription?.cancel();
      _tickerSubscription = null; // Clear the reference
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
    _tickerSubscription?.cancel();
    _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x)
        .listen((_) {
      final now = DateTime.now();
      final newRemaining = timer.endTime!.difference(now);

      if (newRemaining <= Duration.zero) {
        timer.remaining = Duration.zero;
        timer.isRunning = false;
        _tickerSubscription?.cancel();
        _tickerSubscription = null; // Clear the reference
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

  void _playAlarm() async {
    try {
      await _audioPlayer.play(AssetSource('alarm.mp3')); // Play the alarm sound
    } catch (e) {
      print('Error playing alarm sound: $e');
    }
  }
}
