import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/unggah_karya_service.dart';
import '../api/api_service.dart';
// Tambahkan import untuk halaman baru
import 'karya/book_detail_page.dart'; // Anda perlu membuat file ini
import 'karya/read_story_page.dart'; // Anda perlu membuat file ini

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "Tobareads User";
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load user data
      final userData = await AuthService.getUserData();
      if (userData != null) {
        setState(() {
          username = userData['nama'] ?? 'Pengguna';
        });
      }

      // Load books from backend
      setState(() => isLoading = true);

      final rawBooks = await CeritaService.getBooks();

      print('📚 Raw books data structure:');
      if (rawBooks.isNotEmpty) {
        print('First item keys: ${rawBooks[0].keys}');
        print('First item user data: ${rawBooks[0]['user']}');
      }

      // Process books
      final List<Map<String, dynamic>> mappedBooks = [];

      for (var b in rawBooks) {
        if (b != null && b is Map) {
          // DEBUG: Lihat struktur data
          print('📖 Processing book: ${b['judul']}');
          print('   User data: ${b['user']}');

          String authorName = 'Tidak diketahui';
          String? userEmail;

          // Akses data dengan struktur yang benar
          if (b['user'] != null && b['user'] is Map) {
            // Cara 1: Ambil langsung dari user object
            authorName = b['user']['nama']?.toString() ?? 'Tidak diketahui';
            userEmail = b['user']['email']?.toString();

            print('   👤 Found user in data: $authorName ($userEmail)');
          }
          // Jika tidak ada user object, coba field lain
          else if (b['nama_penulis'] != null) {
            authorName = b['nama_penulis'].toString();
          } else if (b['penulis'] != null) {
            authorName = b['penulis'].toString();
          }

          // Jika masih "Tidak diketahui", coba ambil dengan email
          if (authorName == 'Tidak diketahui' && userEmail != null) {
            print('   🔍 Fetching user by email: $userEmail');
            try {
              final userResponse = await ApiService.getUserByEmail(userEmail);
              if (userResponse['success'] == true) {
                authorName =
                    userResponse['data']['user']['nama'] ?? 'Tidak diketahui';
                print('   ✅ Got name from API: $authorName');
              }
            } catch (e) {
              print('   ❌ Error fetching user: $e');
            }
          }

          // Dapatkan gambar URL
          String imageUrl = '';
          if (b['gambar_url'] != null) {
            imageUrl = b['gambar_url'].toString();
          } else if (b['file_lampiran'] != null) {
            // Jika gambar_url tidak ada, coba buat dari file_lampiran
            String filePath = b['file_lampiran'].toString();
            if (!filePath.startsWith('http')) {
              imageUrl = 'http://10.167.29.12:8000/storage/$filePath';
            } else {
              imageUrl = filePath;
            }
          }

          mappedBooks.add({
            'judul': b['judul']?.toString() ?? 'Tanpa Judul',
            'author_name': authorName,
            'image_url': imageUrl,
            'email': userEmail,
            'id_user': b['id_user'] ?? b['user']?['id_user'],
            // Tambahkan data lain yang mungkin diperlukan untuk halaman detail
            'sinopsis': b['sinopsis']?.toString() ?? 'Belum ada sinopsis',
            'isi_cerita': b['isi_cerita']?.toString() ?? 'Belum ada konten',
          });

          print('   ✅ Added: "${b['judul']}" by $authorName');
        }
      }

      setState(() {
        books = mappedBooks;
        isLoading = false;
      });

      print('🎉 Total books loaded: ${books.length}');
    } catch (e) {
      print("❌ [HOME ERROR] $e");
      setState(() => isLoading = false);
    }
  }

  // TAMBAHKAN: Fungsi untuk navigasi ke halaman Karya Saya
  Future<void> _navigateToKaryaSaya() async {
    // Navigate to KaryaSayaPage
    final result = await Navigator.pushNamed(context, '/karya_saya');

    if (result == true) {
      // Refresh data jika ada karya baru ditambahkan
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karya berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // TAMBAHKAN: Fungsi untuk navigasi ke halaman "Semua" dari Kamu Mungkin Suka
  void _navigateToAllRecommended() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AllBooksPage(title: 'Kamu Mungkin Suka', books: books),
      ),
    );
  }

  // TAMBAHKAN: Fungsi untuk navigasi ke halaman "Semua" dari Cerita Paling Banyak Dibaca
  void _navigateToAllPopular() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AllBooksPage(title: 'Cerita Paling Banyak Dibaca', books: books),
      ),
    );
  }

  // TAMBAHKAN: Fungsi untuk navigasi ke halaman "Semua" dari Terakhir Dibaca
  void _navigateToAllLastRead() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AllBooksPage(title: 'Terakhir Dibaca', books: books),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              _buildRecommendedSection(),
              _buildPopularStoriesSection(),
              _buildLastReadSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: FloatingActionButton(
          onPressed: _navigateToKaryaSaya,
          backgroundColor: const Color(0xFF2A486B),
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF2A486B),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Halo,',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A486B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ================= RECOMMENDED =================

  Widget _buildRecommendedSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tombol "Semua"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kamu Mungkin Suka',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A486B),
                ),
              ),
              TextButton(
                onPressed: _navigateToAllRecommended,
                child: const Text(
                  'Semua',
                  style: TextStyle(
                    color: Color(0xFF2A486B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : books.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: StoryCard(
                          title: book['judul'],
                          author: book['author_name'],
                          imageUrl: book['image_url'],
                          onTap: () {
                            // Navigate to book detail (Gambar kedua)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailPage(book: book),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= POPULAR STORIES =================

  Widget _buildPopularStoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tombol "Semua"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cerita Paling Banyak Dibaca',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A486B),
                ),
              ),
              TextButton(
                onPressed: _navigateToAllPopular,
                child: const Text(
                  'Semua',
                  style: TextStyle(
                    color: Color(0xFF2A486B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? _buildEmptyState()
              : SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StoryCard(
                          title: book['judul'],
                          author: book['author_name'],
                          imageUrl: book['image_url'],
                          onTap: () {
                            // Navigate to book detail (Gambar kedua)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailPage(book: book),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // ================= LAST READ =================

  Widget _buildLastReadSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tombol "Semua"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Terakhir Dibaca',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A486B),
                ),
              ),
              TextButton(
                onPressed: _navigateToAllLastRead,
                child: const Text(
                  'Semua',
                  style: TextStyle(
                    color: Color(0xFF2A486B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.history, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Belum ada buku yang kamu baca.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'Belum ada cerita',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _navigateToKaryaSaya,
              child: const Text(
                'Upload Cerita Pertamamu',
                style: TextStyle(color: Color(0xFF2A486B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF2A486B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 48),
          IconButton(
            icon: const Icon(Icons.assignment, color: Colors.grey),
            onPressed: () {
              Navigator.pushNamed(context, '/kuis');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }
}

// ================= STORY CARD =================

class StoryCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Container(
                width: 150,
                height: 120,
                color: Colors.grey[100],
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 150,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.book,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                      )
                    : const Center(
                        child: Icon(Icons.book, size: 40, color: Colors.grey),
                      ),
              ),
            ),

            // TITLE + AUTHOR
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          author,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TAMBAHKAN: Halaman untuk menampilkan semua buku
class AllBooksPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> books;

  const AllBooksPage({super.key, required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2A486B),
        foregroundColor: Colors.white,
      ),
      body: books.isEmpty
          ? const Center(child: Text('Tidak ada cerita'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: book['image_url'].isNotEmpty
                        ? Image.network(
                            book['image_url'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.book, size: 40),
                    title: Text(
                      book['judul'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(book['author_name']),
                    onTap: () {
                      // Navigate to book detail (Gambar kedua)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailPage(book: book),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
