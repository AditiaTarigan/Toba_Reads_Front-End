import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CeritaService {
  static final String baseUrl = "http://10.0.2.2:8000/api";

  // Upload karya baru - FIXED VERSION
  static Future<bool> uploadCerita(
    String judul,
    String isi,
    String? imagePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print('Token: $token');
      print('Judul: $judul');

      final url = Uri.parse('$baseUrl/karya');

      var request = http.MultipartRequest('POST', url);

      // HEADERS
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // FORM FIELDS - PERBAIKAN: gunakan 'isi' bukan 'isi_cerita'
      request.fields['judul'] = judul;
      request.fields['isi'] = isi; // ✅ INI YANG BENAR

      // Tambahkan field user_id jika diperlukan
      final idUser = prefs.getInt('id_user');
      if (idUser != null) {
        request.fields['id_user'] = idUser.toString();
      }

      // FILE IMAGE
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          request.files.add(
            await http.MultipartFile.fromPath('file_lampiran', imagePath),
          );
          print('Image added: $imagePath');
        } catch (e) {
          print('Error adding image: $e');
        }
      } else {
        print('No image provided');
      }

      // DEBUG: Print request details
      print('Request URL: $url');
      print('Request Headers: ${request.headers}');
      print('Request Fields: ${request.fields}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('=== UPLOAD RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body: $responseBody');
      print('=======================');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Gagal upload: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      print('Error in uploadCerita: $e');
      throw Exception('Error: $e');
    }
  }

  // ✅ TAMBAHKAN METHOD GETBOOKS INI
  static Future<List<dynamic>> getBooks() async {
    try {
      // GUNAKAN ENDPOINT /karya UNTUK MENDAPATKAN DATA KARYA USER
      return await getAllKarya();
    } catch (e) {
      print('Error in getBooks: $e');
      return [];
    }
  }

  // METHOD: Ambil semua karya (tanpa filter status)
  static Future<List<dynamic>> getAllKarya() async {
    try {
      final url = Uri.parse('$baseUrl/karya');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Get All Karya Status: ${response.statusCode}');
      print('Get All Karya Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // FORMAT RESPONSE DARI LARAVEL: array langsung atau {data: array}
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'] ?? [];
        } else {
          return [];
        }
      } else {
        print('Error response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting all karya: $e');
      return [];
    }
  }

  // ✅ OPTIONAL: Method untuk get karya user
  static Future<List<dynamic>> getKarya() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('$baseUrl/karya');

      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Get Karya Status: ${response.statusCode}');
      print('Get Karya Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load karya: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getKarya: $e');
      throw Exception('Error: $e');
    }
  }
}
