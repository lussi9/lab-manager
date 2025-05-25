import 'package:flutter/material.dart';
import 'package:lab_manager/calendar/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final userId = FirebaseAuth.instance.currentUser?.uid;

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];
  List<Event> get events => _events;
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;
  List<Event> get eventsOfSelectedDate => _events;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addEvent(Event event) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('events')
          .add(event.toJson());

      //Update the entry so it has the correct id
      final newEvent = Event(
          documentId: docRef.id,
          title: event.title,
          description: event.description,
          from: event.from,
          to: event.to,
          background: event.background,
          isAllDay: event.isAllDay,
          notification: event.notification,);

      _events.add(newEvent);
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error adding event: $e');
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('events')
          .doc(event.documentId)
          .delete();

      // Remove from the local list
      _events.remove(event);
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error deleting event: $e');
    }
  }

  Future<void> editEvent(Event oldEvent, Event newEvent) async {
    try {
      if (oldEvent.documentId == null) {
        throw Exception('Event ID is null');
      }

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('events')
          .doc(oldEvent.documentId)
          .update(newEvent.toJson());

      // Update in the local list
      final index = _events.indexWhere((event) => event.documentId == oldEvent.documentId);
      if (index != -1) {
        _events[index] = newEvent;
        notifyListeners();
      }
      notifyListeners();
    } catch (e) {
      print('Error editing event: $e');
    }
  }

  Future<void> loadEvents() async {
    final eventsData =
    await FirebaseFirestore.instance.collection('Users').doc(userId).collection('events').get();
    _events.clear();

    for (var doc in eventsData.docs) {
      _events.add(Event.fromJson(doc.data(), doc.id));
    }

    notifyListeners();
  }
}