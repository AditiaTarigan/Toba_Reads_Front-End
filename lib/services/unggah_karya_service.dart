import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KaryaModel {
  final int id;
  final String judul;
  final String sinopsis;
  final String isi;
  final String? gambar;
  final String? fileLampiran;
  final int idUser;
  final Map<String, dynamic>? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KaryaModel({
    required this.id,
    required this.judul,
    required this.sinopsis,
    required this.isi,
    this.gambar,
    this.fileLampiran,
    required this.idUser,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  factory KaryaModel.fromJson(Map<String, dynamic> json) {
    print('🔄 [MODEL] Parsing JSON');
    print('🔄 [MODEL] All JSON keys: ${json.keys.toList()}');

    // Parse ID
    int parsedId;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] is String) {
      parsedId = int.tryParse(json['id']) ?? 0;
    } else if (json['id'] != null) {
      parsedId = int.tryParse(json['id'].toString()) ?? 0;
    } else {
      parsedId = json['id_karya'] is int
          ? json['id_karya']
          : int.tryParse(json['id_karya']?.toString() ?? '') ?? 0;
    }

    // Parse id_user
    int parsedIdUser;
    if (json['id_user'] is int) {
      parsedIdUser = json['id_user'];
    } else if (json['id_user'] is String) {
      parsedIdUser = int.tryParse(json['id_user']) ?? 0;
    } else if (json['id_user'] != null) {
      parsedIdUser = int.tryParse(json['id_user'].toString()) ?? 0;
    } else {
      parsedIdUser = 0;
    }

    // Ambil data user
    Map<String, dynamic>? userData;
    if (json['user'] != null && json['user'] is Map) {
      userData = Map<String, dynamic>.from(json['user']);
    }

    // FIX: Ambil isi dari berbagai kemungkinan field
    String parsedIsi =
        json['isi']?.toString() ??
        json['isi_cerita']?.toString() ??
        json['content']?.toString() ??
        '';

    print('🔄 [MODEL] Final parsed isi length: ${parsedIsi.length}');

    return KaryaModel(
      id: parsedId,
      judul: json['judul']?.toString() ?? '',
      sinopsis: json['sinopsis']?.toString() ?? '',
      isi: parsedIsi, // FIX: Gunakan yang sudah diparse
      gambar: json['gambar']?.toString(),
      fileLampiran: json['file_lampiran']?.toString(),
      idUser: parsedIdUser,
      user: userData,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']?.toString() ?? '')
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']?.toString() ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'sinopsis': sinopsis,
      'isi': isi,
      'gambar': gambar,
      'file_lampiran': fileLampiran,
      'id_user': idUser,
      'user': user,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    final userName = user?['nama'] ?? 'User $idUser';
    final synopsisPreview = sinopsis.length > 30
        ? '${sinopsis.substring(0, 30)}...'
        : sinopsis;
    final isiPreview = isi.length > 50 ? '${isi.substring(0, 50)}...' : isi;
    return 'Karya{id: $id, judul: "$judul", sinopsis: "$synopsisPreview", isi: "$isiPreview", user: "$userName"}';
  }
}

class CeritaService {
  static final String baseUrl = "http://10.167.29.12:8000/api";

  // Get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('🔐 [TOKEN] ${token != null ? "Token ada" : "Token TIDAK ADA!"}');
    return token;
  }

  // Get user ID
  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt('id_user');
    print('👤 [USER ID] $idUser');
    return idUser;
  }

  // ========== CREATE ==========
  static Future<Map<String, dynamic>> uploadKarya(
    String judul,
    String sinopsis,
    String isi,
    String? imagePath,
  ) async {
    try {
      print('🚀 [UPLOAD START] ======================================');
      print('📝 Judul: $judul');
      print('📝 Sinopsis: $sinopsis');
      print('📝 Isi length: ${isi.length} characters');
      print('🖼️ Image path: $imagePath');

      // 1. Get authentication data
      final token = await _getToken();
      final idUser = await _getUserId();

      if (token == null) {
        throw Exception('❌ Token tidak ditemukan. Silakan login ulang.');
      }
      if (idUser == null) {
        throw Exception('❌ User ID tidak ditemukan.');
      }

      print('🔑 Token length: ${token.length}');
      print('👤 User ID: $idUser');

      // 2. Prepare URL
      final url = Uri.parse('$baseUrl/karya');
      print('🌐 URL: $url');

      // 3. Create multipart request
      var request = http.MultipartRequest('POST', url);

      // 4. Add headers
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      // 5. Add fields
      request.fields['judul'] = judul;
      request.fields['sinopsis'] = sinopsis;
      request.fields['isi'] = isi;
      request.fields['id_user'] = idUser.toString();
      print('📤 Fields: judul, sinopsis, isi, id_user=$idUser');

      // 6. Add file if exists
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          final file = File(imagePath);
          final exists = await file.exists();
          if (exists) {
            final fileSize = await file.length();
            final fileSizeKB = (fileSize / 1024).toStringAsFixed(2);
            print('📁 File size: $fileSizeKB KB');

            request.files.add(
              await http.MultipartFile.fromPath('file_lampiran', imagePath),
            );
            print('✅ File added: file_lampiran');
          } else {
            print('⚠️ File not found');
          }
        } catch (e) {
          print('❌ File error: $e');
        }
      } else {
        print('ℹ️ No file to upload');
      }

      // 7. Send request
      print('📤 Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');

      // Log response body (limited to 500 chars)
      String responseBody = response.body;
      if (responseBody.length > 500) {
        responseBody = responseBody.substring(0, 500) + '...';
      }
      print('📥 Response body: $responseBody');

      // 8. Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('✅ Upload success!');
          return {
            'success': true,
            'message': data['message'] ?? 'Karya berhasil diupload',
            'data': data['data'],
          };
        } catch (e) {
          print('⚠️ JSON parse error: $e');
          return {
            'success': true,
            'message': 'Karya berhasil diupload',
            'data': null,
          };
        }
      } else {
        String errorMessage = 'Gagal upload (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {}

        print('❌ Upload failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ [UPLOAD ERROR] $e');
      rethrow;
    }
  }

  // ========== READ ==========
  static Future<List<KaryaModel>> getAllKarya() async {
    try {
      print('📡 [API] Fetching karya...');
      final url = Uri.parse('$baseUrl/karya');
      final response = await http.get(url);

      print('📊 [API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // DEBUG: Lihat struktur respons
        print('📦 [API] Response type: ${data.runtimeType}');
        if (data is List && data.isNotEmpty) {
          final firstItem = data[0] as Map;
          print('📦 [API] First item keys: ${firstItem.keys.toList()}');

          // Debug field isi
          print('📦 [API] Has "isi": ${firstItem.containsKey('isi')}');
          print(
            '📦 [API] Has "isi_cerita": ${firstItem.containsKey('isi_cerita')}',
          );

          if (firstItem.containsKey('isi')) {
            final isiValue = firstItem['isi'];
            print('📦 [API] Isi value type: ${isiValue.runtimeType}');
            if (isiValue != null && isiValue is String) {
              final preview = isiValue.length > 50
                  ? '${isiValue.substring(0, 50)}...'
                  : isiValue;
              print('📦 [API] Isi preview: $preview');
            }
          }
        }

        print('📦 [API] Got ${data is List ? data.length : 'some'} karya');

        List<dynamic> karyaList = [];
        if (data is List) {
          karyaList = data;
        } else if (data is Map && data.containsKey('data')) {
          karyaList = data['data'] ?? [];
        } else if (data is Map) {
          karyaList = [data];
        }

        final result = <KaryaModel>[];
        for (var item in karyaList) {
          try {
            if (item is Map) {
              final karya = KaryaModel.fromJson(
                Map<String, dynamic>.from(item),
              );
              result.add(karya);
            }
          } catch (e) {
            print('❌ Parse error: $e');
          }
        }

        print('✅ Parsed ${result.length} karya');
        return result;
      } else {
        print('❌ API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Network error: $e');
      return [];
    }
  }

  static Future<List<KaryaModel>> getKaryaUser() async {
    try {
      final idUser = await _getUserId();
      if (idUser == null) return [];

      final allKarya = await getAllKarya();
      return allKarya.where((karya) => karya.idUser == idUser).toList();
    } catch (e) {
      print('❌ User karya error: $e');
      return [];
    }
  }

  // ========== GET BOOKS ==========
  static Future<List<dynamic>> getBooks() async {
    try {
      final allKarya = await getAllKarya();
      final List<Map<String, dynamic>> books = [];

      for (var karya in allKarya) {
        try {
          String authorName = 'Tidak diketahui';
          if (karya.user != null) {
            authorName = karya.user!['nama']?.toString() ?? 'Tidak diketahui';
          }

          String imageUrl = _getImageUrl(karya);

          // FIX: Pastikan semua field yang diperlukan ada
          final book = {
            'id': karya.id,
            'id_karya': karya.id, // backup field
            'judul': karya.judul,
            'sinopsis': karya.sinopsis,
            'isi': karya.isi, // Field utama
            'isi_cerita': karya.isi, // Backup field
            'content': karya.isi, // Backup field
            'gambar': karya.gambar,
            'file_lampiran': karya.fileLampiran,
            'id_user': karya.idUser,
            'author_name': authorName,
            'user': {'id': karya.idUser, 'nama': authorName},
            'gambar_url': imageUrl,
            'image_url': imageUrl, // Backup field untuk BookDetailPage
            'created_at': karya.createdAt?.toIso8601String(),
          };

          // DEBUG: Cek data
          print('📦 [BOOK] ID: ${karya.id}, Judul: ${karya.judul}');
          print('📦 [BOOK] Isi length: ${karya.isi.length} chars');
          print(
            '📦 [BOOK] Has "isi": ${book['isi'] != null && (book['isi'] as String).isNotEmpty}',
          );

          books.add(book);
        } catch (e) {
          print('❌ Book processing error: $e');
        }
      }

      print('📚 Total books processed: ${books.length}');
      return books;
    } catch (e) {
      print('❌ Books error: $e');
      return [];
    }
  }

  static String _getImageUrl(KaryaModel karya) {
    // Priority 1: file_lampiran dari karya
    if (karya.fileLampiran != null && karya.fileLampiran!.isNotEmpty) {
      if (karya.fileLampiran!.startsWith('http')) {
        return karya.fileLampiran!;
      } else {
        return 'http://10.167.29.12:8000/storage/${karya.fileLampiran!}';
      }
    }

    // Priority 2: gambar dari karya
    if (karya.gambar != null && karya.gambar!.isNotEmpty) {
      if (karya.gambar!.startsWith('http')) {
        return karya.gambar!;
      } else {
        return 'http://10.167.29.12:8000/storage/${karya.gambar!}';
      }
    }

    return 'https://via.placeholder.com/120x150?text=No+Image';
  }

  // ========== UPDATE ==========
  static Future<bool> updateKarya(
    int id,
    String judul,
    String sinopsis,
    String isi,
    String? newImagePath,
    String? existingImageUrl,
  ) async {
    try {
      final token = await _getToken();
      final idUser = await _getUserId();

      if (idUser == null) throw Exception('User ID tidak ditemukan');

      final url = Uri.parse('$baseUrl/karya/$id');
      var request = http.MultipartRequest('POST', url);

      request.fields['_method'] = 'PUT';
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['judul'] = judul;
      request.fields['sinopsis'] = sinopsis;
      request.fields['isi'] = isi;
      request.fields['id_user'] = idUser.toString();

      if (newImagePath != null && newImagePath.isNotEmpty) {
        final file = File(newImagePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('file_lampiran', newImagePath),
          );
        }
      } else if (existingImageUrl == null || existingImageUrl.isEmpty) {
        request.fields['remove_image'] = 'true';
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Update error: $e');
      return false;
    }
  }

  // ========== DELETE ==========
  static Future<bool> deleteKarya(int id) async {
    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/karya/$id');

      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // ========== COMPATIBILITY METHODS ==========
  static Future<Map<String, dynamic>> uploadCerita(
    String judul,
    String sinopsis,
    String isi,
    String? imagePath,
  ) {
    return uploadKarya(judul, sinopsis, isi, imagePath);
  }

  // ========== NEW METHOD: Get Single Book ==========
  static Future<Map<String, dynamic>?> getBookDetail(int id) async {
    try {
      final allBooks = await getBooks();
      final book = allBooks.firstWhere(
        (b) => (b['id'] == id) || (b['id_karya'] == id),
        orElse: () => null,
      );

      if (book != null) {
        print('📖 [BOOK DETAIL] Found book ID: $id');
        return book;
      }

      print('❌ [BOOK DETAIL] Book not found ID: $id');
      return null;
    } catch (e) {
      print('❌ [BOOK DETAIL] Error: $e');
      return null;
    }
  }
}
