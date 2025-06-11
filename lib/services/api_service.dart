import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://212.154.74.47:5000/api';

  Future<User> validatePerson(String tckn, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/school/validate-person'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tckn': tckn,
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Giriş başarısız: ${response.body}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  Future<void> sendNotification(String title, String message) async {
    // TODO: Implement actual API call to send notification
    await Future.delayed(const Duration(seconds: 2)); // Simulating API call
  }
} 