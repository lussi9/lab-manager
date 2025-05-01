import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_manager/model/fungible.dart';

class InventoryProvider extends ChangeNotifier {
  final List<Fungible> _fungibles = [];

  List<Fungible> get fungibles => _fungibles;

  Future<void> addFungible(Fungible fungible) async {
    // Save the Fungible to Firestore
    try {
      final docRef =
      await FirebaseFirestore.instance.collection('fungibles').add(fungible.toJson());

      //Update the Fungible so it has the correct id
      final newFungible = Fungible(
          documentId: docRef.id,
          name: fungible.name,
          description: fungible.description,
          quantity: fungible.quantity);

      _fungibles.add(newFungible);
      _fungibles.sort((a, b) => b.quantity.compareTo(a.quantity)); // Sort after adding
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error adding Fungible: $e');
    }
  }

  Future<void> deleteFungible(Fungible fungible) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('fungibles')
          .doc(fungible.documentId)
          .delete();

      // Remove from the local list
      _fungibles.remove(fungible);
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error deleting Fungible: $e');
    }
  }

  Future<void> editFungible(Fungible oldFungible, Fungible newFungible) async {
    try {
      // Update in Firestore
      await FirebaseFirestore.instance.collection('fungibles').doc(oldFungible.documentId).update(newFungible.toJson());

      // Update in the local list
      final index = _fungibles.indexOf(oldFungible);
      _fungibles[index] = newFungible;
      _fungibles[index].documentId = oldFungible.documentId; // Keep the same document ID
      _fungibles.sort((a, b) => b.quantity.compareTo(a.quantity)); // Sort again after edit
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

    _fungibles.sort((a, b) => b.quantity.compareTo(a.quantity));

    notifyListeners();
  }
}
