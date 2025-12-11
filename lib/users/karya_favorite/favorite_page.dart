import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tobareads/users/karya/read_story_page.dart'; // Pastikan path import ini benar

class FavoritePage extends StatefulWidget {
  // Tidak perlu parameter lagi
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favoriteBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteBooks();
  }

  /// Mengambil semua data buku yang tersimpan dengan key 'data_buku_'
  Future<void> _loadFavoriteBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    List<Map<String, dynamic>> hasil = [];

    for (var key in keys) {
      if (key.startsWith("data_buku_")) {
        final String? jsonString = prefs.getString(key);
        if (jsonString != null) {
          try {
            // Decode string JSON kembali menjadi Map
            final Map<String, dynamic> data = jsonDecode(jsonString);
            hasil.add(data);
          } catch (e) {
            print("Error parsing book data: $e");
          }
        }
      }
    }

    setState(() {
      favoriteBooks = hasil;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A486B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A486B),
        elevation: 0,
        title: const Text(
          "Cerita Favorit",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteBooks.isEmpty
          ? const Center(
              child: Text(
                "Belum ada cerita favorit",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteBooks.length,
              itemBuilder: (context, index) {
                final buku = favoriteBooks[index];
                return _favoriteCard(buku);
              },
            ),
    );
  }

  Widget _favoriteCard(Map<String, dynamic> buku) {
    final String judul = buku['judul'] ?? "Tanpa Judul";
    final String idKarya = buku['id_karya']?.toString() ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: $idKarya",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Kirim data lengkap ke ReadStoryPage
                  builder: (context) => ReadStoryPage(bookId: buku),
                ),
              ).then((_) {
                // Refresh list saat kembali (jika user menghapus bookmark)
                _loadFavoriteBooks();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Lanjut",
                style: TextStyle(
                  color: Color(0xFF2A486B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
