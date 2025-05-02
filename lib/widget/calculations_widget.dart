import 'package:flutter/material.dart';
import 'package:lab_manager/page/calculator_page.dart';
import 'package:lab_manager/page/timer_page.dart';
import 'package:lab_manager/page/converter_page.dart';
import 'package:lab_manager/objects/squareButton.dart';

class CalculationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          squareButton(title: 'Timer', buttontapped: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimerPage()),
            );
          }),
          squareButton(title: 'Calculator', color: const Color.fromRGBO(56, 142, 60, 1), buttontapped: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalculatorPage()),
            );
          }),
          squareButton(title: 'Converter', color: const Color.fromRGBO(67, 160, 71, 1), buttontapped: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConverterMainPage()),
            );
          }),
        ],
      ),
    );
  }
}