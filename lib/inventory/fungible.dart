class Fungible {
  String? documentId;
  final String name;
  final String description;
  final int quantity;

  Fungible({
    this.documentId,
    required this.name,
    required this.description,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
    };
  }

  factory Fungible.fromJson(Map<String, dynamic> json, String id) {
    return Fungible(
      documentId: id,
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
    );
  }
}
