import 'package:lab_manager/inventory/fungible.dart';

class Folder {
  String? documentId;
  String name;
  List<Fungible>? fungibles = [];

  Folder({
    this.documentId,
    required this.name,
    this.fungibles,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fungibles': fungibles?.map((fungible) => fungible.toJson()).toList(),
    };
  }

  factory Folder.fromJson(Map<String, dynamic> json, String id) {
    return Folder(
      documentId: id,
      name: json['name'],
      fungibles: (json['fungibles'] as List<dynamic>?)
          ?.map((fungible) => Fungible.fromJson(fungible, id))
          .toList(),
    );
  }
}
