import 'package:flutter/material.dart';
import 'read_story_page.dart';

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cerita'),
        backgroundColor: const Color(0xFF2A486B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Cover
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: _getCoverImage(book),
              ),
              child: _getPlaceholderIcon(book),
            ),

            // Info Buku
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['judul'] ?? 'Tanpa Judul',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A486B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _getAuthorName(book),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Sinopsis
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A486B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      book['sinopsis']?.isNotEmpty == true
                          ? book['sinopsis']!
                          : 'Tidak ada sinopsis tersedia.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Mulai Membaca - FIX DISINI
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print('🎯 [BUTTON] Data keys: ${book.keys.toList()}');

                        // FIX: Cari field yang benar-benar ada
                        final content = _findRealContent(book);
                        print(
                          '📝 [BUTTON] Found content in field: ${content['field']}',
                        );
                        print(
                          '📝 [BUTTON] Content length: ${content['text']?.length ?? 0}',
                        );

                        if (content['text']?.isNotEmpty == true) {
                          // Buat copy book dengan field yang benar
                          final fixedBook = Map<String, dynamic>.from(book);
                          fixedBook['isi'] =
                              content['text']; // Pastikan ada field 'isi'

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadStoryPage(bookId: book),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Karya "${book['judul']}" tidak memiliki konten.',
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A486B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Mulai Membaca',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === FIX: Fungsi untuk mencari konten yang sebenarnya ===
  Map<String, dynamic> _findRealContent(Map<String, dynamic> book) {
    print('\n🔍 [FIND REAL CONTENT]');

    // Urutan prioritas field yang mungkin berisi konten
    final fieldPriority = [
      'isi', // Field utama seharusnya
      'isi_cerita', // Field yang muncul di data Anda
      'content', // Alternatif umum
      'cerita', // Alternatif lain
      'body', // Alternatif
      'text', // Alternatif
      'deskripsi', // Alternatif
    ];

    for (var field in fieldPriority) {
      if (book.containsKey(field)) {
        final content = book[field]?.toString() ?? '';
        print('   ✅ Found field "$field": ${content.length} chars');
        if (content.isNotEmpty) {
          return {'field': field, 'text': content};
        }
      }
    }

    print('   ❌ No content field found');
    return {'field': null, 'text': ''};
  }

  // Helper Methods
  DecorationImage? _getCoverImage(Map<String, dynamic> book) {
    // Gunakan image_url dari data yang ada
    final imageUrl = book['image_url'] ?? book['gambar_url'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover);
    }
    return null;
  }

  Widget? _getPlaceholderIcon(Map<String, dynamic> book) {
    final imageUrl = book['image_url'] ?? book['gambar_url'];
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.book, size: 80, color: Colors.grey),
      );
    }
    return null;
  }

  String _getAuthorName(Map<String, dynamic> book) {
    return book['author_name'] ?? 'Tidak diketahui';
  }
}
