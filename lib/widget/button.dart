import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final color;
  final textColor;
  final String buttonText;
  final buttontapped;

  MyButton({this.color, this.textColor, this.buttonText = '', this.buttontapped});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: buttontapped,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            alignment: Alignment.center,
            color: color,
            child: Text(
                buttonText,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
            ),
          ),
        ),
    )
    );
  }
}