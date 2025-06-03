import 'package:flutter/material.dart';
import 'package:lab_manager/calculations/calculator_page.dart';
import 'package:lab_manager/calculations/timer_page.dart';
import 'package:lab_manager/calculations/converter_page.dart';

class CalculationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
          flex: 1,
          child: Card(
            child: Center(
              child: ListTile(
                title: Center(child: Text('Timer', style: Theme.of(context).textTheme.titleLarge), ),
                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimerPage()),
                );
              },
              ),
          ))),
          Expanded(
            flex: 1,
            child: Card(
              child: Center(
                child: ListTile(
                  title: Center(child:Text('Calculator', style: Theme.of(context).textTheme.titleLarge)), 
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalculatorPage()),
                    );
                  },),
              )
            )
          ),
          Expanded(
            flex: 1,
            child: Card(
              child: Center(
                child: ListTile(
                  title: Center(child:Text('Converter', style: Theme.of(context).textTheme.titleLarge)),
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConverterView()),
                );
              }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}