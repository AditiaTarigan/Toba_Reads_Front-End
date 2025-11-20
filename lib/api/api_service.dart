import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:8000/api"; // Sesuaikan dengan URL backend Anda

  static const Map<String, String> _jsonHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  static Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
  ) async {
    final Uri registerUrl = Uri.parse("$_baseUrl/register");
    final String body = jsonEncode({
      "nama": nama,
      "email": email,
      "password": password,
    });

    try {
      final response = await http.post(
        registerUrl,
        headers: _jsonHeaders,
        body: body,
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      return _handleResponse(response);
    } on SocketException {
      print("REGISTER ERROR: No Internet connection");
      return {"success": false, "message": "Tidak ada koneksi internet."};
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final Uri loginUrl = Uri.parse("$_baseUrl/login");
    final String body = jsonEncode({
      "email": email,
      "password": password,
    });

    try {
      final response = await http.post(
        loginUrl,
        headers: _jsonHeaders,
        body: body,
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      return _handleResponse(response);
    } on SocketException {
      print("LOGIN ERROR: No Internet connection");
      return {"success": false, "message": "Tidak ada koneksi internet."};
    } catch (e) {
      print("LOGIN ERROR: $e");
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final decodedBody = jsonDecode(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return decodedBody;
        } else {
          return {
            "success": false,
            "message": decodedBody['message'] ?? 'Terjadi kesalahan server.',
            "statusCode": response.statusCode,
          };
        }
      } on FormatException {
        return {
          "success": false,
          "message": "Format respons tidak valid.",
          "statusCode": response.statusCode,
        };
      }
    } else {
      return {
        "success": false,
        "message": "Mendapat respons kosong dari server.",
        "statusCode": response.statusCode,
      };
    }
  }
}