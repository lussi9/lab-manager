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
  int parenthesesCount = 0;
  List<String> history = [];

  @override
  Widget build(BuildContext context) {
    List<String> buttons = [
      'C/AC', '√', '%', '/', 
      '7', '8', '9', 'x',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '( )', '0', '.', '=',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.history, size: 30),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: 'History',
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Center(child: Text('Calculation History')),
            ),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('No history yet.'))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(history[index], style: TextStyle(fontSize: 24),),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    history.clear();
                  });
                  Navigator.pop(context); // Close the drawer
                },
                icon: const Icon(Icons.delete),
                label: const Text('Clear History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            )
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                      alignment: Alignment.centerRight,
                      child: Text(
                        userInput, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Color(0xff299082),
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      alignment: Alignment.centerRight,
                      child: Text(
                        result.toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Color(0xff005a4e),
                          fontSize: 40,
                        )
                      ),
                    )
                  ],
                )
              ),
              Expanded(
                flex: 8,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double width = constraints.maxWidth;
                    double height = constraints.maxHeight - 20;
                    int columns = 4;
                    double spacing = 3;
                    double itemWidth = (width - spacing * (columns - 1)) / columns;
                    double itemHeight = height / 5; // Total rows = 5
                    double aspectRatio = itemWidth / itemHeight;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: buttons.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisSpacing: spacing, crossAxisSpacing: spacing, childAspectRatio: aspectRatio), 
                      itemBuilder: (BuildContext context, int index){
                      if(index == 0){ // C
                        return MyButton(
                          buttonText: buttons[index],
                          color: Color(0xff299082),
                          textColor: Colors.white,
                          buttonTapped: () {
                            setState(() {
                              userInput = userInput.substring(0, userInput.length - 1);
                            });
                          },
                          longPress: () {
                            setState(() {
                              userInput = '';
                              result = '0';
                            });
                          },
                        );
                      } 

                      else if(index == 1){ // sqrt
                        return MyButton(
                          buttonText: buttons[index],
                          color: Color(0xff299082),
                          textColor: Colors.white,
                          buttonTapped: (){
                            setState(() {
                              userInput += buttons[index];
                            });
                          },
                        );
                      }

                      else if(index == 2){ // %
                        return MyButton(
                          buttonText: buttons[index],
                          color: Color(0xff299082),
                          textColor: Colors.white,
                          buttonTapped: () {
                            setState(() {
                              userInput += buttons[index];
                            });
                          }
                        );
                      }

                      else if(index == 16){ // ()
                        return MyButton(
                          buttonText: buttons[index],
                          color: Color(0xFF005a4e),
                          textColor: Colors.white,
                          buttonTapped: () {
                            setState(() {
                              if (parenthesesCount % 2 == 0) {
                                userInput += '(';
                              } else {
                                userInput += ')';
                              }
                              parenthesesCount++;
                            });
                          }
                        );
                      }

                      else if(index == 18){ // .
                        return MyButton(
                          buttonText: buttons[index],
                          color: Color(0xFF005a4e),
                          textColor: Colors.white,
                          buttonTapped: () {
                            setState(() {
                              userInput += buttons[index];
                            });
                          }
                        );
                      }

                      else if(index == 19) { // =
                        return MyButton(
                          buttonText: buttons[index],
                          color: Color(0xff9fe594),
                          textColor: Color(0xff005a4e),
                          buttonTapped: () {
                            setState(() {
                              equalPressed();
                            });
                          }
                        );
                      }

                      else{
                        return MyButton(
                          buttonTapped: (){
                            setState(() {
                              userInput += buttons[index];
                            });
                          },
                          buttonText: buttons[index],
                          color: isOperator(buttons[index])? Color(0xff9fe594) : Color(0xff005a4e),
                          textColor: isOperator(buttons[index])? Color(0xff005a4e) : Colors.white,
                        );
                      }
                    });
                  }
                ) 
              )
            ],
          ),
        )
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

  void equalPressed() {
    String finalUserInput = userInput;

    finalUserInput = finalUserInput.replaceAll('x', '*'); // Replace 'x' with '*'
    finalUserInput = finalUserInput.replaceAll('√', 'sqrt('); // Replace '√' with 'sqrt('

    int openParentheses = '('.allMatches(finalUserInput).length;
    int closeParentheses = ')'.allMatches(finalUserInput).length;
    finalUserInput += ')' * (openParentheses - closeParentheses);

    try {
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(finalUserInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        result = eval.toString(); // Display the result
        if (history.length >= 30) {
          history.removeAt(0); // Remove the oldest
        }
        history.add('$finalUserInput = $result'); // Add to history
      });
    } catch (e) {
      setState(() {
        result = "Error"; // Handle invalid expressions
      });
    }
  }
}
