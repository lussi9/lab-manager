import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lab_manager/calculations/timer_provider.dart';
import 'package:provider/provider.dart';

class TimerPage extends StatefulWidget {
  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  Duration selectedDuration = Duration(minutes: 1);

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

    if (label != null && label.isNotEmpty) {
      Provider.of<TimerProvider>(context, listen: false).addTimer(selectedDuration, label);
    }
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

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
          SizedBox(
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
          ),
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
}