import 'package:flutter/material.dart';

// This widget is used to display an "Add Item" button in the inventory
class AddItem extends StatelessWidget {
  final VoidCallback onPressed;
  AddItem({required this.onPressed});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: onPressed,
        child: Text(
          "Add item", style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}


