class Calculation {
  String? documentId;
  final String calc;

  Calculation({
    this.documentId,
    required this.calc,
  });

  Map<String, dynamic> toJson() => {
    'calculation': calc,
  };

  static Calculation fromJson(Map<String, dynamic> json, String id) => Calculation(
    documentId: id,
    calc: json['calculation'],
  );
}