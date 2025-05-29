import 'package:flutter/material.dart';

class AddItem extends StatelessWidget {
  final VoidCallback onPressed;
  AddItem({required this.onPressed});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(67, 160, 71, 1),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Add item",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}


