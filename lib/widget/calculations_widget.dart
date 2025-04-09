import 'package:flutter/material.dart';

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
            print('Timer tapped'); //TimerWidget()
          }),
          _buildSquare(context, 'Calculator', Colors.green, () {
            print('Calculator tapped'); //CalculatorWidget()
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