import 'package:flutter/material.dart';

// This widget is used for the buttons in the calculator
class MyButton extends StatelessWidget {
  final color;
  final textColor;
  final String buttonText;
  final buttonTapped;
  final longPress;

  MyButton({this.color, this.textColor, this.buttonText = '', this.buttonTapped, this.longPress});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: buttonTapped,
      onLongPress: longPress,
      child: Padding(
        padding: EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          buttonText,
          style: TextStyle(
            color: textColor,
            fontSize: 25,
          ),
        ),
      ),
      ),
    );
  }
}