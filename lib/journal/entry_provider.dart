import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lab_manager/journal/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EntryProvider extends ChangeNotifier {
  final List<Entry> _entries = [];

  List<Entry> get entries => _entries;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addEntry(Entry entry) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('entries')
          .add(entry.toJson());

      // Update the entry so it has the correct ID
      final newEntry = Entry(
        documentId: docRef.id,
        title: entry.title,
        date: entry.date,
        description: entry.description,
      );

      _entries.add(newEntry);
      _entries.sort((a, b) => b.date.compareTo(a.date)); // Sort after adding
      notifyListeners();
    } catch (e) {
      print('Error adding entry: $e');
    }
  }

  Future<void> deleteEntry(Entry entry) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('entries')
          .doc(entry.documentId)
          .delete();
      _entries.remove(entry);
      notifyListeners();
    } catch (e) {
      print('Error deleting entry: $e');
    }
  }

  Future<void> editEntry(Entry oldEntry, Entry newEntry) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('entries')
          .doc(oldEntry.documentId)
          .update(newEntry.toJson());

      final index = _entries.indexOf(oldEntry);
      _entries[index] = newEntry;
      _entries[index].documentId = oldEntry.documentId; // Keep the same document ID
      _entries.sort((a, b) => b.date.compareTo(a.date)); // Sort again after edit
      notifyListeners();

    } catch (e) {
      print('Error editing entry: $e');
    }
  }

  Future<void> loadEntries() async {
    try {
      final entriesData = await FirebaseFirestore.instance
          .collection('users').doc(userId)
          .collection('entries').get();

      _entries.clear();

      for (var doc in entriesData.docs) {
        _entries.add(Entry.fromJson(doc.data(), doc.id));
      }

      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print('Error loading entries: $e');
    }
  }
}