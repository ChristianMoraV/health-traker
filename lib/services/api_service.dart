import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base configurable - se puede cambiar sin recompilar
  static String baseUrl = 'https://18f3-2800-bf0-be42-70ae-38ea-c4e1-8829-5a0a.ngrok-free.app';
  
  // Método para actualizar la URL base dinámicamente
  static void updateBaseUrl(String newUrl) {
    baseUrl = newUrl.endsWith('/') ? newUrl.substring(0, newUrl.length - 1) : newUrl;
  }
  
  // Headers base para todas las peticiones
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Header especial para ngrok-free.app
    if (baseUrl.contains('ngrok-free.app')) {
      headers['ngrok-skip-browser-warning'] = 'true';
    }
    
    return headers;
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(data),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // DELETE request
  static Future<void> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(url, headers: _headers);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
