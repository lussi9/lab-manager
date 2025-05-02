import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_manager/model/fungible.dart';

class InventoryProvider extends ChangeNotifier {
  final List<Fungible> _fungibles = [];

  List<Fungible> get fungibles => _fungibles;
  String selectedOrder = "name";

  Future<void> addFungible(Fungible fungible) async {
    try {
      final docRef =
      await FirebaseFirestore.instance.collection('fungibles').add(fungible.toJson());

      final newFungible = Fungible(
          documentId: docRef.id,
          name: fungible.name,
          description: fungible.description,
          quantity: fungible.quantity);

      _fungibles.add(newFungible);
      orderList();
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error adding Fungible: $e');
    }
  }

  Future<void> deleteFungible(Fungible fungible) async {
    try {
      await FirebaseFirestore.instance
          .collection('fungibles')
          .doc(fungible.documentId)
          .delete();

      _fungibles.remove(fungible);
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error deleting Fungible: $e');
    }
  }

  Future<void> editFungible(Fungible oldFungible, Fungible newFungible) async {
    try {
      await FirebaseFirestore.instance.collection('fungibles').doc(oldFungible.documentId).update(newFungible.toJson());

      final index = _fungibles.indexOf(oldFungible);
      _fungibles[index] = newFungible;
      _fungibles[index].documentId = oldFungible.documentId; // Keep the same document ID
      orderList();
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error editing Fungible: $e');
    }
  }

  Future<void> loadFungibles() async {
    final fungiblesData = await FirebaseFirestore.instance.collection('fungibles').get();
    _fungibles.clear();

    for (var doc in fungiblesData.docs) {
      _fungibles.add(Fungible.fromJson(doc.data(), doc.id));
    }

    orderList();
    notifyListeners();
  }

  void setOrder(String orderBy) async {
    selectedOrder = orderBy;
  }

  void orderList() {
    if (selectedOrder == "name") {
      _fungibles.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedOrder == "quantity") {
      _fungibles.sort((a, b) => a.quantity.compareTo(b.quantity));
    }
  }
}
