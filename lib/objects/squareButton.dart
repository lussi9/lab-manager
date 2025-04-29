import 'package:flutter/material.dart';

class squareButton extends StatelessWidget {
  final Color color;
  final String title;
  final buttontapped;

  squareButton({ this.title = '', this.color = const Color.fromRGBO(46, 125, 50, 1), this.buttontapped});

  @override
  Widget build(BuildContext context){
    return Expanded(
      child: GestureDetector(
        onTap: buttontapped,
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