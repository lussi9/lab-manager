import 'package:flutter/material.dart';
import 'package:lab_manager/model/fungible.dart';
import 'package:lab_manager/provider/inventory_provider.dart';
import 'package:provider/provider.dart';

class AddNewItemForm extends StatefulWidget {
  @override
  _AddNewItemFormState createState() => _AddNewItemFormState();
}

class _AddNewItemFormState extends State<AddNewItemForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add New Item',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: 'Name'),
            onChanged: (value) => _name = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Description'),
            onChanged: (value) => _description = value,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsedValue = int.tryParse(value) ?? 0;
              setState(() {
                _quantity = parsedValue < 0 ? 0 : parsedValue; // Ensure quantity is not below 0
              });
            },
            validator: (value) {
              final parsedValue = int.tryParse(value ?? '');
              if (parsedValue == null || parsedValue < 0) {
                return 'Please enter a valid number greater than or equal to 0';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Provider.of<InventoryProvider>(context, listen: false).addFungible(
                  Fungible(name: _name,description: _description, quantity: _quantity),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}