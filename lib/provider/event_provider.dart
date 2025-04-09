import 'package:flutter/material.dart';
import 'package:lab_manager/model/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => _events;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Event> get eventsOfSelectedDate => _events;

  Future<void> addEvent(Event event) async {
    // Save the event to Firestore
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('events')
          .add(event.toJson());

      //Update the entry so it has the correct id
      final newEvent = Event(
          documentId: docRef.id,
          title: event.title,
          description: event.description,
          from: event.from,
          to: event.to,
          backgroundColor: event.backgroundColor);

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
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(oldEvent.documentId)
          .update(newEvent.toJson());

      // Update in the local list
      final index = _events.indexOf(oldEvent);
      _events[index] = newEvent;
      notifyListeners();
    } catch (e) {
      // Handle any error
      print('Error editing event: $e');
    }
  }

  Future<void> loadEvents() async {
    final eventsData =
    await FirebaseFirestore.instance.collection('events').get();

    _events.clear();

    for (var doc in eventsData.docs) {
      _events.add(Event.fromJson(doc.data(), doc.id));
    }

    notifyListeners();
  }
}