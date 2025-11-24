import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = "http://10.0.2.2:8000/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        body: {"email": email, "password": password},
      );

      final data = jsonDecode(response.body);
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        final user = data["data"]["user"];
        final token = data["data"]["token"];

        await prefs.setString("token", token ?? "");
        await prefs.setString("nama", user["nama"] ?? "");
        await prefs.setInt("id_user", user["id_user"] ?? 0);

        return {"success": true, "user": user, "token": token};
      } else {
        return {"success": false, "message": data['message'] ?? "Login gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString("nama");
    final idUser = prefs.getInt("id_user");
    final token = prefs.getString("token");

    if (nama == null || token == null) return null;

    return {"nama": nama, "id_user": idUser, "token": token};
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<dynamic>> getBooks() async {
    final response = await http.get(Uri.parse("$baseUrl/buku"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Gagal mengambil buku");
    }
  }
}
