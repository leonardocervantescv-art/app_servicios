
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<Map<String, dynamic>> obtenerCategorias() async {
    final uri = Uri.parse('$baseUrl/categorias');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    final dynamic data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (data is Map<String, dynamic>) {
        return data;
      }

      throw Exception('Formato de respuesta inesperado');
    }

    throw Exception(
      'Error HTTP ${response.statusCode}: ${response.body}',
    );
  }
}
