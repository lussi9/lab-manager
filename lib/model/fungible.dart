import 'dart:convert';
import 'package:http/http.dart' as http;

class Fungible {
  final String name;
  final String description;
  final int quantity;

  Fungible({
    required this.name,
    required this.description,
    required this.quantity,
  });

  factory Fungible.fromJson(Map<String, dynamic> json) {
    return Fungible(
      name: json['Fungible'],
      description: json['Descripcion'],
      quantity: json['Cantidad'],
    );
  }

  static Future<List<Fungible>> fetchFungibles() async {
    final response = await http.get(Uri.parse(
        'https://script.google.com/macros/s/AKfycbzpqi1d3M_PMZ8xIVLDeZCMjPoMlnPrUkUuOvy5ssMbnESq_7zf3q-jdCYCUPZjNLHqPA/exec'));
    if(response.statusCode == 200){
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Fungible.fromJson(data)).toList();
    } else{
      throw Exception('Failed to fetch fungibles');
    }
  }
}
