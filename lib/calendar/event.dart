import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  String? documentId;
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;
  String? recurrenceRule;

  Event({
    this.documentId,
    required this.title,
    this.description = '',
    required this.from,
    required this.to,
    this.background = const Color.fromRGBO(67, 160, 71, 1),
    this.isAllDay = false,
    this.recurrenceRule = '',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'from': from,
    'to': to,
    'background': background.toARGB32(),
    'isAllDay': isAllDay,
    'recurrenceRule': recurrenceRule,
  };

  static Event fromJson(Map<String, dynamic> json, String id) => Event(
    documentId: id,
    title: json['title'],
    description: json['description'] ,
    from: (json['from'] as Timestamp).toDate(),
    to: (json['to'] as Timestamp).toDate(),
    background: Color(json['background']), // Handle null case
    isAllDay: json['isAllDay'] ?? false, // Handle null case
    recurrenceRule: json['recurrenceRule'], // Handle null case
  );
}