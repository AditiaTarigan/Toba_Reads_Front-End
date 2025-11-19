import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // ==========================
  // REGISTER
  // ==========================
  static Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"nama": nama, "email": email, "password": password}),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {"success": false, "message": "Terjadi kesalahan jaringan"};
    }
  }

  // ==========================
  // LOGIN
  // ==========================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("LOGIN ERROR: $e");
      return {"success": false, "message": "Gagal terhubung ke server"};
    }
  }
}
