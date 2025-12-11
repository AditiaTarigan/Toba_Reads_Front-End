import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = "http://10.167.29.12:8000/api";

  static const Map<String, String> _jsonHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  // ============ USER OPERATIONS (EMAIL ONLY) ============

  // GET USER BY EMAIL
  //      ET USER BY EMAIL - Perbaiki parsing responsenya
  static Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      print('📨 API Request: GET $_baseUrl/user/email/$email');

      final response = await http.get(
        Uri.parse('$_baseUrl/user/email/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📥 API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API Response Data Structure:');
        print('   data type: ${data.runtimeType}');
        print('   data keys: ${data is Map ? data.keys : 'Not a Map'}');

        // Handle struktur yang benar
        if (data is Map &&
            data.containsKey('success') &&
            data['success'] == true) {
          // Cari user data di berbagai kemungkinan lokasi
          Map<String, dynamic>? userData;

          if (data.containsKey('data') && data['data'] is Map) {
            final innerData = data['data'] as Map;

            if (innerData.containsKey('user')) {
              // Struktur: {"success":true,"data":{"user":{...}}}
              userData = Map<String, dynamic>.from(innerData['user']);
              print('✅ Found user in data[data][user]');
            } else if (innerData.containsKey('data') &&
                innerData['data'] is Map &&
                innerData['data'].containsKey('user')) {
              // Struktur nested lebih dalam
              userData = Map<String, dynamic>.from(innerData['data']['user']);
              print('✅ Found user in data[data][data][user]');
            } else {
              // Mungkin user langsung di data['data']
              userData = Map<String, dynamic>.from(innerData);
              print('✅ Using data[data] as user');
            }
          } else if (data.containsKey('user')) {
            // Struktur: {"success":true,"user":{...}}
            userData = Map<String, dynamic>.from(data['user']);
            print('✅ Found user in data[user]');
          }

          return {
            'success': true,
            'data':
                userData ??
                {}, // ← KIRIM USER DATA LANGSUNG, bukan response penuh
            'message': 'User found',
            'rawResponse': data, // Simpan response lengkap untuk debug
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid response format',
            'data': null,
          };
        }
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'User not found', 'data': null};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch user data: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('❌ Error in getUserByEmail: $e');
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  // UPDATE USER BY EMAIL
  static Future<Map<String, dynamic>> updateUserByEmail(
    String email,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Ambil token jika ada
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      Map<String, String> headers = Map.from(_jsonHeaders);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/users/email/$email'),
        headers: headers,
        body: json.encode(userData),
      );

      print('UPDATE User by Email - URL: $_baseUrl/users/email/$email');
      print('Update data: $userData');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update user',
        };
      }
    } catch (e) {
      print('Error in updateUserByEmail: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // DELETE USER BY EMAIL
  static Future<Map<String, dynamic>> deleteUserByEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      Map<String, String> headers = Map.from(_jsonHeaders);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/users/email/$email'),
        headers: headers,
      );

      print('DELETE User by Email - URL: $_baseUrl/users/email/$email');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to delete user'};
      }
    } catch (e) {
      print('Error in deleteUserByEmail: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ============ AUTH OPERATIONS ============

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
    String? noHp,
    String? bio,
    String? jenisKelamin,
    String? tanggalLahir,
  ) async {
    final Uri registerUrl = Uri.parse("$_baseUrl/register");
    final String body = jsonEncode({
      "nama": nama,
      "email": email,
      "password": password,
      "no_hp": noHp,
      'bio': bio,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
    });

    try {
      final response = await http.post(
        registerUrl,
        headers: _jsonHeaders,
        body: body,
      );

      return _handleResponse(response);
    } on SocketException {
      return {"success": false, "message": "Tidak ada koneksi internet."};
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: _jsonHeaders,
      body: jsonEncode({"email": email, "password": password}),
    );

    return _handleResponse(response);
  }

  // ============ HELPER ============

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isNotEmpty) {
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }
      return {
        "success": false,
        "message": body['message'] ?? 'Terjadi kesalahan server.',
      };
    } else {
      return {"success": false, "message": "Respons kosong dari server."};
    }
  }
}
