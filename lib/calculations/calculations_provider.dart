import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_manager/calculations/calculation.dart';

final userId = FirebaseAuth.instance.currentUser?.uid;

class CalculationsProvider extends ChangeNotifier {
  final List<Calculation> _calculations = [];
  final List<Calculation> _conversions = [];
  List<Calculation> get calculations => _calculations;
  List<Calculation> get conversions => _conversions;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addCalculation(Calculation c) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('calculations').add(c.toJson());

    _calculations.add(c);
    notifyListeners();
  }

  Future<void> loadCalculations() async {
    final calculationsData = await FirebaseFirestore.instance.collection('users').doc(userId)
      .collection('calculations').get();

    _calculations.clear();
    for (var doc in calculationsData.docs) {
      _calculations.add(Calculation.fromJson(doc.data(), doc.id));
    }

    notifyListeners();
  }

  Future<void> addConversion(Calculation c) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('conversions').add(c.toJson());

    _calculations.add(c);
    notifyListeners();
  }

  Future<void> loadConversions() async {
    final conversionsData = await FirebaseFirestore.instance.collection('users').doc(userId)
      .collection('conversions').get();

    _conversions.clear();
    for (var doc in conversionsData.docs) {
      _conversions.add(Calculation.fromJson(doc.data(), doc.id));
    }

    notifyListeners();
  }

  // Deletes history of calculations or conversions
  Future<void> clearHistory(String type) async {
    final data = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection(type)
      .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in data.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    notifyListeners();
  }
}