import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadStoryPage extends StatefulWidget {
  final Map<String, dynamic> bookId;

  const ReadStoryPage({super.key, required this.bookId});

  @override
  State<ReadStoryPage> createState() => _ReadStoryPageState();
}

class _ReadStoryPageState extends State<ReadStoryPage> {
  late Map<String, dynamic> bookData;
  int _currentPage = 1;
  final int _maxCharsPerPage = 1500;
  late List<String> _pages = [];
  bool _isBookmarked = false;
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    bookData = widget.bookId;
    _paginateContent();
    _loadBookmarkStatus();
  }

  // --- TAMBAHKAN FUNGSI HELPER INI UNTUK MENDAPATKAN ID YANG BENAR ---
  String _getBookId() {
    // Cek 'id_karya', jika null cek 'id', jika null pakai hashcode judul
    if (bookData['id_karya'] != null) return bookData['id_karya'].toString();
    if (bookData['id'] != null) return bookData['id'].toString();
    // Fallback jika tidak ada ID sama sekali (mencegah overwrite kosong)
    return bookData['judul'].toString().hashCode.toString();
  }
  // -------------------------------------------------------------------

  void _paginateContent() {
    String content = "";
    final fields = ['isi', 'isi_cerita', 'content', 'cerita', 'body'];

    for (var f in fields) {
      if (bookData.containsKey(f) &&
          bookData[f] != null &&
          bookData[f].toString().trim().isNotEmpty) {
        content = bookData[f].toString();
        break;
      }
    }

    if (content.isEmpty) content = "Konten tidak tersedia.";

    _pages = [];
    if (content.length <= _maxCharsPerPage) {
      _pages.add(content);
    } else {
      for (int i = 0; i < content.length; i += _maxCharsPerPage) {
        int end = i + _maxCharsPerPage;
        if (end > content.length) end = content.length;
        _pages.add(content.substring(i, end));
      }
    }
  }

  Future<void> _loadBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final id = _getBookId(); // Pakai fungsi helper
    setState(() {
      _isBookmarked = prefs.getBool("bookmark_$id") ?? false;
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final id = _getBookId(); // Pakai fungsi helper

    // Debugging print untuk melihat ID apa yang dipakai
    print("🔖 Toggle Bookmark ID: $id");

    final newStatus = !_isBookmarked;

    if (newStatus) {
      await prefs.setBool('bookmark_$id', true);

      // Simpan data lengkap. Kita pastikan ID juga tersimpan di dalam JSON
      // agar nanti FavoritePage membacanya dengan benar
      final Map<String, dynamic> dataToSave = Map.from(bookData);
      dataToSave['id_karya'] = id; // Paksa simpan ID yang konsisten

      await prefs.setString('data_buku_$id', jsonEncode(dataToSave));
    } else {
      await prefs.remove('bookmark_$id');
      await prefs.remove('data_buku_$id');
    }

    setState(() => _isBookmarked = newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus ? "Disimpan ke Favorit" : "Dihapus dari Favorit",
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = bookData['judul'] ?? "Tanpa Judul";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2A486B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                _pages.isNotEmpty ? _pages[_currentPage - 1] : "Memuat...",
                style: TextStyle(fontSize: _fontSize, height: 1.7),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2A486B)),
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text(
                "${_currentPage}/${_pages.length}",
                style: const TextStyle(
                  color: Color(0xFF2A486B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF2A486B)),
                onPressed: _currentPage < _pages.length
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
