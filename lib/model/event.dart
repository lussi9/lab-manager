import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  String? documentId;

  Event({
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    this.backgroundColor = Colors.lightGreen,
    this.documentId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'from': from,
    'to': to,
    'backgroundColor': backgroundColor.value,
  };

  static Event fromJson(Map<String, dynamic> json, String id) => Event(
    documentId: id,
    title: json['title'],
    description: json['description'],
    from: (json['from'] as Timestamp).toDate(),
    to: (json['to'] as Timestamp).toDate(),
    backgroundColor: Color(json['backgroundColor']),
  );
}