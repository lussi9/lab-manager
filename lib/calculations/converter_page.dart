import 'package:flutter/material.dart';
import 'package:lab_manager/calculations/calculation.dart';
import 'package:lab_manager/calculations/calculations_provider.dart';
import 'package:provider/provider.dart';

class ConverterView extends StatefulWidget {
  const ConverterView({super.key});

  @override
  ConverterViewState createState() => ConverterViewState();
}

class ConverterViewState extends State<ConverterView> {
  String? selectedCategory;
  String? fromUnit;
  String? toUnit;
  double? inputValue;
  double? result;

  bool isInputValid = true;
  List<String> history = [];
  
  // Conversion rates for different measurement categories
  static const Map<String, Map<String, double>> conversionRates = {
    'Weight': {
      'Tons': 0.001,
      'Kilograms': 1.0,
      'Grams': 1000.0,
      'Milligrams': 1000000.0,
      'Micrograms': 1000000000.0,
      'Nanograms': 1000000000000.0,
      'Pounds': 2.20462,
    },
    'Volume': {
      'Liters': 1.0,
      'Milliliters': 1000.0,
      'Microliters': 1000000.0,
      'Nanoliters': 1000000000.0,
      'Cubic Meters': 0.001,
    },
    'Concentration': {
      'Molar': 1.0,
      'Millimolar': 1000.0,
      'Micromolar': 1000000.0,
      'Nanomolar': 1000000000.0,
      'Picomolar': 1000000000000.0,
      'Femtomolar': 1000000000000000.0,
      'Percent': 100.0,
      'ppm': 1000000.0,
    },
    'Density': {
      'g/cm³': 1.0,
      'g/mL': 1.0,
      'kg/m³': 1000.0,
      'g/L': 1000.0,
      'mg/mL': 1000000.0,
      'mg/cm³': 1000000.0,
    },
  };

  List<String> get units {
    if (selectedCategory == null) return [];
    return conversionRates[selectedCategory!]!.keys.toList();
  }

  void convert() {
    if (fromUnit == null || toUnit == null || inputValue == null) return;

    // Conversion logic
    final rates = conversionRates[selectedCategory!]!;
    final double baseValue = inputValue! / rates[fromUnit]!; 
    final double converted = baseValue * rates[toUnit]!;

    setState(() {
      result = converted;
      if (history.length >= 30) {
        history.removeAt(0); // Remove the oldest
      }
      history.add('$inputValue $fromUnit = $result $toUnit');
      Provider.of<CalculationsProvider>(context, listen: false).addConversion(Calculation(calc: '$inputValue $fromUnit = $result $toUnit'));
    });
  }

    @override
  void initState(){
    super.initState();
    Provider.of<CalculationsProvider>(context, listen: false).loadCalculations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converter'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.history, size: 30),
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
                          title: Text(history[index], style: TextStyle(fontSize: 20),),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<CalculationsProvider>(context, listen: false).clearHistory('conversions');
                  setState(() {
                    history.clear();
                  });
                  Navigator.pop(context); // Close the drawer
                },
                icon: Icon(Icons.delete),
                label: const Text('Clear History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select the category
            DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select Category', style: TextStyle(color: Color(0xff005a4e))),
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  fromUnit = null;
                  toUnit = null;
                  inputValue = null;
                  result = null;
                });
              },
              items: conversionRates.keys .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, style: TextStyle(color: Color(0xff005a4e))),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            // Dropdown to select the "From Unit"
            DropdownButton<String>(
              hint: Text('From Unit', style: TextStyle(color: Color(0xff005a4e))),
              value: fromUnit,
              onChanged: (value) {
                setState(() {
                  fromUnit = value;
                  convert();
                });
              },
              items: units.map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit, style: TextStyle(color: Color(0xff005a4e))),
                      ))
                  .toList(),
            ),
            // Dropdown to select the "To Unit"
            DropdownButton<String>(
              hint: Text('To Unit', style: TextStyle(color: Color(0xff005a4e))),
              value: toUnit,
              onChanged: (value) {
                setState(() {
                  toUnit = value;
                  convert();
                });
              },
              items: units.map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit, style: TextStyle(color: Color(0xff005a4e))),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            // Input field for the value to convert
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter value' ,
                errorText: isInputValid ? null : 'Invalid input', // Show error message
              ),
              onChanged: (val) {
                setState(() {
                  if (val.isEmpty) {
                    inputValue = null;
                    result = null;
                    isInputValid = true;
                  } else {
                    final parsed = double.tryParse(val);
                    if (parsed != null) {
                      inputValue = parsed;
                      isInputValid = true; // Input is valid
                      convert();
                    } else {
                      isInputValid = false; // Input is invalid
                    }
                  }
                });
              },
            ),
            SizedBox(height: 20),
            // Display the result
            Text(
              result == null
                  ? 'Result: '
                  : 'Result: ${result!.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 24, color: Color(0xff005a4e)),
            ),
          ],
        ),
      ),
    );
  }
}
