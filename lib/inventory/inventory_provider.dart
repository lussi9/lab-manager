import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_manager/inventory/fungible.dart';
import 'package:lab_manager/inventory/folder.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryProvider extends ChangeNotifier {
  final Map<String, List<Fungible>> folderFungibles = {};
  final List<Folder> _folders = [];

  int quantityLimit = 2;
  List<Folder> get folders => _folders;
  List<Fungible> getFungibles(String folderId) {
    return folderFungibles[folderId] ?? [];
  }

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  void setQuantityLimit(int value) {
    quantityLimit = value;
    notifyListeners();
  }
  String selectedOrder = "name";

  Future<void> addFungible(String folderId, Fungible fungible) async {
    try {
      final docRef =
      await FirebaseFirestore.instance.collection('users').doc(userId)
      .collection('folders').doc(folderId).collection('fungibles').add(fungible.toJson());

      final newFungible = Fungible(
          documentId: docRef.id,
          name: fungible.name,
          description: fungible.description,
          quantity: fungible.quantity);

      folderFungibles.putIfAbsent(folderId, () => []);
      folderFungibles[folderId]!.add(newFungible);

      orderList(folderId);
      notifyListeners();
    } catch (e) {
      print('Error adding Fungible: $e');
    }
  }

  Future<void> deleteFungible(String folderId, Fungible fungible) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId)
        .collection('folders').doc(folderId)
        .collection('fungibles').doc(fungible.documentId).delete();
      
      folderFungibles[folderId]?.remove(fungible);
      notifyListeners();
    } catch (e) {
      print('Error deleting Fungible: $e');
    }
  }

  Future<void> updateFungible(String folderId, Fungible fungible) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId)
        .collection('folders').doc(folderId)
        .collection('fungibles').doc(fungible.documentId).update(fungible.toJson());

      final index = folderFungibles[folderId]?.indexWhere((f) => f.documentId == fungible.documentId);
      if (index != null && index >= 0) {
        folderFungibles[folderId]![index] = fungible;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating Fungible: $e');
    }
  }

    Future<void> loadFungibles(String folderId) async {
    final fungiblesData = await FirebaseFirestore.instance.collection('users').doc(userId)
      .collection('folders').doc(folderId)
      .collection('fungibles').get();

    folderFungibles[folderId] = fungiblesData.docs
    .map((doc) => Fungible.fromJson(doc.data(), doc.id))
    .toList();

    orderList(folderId);
    notifyListeners();
  }

  void setOrder(String orderBy, String folderId) async {
    selectedOrder = orderBy;
    orderList(folderId);
    notifyListeners();
  }

  void orderList(String folderId) {
    if (folderFungibles[folderId] == null) return;

    if (selectedOrder == "name") {
      folderFungibles[folderId]!.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedOrder == "quantity") {
      folderFungibles[folderId]!.sort((a, b) => a.quantity.compareTo(b.quantity));
    }
    notifyListeners();
  }

  Future<void> addFolder(Folder folder) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('users').doc(userId)
      .collection('folders').add(folder.toJson());
            final newFolder = Folder(
        documentId: docRef.id,
        name: folder.name,
        fungibles: folder.fungibles,
      );
      _folders.add(newFolder);
      notifyListeners();
    } catch (e) {
      print('Error adding Folder: $e');
    }
  }

  Future<void> updateFolder(Folder folder, String folderName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId)
      .collection('folders').doc(folder.documentId).update({
        'name': folderName,
      });

      final index = _folders.indexWhere((f) => f.documentId == folder.documentId);
      if (index != -1) {
        _folders[index].name = folderName;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating Folder: $e');
    }
  }
    
  Future<void> deleteFolder(Folder folder) async {
    try {
      final folderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('folders')
          .doc(folder.documentId);

      final fungiblesSnapshot = await folderRef.collection('fungibles').get();
      for (final doc in fungiblesSnapshot.docs) {
        await doc.reference.delete();
      }

      await folderRef.delete();
      folderFungibles.remove(folder.documentId);
    } catch (e) {
      print('Error deleting Folder: $e');
    }
  }

  Stream<List<Folder>> folderStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('folders')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Folder.fromJson(doc.data(), doc.id)).toList());
  }

  Future<void> loadFolders() async {
    final foldersData = await FirebaseFirestore.instance.collection('users').doc(userId)
    .collection('folders').get();
    _folders.clear();
    folderFungibles.clear();

    for (var doc in foldersData.docs) {
      final folder = Folder.fromJson(doc.data(), doc.id);
        _folders.add(folder);
        folderFungibles[folder.documentId!] = [];
    }

    notifyListeners();
  }

  Future<void> loadAll() async {
    try {
      final foldersData = await FirebaseFirestore.instance.collection('users').doc(userId)
      .collection('folders').get();

      _folders.clear();
      folderFungibles.clear();

      for (var doc in foldersData.docs) {
        final folder = Folder.fromJson(doc.data(), doc.id);
        _folders.add(folder);

        // Load fungibles for each folder
        final fungiblesData = await FirebaseFirestore.instance.collection('users').doc(userId)
            .collection('folders').doc(folder.documentId)
            .collection('fungibles').get();

        folderFungibles[folder.documentId!] = fungiblesData.docs
            .map((fungibleDoc) => Fungible.fromJson(fungibleDoc.data(), fungibleDoc.id))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading folders and fungibles: $e');
    }
  }

Stream<List<Fungible>> fungiblesStream(String folderId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('folders')
      .doc(folderId)
      .collection('fungibles')
      .snapshots()
      .map((snapshot) {
    List<Fungible> fungibles = snapshot.docs
        .map((doc) => Fungible.fromJson(doc.data(), doc.id))
        .toList();

    if (selectedOrder == "name") {
      fungibles.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedOrder == "quantity") {
      fungibles.sort((a, b) => a.quantity.compareTo(b.quantity));
    }

    return fungibles;
  });
}
}
