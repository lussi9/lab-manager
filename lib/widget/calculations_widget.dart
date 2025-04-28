import 'package:flutter/material.dart';
import 'package:lab_manager/page/calculator_page.dart';
import 'package:lab_manager/page/timer_page.dart';

class CalculationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Calculations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildSquare(context, 'Timer', Colors.blue, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimerPage()),
            );
          }),
          _buildSquare(context, 'Calculator', Colors.green, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalculatorPage()),
            );
          }),
          _buildSquare(context, 'Conversor', Colors.orange, () {
            print('Conversor tapped'); //ConversorWidget()
          }),
        ],
      ),
    );
  }

  Widget _buildSquare(BuildContext context, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}