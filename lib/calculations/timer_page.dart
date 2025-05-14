import 'package:flutter/material.dart';
import 'package:lab_manager/calculations/timer_provider.dart';
import 'package:provider/provider.dart';
import 'package:duration_picker/duration_picker.dart';

class TimerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timers'),
        backgroundColor: Color.fromRGBO(67, 160, 71, 1),
      ),
      body: Consumer<TimerProvider>(
        builder: (context, provider, _) {
          if (provider.timers.isEmpty) {
            return Center(
              child: Text(
                'No timers available.',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.timers.length,
            itemBuilder: (context, index) {
              final timer = provider.timers[index];
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(timer.label, style: TextStyle(fontSize: 20)),
                        Text(
                          timer.remaining.toString().split('.').first,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Add spacing between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            timer.isRunning ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: () {
                            timer.isRunning
                                ? provider.stopTimer(index)
                                : provider.startTimer(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.replay),
                          onPressed: () {
                            provider.resetTimer(index);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddTimerDialog(context),
        backgroundColor: Color.fromRGBO(67, 160, 71, 1),
      ),
    );
  }

  void _showAddTimerDialog(BuildContext context) {
    String label = '';
    Duration duration = Duration(minutes: 1);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('New Timer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (val) => label = val,
                  decoration: InputDecoration(labelText: 'Label'),
                ),
                SizedBox(height: 20),
                DurationPicker(
                  duration: duration,
                  onChange: (val) {
                    setState(() => duration = val);
                  },
                  snapToMins: 1.0,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (duration.inSeconds > 0) {
                    Provider.of<TimerProvider>(context, listen: false)
                        .addTimer(
                      label.isEmpty ? 'Untitled Timer' : label,
                      duration,
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
