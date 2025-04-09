import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  String? documentId;
  final DateTime date;
  final String description;

  Entry({
    this.documentId,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'description': description,
  };

  static Entry fromJson(Map<String, dynamic> json, String id) => Entry(
    documentId: id,
    date: (json['date'] as Timestamp).toDate(),
    description: json['description'],
  );
}