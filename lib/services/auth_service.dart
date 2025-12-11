import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = "http://10.167.29.12:8000/api";

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print('🔐 Login Response Status: ${response.statusCode}');
      print('🔐 Login Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        final user = data["data"]["user"];
        final token = data["data"]["token"] ?? data["token"];

        // SIMPAN SEMUA DATA USER KE SHARED PREFERENCES
        await prefs.setString("token", token ?? "");
        await prefs.setString(
          "userEmail",
          user["email"] ?? email,
        ); // SIMPAN EMAIL
        await prefs.setString("userName", user["nama"] ?? "");
        await prefs.setInt("id_user", user["id_user"] ?? 0);
        await prefs.setString("userPhone", user["no_hp"] ?? "");
        await prefs.setString("userBio", user["bio"] ?? "");
        await prefs.setString("userGender", user["jenis_kelamin"] ?? "");
        await prefs.setString("userBirthDate", user["tanggal_lahir"] ?? "");

        print('✅ Login successful, saved user data:');
        print('   Email: ${user["email"]}');
        print('   Name: ${user["nama"]}');
        print('   Token: $token');

        return {"success": true, "user": user, "token": token};
      } else {
        return {"success": false, "message": data['message'] ?? "Login gagal"};
      }
    } catch (e) {
      print('❌ Login Error: $e');
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil SEMUA data dari SharedPreferences
    final nama = prefs.getString("userName") ?? prefs.getString("nama");
    final email = prefs.getString("userEmail");
    final idUser = prefs.getInt("id_user");
    final token = prefs.getString("token");
    final phone = prefs.getString("userPhone");
    final bio = prefs.getString("userBio");
    final gender = prefs.getString("userGender");
    final birthDate = prefs.getString("userBirthDate");

    if (nama == null || email == null) return null;

    return {
      "nama": nama,
      "email": email,
      "id_user": idUser,
      "token": token,
      "no_hp": phone,
      "bio": bio,
      "jenis_kelamin": gender,
      "tanggal_lahir": birthDate,
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<dynamic>> getBooks() async {
    final response = await http.get(
      Uri.parse("$baseUrl/buku"),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Gagal mengambil buku");
    }
  }
}
