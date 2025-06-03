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
    List<Event> get eventsOfSelectedDate => _events;

  void setDate(DateTime date) => _selectedDate = date;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Event>> get eventStream {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('events')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Event.fromJson(doc.data(), doc.id)).toList());
  }

  Future<void> addEvent(Event event) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('users').doc(userId).collection('events').add(event.toJson());
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(event.documentId)
          .delete();

      _events.removeWhere((e) => e.documentId == event.documentId);
      
      notifyListeners();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  Future<void> editEvent(Event oldEvent, Event newEvent) async {
    try {
      if (oldEvent.documentId == null) {
        throw Exception('Event ID is null');
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(oldEvent.documentId)
          .update(newEvent.toJson());
      
      final index = _events.indexWhere((event) => event.documentId == oldEvent.documentId);
      if (index != -1) {
        _events[index] = newEvent;
      }
      notifyListeners();
    } catch (e) {
      print('Error editing event: $e');
    }
  }
}