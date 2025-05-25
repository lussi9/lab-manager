import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lab_manager/calculations/timer_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class TimerPage extends StatefulWidget {
  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  Duration selectedDuration = Duration(minutes: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timer'),
        backgroundColor: Colors.green[600],),
      body: Column(
        children: [
          SizedBox(height: 10),
          Text('Pick Timer Duration', style: TextStyle(fontSize: 19)),
          SizedBox(height: 20),
          _buildPlatformTimerPicker(),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _addTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(67, 160, 71, 1), 
              foregroundColor: Colors.white,
            ),
            child: Text("Add Timer", style: TextStyle(fontSize: 18)),),
          SizedBox(height: 20),
          Expanded(
            child: Consumer<TimerProvider>(
              builder: (context, provider, _){
              return ListView.builder(
              itemCount: provider.timers.length,
              itemBuilder: (_, index) {
                final t = provider.timers[index];
                return Slidable(
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: 'Delete',
                        onPressed: (context) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${t.label} deleted")),
                          );
                          provider.removeTimer(t);
                        },
                      ),
                    ],),
                  child: ListTile(
                    title: Text(t.label),
                    subtitle: Text(_format(t.remaining)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(t.isRunning ? Icons.pause : Icons.play_arrow),
                          onPressed: () => provider.startPauseTimer(t),
                        ),
                        IconButton(
                          icon: Icon(Icons.restore),
                          onPressed: () => provider.resetTimer(t),
                        ),
                      ],
                    ),
                  ),
                );
              },
              );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlatformTimerPicker() {
    if (kIsWeb) {
      // Web: Custom pickers for hours, minutes, seconds
    int hours = selectedDuration.inHours;
    int minutes = selectedDuration.inMinutes % 60;
    int seconds = selectedDuration.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _numberPicker(
          label: 'Hours',
          value: hours,
          max: 23,
          onChanged: (val) => setState(() {
            selectedDuration = Duration(
              hours: val,
              minutes: minutes,
              seconds: seconds,
            );
          }),
        ),
        SizedBox(width: 16),
        _numberPicker(
          label: 'Minutes',
          value: minutes,
          max: 59,
          onChanged: (val) => setState(() {
            selectedDuration = Duration(
              hours: hours,
              minutes: val,
              seconds: seconds,
            );
          }),
        ),
        SizedBox(width: 16),
        _numberPicker(
          label: 'Seconds',
          value: seconds,
          max: 59,
          onChanged: (val) => setState(() {
            selectedDuration = Duration(
              hours: hours,
              minutes: minutes,
              seconds: val,
            );
          }),
        ),
      ],
    );
    } else if (Platform.isIOS || Platform.isAndroid) {
      return SizedBox(
        height: 150,
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hms,
          initialTimerDuration: selectedDuration,
          onTimerDurationChanged: (val) {
            setState(() {
              selectedDuration = val;
            });
          },
        ),
      );
    } else {
      return Text("Timer Picker not available on this platform.");
    }
  }

  void _addTimer() async {
    final labelController = TextEditingController();

    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter Timer Label"),
        content: TextField(
          controller: labelController,
          autofocus: true,
          decoration: InputDecoration(hintText: "e.g. Experiment 1"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, labelController.text),
              child: Text("OK")),
        ],
      ),
    );

    final timerLabel = (label == null || label.trim().isEmpty)? 'Untitled Timer' : label.trim();
    Provider.of<TimerProvider>(context, listen: false).addTimer(selectedDuration, timerLabel);
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  Widget _numberPicker({
  required String label,
  required int value,
  required int max,
  required ValueChanged<int> onChanged,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label),
      DropdownButton<int>(
        value: value,
        items: List.generate(
          max + 1,
          (i) => DropdownMenuItem(value: i, child: Text(i.toString().padLeft(2, '0'))),
        ),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    ],
  );
}
}