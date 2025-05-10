import 'package:lab_manager/model/fungible.dart';

class Folder {
  String? documentId;
  final String name;
  List<Fungible>? fungibles = [];

  Folder({
    this.documentId,
    required this.name,
    this.fungibles,
  });

  Map<String, dynamic> toJson() {
    return {
      'Folder': name,
      'Fungibles': fungibles?.map((fungible) => fungible.toJson()).toList(),
    };
  }

  factory Folder.fromJson(Map<String, dynamic> json, String id) {
    return Folder(
      documentId: id,
      name: json['Folder'],
      fungibles: (json['Fungibles'] as List<dynamic>?)
          ?.map((fungible) => Fungible.fromJson(fungible, id))
          .toList(),
    );
  }
}
