import 'package:flutter/material.dart';
import 'package:lab_manager/objects/squareButton.dart';

class ConverterMainPage extends StatelessWidget {
  ConverterMainPage({super.key});

  final List<Map<String, dynamic>> unitCategories = [
    {
      'label': 'Weight',
      'units': ['Kilograms', 'Grams', 'Pounds'],
    },
    {
      'label': 'Volume',
      'units': ['Liters', 'Milliliters', 'Gallons'],
    },
    {
      'label': 'Concentration',
      'units': ['Molar', 'Percent', 'ppm'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converter'),
        backgroundColor: Colors.green[800]
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            squareButton(title: 'Concentration', buttontapped: () {
              print('Concentration button tapped');
            }),
            squareButton(title: 'Volume', color: const Color.fromRGBO(56, 142, 60, 1), buttontapped: () {
              print('Volume button tapped');
            }),
            squareButton(title: 'Weight', color: const Color.fromRGBO(67, 160, 71, 1), buttontapped: () {
             print('Weight button tapped');
            }),
          ],
        ),
      )
    );
  }
}

////////////////////////////////////
////////////////////////////////////

/*

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: unitCategories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Unit Converter'),
          bottom: TabBar(
            tabs: unitCategories.map((cat) => Tab(text: cat['label'])).toList(),
          ),
        ),
        body: TabBarView(
          children: unitCategories.map((cat) {
            return ConverterView(
              category: cat['label'],
              units: cat['units'],
            );
          }).toList(),
        ),
      ),
    );
  }*/