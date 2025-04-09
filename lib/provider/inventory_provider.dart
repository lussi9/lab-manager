import 'package:flutter/material.dart';

class InventoryItem {
  String name;
  int quantity;
  String category;

  InventoryItem({required this.name, required this.quantity, required this.category});
}

class InventoryProvider extends ChangeNotifier {
  List<InventoryItem> _items = [];

  List<InventoryItem> get items => _items;

  void addItem(String name, int quantity, String category) {
    _items.add(InventoryItem(name: name, quantity: quantity, category: category));
    notifyListeners();
  }

  /*void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }*/
}
