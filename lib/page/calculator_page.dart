import 'package:flutter/material.dart';
import 'package:lab_manager/objects/button.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  CalculatorPageState createState() => CalculatorPageState();
}

class CalculatorPageState extends State<CalculatorPage> {
  var userInput = '';
  var result = '0';
  @override
  Widget build(BuildContext context) {
    List<String> buttons = [
      'C', '+/-', '%', 'DEL', 
      '7', '8', '9', '/',
      '4', '5', '6', 'x',
      '1', '2', '3', '-',
      '.', '0', '=', '+',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
       children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 70),
                alignment: Alignment.centerRight,
                child: Text(
                  userInput,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                alignment: Alignment.centerRight,
                child: Text(
                  result.toString(),
                ),
              )
            ],
          )
        ),
        Expanded(
          flex:2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              itemCount: buttons.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4), itemBuilder: (BuildContext context, int index){
              if(index == 0){ // C
                return MyButton(
                  buttonText: buttons[index],
                  color: Colors.grey[600],
                  textColor: Colors.white,
                  buttontapped: () {
                    setState(() {
                      userInput = '';
                      result = '0';
                    });
                  }
                );
              } 

              else if(index == 1){ // +/-
                return MyButton(
                  buttonText: buttons[index],
                  color: Colors.grey[600],
                  textColor: Colors.white,
                );
              }

              else if(index == 2){ // %
                return MyButton(
                  buttonText: buttons[index],
                  color: Colors.grey[600],
                  textColor: Colors.white,
                  buttontapped: () {
                    setState(() {
                      userInput += buttons[index];
                    });
                  }
                );
              }

              else if(index == 3){ // DEL
                return MyButton(
                  buttonText: buttons[index],
                  color: Colors.grey[600],
                  textColor: Colors.white,
                  buttontapped: () {
                    setState(() {
                      userInput = userInput.substring(0, userInput.length - 1);
                    });
                  }
                );
              }

              else if(index == 18) { // =
                return MyButton(
                  buttonText: buttons[index],
                  color: Colors.green[800],
                  textColor: Colors.white,
                  buttontapped: () {
                    setState(() {
                      equalPressed();
                    });
                  }
                );
              }

              else{
                return MyButton(
                  buttontapped: (){
                    setState(() {
                      userInput += buttons[index];
                    });
                  },
                  buttonText: buttons[index],
                  color: isOperator(buttons[index])? Colors.green[800] : Colors.grey[800],
                  textColor: Colors.white,
                );
              }
            })
            )
          )
       ],
      ),
    );
  }


  
  bool isOperator(String o){
    if(o =='/' || o =='x' || o =='-' || o =='+' || o =='=' ){
      return true;
    } else{
      return false;
    }
  }

  void equalPressed(){
    String finalUserInput = userInput;
    finalUserInput = userInput.replaceAll('x', '*');

    Parser p = Parser();
    Expression exp = p.parse(finalUserInput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    result = eval.toString(); //.round
  }
}
