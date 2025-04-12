import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lab_manager/provider/timer_provider.dart';
import 'package:provider/provider.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TimerProvider>(context, listen: false);
    updateTimer = Timer.periodic(Duration(seconds: 1), (_) {
      provider.updateElapsed();
    });
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timers')),
      body: Consumer<TimerProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            itemCount: provider.timers.length,
            itemBuilder: (context, index) {
              final timer = provider.timers[index];
              return ListTile(
                title: Text(timer.label),
                subtitle: Text(timer.elapsed.toString().split('.').first),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        timer.isRunning
                            ? provider.stopTimer(index)
                            : provider.startTimer(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.replay),
                      onPressed: () => provider.resetTimer(index),
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
      ),
    );
  }

  void _showAddTimerDialog(BuildContext context) {
    String label = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Timer'),
        content: TextField(
          onChanged: (val) => label = val,
          decoration: InputDecoration(labelText: 'Label'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<TimerProvider>(context, listen: false)
                  .addTimer(label.isEmpty ? 'Untitled Timer' : label);
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
