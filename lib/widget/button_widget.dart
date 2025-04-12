
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget{
  final String text;
  final VoidCallback onClicked;
  final Color color;
  final Color textColor;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
    this.color = Colors.green,
    this.textColor = Colors.white,
  }) : super(key:key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onClicked,
      child: Text(text, style: TextStyle(fontSize: 20, color: textColor)),
  );
}