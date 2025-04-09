import 'package:flutter/material.dart';
import 'package:lab_manager/widget/button_widget.dart';

class CalculationsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Center(
          child: buildButtons(),
        ),
    );
  }

  Widget buildButtons(){
    return ButtonWidget(
      text: 'Start Timer',
      onClicked: () {}
    );
  }
}